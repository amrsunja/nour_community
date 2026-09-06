// =============================================================================
// cancel-subscription Edge Function
// -----------------------------------------------------------------------------
// The donor stops a recurring donation. Owner-checked via the JWT; the row is
// looked up with service_role. By default the subscription runs until the end
// of the paid period (cancel_at_period_end); `immediately: true` cancels now.
// The webhook (`customer.subscription.updated|deleted`) syncs the final state,
// but we also update the row optimistically so the UI reflects it at once.
//
// Payload: { subscriptionId: number, immediately?: boolean }
// Deploy JWT-verified (default): supabase functions deploy cancel-subscription
// =============================================================================

import { corsHeaders } from "../_shared/cors.ts";
import { serviceClient, userClient } from "../_shared/supabase.ts";
import { json, stripeClient } from "../_shared/stripe.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "unauthorized" }, 401);
  const {
    data: { user },
  } = await userClient(authHeader).auth.getUser();
  if (!user) return json({ error: "unauthorized" }, 401);

  let payload: { subscriptionId?: number; immediately?: boolean };
  try {
    payload = await req.json();
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  const { subscriptionId, immediately } = payload;
  if (!Number.isInteger(subscriptionId)) return json({ error: "bad_request" }, 400);

  const admin = serviceClient();
  const { data: sub, error } = await admin
    .from("donation_subscriptions")
    .select("id, user_id, status, stripe_subscription_id")
    .eq("id", subscriptionId)
    .maybeSingle();
  if (error) return json({ error: "db_error" }, 500);
  if (!sub) return json({ error: "not_found" }, 404);
  if (sub.user_id !== user.id) return json({ error: "forbidden" }, 403);
  if (sub.status === "canceled") return json({ ok: true, status: "canceled" });

  const stripe = stripeClient();
  try {
    if (sub.stripe_subscription_id) {
      if (immediately === true || sub.status === "incomplete") {
        await stripe.subscriptions.cancel(sub.stripe_subscription_id);
      } else {
        await stripe.subscriptions.update(sub.stripe_subscription_id, {
          cancel_at_period_end: true,
        });
      }
    }
  } catch (e) {
    console.error("[cancel-subscription] stripe", e);
    return json({ error: "stripe_error" }, 502);
  }

  const now = new Date().toISOString();
  const cancelNow = immediately === true || sub.status === "incomplete" || !sub.stripe_subscription_id;
  const { error: upErr } = await admin
    .from("donation_subscriptions")
    .update(
      cancelNow
        ? { status: "canceled", canceled_at: now, cancel_at_period_end: false }
        : { cancel_at_period_end: true },
    )
    .eq("id", sub.id);
  if (upErr) return json({ error: "db_error" }, 500);

  return json({ ok: true, status: cancelNow ? "canceled" : "cancel_at_period_end" });
});
