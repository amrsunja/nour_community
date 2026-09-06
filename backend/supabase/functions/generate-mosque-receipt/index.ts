// =============================================================================
// generate-mosque-receipt Edge Function (P3 — devis B5)
// -----------------------------------------------------------------------------
//   { transactionId }                 → receipt for one gift (donor or mosque admin)
//   { mosqueId, year, userId? }       → annual recap (admin: any donor; donor: self)
// Produces a PDF (pdf-lib) in the private bucket mosque-receipts/<mosque>/<user>/
// and returns a 1-hour signed URL. Refused when mosques.can_issue_tax_receipts
// is false (legal responsibility stays with the mosque — devis §7).
// =============================================================================

import { PDFDocument, StandardFonts, rgb } from "npm:pdf-lib@1.17.1";
import { corsHeaders } from "../_shared/cors.ts";
import { serviceClient, userClient } from "../_shared/supabase.ts";
import { json } from "../_shared/stripe.ts";

interface Payload {
  transactionId?: number;
  mosqueId?: number;
  year?: number;
  userId?: string;
}

const money = (n: number) => `${n.toFixed(2).replace(".", ",")} €`;

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
  const admin = serviceClient();

  // Resolve scope.
  let mosqueId: number;
  let donorId: string;
  let year: number;
  let txIds: number[] = [];
  if (payload.transactionId) {
    const { data: tx } = await admin.from("transactions").select("id, user_id, mosque_id, status, created_at").eq("id", payload.transactionId).maybeSingle();
    if (!tx || !tx.mosque_id || tx.status !== "succeeded") return json({ error: "not_found" }, 404);
    mosqueId = tx.mosque_id;
    donorId = tx.user_id;
    year = new Date(tx.created_at).getFullYear();
    txIds = [tx.id];
  } else if (payload.mosqueId && payload.year) {
    mosqueId = payload.mosqueId;
    year = payload.year;
    donorId = payload.userId ?? me.id;
  } else {
    return json({ error: "bad_request" }, 400);
  }

  const { data: isAdmin } = await user.rpc("is_mosque_admin", { p_mosque_id: mosqueId });
  if (donorId !== me.id && isAdmin !== true) return json({ error: "forbidden" }, 403);

  const { data: mosque } = await admin.from("mosques").select("id, name, legal_name, address_line, postal_code, city, rna, siren, can_issue_tax_receipts").eq("id", mosqueId).single();
  if (!mosque) return json({ error: "not_found" }, 404);
  if (!mosque.can_issue_tax_receipts) return json({ error: "receipts_not_allowed" }, 422);

  let q = admin.from("transactions").select("id, amount_total, created_at, type").eq("mosque_id", mosqueId).eq("user_id", donorId).eq("status", "succeeded");
  q = txIds.length ? q.in("id", txIds) : q.gte("created_at", `${year}-01-01`).lt("created_at", `${year + 1}-01-01`);
  const { data: txs } = await q.order("created_at");
  if (!txs || txs.length === 0) return json({ error: "no_donations" }, 404);
  const total = txs.reduce((s, t) => s + Number(t.amount_total), 0);

  // Existing receipt for a single tx → reuse.
  if (txIds.length === 1) {
    const { data: existing } = await admin.from("mosque_receipts").select("id, storage_path").eq("transaction_id", txIds[0]).maybeSingle();
    if (existing) {
      const { data: signed } = await admin.storage.from("mosque-receipts").createSignedUrl(existing.storage_path, 3600);
      return json({ receiptId: existing.id, url: signed?.signedUrl ?? null, amount: total });
    }
  }

  const { data: donor } = await admin.from("profiles").select("name").eq("id", donorId).maybeSingle();
  const { data: member } = await admin.from("mosque_members").select("first_name, last_name, email").eq("mosque_id", mosqueId).eq("user_id", donorId).maybeSingle();
  const { data: authUser } = await admin.auth.admin.getUserById(donorId);
  const donorName = member ? `${member.first_name} ${member.last_name}` : donor?.name ?? authUser?.user?.email ?? "Donateur";

  // Receipt number: <mosque>-<year>-<seq>
  const { count } = await admin.from("mosque_receipts").select("id", { count: "exact", head: true }).eq("mosque_id", mosqueId).eq("year", year);
  const number = `${mosqueId}-${year}-${String((count ?? 0) + 1).padStart(4, "0")}`;

  // PDF
  const pdf = await PDFDocument.create();
  const page = pdf.addPage([595, 842]);
  const font = await pdf.embedFont(StandardFonts.Helvetica);
  const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
  let y = 790;
  const line = (text: string, size = 11, f = font, color = rgb(0.1, 0.1, 0.1)) => {
    page.drawText(text, { x: 50, y, size, font: f, color });
    y -= size + 8;
  };
  line("REÇU AU TITRE DES DONS", 18, bold);
  line("à certains organismes d'intérêt général (articles 200, 238 bis et 978 du CGI)", 9);
  y -= 10;
  line(`Numéro d'ordre du reçu : ${number}`, 11, bold);
  y -= 10;
  line("BÉNÉFICIAIRE", 12, bold);
  line(mosque.legal_name ?? mosque.name);
  line([mosque.address_line, [mosque.postal_code, mosque.city].filter(Boolean).join(" ")].filter(Boolean).join(", "));
  if (mosque.rna) line(`RNA : ${mosque.rna}`);
  if (mosque.siren) line(`SIREN : ${mosque.siren}`);
  line("Objet : association cultuelle / d'intérêt général — culte musulman", 10);
  y -= 10;
  line("DONATEUR", 12, bold);
  line(donorName);
  if (member?.email ?? authUser?.user?.email) line(member?.email ?? authUser?.user?.email ?? "");
  y -= 10;
  line(`Le bénéficiaire reconnaît avoir reçu au titre des dons et versements ouvrant droit à réduction d'impôt`, 10);
  line(`la somme de : ${money(total)}`, 14, bold);
  line(`Somme en toutes lettres : ${total.toFixed(2)} euros`, 10);
  line(txIds.length === 1 ? `Date du versement : ${new Date(txs[0].created_at).toLocaleDateString("fr-FR")}` : `Période : année ${year} (${txs.length} versement(s))`, 10);
  line("Nature du don : numéraire — Mode de versement : carte bancaire / paiement en ligne", 10);
  line("Le bénéficiaire certifie sur l'honneur que les dons et versements qu'il reçoit ouvrent droit à la réduction d'impôt", 9);
  line("prévue à l'article 200 du CGI (66 % du montant dans la limite de 20 % du revenu imposable).", 9);
  y -= 20;
  if (txIds.length > 1) {
    line("Détail des versements", 11, bold);
    for (const t of txs) line(`${new Date(t.created_at).toLocaleDateString("fr-FR")}    ${money(Number(t.amount_total))}    ${t.type}`, 9);
  }
  y = 80;
  line(`Fait le ${new Date().toLocaleDateString("fr-FR")} — document généré par Nour pour le compte de ${mosque.name}.`, 8, font, rgb(0.4, 0.4, 0.4));
  line("La responsabilité de l'émission de ce reçu incombe à l'association bénéficiaire.", 8, font, rgb(0.4, 0.4, 0.4));

  const bytes = await pdf.save();
  const path = `${mosqueId}/${donorId}/${number}.pdf`;
  const { error: upErr } = await admin.storage.from("mosque-receipts").upload(path, bytes, { contentType: "application/pdf", upsert: true });
  if (upErr) return json({ error: "storage_error", detail: upErr.message }, 500);

  const { data: receipt, error: rErr } = await admin
    .from("mosque_receipts")
    .insert({ mosque_id: mosqueId, user_id: donorId, transaction_id: txIds.length === 1 ? txIds[0] : null, year, number, amount: total, storage_path: path })
    .select("id")
    .single();
  if (rErr) return json({ error: "db_error", detail: rErr.message }, 500);

  const { data: signed } = await admin.storage.from("mosque-receipts").createSignedUrl(path, 3600);
  return json({ receiptId: receipt.id, number, amount: total, url: signed?.signedUrl ?? null });
});
