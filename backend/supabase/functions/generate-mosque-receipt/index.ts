// =============================================================================
// generate-mosque-receipt — multi-country document generation.
// See docs/TAX_RECEIPTS_MULTI_COUNTRY.md
//
//   { transactionId }                      -> document for one gift
//   { mosqueId, year, userId? }            -> yearly recap
//   { ..., kind: 'tax_receipt'
//        | 'donation_attestation' }        -> default: tax_receipt
//
// This file owns authorisation, the legal gates, numbering, storage and
// persistence. It owns NO country-specific wording: that lives in
// renderers/<cc>.ts, and a country without a renderer produces nothing at all.
// =============================================================================

import { corsHeaders } from "../_shared/cors.ts";
import { serviceClient, userClient } from "../_shared/supabase.ts";
import { json } from "../_shared/stripe.ts";
import { pickRenderer } from "./renderers/registry.ts";
import type { Donor, Gift, Issuer, ReceiptContext, ReceiptKind, RegimeInfo } from "./renderers/types.ts";

interface Payload {
  transactionId?: number;
  mosqueId?: number;
  year?: number;
  userId?: string;
  kind?: ReceiptKind;
}

const BUCKET = "mosque-receipts";
const SIGNED_URL_TTL = 3600;

const isTaxReceipt = (k: ReceiptKind) => k === "tax_receipt";

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

  const kind: ReceiptKind = payload.kind === "donation_attestation" ? "donation_attestation" : "tax_receipt";
  const admin = serviceClient();

  // ── 1. Resolve the scope ──────────────────────────────────────────────────
  let mosqueId: number;
  let donorId: string;
  let year: number;
  let txIds: number[] = [];

  if (payload.transactionId) {
    const { data: tx } = await admin
      .from("transactions")
      .select("id, user_id, mosque_id, status, created_at, is_anonymous")
      .eq("id", payload.transactionId)
      .maybeSingle();
    if (!tx || !tx.mosque_id || tx.status !== "succeeded") return json({ error: "not_found" }, 404);
    mosqueId = tx.mosque_id;
    donorId = tx.user_id;
    year = new Date(tx.created_at).getFullYear();
    txIds = [tx.id];
    // Anonymity protects the donor from the mosque, not from the tax authority:
    // the donor may always ask for their own document, an admin may not.
    if (tx.is_anonymous && donorId !== me.id) return json({ error: "donor_anonymous" }, 403);
  } else if (payload.mosqueId && payload.year) {
    mosqueId = payload.mosqueId;
    year = payload.year;
    donorId = payload.userId ?? me.id;
  } else {
    return json({ error: "bad_request" }, 400);
  }

  // ── 2. Authorisation ──────────────────────────────────────────────────────
  const { data: isAdmin } = await user.rpc("is_mosque_admin", { p_mosque_id: mosqueId });
  const callerIsAdmin = isAdmin === true;
  if (donorId !== me.id && !callerIsAdmin) return json({ error: "forbidden" }, 403);

  // ── 3. Issuer + regime ────────────────────────────────────────────────────
  const { data: mosque } = await admin
    .from("mosques")
    .select(
      "id, name, legal_name, address_line, postal_code, city, country_code, rna, siren, " +
        "legal_registrations, signatory_name, signatory_role, signature_path, can_issue_tax_receipts",
    )
    .eq("id", mosqueId)
    .single();
  if (!mosque) return json({ error: "not_found" }, 404);

  const country = String(mosque.country_code ?? "FR").toUpperCase();
  const { data: regimeRow } = await admin
    .from("tax_regimes")
    .select("*")
    .eq("country_code", country)
    .maybeSingle();

  // ── 4. Legal gates (fail closed) ──────────────────────────────────────────
  if (isTaxReceipt(kind)) {
    if (!mosque.can_issue_tax_receipts) return json({ error: "receipts_not_allowed" }, 422);
    if (!regimeRow || !regimeRow.supported) {
      return json({ error: "regime_unsupported", country }, 422);
    }
    if (regimeRow.kind !== "receipt") {
      return json({ error: "regime_not_receipt_based", country, regime: regimeRow.kind }, 422);
    }
    if (txIds.length === 0 && year >= new Date().getFullYear()) {
      return json({ error: "year_not_closed", year }, 422);
    }
    if (txIds.length === 1 && regimeRow.annual_only) {
      return json({ error: "annual_only", country }, 422);
    }
  }

  const renderer = pickRenderer(country, kind);
  if (!renderer) return json({ error: "regime_unsupported", country }, 422);

  // ── 5. Idempotency: an existing live document wins ────────────────────────
  const existingQuery = admin
    .from("mosque_receipts")
    .select("id, number, storage_path, amount")
    .eq("kind", kind)
    .is("revoked_at", null);
  const { data: existing } = txIds.length === 1
    ? await existingQuery.eq("transaction_id", txIds[0]).maybeSingle()
    : await existingQuery
      .eq("mosque_id", mosqueId)
      .eq("user_id", donorId)
      .eq("year", year)
      .is("transaction_id", null)
      .maybeSingle();

  // A yearly attestation for the RUNNING year goes stale on the next gift, so
  // it is reissued rather than reused. A tax receipt is never in that case: it
  // is only issuable once the year is closed.
  const stale = existing && !isTaxReceipt(kind) && txIds.length === 0 && year >= new Date().getFullYear();

  if (existing && !stale) {
    const { data: signed } = await admin.storage
      .from(BUCKET)
      .createSignedUrl(existing.storage_path, SIGNED_URL_TTL);
    return json({
      receiptId: existing.id,
      number: existing.number,
      amount: Number(existing.amount),
      kind,
      url: signed?.signedUrl ?? null,
      reused: true,
    });
  }

  if (stale && existing) {
    // Documents are never deleted, only superseded: the number stays burnt.
    await admin
      .from("mosque_receipts")
      .update({ revoked_at: new Date().toISOString(), revoked_reason: "superseded" })
      .eq("id", existing.id);
  }

  // ── 6. Gifts ──────────────────────────────────────────────────────────────
  let q = admin
    .from("transactions")
    .select("id, amount_total, created_at, type, currency")
    .eq("mosque_id", mosqueId)
    .eq("user_id", donorId)
    .eq("status", "succeeded");
  q = txIds.length
    ? q.in("id", txIds)
    : q.gte("created_at", `${year}-01-01`).lt("created_at", `${year + 1}-01-01`);
  const { data: txs } = await q.order("created_at");
  if (!txs || txs.length === 0) return json({ error: "no_donations" }, 404);

  const rows = txs as Array<Record<string, unknown>>;
  const currencies: string[] = [
    ...new Set(rows.map((t) => String(t.currency ?? "EUR").toUpperCase())),
  ];
  if (currencies.length > 1) return json({ error: "mixed_currencies", currencies }, 422);
  const currency: string = currencies[0] ?? "EUR";

  const gifts: Gift[] = rows.map((t) => ({
    date: String(t.created_at),
    amount: Number(t.amount_total),
    type: String(t.type ?? ""),
  }));
  const total = gifts.reduce((s, g) => s + g.amount, 0);

  if (isTaxReceipt(kind) && regimeRow?.min_amount && total < Number(regimeRow.min_amount)) {
    return json({ error: "below_threshold", min: Number(regimeRow.min_amount), currency }, 422);
  }

  // ── 7. Donor identity ─────────────────────────────────────────────────────
  const [{ data: taxProfile }, { data: member }, { data: profile }] = await Promise.all([
    admin.from("donor_tax_profiles").select("*").eq("user_id", donorId).maybeSingle(),
    admin
      .from("mosque_members")
      .select("first_name, last_name, email")
      .eq("mosque_id", mosqueId)
      .eq("user_id", donorId)
      .maybeSingle(),
    admin.from("profiles").select("name").eq("id", donorId).maybeSingle(),
  ]);
  const { data: authUser } = await admin.auth.admin.getUserById(donorId);
  const email = member?.email ?? authUser?.user?.email ?? null;

  const donor: Donor = {
    name: taxProfile?.full_name ??
      (member ? `${member.first_name} ${member.last_name}` : null) ??
      profile?.name ??
      email ??
      "",
    email,
    addressLine: taxProfile?.address_line ?? null,
    postalCode: taxProfile?.postal_code ?? null,
    city: taxProfile?.city ?? null,
    countryCode: taxProfile?.country_code ?? null,
  };

  // ── 8. Issuer, including the signature image ──────────────────────────────
  const registrations: Record<string, string> = {
    ...(mosque.legal_registrations ?? {}),
  };
  if (mosque.rna && !registrations.rna) registrations.rna = mosque.rna;
  if (mosque.siren && !registrations.siren) registrations.siren = mosque.siren;

  let signatureImage: Issuer["signatureImage"] = null;
  if (mosque.signature_path) {
    const { data: blob } = await admin.storage.from("mosque-legal").download(mosque.signature_path);
    if (blob) {
      signatureImage = {
        bytes: new Uint8Array(await blob.arrayBuffer()),
        mime: blob.type || (mosque.signature_path.endsWith(".png") ? "image/png" : "image/jpeg"),
      };
    }
  }

  const issuer: Issuer = {
    id: mosque.id,
    name: mosque.name,
    legalName: mosque.legal_name,
    addressLine: mosque.address_line,
    postalCode: mosque.postal_code,
    city: mosque.city,
    countryCode: country,
    registrations,
    signatoryName: mosque.signatory_name,
    signatoryRole: mosque.signatory_role,
    signatureImage,
  };

  const regime: RegimeInfo = {
    countryCode: country,
    kind: String(regimeRow?.kind ?? "none"),
    templateKey: renderer.templateKey,
    templateVersion: renderer.templateVersion,
    legalRef: regimeRow?.legal_ref ?? null,
    locale: String(regimeRow?.locale ?? "en"),
    currency,
    requiresSignature: Boolean(regimeRow?.requires_signature),
    requiresDonorAddress: Boolean(regimeRow?.requires_donor_address),
  };

  const ctx: ReceiptContext = {
    kind,
    issuer,
    donor,
    gifts,
    total,
    currency,
    year,
    number: "",
    locale: regime.locale,
    regime,
    issuedAt: new Date(),
    single: txIds.length === 1,
  };

  // ── 9. Completeness, before anything is written ───────────────────────────
  const problems = renderer.validate(ctx);
  if (problems.length) {
    const donorSide = problems.filter((p) => p.startsWith("donor:"));
    return json(
      {
        error: donorSide.length === problems.length ? "incomplete_donor_data" : "incomplete_issuer_data",
        fields: problems,
      },
      422,
    );
  }

  // ── 10. Number, render, store, persist ────────────────────────────────────
  const { data: number, error: numErr } = await admin.rpc("fn_next_mosque_receipt_number", {
    p_mosque_id: mosqueId,
    p_year: year,
  });
  if (numErr || !number) return json({ error: "db_error", detail: numErr?.message }, 500);
  ctx.number = String(number);

  let bytes: Uint8Array;
  try {
    bytes = await renderer.render(ctx);
  } catch (e) {
    return json({ error: "render_failed", detail: String(e) }, 500);
  }

  const path = `${mosqueId}/${donorId}/${ctx.number}.pdf`;
  const { error: upErr } = await admin.storage
    .from(BUCKET)
    .upload(path, bytes, { contentType: "application/pdf", upsert: true });
  if (upErr) return json({ error: "storage_error", detail: upErr.message }, 500);

  const { data: receipt, error: rErr } = await admin
    .from("mosque_receipts")
    .insert({
      mosque_id: mosqueId,
      user_id: donorId,
      transaction_id: txIds.length === 1 ? txIds[0] : null,
      year,
      number: ctx.number,
      amount: total,
      currency,
      storage_path: path,
      kind,
      country_code: country,
      template_key: renderer.templateKey,
      template_version: renderer.templateVersion,
      issuer_snapshot: {
        legal_name: issuer.legalName,
        address_line: issuer.addressLine,
        postal_code: issuer.postalCode,
        city: issuer.city,
        registrations,
        signatory_name: issuer.signatoryName,
        signatory_role: issuer.signatoryRole,
        legal_ref: regime.legalRef,
      },
    })
    .select("id")
    .single();

  if (rErr) {
    // Never leave an unreferenced document behind.
    await admin.storage.from(BUCKET).remove([path]);
    return json({ error: "db_error", detail: rErr.message }, 500);
  }

  const { data: signed } = await admin.storage.from(BUCKET).createSignedUrl(path, SIGNED_URL_TTL);
  return json({
    receiptId: receipt.id,
    number: ctx.number,
    amount: total,
    currency,
    kind,
    url: signed?.signedUrl ?? null,
  });
});
