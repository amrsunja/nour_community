# Payments V2 — What was implemented & what YOU must configure

Companion to `docs/PAYMENTS_V2_PLAN.md` (audit + design). This file is the
hands‑on checklist to bring the new donation flow live.

---

## 1. What changed (code)

### Backend — `backend/supabase`
| File | What |
|---|---|
| `migrations/20260818000000_ajr_source_donation.sql` | `ajr_source += 'donation'` |
| `migrations/20260818000100_payments_v2.sql` | `impact_projects.images / preset_amounts / stripe_product_id`, `impact_project_tiers`, `profiles.stripe_customer_id`, `donation_subscriptions` (+ enums, RLS, realtime), `transactions += subscription_id / stripe_invoice_id / is_anonymous / payment_method / amount_refunded / client_key`, `stripe_events`, **`fn_apply_tx_to_projects` v2** (INSERT‑aware, distinct donors, +50 ajr, streak quick‑action), `fn_project_recent_donors`, `fn_expire_pending_transactions` + pg_cron job, `fn_admin_subscription_summary` |
| `migrations/20260818000200_impact_tiers_seed.sql` | 4 tiers + 3‑image gallery for *Feed palestinian families* |
| `functions/_shared/stripe.ts` | pinned Stripe client (`2024-06-20`), fee policy, method mapping, amount bounds |
| `functions/create-payment-intent` | v2: `paymentMethod`, `isAnonymous`, `clientKey` (idempotent replay), min/max, receipts, `payment_method_types` per method, returns `fee/amountCharged` |
| `functions/stripe-webhook` | v2: hard idempotency (`stripe_events`), true `net_received`, `payment_intent.canceled`, partial refunds, `invoice.paid / invoice.payment_failed / customer.subscription.*` |
| `functions/create-subscription` | new — Customer + Product + Subscription (`default_incomplete`), returns first‑invoice client secret + ephemeral key |
| `functions/cancel-subscription` | new — owner‑checked cancel (`cancel_at_period_end` or immediate) |
| `config.toml` | registers the two new functions |

### App — `nour_app`
| Area | What |
|---|---|
| Platform | `MainActivity : FlutterFragmentActivity`, `NormalTheme` → `Theme.MaterialComponents.DayNight.NoActionBar` (4 variants), appcompat/material deps, Google Pay meta‑data, `nour://stripe-redirect` intent‑filter, iOS URL scheme `nour`, Apple Pay entitlement, `Stripe.merchantIdentifier` / `Stripe.urlScheme` in `main.dart`, constants `kStripe*`, `kPayPalEnabled` |
| `payments/data` | `tx_enums` (+`PaymentMethodKind`, `DonationFrequency`, `SubscriptionStatus`), `fee_policy.dart`, `donation_subscription_model.dart`, `transaction_model` (+anonymous/method/subscription/refund), `transaction_item_model` (+embedded project), datasource (create intent v2, subscriptions, cancel, history w/ project, recent donors), `stripe_payment_service` (card sheet / Apple Pay / Google Pay / PayPal dispatch, dark appearance), repo |
| `payments/ui` | `donation_amount_sheet.dart` (Yearly / Monthly / One time, presets, manual, footer), `checkout_page.dart` (summary + stepper, anonymous, cover fees, method picker, processing/timeout/failed overlay, resume polling), `donation_reward_page.dart` (+ `reward_coins_badge.dart`), `my_donations_page.dart` (History / Recurring + stop), `checkout_provider/state`, `my_donations_provider` |
| `impact` | model (+`images`, `presetAmounts`, `tiers`, `galleryImages`), `impact_project_tier_model.dart`, detail select embeds tiers, `project_cover_carousel.dart`, `project_tiers_section.dart`, `donors_avatars_widget.dart` (real avatars), detail page wiring (“Donate now”, tier tap → sheet) |
| Routing | `checkout/:projectId`, `donation-reward/:projectId`, `my-donations` (+ `NavigationServices.toCheckout / toDonationReward / toMyDonations`; `.gr.dart` pre‑filled, regenerate anyway) |
| Profile | “My donations” row (Journey section) |
| l10n | 75 new keys in all 11 arb files (`donate_*`, `checkout_*`, `reward_donation_*`, `my_donations_*`, `error_api_payment_*`) |
| Errors | `ApiErrorKey` + `failures.dart` mappings for the new keys |
| pubspec | `uuid: ^4.5.1` |

Zakat: the impact‑project flow always sends `type = donation` (sadaqa). `CheckoutArgs.isZakat` / route query `?zakat=true` is ready for the Zakat‑calculator flow later (it forces cover‑fees on).

---

## 2. Commands to run (in this order)

```bash
# ── Backend ───────────────────────────────────────────────────────────────
cd backend
supabase secrets set STRIPE_SECRET_KEY=sk_test_xxx STRIPE_WEBHOOK_SECRET=whsec_xxx
supabase db push                                   # applies 20260808 → 20260818 migrations
supabase functions deploy create-payment-intent
supabase functions deploy create-subscription
supabase functions deploy cancel-subscription
supabase functions deploy stripe-webhook --no-verify-jwt

# ── App ───────────────────────────────────────────────────────────────────
cd ../nour_app
# .env → STRIPE_PUBLISHABLE_KEY=pk_test_xxx
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # auto_route (.gr.dart) + assets
flutter gen-l10n
flutter analyze                                             # send me the output if anything is red
cd ios && pod install && cd ..
```

