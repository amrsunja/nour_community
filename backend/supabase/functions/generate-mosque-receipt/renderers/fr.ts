// =============================================================================
// France — recu au titre des dons, modele CERFA 11580*05 (ref. 2041-RD).
//
// The official form is not strictly mandatory: an association may issue its own
// document provided every mandatory mention is present ("le contenu prime sur
// la forme"). This renderer reproduces the structure of the form and carries
// each mention explicitly, including the two the previous implementation was
// missing: the amount in words and the signature of an authorised person.
//
// Legal basis: CGI art. 200 (individuals), 238 bis (companies), 978 (IFI).
// An irregular receipt is fined under CGI art. 1740 A.
// =============================================================================

import { PDFDocument, StandardFonts } from "npm:pdf-lib@1.17.1";
import type { ReceiptContext, Renderer } from "./types.ts";
import {
  amountInWords,
  Cursor,
  drawWrapped,
  embedSignature,
  formatDate,
  formatMoney,
  INK,
  MUTED,
  PAGE,
  winAnsi,
  winAnsiOr,
} from "./pdf_kit.ts";

const LOCALE = "fr-FR";

export const frCerfa: Renderer = {
  templateKey: "fr-cerfa-11580-05",
  templateVersion: "05",

  validate(ctx: ReceiptContext): string[] {
    const missing: string[] = [];
    const i = ctx.issuer;
    const d = ctx.donor;

    if (!winAnsi(i.legalName ?? i.name)) missing.push("issuer:legal_name");
    if (!i.addressLine) missing.push("issuer:address_line");
    if (!i.postalCode) missing.push("issuer:postal_code");
    if (!i.city) missing.push("issuer:city");
    if (!i.registrations.rna && !i.registrations.siren) missing.push("issuer:legal_id");
    if (!i.signatoryName) missing.push("issuer:signatory_name");
    if (!i.signatureImage) missing.push("issuer:signature");

    if (!winAnsi(d.name)) missing.push("donor:full_name");
    if (!d.addressLine) missing.push("donor:address_line");
    if (!d.postalCode) missing.push("donor:postal_code");
    if (!d.city) missing.push("donor:city");

    if (ctx.currency.toUpperCase() !== "EUR") missing.push("currency:eur_expected");
    return missing;
  },

  async render(ctx: ReceiptContext): Promise<Uint8Array> {
    const pdf = await PDFDocument.create();
    const page = pdf.addPage([PAGE.width, PAGE.height]);
    const font = await pdf.embedFont(StandardFonts.Helvetica);
    const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
    const c = new Cursor(page, font, bold);

    pdf.setTitle(`Reçu fiscal ${ctx.number}`);
    pdf.setSubject("Reçu au titre des dons à certains organismes d'intérêt général");
    pdf.setProducer("Nour");
    pdf.setCreationDate(ctx.issuedAt);

    const i = ctx.issuer;
    const d = ctx.donor;
    const issuerName = winAnsiOr(i.legalName ?? i.name, `Association ${i.id}`);

    // ── Header ──────────────────────────────────────────────────────────────
    c.text("REÇU AU TITRE DES DONS", { size: 16, bold: true, gap: 3 });
    c.text("à certains organismes d'intérêt général", { size: 10, color: MUTED, gap: 2 });
    c.text("articles 200, 238 bis et 978 du code général des impôts (CGI)", { size: 8.5, color: MUTED });
    c.text(`Modèle CERFA n° 11580*${frCerfa.templateVersion} (2041-RD)`, { size: 8, color: MUTED });
    c.space(4);
    c.rule();

    c.text(`Numéro d'ordre du reçu : ${ctx.number}`, { size: 11, bold: true });
    c.space(2);

    // ── Beneficiary ─────────────────────────────────────────────────────────
    c.section("Bénéficiaire des versements");
    c.text(issuerName, { size: 11, bold: true });
    const address = [i.addressLine, [i.postalCode, i.city].filter(Boolean).join(" ")]
      .filter(Boolean)
      .join(", ");
    if (address) c.text(address);
    if (i.registrations.rna) c.text(`RNA : ${i.registrations.rna}`);
    if (i.registrations.siren) c.text(`SIREN : ${i.registrations.siren}`);
    c.text("Objet : association cultuelle — exercice du culte musulman", { size: 9.5, color: MUTED });
    c.paragraph(
      "Cocher la case concernée : association cultuelle ou de bienfaisance et établissement public " +
        "des cultes reconnus d'Alsace-Moselle (article 200-1-e du CGI) / organisme d'intérêt général " +
        "(article 200-1-b du CGI).",
      { color: MUTED },
    );

    // ── Donor ───────────────────────────────────────────────────────────────
    c.section("Donateur");
    c.text(winAnsiOr(d.name, "Donateur"), { size: 11, bold: true });
    const donorAddress = [d.addressLine, [d.postalCode, d.city].filter(Boolean).join(" ")]
      .filter(Boolean)
      .join(", ");
    if (donorAddress) c.text(donorAddress);
    if (d.email) c.text(d.email, { size: 9, color: MUTED });

    // ── Gift ────────────────────────────────────────────────────────────────
    c.section("Versements");
    c.paragraph(
      "Le bénéficiaire reconnaît avoir reçu au titre des dons et versements ouvrant droit à " +
        "réduction d'impôt la somme de :",
      { size: 9.5, color: INK },
    );
    c.space(2);
    c.text(formatMoney(ctx.total, ctx.currency, LOCALE), { size: 15, bold: true, gap: 4 });
    c.text(`Somme en toutes lettres : ${amountInWords(ctx.total, ctx.currency, LOCALE)}.`, { size: 9.5 });
    c.text(
      ctx.single
        ? `Date du versement : ${formatDate(ctx.gifts[0].date, LOCALE)}`
        : `Période : année ${ctx.year} — ${ctx.gifts.length} versement(s)`,
      { size: 9.5 },
    );
    c.text("Forme du don : acte authentique / acte sous seing privé / déclaration de don manuel : don manuel", { size: 9 });
    c.text("Nature du don : numéraire", { size: 9 });
    c.text("Mode de versement : carte bancaire (paiement en ligne)", { size: 9 });

    if (!ctx.single && ctx.gifts.length > 1) {
      c.space(6);
      c.text("Détail des versements", { size: 9.5, bold: true, gap: 4 });
      const shown = ctx.gifts.slice(0, 24);
      for (const g of shown) {
        c.text(
          `${formatDate(g.date, LOCALE)}    ${formatMoney(g.amount, ctx.currency, LOCALE)}`,
          { size: 8.5, color: MUTED, gap: 2 },
        );
      }
      if (ctx.gifts.length > shown.length) {
        c.text(`… et ${ctx.gifts.length - shown.length} autre(s) versement(s).`, {
          size: 8.5,
          color: MUTED,
        });
      }
    }

    // ── Sworn statement ─────────────────────────────────────────────────────
    c.space(6);
    c.rule(12);
    c.paragraph(
      "Le bénéficiaire certifie sur l'honneur que les dons et versements qu'il reçoit ouvrent droit " +
        "à la réduction d'impôt prévue à l'article 200 du CGI. La réduction d'impôt est égale à 66 % " +
        "du montant des versements, retenus dans la limite de 20 % du revenu imposable.",
      { size: 8.5, color: INK },
    );

    // ── Signature ───────────────────────────────────────────────────────────
    const sig = await embedSignature(pdf, i.signatureImage);
    const signatureTop = Math.max(c.y - 10, 150);
    page.drawText(winAnsi(`Fait le ${formatDate(ctx.issuedAt, LOCALE)}`), {
      x: PAGE.margin,
      y: signatureTop,
      size: 9,
      font,
      color: INK,
    });
    const sigX = PAGE.width - PAGE.margin - 190;
    page.drawText(winAnsi("Signature de la personne habilitée"), {
      x: sigX,
      y: signatureTop,
      size: 9,
      font,
      color: MUTED,
    });
    if (sig) {
      const scale = Math.min(170 / sig.width, 56 / sig.height);
      page.drawImage(sig, {
        x: sigX,
        y: signatureTop - 66,
        width: sig.width * scale,
        height: sig.height * scale,
      });
    }
    page.drawText(winAnsi(i.signatoryName ?? ""), {
      x: sigX,
      y: signatureTop - 80,
      size: 9.5,
      font: bold,
      color: INK,
    });
    if (i.signatoryRole) {
      page.drawText(winAnsi(i.signatoryRole), {
        x: sigX,
        y: signatureTop - 93,
        size: 8.5,
        font,
        color: MUTED,
      });
    }

    // ── Footer (wrapped: a long legal name must not run off the page) ───────
    const footerWidth = PAGE.width - PAGE.margin * 2;
    let fy = drawWrapped(
      page,
      font,
      `Document généré par Nour pour le compte de ${issuerName}. ` +
        "La responsabilité de l'émission de ce reçu incombe à l'association bénéficiaire. " +
        "Le fait de délivrer sciemment un document irrégulier est sanctionné par l'article 1740 A du CGI.",
      { x: PAGE.margin, y: 62, width: footerWidth, size: 7.5, color: MUTED },
    );
    page.drawText(winAnsi(`${frCerfa.templateKey} - ${ctx.number}`), {
      x: PAGE.margin,
      y: Math.max(fy, 26),
      size: 7,
      font,
      color: MUTED,
    });

    return await pdf.save();
  },
};
