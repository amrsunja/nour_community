# Tax receipts — multi-country design & implementation

Status: **implemented (V1 = France only)**
Owner: payments / mosques module
Supersedes: the "Tax receipts" paragraphs of `MOSQUES_MODULE_IMPLEMENTATION.md` §10.4 and §15.

---

## 0. TL;DR for a reviewer

* A tax receipt is **not a PDF template, it is a national legal regime**. The regime decides who may
  issue, what must be on the document, what the thresholds are, and sometimes whether a receipt
  exists at all (UK Gift Aid has none).
* Therefore: one **regime registry** row per country (`public.tax_regimes`) and one **renderer
  plugin** per country in the edge function. **No renderer ⇒ no document.** There is deliberately no
  generic fallback template, because a French-looking PDF handed to a German donor is worse than no
  document at all.
* `mosques.can_issue_tax_receipts` is now a **protected column**. It can only move through
  `public.fn_mosque_set_tax_receipts()`, which validates the country regime, the issuer's legal
  identifiers and signatory, and writes an immutable audit row.
* Every issued document records the template key + version + a snapshot of the issuer, so a receipt
  issued in 2026 can still be explained in 2030 after the official form has changed.
* Documents come in two kinds. `tax_receipt` is the real thing and is gated. `donation_attestation`
  is a neutral proof-of-gift, carries an explicit "no tax relief" disclaimer, and is available in
  every country. Mosques outside a supported regime get the attestation instead of a dead button.

---

## 1. Why the previous implementation was unsafe

| # | Problem | Consequence |
|---|---|---|
| 1 | `can_issue_tax_receipts` was writable by any mosque admin (RLS `mosques_admin_update`, and the column was absent from `fn_mosques_guard_columns`) | Any mosque could grant itself the right to issue French tax documents with one HTTP call |
| 2 | The flag was only settable from `MosqueAdminStripePage`, and only while `!acct.hasAccount` | Once onboarded, the switch vanished — no way back through the UI |
| 3 | No policy on `storage.objects` for the private `mosque-receipts` bucket | `receiptUrl()` signs with the *user* client ⇒ 403 on every receipt open |
| 4 | Receipt number computed as `count(*) + 1` in the edge function | Collides on `unique (mosque_id, number)` during the admin's yearly batch |
| 5 | Yearly recap not deduplicated | The same year could be issued repeatedly under different numbers |
| 6 | Hardcoded French template, `€`, `art. 200 CGI`, French wording, for every `country_code` | A mosque in DE/GB/US would receive a legally void document that *looks* official |
| 7 | No signature block | FR requires the signature of an authorised person — every receipt was formally irregular |
| 8 | "Amount in words" printed digits (`${total.toFixed(2)} euros`) | Another mandatory mention missing |
| 9 | No donor address anywhere in the schema | FR requires the donor's name **and address** |
| 10 | No trace of who declared the right, when, under which legal text | Nothing to show a tax inspector |

Legal exposure: an irregular receipt is fined under **CGI art. 1740 A** (the amount of the tax
reduction wrongly obtained by the donor), and the PDF footer says
`document généré par Nour pour le compte de <mosque>`.

---

## 2. Country regimes

Data below drives `public.tax_regimes`. **`supported = true` is only ever set after a local
accountant or lawyer has signed off on the concrete template.** Nothing here is legal advice.

| Country | `kind` | Legal basis | Issuer eligibility | Notable constraint | V1 |
|---|---|---|---|---|---|
| **FR** | `receipt` | CGI art. 200 / 238 bis / 978 | Self-declared, association 1901 / 1905, RNA (`W` + 9 digits) or SIREN | Own layout allowed if every mandatory mention is present ("le contenu prime sur la forme"); current official model is **CERFA 11580\*05** (a.k.a. 2041-RD). Signature of an authorised person is mandatory. Annual declaration of totals via **form 2070-SD**, within 3 months of year end (31 Dec for calendar years) | ✅ supported |
| **BE** | `receipt` | CIR 92 art. 145/33 | Agrément SPF Finances | Minimum 40 €/year; the association files the data with the tax authority | ⛔ registry row only |
| **DE** | `receipt` | § 10b EStG, § 50 EStDV | Freistellungsbescheid; listed in the **Zuwendungsempfängerregister** (BZSt, live since 2024) | The official **Muster is binding** — deviating from it voids the confirmation. Simplified proof below 300 €. Strong push toward electronic confirmations via BZSt | ⛔ registry row only |
| **NL** | `receipt` | ANBI | ANBI registration | Periodic gift agreements have their own form | ⛔ registry row only |
| **GB** | `reclaim_by_charity` | Gift Aid | HMRC-recognised charity | **There is no donor receipt.** The donor signs a Gift Aid Declaration and HMRC pays +25 % to the charity. Issuing a "receipt" would be meaningless. Needs its own feature (declaration capture at checkout + Charities Online CSV) | ⛔ blocked by design |
| **US** | `receipt` | IRC 170, IRS Pub. 1771 | 501(c)(3), EIN | Written acknowledgement mandatory from **$250**; must state that no goods or services were provided | ⛔ registry row only |
| **CA** | `receipt` | ITA 118.1 | CRA registered charity, registration number | Mandatory CRA wording + the canada.ca URL | ⛔ registry row only |
| everything else | `none` | — | — | Attestation only | ⛔ |

