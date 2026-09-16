// =============================================================================
// confirm-payment Edge Function (platform / impact donations)
// -----------------------------------------------------------------------------
// The platform twin of `confirm-mosque-payment`. The app's "processing" screen
// waits for `stripe-webhook` to flip `transactions.status` / activate the
// subscription; if that endpoint is misconfigured, on an older event shape, or
// simply slow, the donor is charged and the ledger stays empty — which means
// the gift never reaches `impact_projects.collected_amount`.
//
// This asks Stripe directly for the authoritative state of the donor's OWN
// payment and settles it:
//   { transactionId }  → PaymentIntent status → transactions.status
//   { subscriptionId } → Subscription status  → donation_subscriptions.status
//                        + books every paid invoice that has no ledger row yet
//                          (idempotent on transactions.stripe_invoice_id, so
//                           the project trigger can only fire once)
//
// Returns: { status }
// Deploy JWT-verified (default): supabase functions deploy confirm-payment
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
  if (!Number.isInteger(transactionId) && !Number.isInteger(subscriptionId)) {
    return json({ error: "bad_request" }, 400);
  }

  const admin = serviceClient();
  const stripe = stripeClient();

  try {
    return Number.isInteger(subscriptionId)
      ? await reconcileSubscription(admin, stripe, user.id, subscriptionId!)
      : await reconcileTransaction(admin, stripe, user.id, transactionId!);
  } catch (e) {
    const err = e as { message?: string; code?: string; type?: string };
    console.error("[confirm-payment]", err?.type, err?.code, err?.message);
    return json({ error: "stripe_error", message: err?.message ?? null }, 502);
  }
});

// deno-lint-ignore no-explicit-any
async function reconcileTransaction(admin: any, stripe: Stripe, userId: string, transactionId: number) {
  const { data: tx } = await admin
    .from("transactions")
    .select("id, status, stripe_pi_id, mosque_id")
    .eq("id", transactionId)
    .eq("user_id", userId) // a donor may only settle his own row
    .maybeSingle();
  if (!tx) return json({ error: "not_found" }, 404);
  if (tx.status !== "pending" && tx.status !== "processing") return json({ status: tx.status });
  // Mosque rows live on a connected account — confirm-mosque-payment owns those.
  if (tx.mosque_id || !tx.stripe_pi_id) return json({ status: tx.status });

  const pi = await stripe.paymentIntents.retrieve(tx.stripe_pi_id);

  switch (pi.status) {
    case "succeeded": {
      const { error } = await admin
        .from("transactions")
        .update({ status: "succeeded", net_received: await netReceived(stripe, pi) })
        .eq("id", tx.id)
        .neq("status", "succeeded"); // idempotent vs the webhook
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
      // A PI that was never confirmed sits in this state too — only a *failed*
      // attempt is terminal.
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
      const { error } = await admin
        .from("transactions")
        .update({ status: "processing" })
        .eq("id", tx.id)
        .eq("status", "pending");
      if (error) throw error;
      return json({ status: "processing" });
    }
    default:
      return json({ status: tx.status }); // requires_action / _confirmation → keep waiting
  }
}

// deno-lint-ignore no-explicit-any
async function reconcileSubscription(admin: any, stripe: Stripe, userId: string, subscriptionId: number) {
  const { data: sub } = await admin
    .from("donation_subscriptions")
    .select("id, status, stripe_subscription_id, mosque_id")
    .eq("id", subscriptionId)
    .eq("user_id", userId)
    .maybeSingle();
  if (!sub) return json({ error: "not_found" }, 404);
  if (sub.mosque_id || !sub.stripe_subscription_id) return json({ status: sub.status });
  if (sub.status === "canceled") return json({ status: sub.status });

  const s = await stripe.subscriptions.retrieve(sub.stripe_subscription_id);
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

  // Book anything the webhook missed — otherwise the donation is paid but
  // counts nowhere.
  const booked = await recordPaidInvoicesForSubscription(admin, stripe, sub.stripe_subscription_id);
  if (booked > 0) console.log("[confirm-payment] booked", booked, "missing invoice(s) for sub", sub.id);

  return json({ status: mapped });
}

async function netReceived(stripe: Stripe, pi: Stripe.PaymentIntent): Promise<number | null> {
  try {
    const chargeId = typeof pi.latest_charge === "string" ? pi.latest_charge : pi.latest_charge?.id;
    if (!chargeId) return null;
    const ch = await stripe.charges.retrieve(chargeId, { expand: ["balance_transaction"] });
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
