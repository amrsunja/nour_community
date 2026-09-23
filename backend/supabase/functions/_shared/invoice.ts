// =============================================================================
// Shared invoice → ledger logic (platform + connect).
// -----------------------------------------------------------------------------
// WHY THIS FILE EXISTS
// A recurring donation only reaches `impact_projects.collected_amount` /
// `mosque_campaigns.collected_amount` / the mosque fundraising totals through a
// `transactions` row, and that row was created in exactly ONE place: the
// `invoice.paid` webhook handler. Meanwhile the app flips to "success" on
// `donation_subscriptions.status`, which `customer.subscription.updated` (or
// the reconcile endpoints) can set on its own. So any hiccup on the invoice
// path — event not registered, a newer API version on the endpoint, the local
// row not linked yet — produced a paid subscription that counts for nothing,
// silently and permanently.
//
// Everything invoice-related now goes through here:
//   * version-agnostic readers (the 2025 "basil" API removed
//     `invoice.subscription`, `invoice.payment_intent` and
//     `subscription.current_period_end`),
//   * a single idempotent writer used by the webhooks AND by the donor-facing
//     reconcile functions, so a missed webhook self-heals,
//   * `UnresolvedInvoiceError` so the caller can answer 5xx and let Stripe
//     retry instead of acknowledging a silent loss.
//
// Idempotency is the ledger row itself (`transactions.stripe_invoice_id`,
// UNIQUE since 20260917000000), never the event id — that is what makes a
// "Resend" from the Stripe dashboard able to repair past invoices.
// =============================================================================

import type Stripe from "npm:stripe@16.12.0";
import { round2 } from "./stripe.ts";

// deno-lint-ignore no-explicit-any
type Any = any;

/** Raised when a paid invoice cannot be attached to a local subscription. */
export class UnresolvedInvoiceError extends Error {
  constructor(msg: string) {
    super(msg);
    this.name = "UnresolvedInvoiceError";
  }
}

/** Invoices older than this are given up on instead of retried forever. */
const RETRY_WINDOW_MS = 3 * 24 * 60 * 60 * 1000;

export function isWorthRetrying(inv: Stripe.Invoice): boolean {
  const created = (inv as Any).created;
  if (typeof created !== "number") return true;
  return Date.now() - created * 1000 < RETRY_WINDOW_MS;
}

// ── version-agnostic readers ─────────────────────────────────────────────────

/**
 * `invoice.subscription` (<= 2024-06-20) or
 * `invoice.parent.subscription_details.subscription` / the line's parent
 * (>= 2025-03-31 "basil"). Webhook endpoints render events with THEIR OWN API
 * version, which is not the version our SDK is pinned to.
 */
export function invoiceSubscriptionId(inv: Stripe.Invoice): string | null {
  const i = inv as Any;
  const direct = i.subscription;
  if (direct) return typeof direct === "string" ? direct : direct.id ?? null;

  const parent = i.parent?.subscription_details?.subscription;
  if (parent) return typeof parent === "string" ? parent : parent.id ?? null;

  for (const line of (i.lines?.data ?? []) as Any[]) {
    const s = line?.subscription ??
      line?.parent?.subscription_item_details?.subscription;
    if (s) return typeof s === "string" ? s : s.id ?? null;
  }
  return null;
}

/** `invoice.payment_intent` (old) or `invoice.payments[].payment.payment_intent` (basil). */
export function invoicePaymentIntentId(inv: Stripe.Invoice): string | null {
  const i = inv as Any;
  const direct = i.payment_intent;
  if (direct) return typeof direct === "string" ? direct : direct.id ?? null;

  for (const p of (i.payments?.data ?? []) as Any[]) {
    const pi = p?.payment?.payment_intent;
    if (pi) return typeof pi === "string" ? pi : pi.id ?? null;
  }
  return null;
}

/** Metadata carried by the subscription on the invoice, when the shape has it. */
export function invoiceSubscriptionMetadata(inv: Stripe.Invoice): Record<string, string> {
  const i = inv as Any;
  return (i.parent?.subscription_details?.metadata ??
    i.subscription_details?.metadata ?? {}) as Record<string, string>;
}

/** `subscription.current_period_end` (old) or `items.data[0].current_period_end` (basil). */
export function subscriptionPeriodEnd(sub: Stripe.Subscription): string | null {
  const s = sub as Any;
  const ts = s.current_period_end ?? s.items?.data?.[0]?.current_period_end;
  return typeof ts === "number" ? new Date(ts * 1000).toISOString() : null;
}

/** Period end of the invoice's first line — used when the sub isn't fetched. */
export function invoicePeriodEnd(inv: Stripe.Invoice): string | null {
  const ts = (inv as Any).lines?.data?.[0]?.period?.end;
  return typeof ts === "number" ? new Date(ts * 1000).toISOString() : null;
}

