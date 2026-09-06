// =============================================================================
// stripe-connect-webhook Edge Function (P3)
// -----------------------------------------------------------------------------
// Registered in Stripe as a CONNECT webhook ("Listen to events on Connected
// accounts"). Every event carries `event.account` = the mosque's account.
// Signature secret: STRIPE_CONNECT_WEBHOOK_SECRET. Deploy with --no-verify-jwt.
//
//   account.updated                → mosque_stripe_accounts + mosques.donations_enabled
//   payment_intent.succeeded       → transactions → succeeded (mosque rows only)
//   payment_intent.payment_failed  → failed
//   payment_intent.canceled        → failed
//   charge.refunded                → refunded / amount_refunded
//   invoice.paid                   → succeeded transaction linked to the subscription
//   invoice.payment_failed         → subscription past_due
//   customer.subscription.updated/deleted → status sync
// Hard idempotency via stripe_events (shared with the platform webhook).
// =============================================================================

import Stripe from "npm:stripe@16.12.0";
import { serviceClient } from "../_shared/supabase.ts";
import { round2, stripeClient } from "../_shared/stripe.ts";

const stripe = stripeClient();
const whSecret = Deno.env.get("STRIPE_CONNECT_WEBHOOK_SECRET")!;
const admin = serviceClient();
const cryptoProvider = Stripe.createSubtleCryptoProvider();

Deno.serve(async (req) => {
  const sig = req.headers.get("stripe-signature");
  if (!sig) return new Response("missing signature", { status: 400 });
  const body = await req.text();

  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(body, sig, whSecret, undefined, cryptoProvider);
  } catch (e) {
    console.error("[stripe-connect-webhook] bad signature", e);
    return new Response("bad signature", { status: 400 });
  }

  const { error: evErr } = await admin.from("stripe_events").insert({ id: event.id, type: `connect:${event.type}` });
  if (evErr) {
    if (evErr.code === "23505") return new Response("duplicate", { status: 200 });
    console.error("[stripe-connect-webhook] stripe_events insert", evErr);
    return new Response("db error", { status: 500 });
  }

  const account = event.account ?? null;
  const opts = account ? { stripeAccount: account } : undefined;

  try {
    switch (event.type) {
      case "account.updated": {
        const a = event.data.object as Stripe.Account;
        const status = a.charges_enabled ? "active" : a.requirements?.disabled_reason ? "restricted" : "onboarding";
        const { data: row } = await admin
          .from("mosque_stripe_accounts")
          .update({
            status,
            charges_enabled: a.charges_enabled ?? false,
            payouts_enabled: a.payouts_enabled ?? false,
            details_submitted: a.details_submitted ?? false,
            requirements: { currently_due: a.requirements?.currently_due ?? [], disabled_reason: a.requirements?.disabled_reason ?? null },
            onboarded_at: a.charges_enabled ? new Date().toISOString() : null,
          })
          .eq("stripe_account_id", a.id)
          .select("mosque_id")
          .maybeSingle();
        if (row?.mosque_id) {
          await admin.from("mosques").update({ donations_enabled: a.charges_enabled === true }).eq("id", row.mosque_id);
          if (a.charges_enabled) {
            await admin.from("mosque_donation_settings").upsert({ mosque_id: row.mosque_id }, { onConflict: "mosque_id", ignoreDuplicates: true });
          }
        }
        break;
      }

      case "payment_intent.succeeded": {
        const pi = event.data.object as Stripe.PaymentIntent;
        const net = await netReceived(pi, opts);
        const { error } = await admin
          .from("transactions")
          .update({ status: "succeeded", stripe_event_id: event.id, net_received: net })
          .eq("stripe_pi_id", pi.id)
          .not("mosque_id", "is", null)
          .neq("status", "succeeded");
        if (error) throw error;
        break;
      }

      case "payment_intent.payment_failed":
      case "payment_intent.canceled": {
        const pi = event.data.object as Stripe.PaymentIntent;
        const { error } = await admin
          .from("transactions")
          .update({
            status: "failed",
            stripe_event_id: event.id,
            failure_reason: event.type === "payment_intent.canceled" ? (pi.cancellation_reason ?? "canceled") : (pi.last_payment_error?.message ?? "payment_failed"),
          })
          .eq("stripe_pi_id", pi.id)
          .in("status", ["pending", "processing"]);
        if (error) throw error;
        break;
      }

      case "charge.refunded": {
        const ch = event.data.object as Stripe.Charge;
        const piId = typeof ch.payment_intent === "string" ? ch.payment_intent : ch.payment_intent?.id;
        if (!piId) break;
        const full = ch.amount_refunded >= ch.amount;
        const { error } = await admin
          .from("transactions")
          .update({ ...(full ? { status: "refunded" } : {}), amount_refunded: round2((ch.amount_refunded ?? 0) / 100), stripe_event_id: event.id })
          .eq("stripe_pi_id", piId)
          .eq("status", "succeeded");
        if (error) throw error;
        break;
      }

      case "invoice.paid": {
        await handleInvoicePaid(event.data.object as Stripe.Invoice, event.id, opts);
        break;
      }

      case "invoice.payment_failed": {
        const inv = event.data.object as Stripe.Invoice;
        const subId = subscriptionIdOf(inv);
        if (!subId) break;
        const { error } = await admin.from("donation_subscriptions").update({ status: "past_due" }).eq("stripe_subscription_id", subId).neq("status", "canceled");
        if (error) throw error;
        break;
      }

      case "customer.subscription.updated":
      case "customer.subscription.deleted": {
        const sub = event.data.object as Stripe.Subscription;
        const { error } = await admin
          .from("donation_subscriptions")
          .update({
            status: mapSubStatus(sub.status),
            current_period_end: sub.current_period_end ? new Date(sub.current_period_end * 1000).toISOString() : null,
            cancel_at_period_end: sub.cancel_at_period_end ?? false,
            canceled_at: sub.canceled_at ? new Date(sub.canceled_at * 1000).toISOString() : null,
          })
          .eq("stripe_subscription_id", sub.id);
        if (error) throw error;
        break;
      }

      default:
        break;
    }
  } catch (e) {
    console.error("[stripe-connect-webhook] handler error", event.type, e);
    await admin.from("stripe_events").delete().eq("id", event.id);
    return new Response("handler error", { status: 500 });
  }

  return new Response("ok", { status: 200 });
});

