// =============================================================================
// create-mosque-subscription Edge Function (P3 — devis B2/B4)
// -----------------------------------------------------------------------------
// Recurring Sadaqa (monthly / yearly) or yearly membership fee, as a Stripe
// Subscription ON THE CONNECTED ACCOUNT (direct charges → the Customer and the
// Product live on the mosque's account, not on Nour's platform account).
//
// Payload: { mosqueId, amount, currency, interval: 'month'|'year',
//            membershipId?, isAnonymous?, paymentMethod?, clientKey? }
// Returns: { clientSecret, subscriptionId, customerId, ephemeralKeySecret,
//            stripeAccountId, fee: 0, amountCharged }
// =============================================================================

import type Stripe from "npm:stripe@16.12.0";
import { corsHeaders } from "../_shared/cors.ts";
import { serviceClient, userClient } from "../_shared/supabase.ts";
import { isPaymentMethod, json, MAX_AMOUNT, MIN_AMOUNT, type PaymentMethodKind, round2, STRIPE_API_VERSION, stripeClient, stripePaymentMethodTypes, toMinor, validEmail } from "../_shared/stripe.ts";
import { loadChargeableMosque, onAccount } from "../_shared/mosque.ts";

interface Payload {
  mosqueId: number;
  amount: number;
  currency: string;
  interval: "month" | "year";
  membershipId?: number;
  isAnonymous?: boolean;
  paymentMethod?: PaymentMethodKind;
  clientKey?: string;
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
  const { mosqueId, amount, currency, interval, membershipId, isAnonymous, clientKey } = payload;
  const method: PaymentMethodKind = isPaymentMethod(payload.paymentMethod) ? payload.paymentMethod : "card";
  if (!Number.isInteger(mosqueId) || typeof currency !== "string" || !["month", "year"].includes(interval) || !(typeof amount === "number" && amount > 0)) {
    return json({ error: "bad_request" }, 400);
  }
  if (method === "paypal") return json({ error: "method_not_supported" }, 422);
  const amountTotal = round2(amount);
  if (amountTotal < MIN_AMOUNT) return json({ error: "amount_too_small" }, 422);
  if (amountTotal > MAX_AMOUNT) return json({ error: "amount_too_large" }, 422);

  const admin = serviceClient();
  const stripe = stripeClient();

  const loaded = await loadChargeableMosque(admin, mosqueId);
  if ("error" in loaded) return json({ error: loaded.error }, 422);
  const { mosque, acct } = loaded;
  const opts = onAccount(acct);

  let type: "mosque_sadaqa" | "mosque_membership" = "mosque_sadaqa";
  if (membershipId) {
    const { data: m } = await admin.from("mosque_members").select("id, mosque_id, user_id").eq("id", membershipId).maybeSingle();
    if (!m || m.mosque_id !== mosque.id || m.user_id !== user.id) return json({ error: "membership_not_found" }, 404);
    if (interval !== "year") return json({ error: "bad_request", detail: "membership fee is yearly" }, 400);
    type = "mosque_membership";
  }

  // Replay.
  if (clientKey) {
    const { data: existing } = await admin
      .from("donation_subscriptions")
      .select("id, stripe_subscription_id, stripe_customer_id, amount, status")
      .eq("client_key", clientKey)
      .eq("user_id", user.id)
      .maybeSingle();
    if (existing?.stripe_subscription_id && existing.status === "incomplete") {
      try {
        const sub = await stripe.subscriptions.retrieve(existing.stripe_subscription_id, { expand: ["latest_invoice.payment_intent"] }, opts);
        const pi = (sub.latest_invoice as Stripe.Invoice | null)?.payment_intent as Stripe.PaymentIntent | null;
        if (pi?.client_secret) {
          const ek = await stripe.ephemeralKeys.create({ customer: existing.stripe_customer_id! }, { apiVersion: STRIPE_API_VERSION, ...opts });
          return json({ clientSecret: pi.client_secret, subscriptionId: existing.id, customerId: existing.stripe_customer_id, ephemeralKeySecret: ek.secret, stripeAccountId: acct.stripe_account_id, fee: 0, amountCharged: Number(existing.amount) });
        }
      } catch (_) { /* fall through */ }
      await admin.from("donation_subscriptions").update({ client_key: null }).eq("id", existing.id);
    }
  }

