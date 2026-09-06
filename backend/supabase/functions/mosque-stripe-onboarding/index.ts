// =============================================================================
// mosque-stripe-onboarding Edge Function (P3 — devis B1)
// -----------------------------------------------------------------------------
//   { mosqueId, action: 'start' | 'status', canIssueTaxReceipts?: boolean }
// start  → creates (or reuses) a Stripe Connect EXPRESS account for the
//          mosque and returns an Account Link URL (hosted onboarding).
// status → refreshes charges/payouts flags from Stripe and updates
//          mosques.donations_enabled accordingly.
// Caller must be an admin of the approved mosque.
// =============================================================================

import { corsHeaders } from "../_shared/cors.ts";
import { serviceClient, userClient } from "../_shared/supabase.ts";
import { json, stripeClient } from "../_shared/stripe.ts";

interface Payload {
  mosqueId: number;
  action: "start" | "status";
  canIssueTaxReceipts?: boolean;
}

const RETURN_URL = Deno.env.get("STRIPE_CONNECT_RETURN_URL") ?? "https://nour-community.com/mosque-admin/stripe/return";
const REFRESH_URL = Deno.env.get("STRIPE_CONNECT_REFRESH_URL") ?? "https://nour-community.com/mosque-admin/stripe/refresh";

function mapStatus(a: { charges_enabled?: boolean; details_submitted?: boolean; requirements?: { disabled_reason?: string | null; currently_due?: string[] } }) {
  if (a.charges_enabled) return "active";
  if (a.requirements?.disabled_reason) return "restricted";
  if (a.details_submitted) return "onboarding";
  return "onboarding";
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "unauthorized" }, 401);
  const user = userClient(authHeader);
  const { data: { user: me } } = await user.auth.getUser();
  if (!me) return json({ error: "unauthorized" }, 401);

  let payload: Payload;
  try {
    payload = (await req.json()) as Payload;
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  if (!Number.isInteger(payload.mosqueId)) return json({ error: "bad_request" }, 400);

  // is_mosque_admin via the caller's JWT.
  const { data: isAdmin } = await user.rpc("is_mosque_admin", { p_mosque_id: payload.mosqueId });
  if (isAdmin !== true) return json({ error: "forbidden" }, 403);

  const admin = serviceClient();
  const stripe = stripeClient();
  const { data: mosque } = await admin
    .from("mosques")
    .select("id, name, email, country_code, status, can_issue_tax_receipts")
    .eq("id", payload.mosqueId)
    .single();
  if (!mosque || mosque.status !== "approved") return json({ error: "mosque_not_approved" }, 403);

  if (typeof payload.canIssueTaxReceipts === "boolean") {
    await admin.from("mosques").update({ can_issue_tax_receipts: payload.canIssueTaxReceipts }).eq("id", mosque.id);
  }

  const { data: existing } = await admin
    .from("mosque_stripe_accounts")
    .select("stripe_account_id, status")
    .eq("mosque_id", mosque.id)
    .maybeSingle();

  let accountId = existing?.stripe_account_id as string | undefined;

  try {
    if (!accountId) {
      const account = await stripe.accounts.create({
        type: "express",
        country: (mosque.country_code ?? "FR").toUpperCase(),
        email: mosque.email ?? me.email ?? undefined,
        business_type: "non_profit",
        capabilities: { card_payments: { requested: true }, transfers: { requested: true } },
        business_profile: { name: mosque.name, mcc: "8661" }, // 8661 = religious organizations
        metadata: { mosque_id: String(mosque.id) },
      });
      accountId = account.id;
      await admin.from("mosque_stripe_accounts").upsert({
        mosque_id: mosque.id,
        stripe_account_id: accountId,
        status: "onboarding",
      });
    }

    if (payload.action === "start") {
      const link = await stripe.accountLinks.create({
        account: accountId,
        type: "account_onboarding",
        return_url: RETURN_URL,
        refresh_url: REFRESH_URL,
      });
      return json({ url: link.url, accountId });
    }

    // status
    const acct = await stripe.accounts.retrieve(accountId);
    const status = mapStatus(acct);
    await admin.from("mosque_stripe_accounts").update({
      status,
      charges_enabled: acct.charges_enabled ?? false,
      payouts_enabled: acct.payouts_enabled ?? false,
      details_submitted: acct.details_submitted ?? false,
      requirements: {
        currently_due: acct.requirements?.currently_due ?? [],
        disabled_reason: acct.requirements?.disabled_reason ?? null,
      },
      onboarded_at: acct.charges_enabled ? new Date().toISOString() : null,
    }).eq("mosque_id", mosque.id);

    // donations_enabled is a protected column: service role bypasses the guard.
    await admin.from("mosques").update({ donations_enabled: acct.charges_enabled === true }).eq("id", mosque.id);
    if (acct.charges_enabled) {
      await admin.from("mosque_donation_settings").upsert({ mosque_id: mosque.id }, { onConflict: "mosque_id", ignoreDuplicates: true });
    }

    let dashboardUrl: string | null = null;
    try {
      const login = await stripe.accounts.createLoginLink(accountId);
      dashboardUrl = login.url;
    } catch (_) { /* express dashboard not available until onboarded */ }

    return json({
      accountId,
      status,
      chargesEnabled: acct.charges_enabled ?? false,
      payoutsEnabled: acct.payouts_enabled ?? false,
      currentlyDue: acct.requirements?.currently_due ?? [],
      dashboardUrl,
    });
  } catch (e) {
    const err = e as { message?: string; code?: string };
    console.error("[mosque-stripe-onboarding]", err?.code, err?.message);
    return json({ error: "stripe_error", code: err?.code ?? null, message: err?.message ?? null }, 502);
  }
});
