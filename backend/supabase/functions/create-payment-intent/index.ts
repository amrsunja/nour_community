// =============================================================================
// create-payment-intent Edge Function
// -----------------------------------------------------------------------------
// Phase 1 of the payment flow. The client sends the chosen items (project +
// amount), the payment `type` (zakat|donation) and its Supabase JWT. This
// function:
//   1. Resolves the user from the JWT.
//   2. Validates the referenced projects SERVER-SIDE (active, currency match,
//      zakat-eligibility) with the service_role client.
//   3. Computes amount_total / fee_covered / amount_charged.
//   4. Inserts a `pending` transaction + its items.
//   5. Creates a Stripe PaymentIntent (minor units) linked via metadata.
//   6. Stores stripe_pi_id and returns { clientSecret, transactionId }.
//
// The client never decides a price and never writes a money row.
// Deploy JWT-verified (default): supabase functions deploy create-payment-intent
// =============================================================================

import Stripe from "https://esm.sh/stripe@16?target=deno";
import { corsHeaders } from "../_shared/cors.ts";
import { serviceClient, userClient } from "../_shared/supabase.ts";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  httpClient: Stripe.createFetchHttpClient(),
});

// EU card fee approximation used when the donor opts to cover fees. Kept in one
// place so it stays consistent with the amount actually charged.
const FEE_RATE = 0.015; // 1.5 %
const FEE_FIXED = 0.25; // + 0.25

interface Item {
  project_id: number;
  amount: number;
}

interface Payload {
  type: "zakat" | "donation";
  currency: string;
  items: Item[];
  coverFees?: boolean;
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
  const { type, currency, items, coverFees } = payload;

  if (
    !["zakat", "donation"].includes(type) ||
    typeof currency !== "string" ||
    !Array.isArray(items) ||
    items.length === 0
  ) {
    return json({ error: "bad_request" }, 400);
  }

  // 3. service_role client — bypasses RLS to read projects & write the tx.
  const admin = serviceClient();

  const ids = items.map((i) => i.project_id);
  const { data: projects, error: pErr } = await admin
    .from("impact_projects")
    .select("id, is_active, eligible_for_zakat, currency")
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
    if (!(typeof it.amount === "number" && it.amount > 0)) {
      return json({ error: "bad_amount" }, 422);
    }
  }

  const amountTotal = round2(items.reduce((s, i) => s + i.amount, 0));
  const fee = coverFees ? round2(amountTotal * FEE_RATE + FEE_FIXED) : 0;
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
    })
    .select("id")
    .single();
  if (txErr || !tx) return json({ error: "db_error" }, 500);

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

  // 6. Stripe PaymentIntent in minor units, linked back to our tx via metadata.
  let pi: Stripe.PaymentIntent;
  try {
    pi = await stripe.paymentIntents.create({
      amount: Math.round(amountCharged * 100),
      currency: currency.toLowerCase(),
      automatic_payment_methods: { enabled: true },
      metadata: {
        transaction_id: String(tx.id),
        user_id: user.id,
        type,
      },
    });
  } catch (e) {
    await admin.from("transactions").delete().eq("id", tx.id);
    console.error("[create-payment-intent] stripe", e);
    return json({ error: "stripe_error" }, 502);
  }

  await admin.from("transactions").update({ stripe_pi_id: pi.id }).eq("id", tx.id);

  return json({ clientSecret: pi.client_secret, transactionId: tx.id });
});

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

const round2 = (n: number) => Math.round(n * 100) / 100;
