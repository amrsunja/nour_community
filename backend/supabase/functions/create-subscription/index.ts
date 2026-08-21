// =============================================================================
// create-subscription Edge Function
// -----------------------------------------------------------------------------
// Phase 1 of a RECURRING donation (monthly / yearly, per project). Donations
// only — zakat is never recurring.
//
//   1. Resolve the user from the JWT.
//   2. Validate the project (active, currency) and the amount bounds.
//   3. Get/create the Stripe Customer (profiles.stripe_customer_id) and the
//      project's Stripe Product (impact_projects.stripe_product_id).
//   4. Insert a donation_subscriptions row (status = incomplete, idempotent per
//      clientKey).
//   5. Create the Stripe Subscription with an inline recurring price,
//      payment_behavior = default_incomplete, and the default payment method
//      saved on the subscription; expand the first invoice's PaymentIntent.
//   6. Return { clientSecret, subscriptionId, customerId, ephemeralKeySecret,
//      fee, amountCharged, paymentMethod }.
//
// The app confirms the first invoice's PaymentIntent exactly like a one-time
// payment (PaymentSheet / Apple Pay / Google Pay / PayPal). Stripe then
// attaches the payment method to the subscription; `invoice.paid` webhooks
// create one succeeded transaction per period.
//
// Payload:
//   {
//     projectId: number, amount: number, currency: 'EUR',
//     interval: 'month' | 'year',
//     coverFees?: boolean, isAnonymous?: boolean,
//     paymentMethod?: 'card'|'apple_pay'|'google_pay'|'paypal',
//     clientKey?: string
//   }
// Deploy JWT-verified (default): supabase functions deploy create-subscription
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
  STRIPE_API_VERSION,
  stripeClient,
  stripePaymentMethodTypes,
  toMinor,
  validEmail,
} from "../_shared/stripe.ts";