`kind = 'reclaim_by_charity'` and `kind = 'none'` can **never** produce a `tax_receipt`, regardless of
`supported`. This is enforced in `fn_mosque_set_tax_receipts` and again in the edge function.

---

## 3. Data model

### 3.1 `public.tax_regimes` — one row per country

| Column | Purpose |
|---|---|
| `country_code` (PK) | ISO 3166-1 alpha-2, upper case |
| `kind` | `receipt` / `reclaim_by_charity` / `none` |
| `supported` | a renderer exists **and** the template was legally validated |
| `template_key`, `template_version` | e.g. `fr-cerfa-11580-05`, `05` — copied onto every issued document |
| `legal_ref` | printed on the document and shown in the admin UI |
| `locale`, `currency` | language of the legal wording, expected currency |
| `required_fields` | `text[]` of `mosques` columns that must be non-empty to enable the right |
| `required_ids` | `jsonb` — `[{"any_of":["rna","siren"],"patterns":{"rna":"^W\\d{9}$"}}]` |
| `requires_signature` | blocks enabling until a signatory name **and** a signature image exist |
| `requires_donor_address` | renderer refuses without the donor's postal address |
| `min_amount` | threshold below which no receipt is issued (US: 250) |
| `annual_only` | per-gift receipts disabled, yearly recap only |
| `verifiable_registry` | `bzst` / `irs_teos` / `null` — hook for future automated eligibility checks |

Read: any authenticated user (the app shows regime state). Write: Nour admin only.

### 3.2 `mosques` — new columns

| Column | Notes |
|---|---|
| `legal_registrations jsonb` | generic per-country identifiers: FR `{"rna":"W751234567","siren":"…"}`, DE `{"vereinsregister":"VR 12345 B"}`, GB `{"charity_number":"…"}`, US `{"ein":"…"}`. Backfilled from `rna`/`siren`. **Protected column.** |
| `signatory_name`, `signatory_role` | printed under the signature. Editable by the mosque admin. |
| `signature_path` | object path in the private `mosque-legal` bucket. Editable by the mosque admin. |

`can_issue_tax_receipts` joins `rna`, `siren`, `legal_status`, `donations_enabled`, … in the
protected list of `fn_mosques_guard_columns`.

### 3.3 `public.mosque_tax_declarations` — audit, append-only

One row per toggle, both directions: `mosque_id`, `user_id` (who declared), `enabled`,
`country_code`, `template_key`, `template_version`, `legal_ref`, `declaration_text_version`,
snapshot of `legal_name` / `legal_registrations` / signatory, `created_at`.
No client INSERT/UPDATE/DELETE — only the RPC writes here.

### 3.4 `public.donor_tax_profiles` — the donor's fiscal identity

FR (and most `receipt` regimes) require the donor's **name and postal address**, which the app never
collected. `donor_tax_profiles(user_id PK, full_name, address_line, postal_code, city,
country_code)` is filled by the donor once, on their own row, RLS `user_id = auth.uid()`.
Mosque admins never read it directly; the edge function (service role) does.

Resolution order for the donor block: `donor_tax_profiles` → `mosque_members`
(first/last name, email) → `profiles.name` → auth email. If the regime requires an address and none
is found, generation fails with `incomplete_donor_data` and the field list, so the UI can tell the
donor exactly what to complete.

### 3.5 `public.mosque_receipts` — new columns

`kind` (`tax_receipt` | `donation_attestation`), `country_code`, `template_key`,
`template_version`, `currency`, `issuer_snapshot jsonb`, `revoked_at`, `revoked_reason`.

