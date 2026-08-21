// =============================================================================
// create-payment-intent Edge Function (v2)
// -----------------------------------------------------------------------------
// Phase 1 of a ONE-TIME payment. The client sends the chosen items (project +
// amount), the payment `type` (zakat|donation), the selected payment method,
// donor options and its Supabase JWT. This function:
//   1. Resolves the user from the JWT.
//   2. Validates the referenced projects SERVER-SIDE (active, currency match,
//      zakat-eligibility, amount bounds) with the service_role client.
//   3. Computes amount_total / fee_covered / amount_charged (fee policy lives
//      in _shared/stripe.ts — the client never decides a price).
//   4. Inserts a `pending` transaction + its items (idempotent per clientKey).
//   5. Creates a Stripe PaymentIntent restricted to the chosen method.
//   6. Stores stripe_pi_id and returns { clientSecret, transactionId, fee,
//      amountCharged, paymentMethod }.
//
// Payload:
//   {
//     type: 'zakat' | 'donation',
//     currency: 'EUR',
//     items: [{ project_id: number, amount: number }],
//     coverFees?: boolean,
//     isAnonymous?: boolean,
//     paymentMethod?: 'card' | 'apple_pay' | 'google_pay' | 'paypal',   // default card
//     clientKey?: string   // uuid per attempt — replays return the same intent
//   }
//
// Deploy JWT-verified (default): supabase functions deploy create-payment-intent
// =============================================================================

import type Stripe from "npm:stripe@16.12.0";
import { corsHeaders } from "../_shared/cors.ts";
import { serviceClient, userClient } from "../_shared/supabase.ts";
import {
  estimateFee,
  isPaymentMethod,
  json,
  MAX_AMOUNT,
  MIN_AMOUNT,
  type PaymentMethodKind,
  round2,
  stripeClient,
  stripePaymentMethodTypes,
  toMinor,
  validEmail,
} from "../_shared/stripe.ts";

interface Item {
  project_id: number;
  amount: number;
}

