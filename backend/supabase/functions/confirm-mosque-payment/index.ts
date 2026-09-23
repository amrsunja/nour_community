// =============================================================================
// confirm-mosque-payment Edge Function
// -----------------------------------------------------------------------------
// WHY: with Stripe Connect DIRECT charges the app's "processing" screen waits
// for `stripe-connect-webhook` to flip `transactions.status`. If that endpoint
// is not registered in Stripe, its secret is wrong, or Stripe is simply slow,
// the donor is charged but the app spins until the 90 s timeout and shows
// "Taking longer than expected" — even though the money went through.
//
// This function is the donor-triggered reconciliation: it asks Stripe directly
// for the authoritative status of the donor's OWN transaction / subscription
// and settles the row. The webhook stays the source of truth for everything
// else (net_received, refunds, recurring invoices); this only closes the UX gap.
//
// Payload: { transactionId } | { subscriptionId }
// Returns: { status } — transactions.status or donation_subscriptions.status
//
// It also books any paid invoice of the donor's subscription that has no ledger
// row yet, so a recurring gift still lands in the mosque's totals and in the
// campaign progress when the `invoice.paid` webhook never arrived.
//
// Safe to call repeatedly: every write is guarded on the current status and the
// invoice write is idempotent on `transactions.stripe_invoice_id`, so the
// campaign-progress trigger (fn_apply_tx_to_mosque) can only fire once, even if
// the webhook and this function land at the same moment.
// =============================================================================

import type Stripe from "npm:stripe@16.12.0";
import { corsHeaders } from "../_shared/cors.ts";
import { serviceClient, userClient } from "../_shared/supabase.ts";
import { json, round2, stripeClient } from "../_shared/stripe.ts";
import { recordPaidInvoicesForSubscription, subscriptionPeriodEnd } from "../_shared/invoice.ts";

interface Payload {
  transactionId?: number;
  subscriptionId?: number;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "unauthorized" }, 401);
  const { data: { user } } = await userClient(authHeader).auth.getUser();
  if (!user) return json({ error: "unauthorized" }, 401);

  let payload: Payload;
  try {
    payload = (await req.json()) as Payload;
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  const { transactionId, subscriptionId } = payload;
  if (!Number.isInteger(transactionId) && !Number.isInteger(subscriptionId)) return json({ error: "bad_request" }, 400);

  const admin = serviceClient();
  const stripe = stripeClient();

  try {
    if (Number.isInteger(subscriptionId)) {
      return await reconcileSubscription(admin, stripe, user.id, subscriptionId!);
    }
    return await reconcileTransaction(admin, stripe, user.id, transactionId!);
  } catch (e) {
    const err = e as { message?: string; code?: string; type?: string };
    console.error("[confirm-mosque-payment]", err?.type, err?.code, err?.message);
    return json({ error: "stripe_error", message: err?.message ?? null }, 502);
  }
});

// deno-lint-ignore no-explicit-any
async function reconcileTransaction(admin: any, stripe: Stripe, userId: string, transactionId: number) {
  const { data: tx } = await admin
    .from("transactions")
    .select("id, status, stripe_pi_id, stripe_account_id, mosque_id")
    .eq("id", transactionId)
    .eq("user_id", userId)            // a donor may only settle his own row
    .maybeSingle();
  if (!tx) return json({ error: "not_found" }, 404);
  // Terminal, or not a mosque charge, or the PaymentIntent is not attached yet.
  if (tx.status !== "pending" && tx.status !== "processing") return json({ status: tx.status });
  if (!tx.mosque_id || !tx.stripe_pi_id) return json({ status: tx.status });

  const opts = tx.stripe_account_id ? { stripeAccount: tx.stripe_account_id } : undefined;
  const pi = await stripe.paymentIntents.retrieve(tx.stripe_pi_id, undefined, opts);

  switch (pi.status) {
    case "succeeded": {
      const { error } = await admin
        .from("transactions")
        .update({ status: "succeeded", net_received: await netReceived(stripe, pi, opts) })
        .eq("id", tx.id)
        .neq("status", "succeeded");   // idempotent vs the webhook
      if (error) throw error;
      return json({ status: "succeeded" });
    }
    case "canceled": {
      const { error } = await admin
        .from("transactions")
        .update({ status: "failed", failure_reason: pi.cancellation_reason ?? "canceled" })
        .eq("id", tx.id)
        .in("status", ["pending", "processing"]);
      if (error) throw error;
      return json({ status: "failed" });
    }
    case "requires_payment_method": {
      // Only a *failed* attempt is terminal here — a PI that was never
      // confirmed sits in the same state and must stay pending.
      if (!pi.last_payment_error) return json({ status: tx.status });
      const { error } = await admin
        .from("transactions")
        .update({ status: "failed", failure_reason: pi.last_payment_error.message ?? "payment_failed" })
        .eq("id", tx.id)
        .in("status", ["pending", "processing"]);
      if (error) throw error;
      return json({ status: "failed" });
    }
    case "processing": {
      const { error } = await admin.from("transactions").update({ status: "processing" }).eq("id", tx.id).eq("status", "pending");
      if (error) throw error;
      return json({ status: "processing" });
    }
    default:
      // requires_action / requires_confirmation / requires_capture → keep waiting.
      return json({ status: tx.status });
  }
}

// deno-lint-ignore no-explicit-any
async function reconcileSubscription(admin: any, stripe: Stripe, userId: string, subscriptionId: number) {
  const { data: sub } = await admin
    .from("donation_subscriptions")
    .select("id, status, stripe_subscription_id, stripe_account_id, mosque_id")
    .eq("id", subscriptionId)
    .eq("user_id", userId)
    .maybeSingle();
  if (!sub) return json({ error: "not_found" }, 404);
  if (!sub.mosque_id || !sub.stripe_subscription_id) return json({ status: sub.status });
  if (sub.status === "canceled") return json({ status: sub.status });

  const opts = sub.stripe_account_id ? { stripeAccount: sub.stripe_account_id } : undefined;
  const s = await stripe.subscriptions.retrieve(sub.stripe_subscription_id, undefined, opts);
  const mapped = mapSubStatus(s.status);
  if (mapped === "incomplete") return json({ status: "incomplete" });

  if (sub.status === "incomplete") {
    const { error } = await admin
      .from("donation_subscriptions")
      .update({
        status: mapped,
        current_period_end: subscriptionPeriodEnd(s),
        cancel_at_period_end: s.cancel_at_period_end ?? false,
      })
      .eq("id", sub.id)
      .eq("status", "incomplete");
    if (error) throw error;
  }

  // The webhook stays the normal writer, but it is not the only one any more:
  // a paid invoice that never produced a ledger row is money the mosque's
  // totals never saw. Idempotent on transactions.stripe_invoice_id.
  const booked = await recordPaidInvoicesForSubscription(admin, stripe, sub.stripe_subscription_id, opts);
  if (booked > 0) console.log("[confirm-mosque-payment] booked", booked, "missing invoice(s) for sub", sub.id);

  return json({ status: mapped });
}

async function netReceived(stripe: Stripe, pi: Stripe.PaymentIntent, opts?: Stripe.RequestOptions): Promise<number | null> {
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
