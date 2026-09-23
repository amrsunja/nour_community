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
//                                    (campaign gift → campaign progress)
//   invoice.payment_failed         → subscription past_due
//   customer.subscription.updated/deleted → status sync
// Hard idempotency via stripe_events (shared with the platform webhook).
// =============================================================================

import Stripe from "npm:stripe@16.12.0";
import { serviceClient } from "../_shared/supabase.ts";
import { round2, stripeClient } from "../_shared/stripe.ts";
import {
  invoiceSubscriptionId,
  isWorthRetrying,
  recordInvoiceTransaction,
  subscriptionPeriodEnd,
  UnresolvedInvoiceError,
} from "../_shared/invoice.ts";

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

  // Invoice events are de-duplicated by the ledger row (transactions
  // .stripe_invoice_id, UNIQUE), not by the event id — so a "Resend" from the
  // Stripe dashboard can repair an invoice that was never booked.
  const isInvoiceEvent = event.type.startsWith("invoice.");
  const { error: evErr } = await admin.from("stripe_events").insert({ id: event.id, type: `connect:${event.type}` });
  if (evErr) {
    if (evErr.code !== "23505") {
      console.error("[stripe-connect-webhook] stripe_events insert", evErr);
      return new Response("db error", { status: 500 });
    }
    if (!isInvoiceEvent) return new Response("duplicate", { status: 200 });
  }

  const account = event.account ?? null;
  const opts = account ? { stripeAccount: account } : undefined;

  try {
    switch (event.type) {
      case "account.updated": {
        const a = event.data.object as Stripe.Account;
        const status = a.requirements?.disabled_reason
          ? "restricted"
          : a.charges_enabled && a.details_submitted
          ? "active"
          : a.charges_enabled || a.details_submitted
          ? "onboarding"
          : "not_started";
        const { data: row } = await admin
          .from("mosque_stripe_accounts")
          .update({
            status,
            charges_enabled: a.charges_enabled ?? false,
            payouts_enabled: a.payouts_enabled ?? false,
            details_submitted: a.details_submitted ?? false,
            requirements: { currently_due: a.requirements?.currently_due ?? [], disabled_reason: a.requirements?.disabled_reason ?? null },
            ...(a.charges_enabled ? { onboarded_at: new Date().toISOString() } : {}),
          })
          .eq("stripe_account_id", a.id)
          .select("mosque_id")
          .maybeSingle();
        if (row?.mosque_id) {
          await admin.from("mosques").update({ donations_enabled: a.charges_enabled === true }).eq("id", row.mosque_id);
          if (a.charges_enabled) {
            await admin.from("mosque_donation_settings").upsert({ mosque_id: row.mosque_id }, { onConflict: "mosque_id", ignoreDuplicates: true });
            await admin.from("mosque_campaign_settings").upsert({ mosque_id: row.mosque_id }, { onConflict: "mosque_id", ignoreDuplicates: true });
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

      // Stripe emits both for a paid invoice; booking is idempotent, so either
      // one landing is enough for the gift to count.
      case "invoice.paid":
      case "invoice.payment_succeeded": {
        await handleInvoicePaid(event.data.object as Stripe.Invoice, event.id, opts);
        break;
      }

      case "invoice.payment_failed": {
        const inv = event.data.object as Stripe.Invoice;
        const subId = invoiceSubscriptionId(inv);
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
            current_period_end: subscriptionPeriodEnd(sub),
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

/**
 * A paid invoice → one succeeded mosque transaction, through the shared
 * idempotent writer in `_shared/invoice.ts` (campaign re-validation, direct
 * charge net, `stripe_invoice_id` idempotency). An invoice we cannot attach to
 * a local subscription frees the idempotency slot and answers 5xx so Stripe
 * retries — a silent 200 used to lose the money row for good.
 */
async function handleInvoicePaid(inv: Stripe.Invoice, eventId: string, opts?: Stripe.RequestOptions) {
  try {
    const outcome = await recordInvoiceTransaction({ admin, stripe, inv, eventId, opts });
    if (outcome === "recorded") console.log("[stripe-connect-webhook] invoice booked", inv.id);
  } catch (e) {
    if (e instanceof UnresolvedInvoiceError) {
      if (isWorthRetrying(inv)) throw e;
      console.error("[stripe-connect-webhook] giving up on stale invoice", inv.id, e.message);
      return;
    }
    throw e;
  }
}