> The code was written without a Dart analyzer available in my environment —
> run `flutter analyze` and paste any errors back to me; I'll fix them in one pass.

---

## 3. Stripe Dashboard

1. **API keys** — Developers → API keys → `pk_test_…` (→ `nour_app/.env`), `sk_test_…` (→ Supabase secrets).
2. **Webhook** — Developers → Webhooks → *Add endpoint*
   `https://gawzqxnhliggvyebldmb.supabase.co/functions/v1/stripe-webhook`
   Events:
   `payment_intent.succeeded`, `payment_intent.payment_failed`, `payment_intent.canceled`,
   `charge.refunded`, `invoice.paid`, `invoice.payment_failed`,
   `customer.subscription.updated`, `customer.subscription.deleted`
   → copy the **Signing secret** (`whsec_…`) → `supabase secrets set STRIPE_WEBHOOK_SECRET=…`, then redeploy `stripe-webhook`.
3. **Payment methods** — Settings → Payment methods: enable **Cards**, **Apple Pay**, **Google Pay**, **PayPal**.
   *PayPal via Stripe is available for EU accounts and must be activated; recurring PayPal needs “PayPal recurring payments” enabled too. If PayPal is not offered on your account, set `kPayPalEnabled = false` in `constants.dart` (row disappears).*
4. **Apple Pay certificate** — Settings → Payment methods → Apple Pay → *Add new application* → download the CSR → Apple Developer → Certificates → *Apple Pay Payment Processing Certificate* for merchant `merchant.com.nourcommunity.nour` → upload back to Stripe.
5. **Branding / receipts** — Settings → Business → statement descriptor `NOUR COMMUNITY`, logo & colours (receipts are emailed automatically: `receipt_email` is set).
6. Later, **live mode**: repeat 1‑2 with `pk_live/sk_live`, a live webhook endpoint and its own `whsec_…`.

## 4. Apple / Google

- **Apple Merchant ID**: developer.apple.com → Identifiers → *Merchant IDs* → `merchant.com.nourcommunity.nour` (must match `kStripeMerchantIdentifier` and `Runner.entitlements`). Xcode → Runner → *Signing & Capabilities* → *+ Apple Pay* → tick the merchant ID (regenerates the provisioning profile).
- **Google Pay**: test mode needs nothing. Production: Google Pay & Wallet Console → integrate app (screenshots review) — do this before release.

## 5. Supabase

- Database → Extensions → enable **pg_cron** (the migration schedules `payments-expire-pending` hourly if the extension is present; if you enable it *after* pushing, run once:
  `select cron.schedule('payments-expire-pending','17 * * * *','select public.fn_expire_pending_transactions()');`).
- Realtime → make sure `transactions` and `donation_subscriptions` are in the `supabase_realtime` publication (migrations do it; verify in Database → Publications).

## 6. Test plan (Stripe test mode)

| Case | How | Expect |
|---|---|---|
| Card OK | `4242 4242 4242 4242` | Reward page; `transactions.status = succeeded`; `collected_amount`, `donors_count`, `ajr_log(+50)` updated |
| 3DS | `4000 0025 0000 3155` | PaymentSheet 3DS challenge → same as above |
| Decline | `4000 0000 0000 9995` | Overlay “Payment failed” → Try again |
| Cancel sheet | dismiss PaymentSheet | back to form; row expires to `failed/abandoned` after 24h |
| Apple Pay | sandbox tester account | native sheet → succeeded |
| Google Pay | test env | native sheet → succeeded |
| PayPal | test mode auto‑approves | browser → back to app → succeeded (also test killing the app while in the browser → reopen → resume polling) |
| Monthly | pick *Monthly*, card | `donation_subscriptions.status = active`, first `transactions` row with `subscription_id`; Stripe → Subscriptions shows it |
| Stop recurring | My donations → Recurring → Stop | `cancel_at_period_end = true`, chip “Ends on …” |
| Refund | Stripe → Payments → refund | full → `refunded` + reversal; partial → `amount_refunded` |
| Duplicate webhook | Stripe → resend event | no double count (`stripe_events`) |
| Anonymous | tick “Make this anonymous” | not returned by `fn_project_recent_donors` |

Local: `supabase functions serve --env-file .env` + `stripe listen --forward-to localhost:54321/functions/v1/stripe-webhook`.

---

## 7. Known follow‑ups (not blocking)

- Admin: refunds button + subscriptions tab (`fn_admin_subscription_summary` is ready).
- Zakat calculator → checkout with `isZakat = true` and multi‑project items.
- Push notification when a recurring charge fails (`invoice.payment_failed`).
- Replace the painted coins (`reward_coins_badge.dart`) with the brand illustration if one is produced.
