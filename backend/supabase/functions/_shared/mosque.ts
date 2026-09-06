// Shared helpers for the mosque payment functions (Stripe Connect direct charges).
import type Stripe from "npm:stripe@16.12.0";
import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export interface MosqueAccount {
  mosque_id: number;
  stripe_account_id: string;
  status: string;
  charges_enabled: boolean;
}

/** The mosque must be approved, donations enabled and its Connect account chargeable. */
export async function loadChargeableMosque(admin: SupabaseClient, mosqueId: number) {
  const { data: mosque } = await admin
    .from("mosques")
    .select("id, name, status, donations_enabled, can_issue_tax_receipts, country_code")
    .eq("id", mosqueId)
    .maybeSingle();
  if (!mosque || mosque.status !== "approved") return { error: "mosque_not_approved" as const };
  if (!mosque.donations_enabled) return { error: "donations_disabled" as const };
  const { data: acct } = await admin
    .from("mosque_stripe_accounts")
    .select("mosque_id, stripe_account_id, status, charges_enabled")
    .eq("mosque_id", mosqueId)
    .maybeSingle();
  if (!acct || !acct.charges_enabled) return { error: "donations_disabled" as const };
  return { mosque, acct: acct as MosqueAccount };
}

/** Stripe request options targeting the connected account. */
export const onAccount = (acct: MosqueAccount, extra?: Stripe.RequestOptions): Stripe.RequestOptions => ({
  stripeAccount: acct.stripe_account_id,
  ...(extra ?? {}),
});

/** Statement descriptor suffix (max 22 chars, letters/digits/spaces). */
export function descriptorSuffix(name: string): string {
  return name.normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/[^A-Za-z0-9 ]/g, "").trim().slice(0, 22) || "DON";
}
