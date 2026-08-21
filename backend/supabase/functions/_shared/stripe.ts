// =============================================================================
// Shared Stripe helpers for the payment functions.
// -----------------------------------------------------------------------------
// * One pinned Stripe client (API version 2024-06-20 — matches stripe@16 and
//   keeps `latest_invoice.payment_intent` expandable for subscriptions).
//   Imported via `npm:` — the esm.sh `?target=deno` build breaks in the
//   Supabase Edge Runtime ("Deno.core.runMicrotasks() is not supported").
// * The fee policy (single source of truth — the Dart `FeePolicy` mirrors it
//   for display only; the amount actually charged always comes from here).
// * Payment-method mapping between the app's picker and Stripe.
// =============================================================================

import Stripe from "npm:stripe@16.12.0";
import { corsHeaders } from "./cors.ts";

export const STRIPE_API_VERSION = "2024-06-20";

let _stripe: Stripe | null = null;
export function stripeClient(): Stripe {
  if (_stripe) return _stripe;
  const key = Deno.env.get("STRIPE_SECRET_KEY");
  if (!key) throw new Error("STRIPE_SECRET_KEY is not set");
  _stripe = new Stripe(key, {
    apiVersion: STRIPE_API_VERSION,
    httpClient: Stripe.createFetchHttpClient(),
  });
  return _stripe;
}

/** The app's payment method picker values. */
export type PaymentMethodKind = "card" | "apple_pay" | "google_pay" | "paypal";
export const PAYMENT_METHODS: PaymentMethodKind[] = [
  "card",
  "apple_pay",
  "google_pay",
  "paypal",
];

/** Stripe `payment_method_types` for a picker value. Wallets are card rails. */
export function stripePaymentMethodTypes(method: PaymentMethodKind): string[] {
  return method === "paypal" ? ["paypal"] : ["card"];
}

/** Amount guards (in major units, i.e. EUR). */
export const MIN_AMOUNT = 1;
export const MAX_AMOUNT = 10_000;

// Fee approximation used when the donor opts to "cover transaction fees".
// EU cards / wallets: 1.5 % + 0.25 ; PayPal (EU): 2.9 % + 0.35.
// NOTE: keep in sync with nour_app/lib/src/features/payments/data/fee_policy.dart
const FEES: Record<PaymentMethodKind, { pct: number; fixed: number }> = {
  card: { pct: 0.015, fixed: 0.25 },
  apple_pay: { pct: 0.015, fixed: 0.25 },
  google_pay: { pct: 0.015, fixed: 0.25 },
  paypal: { pct: 0.029, fixed: 0.35 },
};

export function estimateFee(amount: number, method: PaymentMethodKind): number {
  if (!(amount > 0)) return 0;
  const f = FEES[method] ?? FEES.card;
  return round2(amount * f.pct + f.fixed);
}

export const round2 = (n: number) => Math.round(n * 100) / 100;
export const toMinor = (n: number) => Math.round(n * 100);

export const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

export function isPaymentMethod(v: unknown): v is PaymentMethodKind {
  return typeof v === "string" && (PAYMENT_METHODS as string[]).includes(v);
}

/** Email usable for Stripe (`receipt_email`, customer) — undefined when empty/invalid. */
export function validEmail(email: string | null | undefined): string | undefined {
  const e = email?.trim();
  return e && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e) ? e : undefined;
}
