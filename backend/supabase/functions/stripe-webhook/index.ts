// =============================================================================
// stripe-webhook Edge Function (v2)
// -----------------------------------------------------------------------------
// The single authority that flips money rows. Stripe (not the app) is the
// source of truth.
//
//   1. Verify the signature with STRIPE_WEBHOOK_SECRET using the RAW body.
//   2. Hard idempotency: every event id is recorded in `stripe_events`; a replay
//      is acknowledged and skipped.
//   3. One-time payments
//        payment_intent.succeeded       -> succeeded (+ true net from the balance tx)
//        payment_intent.payment_failed  -> failed
//        payment_intent.canceled        -> failed (reason 'canceled')
//        charge.refunded                -> refunded (full) / amount_refunded (partial)
//   4. Recurring donations
//        invoice.paid                   -> insert a succeeded transaction (+ items)
//                                          linked to the subscription; sub -> active
//        invoice.payment_failed         -> sub -> past_due
//        customer.subscription.updated  -> sync status / period / cancel flags
//        customer.subscription.deleted  -> sub -> canceled
//   5. 2xx for handled/ignored events, 5xx on transient DB errors (Stripe retries).
//
// MUST be deployed with --no-verify-jwt (Stripe sends no Supabase JWT):
//   supabase functions deploy stripe-webhook --no-verify-jwt
// =============================================================================

import Stripe from "npm:stripe@16.12.0";
import { serviceClient } from "../_shared/supabase.ts";
import { round2, stripeClient } from "../_shared/stripe.ts";

const stripe = stripeClient();
const whSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;
const admin = serviceClient();
// Edge Runtime has no Node crypto — verify signatures with WebCrypto.
const cryptoProvider = Stripe.createSubtleCryptoProvider();

Deno.serve(async (req) => {
  const sig = req.headers.get("stripe-signature");
  if (!sig) return new Response("missing signature", { status: 400 });

  const body = await req.text(); // raw body REQUIRED for signature verification

  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(
      body,
      sig,
      whSecret,
      undefined,
      cryptoProvider,
    );
  } catch (e) {
    console.error("[stripe-webhook] bad signature", e);
    return new Response("bad signature", { status: 400 });
  }

  // Hard idempotency — record the event id first; a duplicate delivery is a no-op.
  const { error: evErr } = await admin
    .from("stripe_events")
    .insert({ id: event.id, type: event.type });
  if (evErr) {
    if (evErr.code === "23505") {
      return new Response("duplicate", { status: 200 });
    }
    console.error("[stripe-webhook] stripe_events insert", evErr);
    return new Response("db error", { status: 500 });
  }

  try {
    switch (event.type) {
      // ── One-time ──────────────────────────────────────────────────────────
      case "payment_intent.succeeded": {
        const pi = event.data.object as Stripe.PaymentIntent;
        // Subscription invoices are handled by invoice.paid; their PIs carry no
        // transaction row keyed on stripe_pi_id, so this update matches 0 rows.
        const net = await netReceived(pi);
        const { error } = await admin
          .from("transactions")
          .update({
            status: "succeeded",
            stripe_event_id: event.id,
            net_received: net,
            payment_method: metaMethod(pi) ?? undefined,
          })
          .eq("stripe_pi_id", pi.id)
          .neq("status", "succeeded"); // status guard vs out-of-order events
        if (error) throw error;
        break;
      }

      case "payment_intent.payment_failed": {
        const pi = event.data.object as Stripe.PaymentIntent;
        const { error } = await admin
          .from("transactions")
          .update({
            status: "failed",
            stripe_event_id: event.id,
            failure_reason: pi.last_payment_error?.message ?? "payment_failed",
          })
          .eq("stripe_pi_id", pi.id)
          .in("status", ["pending", "processing"]);
        if (error) throw error;
        break;
      }

      case "payment_intent.canceled": {
        const pi = event.data.object as Stripe.PaymentIntent;
        const { error } = await admin
          .from("transactions")
          .update({
            status: "failed",
            stripe_event_id: event.id,
            failure_reason: pi.cancellation_reason ?? "canceled",
          })
          .eq("stripe_pi_id", pi.id)
          .in("status", ["pending", "processing"]);
        if (error) throw error;
        break;
      }

      case "charge.refunded": {
        const ch = event.data.object as Stripe.Charge;
        const piId = typeof ch.payment_intent === "string"
          ? ch.payment_intent
          : ch.payment_intent?.id;
        if (!piId) break;
        const refunded = round2((ch.amount_refunded ?? 0) / 100);
        const full = ch.amount_refunded >= ch.amount;
        const { error } = await admin
          .from("transactions")
          .update({
            ...(full ? { status: "refunded" } : {}),
            amount_refunded: refunded,
            stripe_event_id: event.id,
          })
          .eq("stripe_pi_id", piId)
          .eq("status", "succeeded"); // trigger reverses collected_amount on full refund
        if (error) throw error;
        break;
      }

      // ── Recurring ─────────────────────────────────────────────────────────
      case "invoice.paid": {
        const inv = event.data.object as Stripe.Invoice;
        await handleInvoicePaid(inv, event.id);
        break;
      }

      case "invoice.payment_failed": {
        const inv = event.data.object as Stripe.Invoice;
        const subId = subscriptionIdOf(inv);
        if (!subId) break;
        const { error } = await admin
          .from("donation_subscriptions")
          .update({ status: "past_due" })
          .eq("stripe_subscription_id", subId)
          .neq("status", "canceled");
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
            current_period_end: sub.current_period_end
              ? new Date(sub.current_period_end * 1000).toISOString()
              : null,
            cancel_at_period_end: sub.cancel_at_period_end ?? false,
            canceled_at: sub.canceled_at
              ? new Date(sub.canceled_at * 1000).toISOString()
              : null,
          })
          .eq("stripe_subscription_id", sub.id);
        if (error) throw error;
        break;
      }

      default:
        // Unhandled event types are acknowledged so Stripe stops retrying.
        break;
    }
  } catch (e) {
    console.error("[stripe-webhook] handler error", event.type, e);
    // Free the idempotency slot so the retry can be processed.
    await admin.from("stripe_events").delete().eq("id", event.id);
    return new Response("handler error", { status: 500 });
  }

  return new Response("ok", { status: 200 }); // 2xx => Stripe won't retry
});