interface Payload {
  projectId: number;
  amount: number;
  currency: string;
  interval: "month" | "year";
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

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "unauthorized" }, 401);
  const {
    data: { user },
  } = await userClient(authHeader).auth.getUser();
  if (!user) return json({ error: "unauthorized" }, 401);

  let payload: Payload;
  try {
    payload = (await req.json()) as Payload;
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  const { projectId, amount, currency, interval, coverFees, isAnonymous, clientKey } = payload;
  const method: PaymentMethodKind = isPaymentMethod(payload.paymentMethod)
    ? payload.paymentMethod
    : "card";

  if (
    !Number.isInteger(projectId) ||
    typeof currency !== "string" ||
    !["month", "year"].includes(interval) ||
    !(typeof amount === "number" && Number.isFinite(amount) && amount > 0)
  ) {
    return json({ error: "bad_request" }, 400);
  }
  if (clientKey !== undefined && (typeof clientKey !== "string" || clientKey.length > 64)) {
    return json({ error: "bad_request" }, 400);
  }

  const amountTotal = round2(amount);
  if (amountTotal < MIN_AMOUNT) return json({ error: "amount_too_small" }, 422);
  if (amountTotal > MAX_AMOUNT) return json({ error: "amount_too_large" }, 422);

  const admin = serviceClient();
  const stripe = stripeClient();

  // Idempotent replay.
  if (clientKey) {
    const { data: existing } = await admin
      .from("donation_subscriptions")
      .select("id, stripe_subscription_id, stripe_customer_id, fee_covered, amount, payment_method, status")
      .eq("client_key", clientKey)
      .eq("user_id", user.id)
      .maybeSingle();
    if (existing?.stripe_subscription_id && existing.status === "incomplete") {
      try {
        const sub = await stripe.subscriptions.retrieve(existing.stripe_subscription_id, {
          expand: ["latest_invoice.payment_intent"],
        });
        const pi = (sub.latest_invoice as Stripe.Invoice | null)?.payment_intent as
          | Stripe.PaymentIntent
          | null;
        if (pi?.client_secret) {
          const ek = await ephemeralKey(stripe, existing.stripe_customer_id!);
          return json({
            clientSecret: pi.client_secret,
            subscriptionId: existing.id,
            customerId: existing.stripe_customer_id,
            ephemeralKeySecret: ek,
            fee: Number(existing.fee_covered),
            amountCharged: round2(Number(existing.amount) + Number(existing.fee_covered)),
            paymentMethod: existing.payment_method,
          });
        }
      } catch (e) {
        console.error("[create-subscription] replay", e);
      }
      await admin.from("donation_subscriptions").update({ client_key: null }).eq("id", existing.id);
    }
  }

  // 2. Project validation.
  const { data: project, error: pErr } = await admin
    .from("impact_projects")
    .select("id, is_active, currency, title_en, stripe_product_id")
    .eq("id", projectId)
    .maybeSingle();
  if (pErr) return json({ error: "db_error" }, 500);
  if (!project || !project.is_active) return json({ error: "project_inactive" }, 422);
  if (project.currency !== currency) return json({ error: "currency_mismatch" }, 422);

  const fee = coverFees ? estimateFee(amountTotal, method) : 0;
  const amountCharged = round2(amountTotal + fee);

  // 3a. Stripe Customer (one per user).
  const { data: profile } = await admin
    .from("profiles")
    .select("id, name, stripe_customer_id")
    .eq("id", user.id)
    .maybeSingle();

  let customerId = profile?.stripe_customer_id as string | null | undefined;
  if (!customerId) {
    try {
      const customer = await stripe.customers.create({
        email: validEmail(user.email),
        name: profile?.name ?? undefined,
        metadata: { user_id: user.id },
      });
      customerId = customer.id;
      await admin.from("profiles").update({ stripe_customer_id: customerId }).eq("id", user.id);
    } catch (e) {
      const err = e as { message?: string; code?: string };
      console.error("[create-subscription] customer", err?.code, err?.message);
      return json({ error: "stripe_error", code: err?.code ?? null, message: err?.message ?? null }, 502);
    }
  }

  // 3b. Stripe Product (one per project).
  let productId = project.stripe_product_id as string | null;
  if (!productId) {
    try {
      const product = await stripe.products.create({
        name: `Nour — ${project.title_en}`,
        metadata: { impact_project_id: String(project.id) },
      });
      productId = product.id;
      await admin.from("impact_projects").update({ stripe_product_id: productId }).eq("id", project.id);
    } catch (e) {
      const err = e as { message?: string; code?: string };
      console.error("[create-subscription] product", err?.code, err?.message);
      return json({ error: "stripe_error", code: err?.code ?? null, message: err?.message ?? null }, 502);
    }
  }

  // 4. Local subscription row (incomplete until the first invoice is paid).
  const { data: row, error: rowErr } = await admin
    .from("donation_subscriptions")
    .insert({
      user_id: user.id,
      impact_project_id: project.id,
      type: "donation",
      amount: amountTotal,
      fee_covered: fee,
      currency,
      interval,
      status: "incomplete",
      is_anonymous: isAnonymous === true,
      payment_method: method,
      stripe_customer_id: customerId,
      client_key: clientKey ?? null,
    })
    .select("id")
    .single();
  if (rowErr || !row) {
    console.error("[create-subscription] insert", rowErr);
    return json({ error: "db_error" }, 500);
  }

  // 5. Stripe Subscription with an inline recurring price.
  let sub: Stripe.Subscription;
  try {
    sub = await stripe.subscriptions.create(
      {
        customer: customerId,
        items: [{
          price_data: {
            currency: currency.toLowerCase(),
            product: productId,
            unit_amount: toMinor(amountCharged),
            recurring: { interval },
          },
        }],
        payment_behavior: "default_incomplete",
        payment_settings: {
          save_default_payment_method: "on_subscription",
          payment_method_types: stripePaymentMethodTypes(method) as
            Stripe.SubscriptionCreateParams.PaymentSettings.PaymentMethodType[],
        },
        expand: ["latest_invoice.payment_intent"],
        metadata: {
          subscription_row_id: String(row.id),
          user_id: user.id,
          project_id: String(project.id),
          type: "donation",
          payment_method: method,
          anonymous: isAnonymous === true ? "1" : "0",
        },
      },
      clientKey ? { idempotencyKey: `sub:${user.id}:${clientKey}` } : undefined,
    );
  } catch (e) {
    await admin.from("donation_subscriptions").delete().eq("id", row.id);
    const err = e as { message?: string; code?: string; type?: string; param?: string };
    console.error("[create-subscription] stripe", err?.type, err?.code, err?.param, err?.message);
    return json(
      { error: "stripe_error", code: err?.code ?? err?.type ?? null, message: err?.message ?? null },
      502,
    );
  }

  const pi = (sub.latest_invoice as Stripe.Invoice | null)?.payment_intent as
    | Stripe.PaymentIntent
    | null;
  if (!pi?.client_secret) {
    await admin.from("donation_subscriptions").delete().eq("id", row.id);
    try { await stripe.subscriptions.cancel(sub.id); } catch (_) { /* ignore */ }
    console.error("[create-subscription] no payment intent on first invoice");
    return json({ error: "stripe_error" }, 502);
  }

  await admin
    .from("donation_subscriptions")
    .update({
      stripe_subscription_id: sub.id,
      current_period_end: sub.current_period_end
        ? new Date(sub.current_period_end * 1000).toISOString()
        : null,
    })
    .eq("id", row.id);

  // Attach our metadata to the first PI too so payment_intent.* events are
  // self-describing in the Stripe dashboard.
  try {
    await stripe.paymentIntents.update(pi.id, {
      description: `Nour Community — recurring ${interval}ly — ${project.title_en}`,
      receipt_email: validEmail(user.email),
      metadata: {
        subscription_row_id: String(row.id),
        user_id: user.id,
        type: "donation",
        payment_method: method,
      },
    });
  } catch (_) { /* cosmetic */ }

  const ek = await ephemeralKey(stripe, customerId);

  return json({
    clientSecret: pi.client_secret,
    subscriptionId: row.id,
    customerId,
    ephemeralKeySecret: ek,
    fee,
    amountCharged,
    paymentMethod: method,
  });
});

async function ephemeralKey(stripe: Stripe, customerId: string): Promise<string | null> {
  try {
    const key = await stripe.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: STRIPE_API_VERSION },
    );
    return key.secret ?? null;
  } catch (e) {
    console.error("[create-subscription] ephemeral key", e);
    return null;
  }
}