Documents are **never deleted**: a wrong receipt is revoked, keeping the number burnt. Numbering is
sequential per `(mosque_id, year)` and must not have holes that look like destroyed evidence.

### 3.6 `public.mosque_receipt_counters` — atomic numbering

`(mosque_id, year) → seq`, incremented by `fn_next_mosque_receipt_number()` with an
`insert … on conflict do update … returning`. Backfilled from existing rows on migration.

---

## 4. Enabling the right — `fn_mosque_set_tax_receipts`

`security definer`, the **only** writer of `can_issue_tax_receipts`.

```
fn_mosque_set_tax_receipts(p_mosque_id, p_enabled, p_declaration_version) → boolean
```

Enabling runs, in order:

1. caller is `is_mosque_admin(p_mosque_id)` or `is_admin()` — else `forbidden`
2. regime row exists and `supported` — else `regime_unsupported`
3. `regime.kind = 'receipt'` — else `regime_not_receipt_based` (this is what stops GB)
4. `mosques.status = 'approved'` — else `mosque_not_approved`
5. every `regime.required_fields` column non-empty — else `missing_field:<name>`
6. at least one `required_ids.any_of` identifier present, matching its pattern — else
   `legal_id_missing` / `legal_id_invalid:<key>`
7. if `regime.requires_signature`: `signatory_name` and `signature_path` present — else
   `signatory_missing`

Then, in one transaction: set the flag (via `set_config('nour.trusted','on',true)` so the guard lets
it through), and on **disable** also clear `show_tax_badge` on `mosque_donation_settings`,
`mosque_campaign_settings` and every campaign — a mosque must never advertise "-66 %" it cannot back
with a document. Finally insert the audit row.

`required_ids` / `required_fields` live in data, so tightening a country's requirements is an
`update` on one row, not a deploy.

---

## 5. Document generation — `generate-mosque-receipt`

```
generate-mosque-receipt/
├── index.ts               orchestration: authz, scope, gates, storage, numbering, persistence
└── renderers/
    ├── types.ts           ReceiptContext + Renderer contract
    ├── pdf_kit.ts         shared drawing helpers, money, amount-in-words (fr/en)
    ├── registry.ts        country → renderer. THE only place a country is wired in
    ├── fr.ts              CERFA 11580*05
    └── attestation.ts     neutral, all countries, explicit "no tax relief"
```

### 5.1 Request

```jsonc
{ "transactionId": 123 }                                  // one gift
{ "mosqueId": 7, "year": 2025, "userId": "uuid?" }        // yearly recap
{ ..., "kind": "tax_receipt" | "donation_attestation" }   // default: tax_receipt
```

### 5.2 Gate order (fail closed)

1. authenticated; `donorId === me.id` or `is_mosque_admin(mosqueId)` — else `403 forbidden`
2. existing non-revoked document for the same scope ⇒ return it (idempotent, both per-gift and
   yearly)
3. `kind = 'tax_receipt'` ⇒ `mosques.can_issue_tax_receipts` — else `422 receipts_not_allowed`
4. regime `supported` and `kind = 'receipt'` — else `422 regime_unsupported` /
   `422 regime_not_receipt_based`
5. yearly recap for a year that has not ended — `422 year_not_closed`
6. per-gift receipt while `regime.annual_only` — `422 annual_only`
7. transactions found, all in one currency — else `404 no_donations` / `422 mixed_currencies`
8. total ≥ `regime.min_amount` — else `422 below_threshold`
9. `renderer.validate(ctx)` — else `422 incomplete_issuer_data` / `422 incomplete_donor_data`
   with the missing field names

Only then: number → render → upload → insert. If the insert fails, the uploaded object is removed,
so storage never holds an unreferenced document.

### 5.3 Renderer contract

```ts
interface Renderer {
  templateKey: string;
  templateVersion: string;
  validate(ctx: ReceiptContext): string[];       // missing field names; empty = ok
  render(ctx: ReceiptContext): Promise<Uint8Array>;
}
```

`registry.ts` maps `FR → frCerfa` and nothing else today. `pickRenderer` returns `null` for an
unknown country and the caller turns that into `regime_unsupported`. Adding a country is: write
`renderers/xx.ts`, add one line to the registry, flip one row in `tax_regimes`.

### 5.4 FR renderer — mandatory mentions checklist