// ── helpers ───────────────────────────────────────────────────────────────────

/** True net after Stripe fees, from the charge's balance transaction. */
async function netReceived(pi: Stripe.PaymentIntent): Promise<number | null> {
  try {
    const chargeId = typeof pi.latest_charge === "string"
      ? pi.latest_charge
      : pi.latest_charge?.id;
    if (!chargeId) return null;
    const ch = await stripe.charges.retrieve(chargeId, {
      expand: ["balance_transaction"],
    });
    const bt = ch.balance_transaction as Stripe.BalanceTransaction | null;
    if (bt && typeof bt.net === "number") return round2(bt.net / 100);
    return null;
  } catch (e) {
    console.error("[stripe-webhook] netReceived", e);
    return null;
  }
}

function metaMethod(pi: Stripe.PaymentIntent): string | null {
  const m = pi.metadata?.payment_method;
  return typeof m === "string" && m.length > 0 ? m : null;
}

function subscriptionIdOf(inv: Stripe.Invoice): string | null {
  const s = inv.subscription;
  if (!s) return null;
  return typeof s === "string" ? s : s.id;
}

function mapSubStatus(
  s: Stripe.Subscription.Status,
): "incomplete" | "active" | "past_due" | "canceled" | "unpaid" | "paused" {
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
    case "incomplete":
    default:
      return "incomplete";
  }
}

/**
 * A paid invoice = one succeeded transaction for the subscription's project.
 * Idempotent on stripe_invoice_id. Inserting directly as `succeeded` is
 * supported by fn_apply_tx_to_projects v2 (INSERT-aware).
 */
async function handleInvoicePaid(inv: Stripe.Invoice, eventId: string) {
  const stripeSubId = subscriptionIdOf(inv);
  if (!stripeSubId) return; // not a subscription invoice

  const { data: sub, error: sErr } = await admin
    .from("donation_subscriptions")
    .select("id, user_id, impact_project_id, type, amount, fee_covered, currency, is_anonymous, payment_method")
    .eq("stripe_subscription_id", stripeSubId)
    .maybeSingle();
  if (sErr) throw sErr;
  if (!sub) {
    console.warn("[stripe-webhook] invoice.paid for unknown subscription", stripeSubId);
    return;
  }

  // Already recorded? (idempotent)
  const { data: dup } = await admin
    .from("transactions")
    .select("id")
    .eq("stripe_invoice_id", inv.id)
    .maybeSingle();

  if (!dup) {
    const paidMinor = inv.amount_paid ?? 0;
    const amountCharged = round2(paidMinor / 100);
    // Body = subscription amount; anything above it is the covered fee.
    const amountTotal = Number(sub.amount);
    const feeCovered = round2(Math.max(0, amountCharged - amountTotal));
    const piId = typeof inv.payment_intent === "string"
      ? inv.payment_intent
      : inv.payment_intent?.id ?? null;

    let net: number | null = null;
    if (piId) {
      try {
        const pi = await stripe.paymentIntents.retrieve(piId);
        net = await netReceived(pi);
      } catch (_) { /* best effort */ }
    }

    const { data: tx, error: txErr } = await admin
      .from("transactions")
      .insert({
        user_id: sub.user_id,
        type: sub.type,
        status: "pending", // flipped below so the trigger path is the same as one-time
        currency: sub.currency,
        amount_total: amountTotal,
        fee_covered: feeCovered,
        amount_charged: amountCharged,
        net_received: net,
        stripe_pi_id: piId,
        stripe_invoice_id: inv.id,
        stripe_event_id: eventId,
        subscription_id: sub.id,
        is_anonymous: sub.is_anonymous,
        payment_method: sub.payment_method,
      })
      .select("id")
      .single();
    if (txErr || !tx) throw txErr ?? new Error("tx insert failed");

    const { error: itErr } = await admin.from("transaction_items").insert({
      transaction_id: tx.id,
      impact_project_id: sub.impact_project_id,
      amount: amountTotal,
    });
    if (itErr) throw itErr;

    // pending -> succeeded : credits the project + ajr via the trigger.
    const { error: upErr } = await admin
      .from("transactions")
      .update({ status: "succeeded" })
      .eq("id", tx.id);
    if (upErr) throw upErr;
  }

  // Subscription is (or stays) active after a paid invoice.
  const periodEnd = inv.lines?.data?.[0]?.period?.end;
  const { error: subErr } = await admin
    .from("donation_subscriptions")
    .update({
      status: "active",
      ...(periodEnd
        ? { current_period_end: new Date(periodEnd * 1000).toISOString() }
        : {}),
    })
    .eq("id", sub.id)
    .neq("status", "canceled");
  if (subErr) throw subErr;
}
