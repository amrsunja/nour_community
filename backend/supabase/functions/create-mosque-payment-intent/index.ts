// =============================================================================
// create-mosque-payment-intent Edge Function (P3 — devis B2/B3/B6)
// -----------------------------------------------------------------------------
// One-time gift to a mosque: Sadaqa, campaign contribution or one-time
// membership fee. DIRECT CHARGE on the mosque's connected account: Nour never
// holds the funds. The PaymentIntent lives on the connected account, so the
// app must set Stripe.stripeAccountId before confirming.
//
// Payload: { mosqueId, amount, currency: 'EUR', campaignId?, membershipId?,
//            isAnonymous?, paymentMethod?, clientKey? }
// Returns: { clientSecret, transactionId, stripeAccountId, fee: 0, amountCharged }
// =============================================================================

import { corsHeaders } from "../_shared/cors.ts";
import { serviceClient, userClient } from "../_shared/supabase.ts";
import { isPaymentMethod, json, MAX_AMOUNT, MIN_AMOUNT, type PaymentMethodKind, round2, stripeClient, stripePaymentMethodTypes, toMinor, validEmail } from "../_shared/stripe.ts";
import { descriptorSuffix, loadChargeableMosque, onAccount } from "../_shared/mosque.ts";

interface Payload {
  mosqueId: number;
  amount: number;
  currency: string;
  campaignId?: number;
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
  const { mosqueId, amount, currency, campaignId, membershipId, isAnonymous, clientKey } = payload;
  const method: PaymentMethodKind = isPaymentMethod(payload.paymentMethod) ? payload.paymentMethod : "card";
  if (!Number.isInteger(mosqueId) || typeof currency !== "string" || !(typeof amount === "number" && Number.isFinite(amount) && amount > 0)) {
    return json({ error: "bad_request" }, 400);
  }
  if (method === "paypal") return json({ error: "method_not_supported" }, 422);
  const amountTotal = round2(amount);
  if (amountTotal < MIN_AMOUNT) return json({ error: "amount_too_small" }, 422);
  if (amountTotal > MAX_AMOUNT) return json({ error: "amount_too_large" }, 422);

  const admin = serviceClient();
  const stripe = stripeClient();

  // Idempotent replay.
  if (clientKey) {
    const { data: existing } = await admin
      .from("transactions")
      .select("id, stripe_pi_id, stripe_account_id, amount_charged, status")
      .eq("client_key", clientKey)
      .eq("user_id", user.id)
      .maybeSingle();
    if (existing?.stripe_pi_id && existing.status === "pending" && existing.stripe_account_id) {
      try {
        const pi = await stripe.paymentIntents.retrieve(existing.stripe_pi_id, undefined, { stripeAccount: existing.stripe_account_id });
        if (pi.client_secret) {
          return json({ clientSecret: pi.client_secret, transactionId: existing.id, stripeAccountId: existing.stripe_account_id, fee: 0, amountCharged: Number(existing.amount_charged) });
        }
      } catch (_) { /* fall through */ }
    }
  }

  const loaded = await loadChargeableMosque(admin, mosqueId);
  if ("error" in loaded) return json({ error: loaded.error }, 422);
  const { mosque, acct } = loaded;

  let type: "mosque_sadaqa" | "mosque_campaign" | "mosque_membership" = "mosque_sadaqa";
  let campaignTitle: string | null = null;
  if (campaignId) {
    const { data: c } = await admin.from("mosque_campaigns").select("id, mosque_id, status, ends_at, title, currency").eq("id", campaignId).maybeSingle();
    if (!c || c.mosque_id !== mosque.id) return json({ error: "campaign_not_found" }, 404);
    if (c.status !== "active" || new Date(c.ends_at) < new Date()) return json({ error: "campaign_closed" }, 422);
    if (c.currency !== currency) return json({ error: "currency_mismatch" }, 422);
    type = "mosque_campaign";
    campaignTitle = c.title;
  } else if (membershipId) {
    const { data: m } = await admin.from("mosque_members").select("id, mosque_id, user_id").eq("id", membershipId).maybeSingle();
    if (!m || m.mosque_id !== mosque.id || m.user_id !== user.id) return json({ error: "membership_not_found" }, 404);
    type = "mosque_membership";
  }

  // Ledger row first (pending).
  const { data: tx, error: txErr } = await admin
    .from("transactions")
    .insert({
      user_id: user.id,
      type,
      status: "pending",
      currency,
      amount_total: amountTotal,
      fee_covered: 0,
      amount_charged: amountTotal,
      is_anonymous: isAnonymous === true,
      payment_method: method,
      client_key: clientKey ?? null,
      mosque_id: mosque.id,
      mosque_campaign_id: campaignId ?? null,
      membership_id: membershipId ?? null,
      stripe_account_id: acct.stripe_account_id,
    })
    .select("id")
    .single();
  if (txErr || !tx) {
    console.error("[create-mosque-payment-intent] insert", txErr);
    return json({ error: "db_error" }, 500);
  }

  try {
    const pi = await stripe.paymentIntents.create(
      {
        amount: toMinor(amountTotal),
        currency: currency.toLowerCase(),
        payment_method_types: stripePaymentMethodTypes(method),
        receipt_email: validEmail(user.email),
        description: campaignTitle ? `${mosque.name} — ${campaignTitle}` : `${mosque.name} — ${type === "mosque_membership" ? "Adhésion" : "Sadaqa"}`,
        statement_descriptor_suffix: descriptorSuffix(mosque.name),
        // application_fee_amount: reserved for V3 "Mosquée Pro" (0 today).
        metadata: {
          transaction_id: String(tx.id),
          user_id: user.id,
          mosque_id: String(mosque.id),
          campaign_id: campaignId ? String(campaignId) : "",
          membership_id: membershipId ? String(membershipId) : "",
          type,
          payment_method: method,
          anonymous: isAnonymous === true ? "1" : "0",
        },
      },
      onAccount(acct, clientKey ? { idempotencyKey: `mpi:${user.id}:${clientKey}` } : undefined),
    );
    await admin.from("transactions").update({ stripe_pi_id: pi.id }).eq("id", tx.id);
    return json({ clientSecret: pi.client_secret, transactionId: tx.id, stripeAccountId: acct.stripe_account_id, fee: 0, amountCharged: amountTotal });
  } catch (e) {
    await admin.from("transactions").delete().eq("id", tx.id);
    const err = e as { message?: string; code?: string; type?: string };
    console.error("[create-mosque-payment-intent] stripe", err?.type, err?.code, err?.message);
    return json({ error: "stripe_error", code: err?.code ?? err?.type ?? null, message: err?.message ?? null }, 502);
  }
});