interface Payload {
  type: "zakat" | "donation";
  currency: string;
  items: Item[];
  coverFees?: boolean;
  isAnonymous?: boolean;
  paymentMethod?: PaymentMethodKind;
  clientKey?: string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  // 1. Authenticated user (from the caller's JWT).
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "unauthorized" }, 401);

  const {
    data: { user },
  } = await userClient(authHeader).auth.getUser();
  if (!user) return json({ error: "unauthorized" }, 401);

  // 2. Client payload — amounts are donor-chosen but must be validated.
  let payload: Payload;
  try {
    payload = (await req.json()) as Payload;
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  const { type, currency, items, coverFees, isAnonymous, clientKey } = payload;
  const method: PaymentMethodKind = isPaymentMethod(payload.paymentMethod)
    ? payload.paymentMethod
    : "card";

  if (
    !["zakat", "donation"].includes(type) ||
    typeof currency !== "string" ||
    !Array.isArray(items) ||
    items.length === 0 ||
    items.length > 20
  ) {
    return json({ error: "bad_request" }, 400);
  }
  if (clientKey !== undefined && (typeof clientKey !== "string" || clientKey.length > 64)) {
    return json({ error: "bad_request" }, 400);
  }

  // 3. service_role client — bypasses RLS to read projects & write the tx.
  const admin = serviceClient();
  const stripe = stripeClient();

  // Idempotent replay: same clientKey => hand back the same intent.
  if (clientKey) {
    const { data: existing } = await admin
      .from("transactions")
      .select("id, stripe_pi_id, fee_covered, amount_charged, payment_method, status")
      .eq("client_key", clientKey)
      .eq("user_id", user.id)
      .maybeSingle();
    if (existing?.stripe_pi_id && existing.status === "pending") {
      try {
        const pi = await stripe.paymentIntents.retrieve(existing.stripe_pi_id);
        return json({
          clientSecret: pi.client_secret,
          transactionId: existing.id,
          fee: Number(existing.fee_covered),
          amountCharged: Number(existing.amount_charged),
          paymentMethod: existing.payment_method,
        });
      } catch (e) {
        console.error("[create-payment-intent] replay retrieve", e);
        // fall through and create a fresh one (client_key freed below)
        await admin.from("transactions").update({ client_key: null }).eq("id", existing.id);
      }
    }
  }

  const ids = items.map((i) => i.project_id);
  const { data: projects, error: pErr } = await admin
    .from("impact_projects")
    .select("id, is_active, eligible_for_zakat, currency, title_en")
    .in("id", ids);
  if (pErr) return json({ error: "db_error" }, 500);

  // 4. Server-side validation — never trust the client.
  for (const it of items) {
    const p = projects?.find((x) => x.id === it.project_id);
    if (!p || !p.is_active) return json({ error: "project_inactive" }, 422);
    if (p.currency !== currency) return json({ error: "currency_mismatch" }, 422);
    if (type === "zakat" && !p.eligible_for_zakat) {
      return json({ error: "not_zakat_eligible" }, 422);
    }
    if (!(typeof it.amount === "number" && Number.isFinite(it.amount) && it.amount > 0)) {
      return json({ error: "bad_amount" }, 422);
    }
  }

  const amountTotal = round2(items.reduce((s, i) => s + i.amount, 0));
  if (amountTotal < MIN_AMOUNT) return json({ error: "amount_too_small" }, 422);
  if (amountTotal > MAX_AMOUNT) return json({ error: "amount_too_large" }, 422);

  const fee = coverFees ? estimateFee(amountTotal, method) : 0;
  const amountCharged = round2(amountTotal + fee);

  // 5. Create the pending transaction + items.
  const { data: tx, error: txErr } = await admin
    .from("transactions")
    .insert({
      user_id: user.id,
      type,
      currency,
      amount_total: amountTotal,
      fee_covered: fee,
      amount_charged: amountCharged,
      status: "pending",
      is_anonymous: isAnonymous === true,
      payment_method: method,
      client_key: clientKey ?? null,
    })
    .select("id")
    .single();
  if (txErr || !tx) {
    console.error("[create-payment-intent] insert tx", txErr);
    return json({ error: "db_error" }, 500);
  }

  const { error: itErr } = await admin.from("transaction_items").insert(
    items.map((i) => ({
      transaction_id: tx.id,
      impact_project_id: i.project_id,
      amount: round2(i.amount),
    })),
  );
  if (itErr) {
    // Roll back the orphan transaction so we don't leak a dangling pending row.
    await admin.from("transactions").delete().eq("id", tx.id);
    return json({ error: "db_error" }, 500);
  }

  // 6. Stripe PaymentIntent in minor units, restricted to the chosen method,
  //    linked back to our tx via metadata. Receipt goes to the donor's email.
  const projectLabel = projects && projects.length === 1
    ? projects[0].title_en
    : `${items.length} projects`;
  let pi: Stripe.PaymentIntent;
  try {
    pi = await stripe.paymentIntents.create(
      {
        amount: toMinor(amountCharged),
        currency: currency.toLowerCase(),
        payment_method_types: stripePaymentMethodTypes(method),
        description: `Nour Community — ${type} — ${projectLabel}`,
        receipt_email: validEmail(user.email),
        metadata: {
          transaction_id: String(tx.id),
          user_id: user.id,
          type,
          payment_method: method,
          anonymous: isAnonymous === true ? "1" : "0",
        },
      },
      clientKey ? { idempotencyKey: `pi:${user.id}:${clientKey}` } : undefined,
    );
  } catch (e) {
    await admin.from("transactions").delete().eq("id", tx.id);
    const err = e as { message?: string; code?: string; type?: string; param?: string };
    console.error("[create-payment-intent] stripe", err?.type, err?.code, err?.param, err?.message);
    // Surface Stripe's reason (no secrets in it) so the app log is actionable,
    // e.g. "The payment method type "paypal" is invalid" → enable it in Stripe.
    return json(
      { error: "stripe_error", code: err?.code ?? err?.type ?? null, message: err?.message ?? null },
      502,
    );
  }

  await admin
    .from("transactions")
    .update({ stripe_pi_id: pi.id })
    .eq("id", tx.id);

  return json({
    clientSecret: pi.client_secret,
    transactionId: tx.id,
    fee,
    amountCharged,
    paymentMethod: method,
  });
});