// ── net received ─────────────────────────────────────────────────────────────

export async function netReceivedFor(
  stripe: Stripe,
  piId: string | null,
  opts?: Stripe.RequestOptions,
): Promise<number | null> {
  if (!piId) return null;
  try {
    const pi = await stripe.paymentIntents.retrieve(piId, undefined, opts);
    const chargeId = typeof pi.latest_charge === "string" ? pi.latest_charge : pi.latest_charge?.id;
    if (!chargeId) return null;
    const ch = await stripe.charges.retrieve(chargeId, { expand: ["balance_transaction"] }, opts);
    const bt = ch.balance_transaction as Stripe.BalanceTransaction | null;
    return bt && typeof bt.net === "number" ? round2(bt.net / 100) : null;
  } catch (_) {
    return null; // best effort — never block the ledger row
  }
}

// ── the single writer ────────────────────────────────────────────────────────

export type RecordOutcome = "recorded" | "duplicate" | "not_paid" | "not_a_subscription";

interface RecordArgs {
  admin: Any;
  stripe: Stripe;
  inv: Stripe.Invoice;
  /** Stripe event id, when this runs from a webhook. */
  eventId?: string | null;
  /** Connected-account options for mosque (direct charge) invoices. */
  opts?: Stripe.RequestOptions;
}

/**
 * Books a paid invoice as ONE succeeded transaction, idempotent on
 * `stripe_invoice_id`. Impact subscriptions also get their `transaction_items`
 * row (that is what `fn_apply_tx_to_projects` reads); mosque subscriptions
 * carry the target on the transaction itself (`fn_apply_tx_to_mosque`).
 *
 * Throws [UnresolvedInvoiceError] when the invoice belongs to a subscription we
 * cannot map to a local row — the caller decides whether to ask for a retry.
 */
export async function recordInvoiceTransaction(
  { admin, stripe, inv, eventId = null, opts }: RecordArgs,
): Promise<RecordOutcome> {
  const invId = (inv as Any).id as string | undefined;
  if (!invId) return "not_a_subscription";
  if ((inv as Any).status !== "paid" && ((inv as Any).amount_paid ?? 0) <= 0) return "not_paid";

  const stripeSubId = invoiceSubscriptionId(inv);
  if (!stripeSubId) return "not_a_subscription";

  const sub = await resolveSubscriptionRow(admin, stripe, inv, stripeSubId, opts);
  if (!sub) {
    throw new UnresolvedInvoiceError(
      `no donation_subscriptions row for stripe subscription ${stripeSubId} (invoice ${invId})`,
    );
  }

  // Already booked? (cheap check; the UNIQUE index is the real guard)
  const { data: dup } = await admin
    .from("transactions")
    .select("id")
    .eq("stripe_invoice_id", invId)
    .maybeSingle();
  if (dup) {
    await markSubscriptionActive(admin, sub.id, invoicePeriodEnd(inv));
    return "duplicate";
  }

  const isMosque = sub.mosque_id != null;
  const amountCharged = round2(((inv as Any).amount_paid ?? 0) / 100);
  const amountTotal = Number(sub.amount);
  const piId = invoicePaymentIntentId(inv);
  const net = await netReceivedFor(stripe, piId, opts);

  // A recurring campaign gift keeps charging after the campaign closed or ran
  // out: the money still reaches the mosque, but it is booked as Sadaqa rather
  // than inflating a finished campaign.
  let campaignId: number | null = sub.mosque_campaign_id ?? null;
  let type: string = sub.type;
  if (isMosque && campaignId) {
    const { data: c } = await admin
      .from("mosque_campaigns")
      .select("status, ends_at")
      .eq("id", campaignId)
      .maybeSingle();
    if (!c || c.status !== "active" || new Date(c.ends_at) < new Date()) {
      campaignId = null;
      type = "mosque_sadaqa";
    }
  }

  const base = {
    user_id: sub.user_id,
    type,
    currency: sub.currency,
    amount_total: amountTotal,
    amount_charged: amountCharged,
    net_received: net,
    stripe_pi_id: piId,
    stripe_invoice_id: invId,
    stripe_event_id: eventId,
    subscription_id: sub.id,
    is_anonymous: sub.is_anonymous,
    payment_method: sub.payment_method,
  };

  if (isMosque) {
    // Direct charge: no platform fee, and the trigger reads the row itself, so
    // it can be inserted as `succeeded` in one go.
    const { error } = await admin.from("transactions").insert({
      ...base,
      status: "succeeded",
      fee_covered: 0,
      mosque_id: sub.mosque_id,
      mosque_campaign_id: campaignId,
      membership_id: sub.membership_id,
      stripe_account_id: sub.stripe_account_id,
    });
    if (error) {
      if (isUniqueViolation(error)) return "duplicate"; // concurrent delivery won
      throw error;
    }
    if (sub.mosque_campaign_id && campaignId === null) {
      await admin
        .from("donation_subscriptions")
        .update({ type: "mosque_sadaqa", mosque_campaign_id: null })
        .eq("id", sub.id);
    }
  } else {
    // Impact: the body is the subscription amount, anything above it is the
    // fee the donor chose to cover. Insert pending → items → succeeded so the
    // project trigger sees the breakdown it needs.
    const { data: tx, error: txErr } = await admin
      .from("transactions")
      .insert({
        ...base,
        status: "pending",
        fee_covered: round2(Math.max(0, amountCharged - amountTotal)),
      })
      .select("id")
      .single();
    if (txErr || !tx) {
      if (isUniqueViolation(txErr)) return "duplicate";
      throw txErr ?? new Error("tx insert failed");
    }

    const { error: itErr } = await admin.from("transaction_items").insert({
      transaction_id: tx.id,
      impact_project_id: sub.impact_project_id,
      amount: amountTotal,
    });
    if (itErr) {
      // Never leave a pending orphan behind: it would block the unique index
      // and never credit the project.
      await admin.from("transactions").delete().eq("id", tx.id);
      throw itErr;
    }

    const { error: upErr } = await admin
      .from("transactions")
      .update({ status: "succeeded" })
      .eq("id", tx.id)
      .neq("status", "succeeded");
    if (upErr) throw upErr;
  }

  await markSubscriptionActive(admin, sub.id, invoicePeriodEnd(inv));
  return "recorded";
}