| Mention | Source |
|---|---|
| Form reference (CERFA 11580\*05) + articles 200 / 238 bis / 978 CGI | template |
| Receipt order number | `fn_next_mosque_receipt_number` |
| Beneficiary: legal name, address, object, RNA / SIREN | `mosques` + `legal_registrations` |
| Donor: name **and** address | `donor_tax_profiles` |
| Amount in figures **and in words** | `pdf_kit.amountInWords('fr')` |
| Date of payment (or the period + per-gift detail table for a yearly recap) | `transactions` |
| Nature of the gift + means of payment | template |
| Sworn statement of the beneficiary | template |
| **Signature of an authorised person** — image + name + role | `signature_path`, `signatory_name`, `signatory_role` |
| Issuance date | `now()` |

### 5.5 Attestation renderer

Same issuer/donor/amount blocks, none of the tax vocabulary, and a bordered disclaimer in the
document's own locale: *this document is a simple proof of donation and does not give right to any
tax reduction*. Available in every country, no gating beyond "the donation exists".

---

## 6. Reporting — `fn_mosque_tax_year_summary`

Returns `receipts_count`, `donors_count`, `total`, `currency` for a `(mosque, year)`, restricted to
mosque admins, counting non-revoked `tax_receipt` rows only. This is what a French association needs
in order to file **2070-SD**, and it is a real reason for a mosque to keep issuing through Nour
rather than by hand.

---

## 7. Client

### 7.1 Mosque admin

New page **`MosqueAdminTaxSettingsPage`** (`mosque-admin/donations/tax-receipts`), reached from the
fundraising settings. It shows:

* the regime card: country, legal reference, and one of *available* / *not supported in your
  country* / *not receipt-based (Gift Aid)*
* the blocking checklist — legal name, address, identifier, signatory — each row resolved with the
  exact reason the RPC would refuse
* signatory name + role, and the signature image upload (private `mosque-legal` bucket)
* the right toggle, guarded by a **declaration dialog** whose text version is written to the audit
  row
* a link to the receipts list and to the yearly summary

`MosqueAdminStripePage` loses the toggle entirely — the right is a legal attribute, not a payments
one, and coupling it to onboarding is what created the dead end.

### 7.2 Donor

`My donations → Mosques → Receipts` gains self-service: the donor picks a **closed** year for a
mosque they gave to and requests the document. If their fiscal profile is incomplete, a sheet
collects name + address first and stores it in `donor_tax_profiles`.

Anonymous gifts: a mosque admin cannot issue for an anonymous donor (they must not learn who it
was), but the donor can always request their own — anonymity is towards the public, not towards the
tax authority.

---

## 8. Error codes

| Code | Meaning | Surfaced as |
|---|---|---|
| `receipts_not_allowed` | right not enabled for this mosque | existing key |
| `regime_unsupported` | no validated template for this country | "not available in your country yet" |
| `regime_not_receipt_based` | Gift Aid-style regime | "your country uses a different mechanism" |
| `missing_field:<name>` / `legal_id_missing` / `legal_id_invalid:<key>` | issuer data incomplete | checklist row |
| `signatory_missing` | signature not configured | checklist row |
| `incomplete_issuer_data` / `incomplete_donor_data` | caught at render time, with field list | actionable message |
| `year_not_closed` | yearly recap requested during the running year | "available from 1 January" |
| `below_threshold` | under the country minimum | shows the minimum |
| `mixed_currencies` | gifts in several currencies in one year | admin must split |
| `annual_only` | per-gift receipt in a yearly-only regime | — |

---

## 9. Rollout

1. **V1 (this change)** — registry + plugin architecture, FR renderer at CERFA 11580\*05 with
   signature and amount in words, attestation everywhere else, protected column, audit, storage
   policies, atomic numbering, donor fiscal profile, self-service.
2. **V2** — BE, then DE. DE only against the binding § 50 EStDV Muster, plus eligibility checked
   against the BZSt register (`verifiable_registry = 'bzst'`) instead of self-declaration.
3. **V3** — GB Gift Aid as a separate feature: declaration capture at checkout, Charities Online
   export. Never through this function.
4. **V4** — US / CA on demand.

Checklist before flipping any `supported` to `true`:

- [ ] official template obtained and version recorded in `template_version`
- [ ] every mandatory mention mapped to a data source
- [ ] eligibility criterion expressible in `required_fields` / `required_ids`
- [ ] threshold and periodicity encoded (`min_amount`, `annual_only`)
- [ ] wording reviewed by a local accountant or lawyer
- [ ] a rendered sample checked against a real receipt from that country
