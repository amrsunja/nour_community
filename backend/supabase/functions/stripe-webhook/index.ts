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
import {
  invoiceSubscriptionId,
  isWorthRetrying,
  recordInvoiceTransaction,
  subscriptionPeriodEnd,
  UnresolvedInvoiceError,
} from "../_shared/invoice.ts";

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
  // EXCEPT for invoice events: their idempotency key is the ledger row
  // (transactions.stripe_invoice_id, UNIQUE), so a "Resend" from the Stripe
  // dashboard can still repair an invoice that was never booked.
  const isInvoiceEvent = event.type.startsWith("invoice.");
  const { error: evErr } = await admin
    .from("stripe_events")
    .insert({ id: event.id, type: event.type });
  if (evErr) {
    if (evErr.code !== "23505") {
      console.error("[stripe-webhook] stripe_events insert", evErr);
      return new Response("db error", { status: 500 });
    }
    if (!isInvoiceEvent) return new Response("duplicate", { status: 200 });
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
      // Both are emitted for a paid invoice; booking is idempotent on
      // stripe_invoice_id, so handling either (or both) is safe — and one of
      // them landing is enough for the money to count.
      case "invoice.paid":
      case "invoice.payment_succeeded": {
        const inv = event.data.object as Stripe.Invoice;
        await handleInvoicePaid(inv, event.id);
        break;
      }

      case "invoice.payment_failed": {
        const inv = event.data.object as Stripe.Invoice;
        const subId = invoiceSubscriptionId(inv);
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
            current_period_end: subscriptionPeriodEnd(sub),
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
 * All of it lives in `_shared/invoice.ts` (version-agnostic readers + the
 * single idempotent writer), shared with the connect webhook and the reconcile
 * endpoints. An invoice we cannot map to a local subscription is NOT
 * acknowledged: we free the idempotency slot and answer 5xx so Stripe retries,
 * instead of losing the money row for good.
 */
async function handleInvoicePaid(inv: Stripe.Invoice, eventId: string) {
  try {
    const outcome = await recordInvoiceTransaction({ admin, stripe, inv, eventId });
    if (outcome === "recorded") {
      console.log("[stripe-webhook] invoice booked", inv.id);
    }
  } catch (e) {
    if (e instanceof UnresolvedInvoiceError) {
      if (isWorthRetrying(inv)) throw e; // 5xx → Stripe retries
      console.error("[stripe-webhook] giving up on stale invoice", inv.id, e.message);
      return;
    }
    throw e;
  }
}