async function netReceived(pi: Stripe.PaymentIntent, opts?: Stripe.RequestOptions): Promise<number | null> {
  try {
    const chargeId = typeof pi.latest_charge === "string" ? pi.latest_charge : pi.latest_charge?.id;
    if (!chargeId) return null;
    const ch = await stripe.charges.retrieve(chargeId, { expand: ["balance_transaction"] }, opts);
    const bt = ch.balance_transaction as Stripe.BalanceTransaction | null;
    return bt && typeof bt.net === "number" ? round2(bt.net / 100) : null;
  } catch (_) {
    return null;
  }
}

function subscriptionIdOf(inv: Stripe.Invoice): string | null {
  const s = inv.subscription;
  return !s ? null : typeof s === "string" ? s : s.id;
}

function mapSubStatus(s: Stripe.Subscription.Status) {
  switch (s) {
    case "active":
    case "trialing":
      return "active";
    case "past_due":
      return "past_due";
    case "canceled":
    case "incomplete_expired":
      return "canceled";
    case "unpaid":
      return "unpaid";
    case "paused":
      return "paused";
    default:
      return "incomplete";
  }
}

/** A paid invoice → one succeeded mosque transaction (no transaction_items). */
async function handleInvoicePaid(inv: Stripe.Invoice, eventId: string, opts?: Stripe.RequestOptions) {
  const stripeSubId = subscriptionIdOf(inv);
  if (!stripeSubId) return;
  const { data: sub, error: sErr } = await admin
    .from("donation_subscriptions")
    .select("id, user_id, mosque_id, membership_id, type, amount, currency, is_anonymous, payment_method, stripe_account_id")
    .eq("stripe_subscription_id", stripeSubId)
    .maybeSingle();
  if (sErr) throw sErr;
  if (!sub || !sub.mosque_id) return;

  const { data: dup } = await admin.from("transactions").select("id").eq("stripe_invoice_id", inv.id).maybeSingle();
  if (!dup) {
    const amountCharged = round2((inv.amount_paid ?? 0) / 100);
    const piId = typeof inv.payment_intent === "string" ? inv.payment_intent : inv.payment_intent?.id ?? null;
    let net: number | null = null;
    if (piId) {
      try {
        net = await netReceived(await stripe.paymentIntents.retrieve(piId, undefined, opts), opts);
      } catch (_) { /* best effort */ }
    }
    const { error: txErr } = await admin.from("transactions").insert({
      user_id: sub.user_id,
      type: sub.type,
      status: "succeeded",
      currency: sub.currency,
      amount_total: Number(sub.amount),
      fee_covered: 0,
      amount_charged: amountCharged,
      net_received: net,
      stripe_pi_id: piId,
      stripe_invoice_id: inv.id,
      stripe_event_id: eventId,
      subscription_id: sub.id,
      is_anonymous: sub.is_anonymous,
      payment_method: sub.payment_method,
      mosque_id: sub.mosque_id,
      membership_id: sub.membership_id,
      stripe_account_id: sub.stripe_account_id,
    });
    if (txErr) throw txErr;
  }
  await admin.from("donation_subscriptions").update({ status: "active" }).eq("id", sub.id).in("status", ["incomplete", "past_due"]);
}
