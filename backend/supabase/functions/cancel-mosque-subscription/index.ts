// =============================================================================
// cancel-mosque-subscription Edge Function (P3) — mirrors cancel-subscription
// for subscriptions living on a connected account.
//   { subscriptionId, immediately?: boolean }
// =============================================================================

import { corsHeaders } from "../_shared/cors.ts";
import { serviceClient, userClient } from "../_shared/supabase.ts";
import { json, stripeClient } from "../_shared/stripe.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "unauthorized" }, 401);
  const { data: { user } } = await userClient(authHeader).auth.getUser();
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
    .select("id, user_id, status, stripe_subscription_id, stripe_account_id, mosque_id")
    .eq("id", subscriptionId)
    .maybeSingle();
  if (error) return json({ error: "db_error" }, 500);
  if (!sub) return json({ error: "not_found" }, 404);
  if (sub.user_id !== user.id) return json({ error: "forbidden" }, 403);
  if (!sub.mosque_id || !sub.stripe_account_id) return json({ error: "bad_request", detail: "not a mosque subscription" }, 400);
  if (sub.status === "canceled") return json({ ok: true, status: "canceled" });

  const stripe = stripeClient();
  const opts = { stripeAccount: sub.stripe_account_id as string };
  try {
    if (sub.stripe_subscription_id) {
      if (immediately === true || sub.status === "incomplete") {
        await stripe.subscriptions.cancel(sub.stripe_subscription_id, undefined, opts);
      } else {
        await stripe.subscriptions.update(sub.stripe_subscription_id, { cancel_at_period_end: true }, opts);
      }
    }
    const patch = immediately === true || sub.status === "incomplete"
      ? { status: "canceled", canceled_at: new Date().toISOString() }
      : { cancel_at_period_end: true };
    await admin.from("donation_subscriptions").update(patch).eq("id", sub.id);
    return json({ ok: true, ...patch });
  } catch (e) {
    const err = e as { message?: string; code?: string };
    console.error("[cancel-mosque-subscription]", err?.code, err?.message);
    return json({ error: "stripe_error", code: err?.code ?? null, message: err?.message ?? null }, 502);
  }
});
