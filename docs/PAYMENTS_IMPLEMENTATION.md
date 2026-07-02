# Payment System — Implementation Notes

Implements `docs/new_payment_system_logic.md` + the admin/transparency devis
(admin payments tooling, payout proofs, per-project "Transactions" section).

## What was built

### Backend (`backend/supabase`)
- **Migration** `migrations/20260808000000_payment_system.sql`
  - Drops the legacy `zakat_transactions` / `donation_transactions` tables and
    their insert-time trigger.
  - Enums `tx_status`, `tx_type`, `payout_method`, `payout_status`.
  - Tables `transactions`, `transaction_items`, `payouts`, `payout_items`.
  - `fn_apply_tx_to_projects` trigger — credits `collected_amount` **and**
    `donors_count` only on `pending → succeeded`; reverses on `→ refunded`.
  - RLS: clients read only their own transactions; payouts admin-only, plus a
    `confirmed`-only read policy powering the public transparency section.
  - `v_project_balances` view (security_invoker) + `fn_admin_project_analytics()`
    (admin-gated SECURITY DEFINER) for the analytics page.
  - Private `payout-proofs` storage bucket (admin write / authenticated read via
    signed URLs).
  - Adds `transactions` to the `supabase_realtime` publication.
  - Repoints `fn_user_statistics.completed_deeds` at the new `transactions`
    table (the old one referenced the dropped `donation_transactions`).
- **Edge functions**
  - `functions/create-payment-intent` — validates items server-side, inserts a
    pending transaction, creates the Stripe PaymentIntent.
  - `functions/stripe-webhook` — signature-verified, idempotent status updates.
  - `config.toml` registers both (`stripe-webhook` = `verify_jwt = false`).

### Flutter (`nour_app/lib/src/features`)
- `payments/` — models, remote datasource (create-intent, Realtime status,
  history, project payouts), `StripePaymentService` (flutter_stripe seam),
  repo, donation presenter/state, `DonationSheet`, transparency widgets.
- `admin/` — analytics datasource/repo, `AdminPresenter`, `AdminDashboardPage`
  (Projects / Payouts / Received tabs), `RecordPayoutSheet` (with proof upload).
- `impact/…/impact_project_detail_page.dart` — donate CTA + "Transactions"
  transparency section.
- `profile/…/profile_page.dart` — admin card (shown when `is_admin`).
- Routing, `NavigationServices.toAdminDashboard()`, l10n (en/fr), `flutter_stripe`
  dependency, guarded Stripe init in `main.dart`.

## Required steps to run

```bash
# 1. Backend
cd backend
supabase secrets set STRIPE_SECRET_KEY=sk_test_xxx STRIPE_WEBHOOK_SECRET=whsec_xxx
supabase db push
supabase functions deploy create-payment-intent
supabase functions deploy stripe-webhook --no-verify-jwt
# Stripe dashboard: add webhook -> https://<REF>.supabase.co/functions/v1/stripe-webhook
#   events: payment_intent.succeeded, payment_intent.payment_failed, charge.refunded

# 2. App
cd ../nour_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # auto_route + assets
flutter gen-l10n                                            # new arb keys
# add STRIPE_PUBLISHABLE_KEY=pk_test_xxx to nour_app/.env
```

### Native config (flutter_stripe)
- iOS: `ios/Podfile` platform ≥ 13.0; Apple Pay merchant id if used.
- Android: app theme must extend `Theme.AppCompat`/`MaterialComponents`;
  `minSdkVersion` ≥ 21.

## Notes
- Payments stay disabled until `STRIPE_PUBLISHABLE_KEY` (a `pk_…` value) is set —
  `main.dart` guards init so a missing key never crashes startup.
- To grant admin access: set `profiles.is_admin = true` for the user.
- Payout proofs live in the private `payout-proofs` bucket; the app renders them
  via short-lived signed URLs (admin ledger + project transparency).