  try {
    // Customer on the CONNECTED account (one per user per mosque; looked up by metadata).
    const { data: profile } = await admin.from("profiles").select("name").eq("id", user.id).maybeSingle();
    let customerId: string | undefined;
    const found = await stripe.customers.search({ query: `metadata['user_id']:'${user.id}'`, limit: 1 }, opts);
    if (found.data.length > 0) customerId = found.data[0].id;
    if (!customerId) {
      const c = await stripe.customers.create({ email: validEmail(user.email), name: profile?.name ?? undefined, metadata: { user_id: user.id } }, opts);
      customerId = c.id;
    }

    // Product on the connected account.
    const productName = type === "mosque_membership" ? `${mosque.name} — Adhésion` : `${mosque.name} — Sadaqa`;
    const products = await stripe.products.search({ query: `metadata['nour_type']:'${type}' AND active:'true'`, limit: 1 }, opts);
    const productId = products.data[0]?.id ?? (await stripe.products.create({ name: productName, metadata: { nour_type: type, mosque_id: String(mosque.id) } }, opts)).id;

    const { data: row, error: rowErr } = await admin
      .from("donation_subscriptions")
      .insert({
        user_id: user.id,
        impact_project_id: null,
        mosque_id: mosque.id,
        membership_id: membershipId ?? null,
        type,
        amount: amountTotal,
        fee_covered: 0,
        currency,
        interval,
        status: "incomplete",
        is_anonymous: isAnonymous === true,
        payment_method: method,
        stripe_customer_id: customerId,
        stripe_account_id: acct.stripe_account_id,
        client_key: clientKey ?? null,
      })
      .select("id")
      .single();
    if (rowErr || !row) {
      console.error("[create-mosque-subscription] insert", rowErr);
      return json({ error: "db_error" }, 500);
    }

    let sub: Stripe.Subscription;
    try {
      sub = await stripe.subscriptions.create(
        {
          customer: customerId,
          items: [{ price_data: { currency: currency.toLowerCase(), product: productId, unit_amount: toMinor(amountTotal), recurring: { interval } } }],
          payment_behavior: "default_incomplete",
          payment_settings: {
            save_default_payment_method: "on_subscription",
            payment_method_types: stripePaymentMethodTypes(method) as Stripe.SubscriptionCreateParams.PaymentSettings.PaymentMethodType[],
          },
          expand: ["latest_invoice.payment_intent"],
          metadata: {
            subscription_row_id: String(row.id),
            user_id: user.id,
            mosque_id: String(mosque.id),
            membership_id: membershipId ? String(membershipId) : "",
            type,
            payment_method: method,
            anonymous: isAnonymous === true ? "1" : "0",
          },
        },
        onAccount(acct, clientKey ? { idempotencyKey: `msub:${user.id}:${clientKey}` } : undefined),
      );
    } catch (e) {
      await admin.from("donation_subscriptions").delete().eq("id", row.id);
      throw e;
    }

    const pi = (sub.latest_invoice as Stripe.Invoice | null)?.payment_intent as Stripe.PaymentIntent | null;
    if (!pi?.client_secret) {
      await admin.from("donation_subscriptions").delete().eq("id", row.id);
      return json({ error: "stripe_error", message: "no payment intent on first invoice" }, 502);
    }
    await admin.from("donation_subscriptions").update({ stripe_subscription_id: sub.id }).eq("id", row.id);
    if (membershipId) await admin.from("mosque_members").update({ fee_subscription_id: row.id }).eq("id", membershipId);

    const ek = await stripe.ephemeralKeys.create({ customer: customerId }, { apiVersion: STRIPE_API_VERSION, ...opts });
    return json({ clientSecret: pi.client_secret, subscriptionId: row.id, customerId, ephemeralKeySecret: ek.secret, stripeAccountId: acct.stripe_account_id, fee: 0, amountCharged: amountTotal });
  } catch (e) {
    const err = e as { message?: string; code?: string; type?: string };
    console.error("[create-mosque-subscription]", err?.type, err?.code, err?.message);
    return json({ error: "stripe_error", code: err?.code ?? err?.type ?? null, message: err?.message ?? null }, 502);
  }
});
