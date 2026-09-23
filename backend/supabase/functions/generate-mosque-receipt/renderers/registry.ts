// =============================================================================
// Country -> renderer. THE single place a country becomes issuable.
//
// Adding a country is: write renderers/<cc>.ts, add one line here, flip
// tax_regimes.supported for that country. Nothing else changes.
//
// There is NO fallback on purpose: pickRenderer() returning null makes the
// edge function answer 422 regime_unsupported rather than produce a document
// whose legal wording belongs to another jurisdiction.
// =============================================================================

import type { ReceiptKind, Renderer } from "./types.ts";
import { frCerfa } from "./fr.ts";
import { attestation } from "./attestation.ts";

const TAX_RENDERERS: Record<string, Renderer> = {
  FR: frCerfa,
  // BE: beRenderer,   <- V2, only once the template is validated locally
  // DE: deMuster,     <- V2, MUST follow the binding Par. 50 EStDV Muster
  // GB: never — Gift Aid has no donor receipt (see docs §2)
};

export function pickRenderer(countryCode: string, kind: ReceiptKind): Renderer | null {
  if (kind === "donation_attestation") return attestation;
  return TAX_RENDERERS[(countryCode ?? "").toUpperCase()] ?? null;
}

export function supportedTaxCountries(): string[] {
  return Object.keys(TAX_RENDERERS);
}
