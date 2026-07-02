// =============================================================================
// stripe-webhook Edge Function
// -----------------------------------------------------------------------------
// Phase 3 of the payment flow — the single authority that flips a transaction
// to `succeeded`. Stripe (not the app) is the source of truth.
//
//   1. Verify the signature with STRIPE_WEBHOOK_SECRET using the RAW body.
//   2. payment_intent.succeeded    -> status = succeeded (idempotent guard),
//                                      trg_tx_apply credits collected_amount.
//   3. payment_intent.payment_failed -> status = failed.
//   4. charge.refunded             -> status = refunded, trigger reverses credit.
//   5. Always return 2xx for handled events so Stripe does not retry.
//
// MUST be deployed with --no-verify-jwt (Stripe sends no Supabase JWT; security
// comes from the Stripe signature check):
//   supabase functions deploy stripe-webhook --no-verify-jwt
// =============================================================================

import Stripe from "https://esm.sh/stripe@16?target=deno";
import { serviceClient } from "../_shared/supabase.ts";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  httpClient: Stripe.createFetchHttpClient(),
});
const whSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;
const admin = serviceClient();

Deno.serve(async (req) => {
  const sig = req.headers.get("stripe-signature");
  if (!sig) return new Response("missing signature", { status: 400 });

  const body = await req.text(); // raw body REQUIRED for signature verification

  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(body, sig, whSecret);
  } catch (e) {
    console.error("[stripe-webhook] bad signature", e);
    return new Response("bad signature", { status: 400 });
  }

  try {
    switch (event.type) {
      case "payment_intent.succeeded": {
        const pi = event.data.object as Stripe.PaymentIntent;
        await admin
          .from("transactions")
          .update({
            status: "succeeded",
            stripe_event_id: event.id,
            net_received: pi.amount_received != null
              ? pi.amount_received / 100
              : null,
            updated_at: new Date().toISOString(),
          })
          .eq("stripe_pi_id", pi.id)
          .neq("status", "succeeded"); // idempotency guard vs duplicate webhooks
        // trg_tx_apply credits collected_amount + donors_count.
        break;
      }

      case "payment_intent.payment_failed": {
        const pi = event.data.object as Stripe.PaymentIntent;
        await admin
          .from("transactions")
          .update({
            status: "failed",
            stripe_event_id: event.id,
            failure_reason: pi.last_payment_error?.message ?? null,
          })
          .eq("stripe_pi_id", pi.id)
          .eq("status", "pending");
        break;
      }

      case "charge.refunded": {
        const ch = event.data.object as Stripe.Charge;
        await admin
          .from("transactions")
          .update({ status: "refunded", stripe_event_id: event.id })
          .eq("stripe_pi_id", ch.payment_intent as string)
          .eq("status", "succeeded"); // trigger reverses collected_amount
        break;
      }

      default:
        // Unhandled event types are acknowledged so Stripe stops retrying.
        break;
    }
  } catch (e) {
    console.error("[stripe-webhook] handler error", e);
    // Return 500 so Stripe retries transient DB failures.
    return new Response("handler error", { status: 500 });
  }

  return new Response("ok", { status: 200 }); // 2xx => Stripe won't retry
});
