// =============================================================================
// Renderer contract — see docs/TAX_RECEIPTS_MULTI_COUNTRY.md §5
//
// A tax receipt is a national legal regime, not a template. Each country that
// Nour supports ships ONE renderer implementing this interface, and the country
// is wired in exactly one place (registry.ts). A country without a renderer
// produces no tax document at all: there is deliberately no generic fallback,
// because a French-looking PDF handed to a German donor is worse than nothing.
// =============================================================================

export type ReceiptKind = "tax_receipt" | "donation_attestation";

export interface Gift {
  date: string;   // ISO
  amount: number;
  type: string;   // mosque_sadaqa | mosque_campaign | mosque_membership | …
}

export interface IssuerImage {
  bytes: Uint8Array;
  mime: string;
}

export interface Issuer {
  id: number;
  name: string;
  legalName: string | null;
  addressLine: string | null;
  postalCode: string | null;
  city: string | null;
  countryCode: string;
  /** Per-country legal identifiers: { rna, siren } | { charity_number } | … */
  registrations: Record<string, string>;
  signatoryName: string | null;
  signatoryRole: string | null;
  signatureImage: IssuerImage | null;
}

export interface Donor {
  name: string;
  email: string | null;
  addressLine: string | null;
  postalCode: string | null;
  city: string | null;
  countryCode: string | null;
}

export interface RegimeInfo {
  countryCode: string;
  kind: string;
  templateKey: string;
  templateVersion: string;
  legalRef: string | null;
  locale: string;
  currency: string;
  requiresSignature: boolean;
  requiresDonorAddress: boolean;
}

export interface ReceiptContext {
  kind: ReceiptKind;
  issuer: Issuer;
  donor: Donor;
  gifts: Gift[];
  total: number;
  currency: string;
  year: number;
  number: string;
  locale: string;
  regime: RegimeInfo;
  issuedAt: Date;
  /** true when the document covers a single gift, false for a yearly recap */
  single: boolean;
}

export interface Renderer {
  templateKey: string;
  templateVersion: string;
  /**
   * Returns the list of missing/invalid inputs, prefixed `issuer:` or `donor:`.
   * An empty array means the document can be produced. Never throws.
   */
  validate(ctx: ReceiptContext): string[];
  render(ctx: ReceiptContext): Promise<Uint8Array>;
}