/**
 * Books every paid invoice Stripe has for a subscription that is missing from
 * the ledger. Used by the donor-facing reconcile endpoints so a subscription
 * whose webhook never landed still counts.
 */
export async function recordPaidInvoicesForSubscription(
  admin: Any,
  stripe: Stripe,
  stripeSubscriptionId: string,
  opts?: Stripe.RequestOptions,
  limit = 6,
): Promise<number> {
  let booked = 0;
  try {
    const invoices = await stripe.invoices.list(
      { subscription: stripeSubscriptionId, status: "paid", limit },
      opts,
    );
    for (const inv of invoices.data) {
      try {
        if (await recordInvoiceTransaction({ admin, stripe, inv, opts }) === "recorded") booked++;
      } catch (e) {
        if (!(e instanceof UnresolvedInvoiceError)) throw e;
      }
    }
  } catch (e) {
    console.error("[invoice] recordPaidInvoicesForSubscription", (e as Error)?.message);
  }
  return booked;
}

// ── internals ────────────────────────────────────────────────────────────────

function isUniqueViolation(error: Any): boolean {
  return error?.code === "23505";
}

const SUB_COLUMNS =
  "id, user_id, impact_project_id, mosque_id, mosque_campaign_id, membership_id, " +
  "type, amount, currency, is_anonymous, payment_method, stripe_account_id, stripe_subscription_id";

/**
 * Finds the local subscription row: by `stripe_subscription_id` first, then by
 * the `subscription_row_id` metadata both create-* functions write (covers the
 * window where the Stripe subscription exists but the link column is not
 * written yet, and repairs it).
 */
async function resolveSubscriptionRow(
  admin: Any,
  stripe: Stripe,
  inv: Stripe.Invoice,
  stripeSubId: string,
  opts?: Stripe.RequestOptions,
): Promise<Any | null> {
  const { data: byId } = await admin
    .from("donation_subscriptions")
    .select(SUB_COLUMNS)
    .eq("stripe_subscription_id", stripeSubId)
    .maybeSingle();
  if (byId) return byId;

  let rowId = Number(invoiceSubscriptionMetadata(inv).subscription_row_id);
  if (!Number.isInteger(rowId) || rowId <= 0) {
    try {
      const s = await stripe.subscriptions.retrieve(stripeSubId, undefined, opts);
      rowId = Number(s.metadata?.subscription_row_id);
    } catch (_) { /* fall through */ }
  }
  if (!Number.isInteger(rowId) || rowId <= 0) return null;

  const { data: byMeta } = await admin
    .from("donation_subscriptions")
    .select(SUB_COLUMNS)
    .eq("id", rowId)
    .maybeSingle();
  if (!byMeta) return null;

  if (!byMeta.stripe_subscription_id) {
    await admin
      .from("donation_subscriptions")
      .update({ stripe_subscription_id: stripeSubId })
      .eq("id", byMeta.id);
  }
  return byMeta;
}

async function markSubscriptionActive(admin: Any, id: number, periodEnd: string | null) {
  await admin
    .from("donation_subscriptions")
    .update({ status: "active", ...(periodEnd ? { current_period_end: periodEnd } : {}) })
    .eq("id", id)
    .neq("status", "canceled");
}
