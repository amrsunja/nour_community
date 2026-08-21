# Payments V2 — Audit & Implementation Plan

> **Status (2026‑08‑17): implemented** — backend migrations/functions, platform config and the
> full Flutter flow (amount sheet → checkout → reward, recurring, My donations) are in the repo.
> Configuration + test checklist: `docs/PAYMENTS_V2_SETUP.md`. Decisions taken: zakat stays hidden
> in the impact flow (`isZakat` param reserved for the Zakat calculator), recurring = per project
> via Stripe Subscriptions, Card + Apple Pay + Google Pay + PayPal, ajr (+50) & real donor avatars.

**Scope:** Impact projects → donation flow (one‑time + recurring), checkout, payment methods, reward screen, anonymity, tiers.
**Stack:** Supabase (Postgres, Edge Functions, Realtime, Storage) · Flutter (`flutter_stripe` 13, Riverpod, auto_route) · Stripe.
**Inputs:** current code (`backend/`, `nour_app/`), `docs/new_payment_system_logic.md`, `docs/PAYMENTS_IMPLEMENTATION.md`, the 4 design screenshots (project detail, "Donate how much?", Checkout, Donation reward).

---

## 0. TL;DR

| Area | State |
|---|---|
| Backend money model (`transactions`, `transaction_items`, `payouts`, triggers, RLS, webhook, `create-payment-intent`) | ✅ Built, sound architecture, a few bugs (see §2) |
| Admin panel + payout proofs + project "Transactions" transparency section | ✅ Built |
| Stripe keys / webhook / native platform config | ❌ Not configured (`STRIPE_PUBLISHABLE_KEY=todo_insert`, Android theme/activity wrong, no Apple Pay / Google Pay / URL scheme) — payments are effectively **disabled** today |
| Project detail: cover carousel, "Your donation provides" tiers | ❌ Missing |
| Amount sheet (Yearly / Monthly / One time, preset list, manual amount) | ⚠️ Partial (single sheet with chips + amount + zakat toggle + fee toggle; pays immediately) |
| Checkout page (summary + stepper, anonymous, cover fees, PayPal / Card / Apple Pay / Google Pay picker) | ❌ Missing (Stripe PaymentSheet is used directly instead) |
| Reward page ("Jazak Allahu Khayr", coins, project card, "Alhamdulilah") | ❌ Missing (inline `_StatusView` in the sheet) |
| Recurring donations (monthly / yearly) | ❌ Missing entirely (Stripe Subscriptions, new tables, new webhooks) |
| Anonymous donations | ❌ Missing (no column, no UI) |
| Donation history / receipts | ❌ Datasource `getHistory()` exists, no UI, no Stripe receipts |

---

## 1. What exists today (audit)

### 1.1 Backend — `backend/supabase`

**Migration `20260808000000_payment_system.sql`**
- Enums: `tx_status (pending|processing|succeeded|failed|refunded)`, `tx_type (zakat|donation)`, `payout_method`, `payout_status`.
- `transactions` (1 row = 1 PaymentIntent; `amount_total`, `fee_covered`, `amount_charged`, `net_received`, `stripe_pi_id unique`, `stripe_event_id`, `failure_reason`).
- `transaction_items` (per‑project split; invariant `sum(items) = amount_total`).
- `payouts` + `payout_items` (manual owner → partner ledger, proofs in private bucket `payout-proofs`).
- Trigger `fn_apply_tx_to_projects` **AFTER UPDATE OF status**: on `→ succeeded` credits `impact_projects.collected_amount` and `donors_count += 1`; on `succeeded → refunded` reverses.
- RLS: users read own tx/items, admins read all; **no client insert/update** (all writes via service_role). Payouts admin‑only + `confirmed` public read.
- `v_project_balances` (security_invoker) + `fn_admin_project_analytics()` (SECURITY DEFINER, admin‑gated).
- `transactions` added to `supabase_realtime`.
- `fn_user_statistics.completed_deeds` re‑pointed to `transactions`.

**Edge functions**
- `create-payment-intent` (JWT verified): resolves user → validates items server‑side (active, currency, zakat‑eligibility, amount > 0) → computes fee (`1.5 % + 0.25`) if `coverFees` → inserts `pending` tx + items → `stripe.paymentIntents.create({ automatic_payment_methods, metadata })` → stores `stripe_pi_id` → returns `{ clientSecret, transactionId }`. Rolls back the tx on item/Stripe failure.
- `stripe-webhook` (`verify_jwt = false`, signature‑verified): `payment_intent.succeeded → succeeded` (guard `neq status succeeded`), `payment_intent.payment_failed → failed` (guard `eq pending`), `charge.refunded → refunded` (guard `eq succeeded`). Returns 500 on DB error so Stripe retries.
- `_shared/supabase.ts` (`serviceClient`, `userClient`), `_shared/cors.ts`, `_shared/errors.ts`.
- `config.toml` registers both functions.

### 1.2 Flutter — `nour_app/lib/src/features`

- `payments/data`: `tx_enums.dart` (`TxType`, `TxStatus`, `PayoutMethod`, `PayoutStatus`, `PaymentItem`), `transaction_model.dart`, `transaction_item_model.dart`, `payout_model.dart`, `payment_remote_datasource.dart` (`createPaymentIntent`, `watchTransactionStatus` (Realtime), `fetchTransactionStatus`, `getHistory`, `getProjectPayouts`), `services/stripe_payment_service.dart` (`initPaymentSheet` + `presentPaymentSheet`, no Apple/Google Pay config), `payment_repo.dart`.
- `payments/ui`: `donation_provider.dart` (`DonationPresenter`: create intent → sheet → processing → Realtime/45 s fallback → success/failed), `donation_state.dart` (`DonationPhase`), `donation_sheet.dart` (title, zakat/donation tabs, amount input, chips 10/25/50/100, cover‑fees toggle, "Pay X" button, inline status view), `project_transactions_section.dart`, `payout_proof_image.dart`, `project_payouts_provider.dart`.
- `impact/ui/pages/impact_project_detail_page.dart`: cover (single image), badge, title/subtitle, progress card (`DonorsAvatarsWidget` = decorative), about + read more, partner card, stories timeline, transparency section, bottom CTA → `DonationSheet.show(...)` → `presenter.refresh()` on success. Comment in file: *"Your donation provides" block intentionally left out*.
- `admin/…`: dashboard (Projects / Payouts / Received), `RecordPayoutSheet` with proof upload.
- `main.dart`: Stripe init guarded on `pk_` prefix. `EnvServices.stripePublishableKey` ← `.env` (`todo_insert`).
- l10n: `donate_*`, `impact_transactions_*`, `admin_*` keys exist (en/fr at least).

---

## 2. Bugs / weaknesses in the existing implementation

Ordered by impact.

1. **Payments cannot run**: `STRIPE_PUBLISHABLE_KEY=todo_insert` in `nour_app/.env`; no Supabase secrets set; no Stripe webhook endpoint; functions likely not deployed. → §8.
2. **Android will crash on `presentPaymentSheet`**: `MainActivity : FlutterActivity()` must be `FlutterFragmentActivity`, and `NormalTheme`/`LaunchTheme` parent is `Theme.Black.NoTitleBar` — flutter_stripe requires `Theme.AppCompat.*` / `Theme.MaterialComponents.*` (+ `androidx.appcompat` dependency). Also needs `<meta-data android:name="com.google.android.gms.wallet.api.enabled" android:value="true"/>` for Google Pay.
3. **`net_received` is wrong**: webhook stores `pi.amount_received / 100` = gross charged, not net after Stripe fee. Real net = `charge.balance_transaction.net` (expand `latest_charge.balance_transaction`). Rename or fix (see §5.2 webhook).
4. **Abandoned intents stay `pending` forever**: `payment_intent.canceled` not handled and there is no TTL cleanup. Add handler + `pg_cron` job (`pending` older than 24 h → `failed`, `failure_reason='abandoned'`).
5. **Trigger ignores INSERT**: `trg_tx_apply` is `AFTER UPDATE OF status`. Any future path that inserts a row already `succeeded` (recurring invoices, admin manual entries) will not credit the project. Change to `AFTER INSERT OR UPDATE OF status` with `TG_OP` handling.
6. **`donors_count += 1` per transaction, not per donor**: recurring donations / repeat donors inflate "12k+ people". Increment only when the user has no earlier `succeeded` tx for the project (or store `distinct` count via a view).
7. **UI can hang in "Processing…"**: after the single 45 s fallback the sheet stays in processing with no exit. Add periodic polling (every 5 s up to ~2 min) + a "taking longer than expected — we'll notify you, check *My donations*" terminal state.
8. **Client fee estimate duplicated** (`_estimateFee` in Dart = `1.5 % + 0.25` in TS). Fee must be quoted by the server (return `fee`, `amountCharged` from a `quote` step or from `create-payment-intent`) so the UI never disagrees with the charge. Also: Stripe EU fees differ per method (PayPal ≈ 2.9 % + 0.35, non‑EU cards higher) — see §4.4.
9. **No min/max amount guard**: Stripe rejects `< 0.50 €`; add `MIN_AMOUNT = 1`, `MAX_AMOUNT = 10 000` (per tx) server‑side; block on client too.
10. **Refund handling is all‑or‑nothing**: `charge.refunded` fires on partial refunds too; check `charge.amount_refunded == charge.amount` before flipping to `refunded` (partial → keep `succeeded`, store `amount_refunded`).
11. **No receipts**: pass `receipt_email: user.email` and `description` on the PaymentIntent so Stripe emails a receipt; add `statement_descriptor_suffix: 'NOUR DON'`.
12. **`DonorsAvatarsWidget` is fake** (3 coloured circles). Fine as placeholder; if real avatars are wanted, needs anonymity support first (§4.3).
13. **`sign_in_with_apple`/Realtime**: Realtime `postgres_changes` on `transactions` works with RLS, OK — but Realtime is not delivered when the app is backgrounded (Apple Pay sheet / PayPal redirect leaves the app). Polling on resume (`AppLifecycleListener`) is required for the PayPal redirect flow.
14. Minor: `create-payment-intent` uses `automatic_payment_methods` — with the custom method picker (§4.4) switch to explicit `payment_method_types`. `stripe_event_id` unused for idempotency (fine because of status guards). `_Badge` in detail page is dead code.

---

## 3. Screenshot analysis → gaps

### 3.1 "Impact – project" (detail page)

| Design element | Today | Gap |
|---|---|---|
| Cover **carousel** with page dots (3 images) | single `cover_image_url` | need `impact_projects.images text[]` (or reuse cover + `gallery_images`), `PageView` + dots (same as story card) |
| Urgent badge, title, subtitle | ✅ | – |
| Progress `12,400€ / 50,000€`, bar, avatars + "12k+ people have donated" | ✅ | (avatars decorative) |
| About + Read more | ✅ | – |
| **"Your donation provides"** — 4 tiers (Daily food parcel 10€ / Clean water supply 25€ / Medical aid kit 50€ / Emergency shelter 100€), each title + subtitle + amount | ❌ | new table `impact_project_tiers` (multi‑lang title/subtitle, amount, position); tapping a tier opens the amount sheet with that amount preselected (and *One time*) |
| Partner organization card | ✅ | – |
| Stories from the field timeline | ✅ | – |
| "Donate now" sticky CTA | ✅ (label differs: "Donate / Donate or give zakat") | rename to *Donate now*; keep zakat choice inside the flow |
| (Transactions transparency section) | ✅ built, not in mock | keep, place after stories |

### 3.2 "Donate how much?" (bottom sheet)

| Design element | Today | Gap |
|---|---|---|
| Frequency segmented control **Yearly / Monthly / One time** | ❌ | recurring = Stripe Subscriptions (§4.5). Default *One time*. |
| "How much would you like to give ?" + preset **list buttons 10€ / 50€ / 100€ / 150€** | chips 10/25/50/100 | full‑width list buttons; values from tiers if project has tiers, else `[10, 50, 100, 150]` default (store defaults in `impact_projects.preset_amounts int[]`, fallback constant) |
| "Or" divider + "Enter amount manually" | ✅ input | restyle |
| **Checkout** button → Checkout page | pays directly | sheet only collects `{frequency, amount}` and pushes `CheckoutRoute` |
| Footer "Funds are distributed via verified partners · 100% transparent" | ❌ | l10n text |
| Zakat / Donation switch (current) | ✅ in sheet | **not in mock** → move to Checkout "Donation options" as *"This is my Zakat"* row, visible only if `eligible_for_zakat` (see open question Q1). Zakat must be one‑time only (disable Yearly/Monthly when zakat is selected). |

### 3.3 "Checkout" (full page)

| Design element | Today | Gap |
|---|---|---|
| Header "Checkout" + back | – | new route `checkout` |
| **My donation** card: project image, title, subtitle, amount stepper `− 100€ +`, small user avatar | – | stepper step = 5 € (or 10 €); min 1 €; avatar = current profile avatar (or nothing) |
| **Donation options** — "Make this anonymous — Your name won't appear in public counts" (checkbox) | ❌ | `transactions.is_anonymous bool` (+ `donation_subscriptions.is_anonymous`), passed to edge fn |
| "Cover transaction fees (+0.25€) — 100% of your donation reaches projects" | ✅ toggle | fee amount must come from server quote per method (§4.4) |
| **Payment method** radio list: PayPal, Debit/Credit card, Apple Pay (+ presumably Google Pay below the fold) | Stripe PaymentSheet decides | custom picker → each maps to a Stripe confirmation path (§4.4) |
| **Checkout** CTA | – | starts payment for the selected method |

### 3.4 "Donation reward" (full page)

| Design element | Today | Gap |
|---|---|---|
| Rays background, gold coins illustration | inline `_StatusView` in the sheet | new full‑screen `DonationRewardPage` (reuse `reward_scaffold.dart` pattern from `reward_streak_page.dart`), asset needed (coins PNG/Lottie from brand kit) |
| "Jazak Allahu Khayr" + "Your donation has been received. May Allah accept it and multiply its reward." | l10n `donate_success_*` | new keys |
| "You donated 100€" | – | amount from tx |
| Project card (label "Project", title, subtitle, "Via Islamic Organization · Verified") | – | reuse partner data |
| "Alhamdulilah" button → back to project (refreshed) | – | `popUntil` project detail + refresh |
| (Optional) award ajr for the deed | – | `ajr_source` enum lacks `donation`; add `'donation'` + insert `ajr_log` in the trigger on `→ succeeded` (Q3) |

---

## 4. Target architecture

### 4.1 Flow (one‑time)

```
ProjectDetail ──"Donate now" / tier tap──► AmountSheet {frequency, amount}
      └─► CheckoutPage {amount stepper, isZakat?, isAnonymous, coverFees, method}
             │  1. POST create-payment-intent {items, type, coverFees, isAnonymous, method}
             │     ◄─ {clientSecret, transactionId, fee, amountCharged}
             │  2. confirm by method:
             │       card       → PaymentSheet (PI restricted to ['card'])
             │       apple_pay  → Stripe.confirmPlatformPayPaymentIntent (iOS)
             │       google_pay → Stripe.confirmPlatformPayPaymentIntent (Android)
             │       paypal     → Stripe.confirmPayment(PaymentMethodParams.payPal) → browser redirect → returnURL
             │  3. phase = processing → Realtime on transactions.id + polling
             ▼
      DonationRewardPage (on `succeeded`)   /   error snackbar + stay on checkout (on `failed`)
```

Truth stays server‑side (webhook). Nothing changes in the trust model.

### 4.2 Flow (recurring — Monthly / Yearly)

```
CheckoutPage ── POST create-subscription {project_id, amount, interval, isAnonymous, coverFees, method}
   Edge fn: get/create Stripe Customer (profiles.stripe_customer_id)
            get/create Product per project (impact_projects.stripe_product_id) — or one global product
            subscription = stripe.subscriptions.create({
              customer, items:[{ price_data:{ currency, unit_amount, recurring:{interval}, product } }],
              payment_behavior:'default_incomplete',
              payment_settings:{ save_default_payment_method:'on_subscription',
                                 payment_method_types:[...] },
              expand:['latest_invoice.payment_intent'],       // API < 2025-03; else latest_invoice.confirmation_secret
              metadata:{ subscription_row_id, user_id, project_id, type:'donation' } })
            insert donation_subscriptions(status='incomplete')
            return { clientSecret (first invoice PI), customerId, ephemeralKeySecret, subscriptionId }
   App: PaymentSheet(customerId, ephemeralKey, clientSecret)  → PM saved on subscription
   Webhooks: invoice.paid            → insert transactions(succeeded, subscription_id, stripe_invoice_id) + items → trigger credits project
             invoice.payment_failed  → subscription status past_due, notify
             customer.subscription.updated/deleted → sync status/period/canceled_at
   App: "My recurring donations" (profile) → cancel → POST cancel-subscription (cancel_at_period_end)
```

Notes: Apple Pay / Google Pay / card work with subscriptions via PaymentSheet. PayPal recurring via Stripe is available for EU merchants (must be enabled in Dashboard); if not available in your account, hide PayPal when frequency ≠ one‑time. Zakat is never recurring.

### 4.3 Anonymity

- `transactions.is_anonymous boolean not null default false` (+ same on `donation_subscriptions`, copied to each invoice tx).
- Public surfaces that show *who* donated (future "recent donors" avatars, admin exports shared publicly) must filter `is_anonymous = false`. Aggregates (`collected_amount`, `donors_count`) still include anonymous gifts. Admin still sees the user (legal/receipts).
- Optional: RPC `fn_project_recent_donors(project_id, limit)` SECURITY DEFINER returning `avatar_url` of last N non‑anonymous succeeded donors → replaces `DonorsAvatarsWidget` colours.

### 4.4 Payment methods (Stripe only — no PayPal SDK)

All four methods run on the **same** PaymentIntent pipeline; only the confirmation call differs. Requirements:

| Method | Backend | App (flutter_stripe) | Config |
|---|---|---|---|
| Card | `payment_method_types:['card']` | `initPaymentSheet(paymentIntentClientSecret, merchantDisplayName, appearance dark)` + `presentPaymentSheet()` | – |
| Apple Pay | `['card']` | `Stripe.merchantIdentifier = 'merchant.com.nourcommunity.nour'` before `applySettings()`; `Stripe.instance.confirmPlatformPayPaymentIntent(clientSecret, confirmParams: PlatformPayConfirmParams.applePay(applePay: ApplePayParams(merchantCountryCode:'FR', currencyCode:'EUR', cartItems:[…])))`; check `isPlatformPaySupported()` to show/hide row | Apple Merchant ID + Xcode *Apple Pay* capability + entitlement `com.apple.developer.in-app-payments`; merchant ID registered in Stripe → Settings → Payment methods → Apple Pay (certificate) |
| Google Pay | `['card']` | `confirmPlatformPayPaymentIntent(… PlatformPayConfirmParams.googlePay(googlePay: GooglePayParams(merchantCountryCode:'FR', currencyCode:'EUR', testEnv: !isProd)))` | manifest `com.google.android.gms.wallet.api.enabled=true`; Google Pay enabled in Stripe (test mode needs nothing else; prod needs Google Pay & Wallet Console) |
| PayPal | `payment_method_types:['paypal']` (EUR, EU account) | `Stripe.urlScheme = 'nour'`; `Stripe.instance.confirmPayment(paymentIntentClientSecret: clientSecret, data: PaymentMethodParams.payPal(paymentMethodData: PaymentMethodData()))` → SFSafariVC / Custom Tab → return; then poll status | enable PayPal in Stripe Dashboard (Payment methods); iOS `CFBundleURLSchemes` add `nour`; Android intent‑filter `nour://` (or `nour://stripe-redirect`) |

Fee quote per method (server, single source of truth):

```ts
const FEES = { card: {pct:0.015, fixed:0.25}, apple_pay:{pct:0.015, fixed:0.25},
               google_pay:{pct:0.015, fixed:0.25}, paypal:{pct:0.029, fixed:0.35} };
```
Return `fee` from `create-payment-intent`; the Checkout page shows "Cover transaction fees (+X€)" using a light `quote-fee` call (or compute the same table client‑side and let the server override — server value wins). Recommendation: expose `GET quote?amount&method` in the same function (`action:'quote'`) to avoid duplication.

Alternative (simpler, less on‑brand): keep the native PaymentSheet with `automatic_payment_methods` and Apple/Google Pay configured — Stripe renders card/Apple/Google/PayPal itself. Then the "Payment method" list in the design becomes a single "Continue to payment" button. **Recommended: custom picker** (matches design; PayPal is one line each way).

### 4.5 Recurring — data model

```sql
create type public.donation_interval as enum ('month','year');
create type public.subscription_status as enum
  ('incomplete','active','past_due','canceled','unpaid','paused');

create table public.donation_subscriptions (
  id                     bigserial primary key,
  user_id                uuid not null references public.profiles(id) on delete restrict,
  impact_project_id      bigint not null references public.impact_projects(id) on delete restrict,
  type                   public.tx_type not null default 'donation' check (type = 'donation'),
  amount                 numeric(12,2) not null check (amount > 0),   -- body per period
  fee_covered            numeric(12,2) not null default 0,
  currency               public.currency_type not null default 'EUR',
  interval               public.donation_interval not null,
  status                 public.subscription_status not null default 'incomplete',
  is_anonymous           boolean not null default false,
  stripe_subscription_id text unique,
  stripe_customer_id     text,
  current_period_end     timestamptz,
  cancel_at_period_end   boolean not null default false,
  canceled_at            timestamptz,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);
alter table public.transactions
  add column subscription_id   bigint references public.donation_subscriptions(id) on delete set null,
  add column stripe_invoice_id text unique,
  add column is_anonymous      boolean not null default false,
  add column payment_method    text,            -- 'card'|'apple_pay'|'google_pay'|'paypal'
  add column amount_refunded   numeric(12,2) not null default 0;
alter table public.profiles add column stripe_customer_id text unique;
alter table public.impact_projects add column stripe_product_id text;
-- RLS: user reads own subscriptions; admin all; no client writes.
```

### 4.6 Tiers + gallery

```sql
create table public.impact_project_tiers (
  id                bigserial primary key,
  impact_project_id bigint not null references public.impact_projects(id) on delete cascade,
  amount            numeric(12,2) not null check (amount > 0),
  title_en text not null, title_fr text not null, title_ar text not null,
  title_de text, title_nl text, title_tr text, title_id text, title_ur text, title_bn text, title_ms text, title_ru text,
  subtitle_en text, subtitle_fr text, subtitle_ar text,
  subtitle_de text, subtitle_nl text, subtitle_tr text, subtitle_id text, subtitle_ur text, subtitle_bn text, subtitle_ms text, subtitle_ru text,
  position int not null default 0,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index on public.impact_project_tiers(impact_project_id, position);
alter table public.impact_project_tiers enable row level security;
create policy tiers_read on public.impact_project_tiers for select to authenticated using (true);

alter table public.impact_projects
  add column images text[] not null default '{}',          -- gallery (cover first); keep cover_image_url as fallback
  add column preset_amounts int[] not null default '{10,50,100,150}';
```
Seed the 4 tiers of the mock for project *Feed palestinian families* in a new seed migration.

---

## 5. Backend work items

### 5.1 Migration `20260818000000_payments_v2.sql`
1. §4.5 + §4.6 DDL, enums, indexes, RLS, `set_updated_at` triggers.
2. `fn_apply_tx_to_projects` → handle `INSERT` (`TG_OP='INSERT' and new.status='succeeded'`) and dedupe donors:
```sql
if (tg_op = 'INSERT' and new.status = 'succeeded')
   or (tg_op = 'UPDATE' and new.status = 'succeeded' and old.status is distinct from 'succeeded') then
  update public.impact_projects p
     set collected_amount = collected_amount + i.amount,
         donors_count = donors_count + case when exists (
             select 1 from public.transactions t2 join public.transaction_items i2 on i2.transaction_id = t2.id
              where t2.user_id = new.user_id and t2.status = 'succeeded' and t2.id <> new.id
                and i2.impact_project_id = i.impact_project_id) then 0 else 1 end
    from public.transaction_items i
   where i.transaction_id = new.id and p.id = i.impact_project_id;
end if;
```
   trigger: `after insert or update of status on public.transactions`.
3. Add `'donation'` to `ajr_source` + optional ajr grant on `→ succeeded` (Q3).
4. `pg_cron` (extension `pg_cron` — enable in Dashboard → Integrations) job: every hour `update transactions set status='failed', failure_reason='abandoned' where status='pending' and created_at < now() - interval '24 hours'`.
5. `fn_project_recent_donors(p_project_id, p_limit)` (optional, §4.3).
6. `v_project_balances` / `fn_admin_project_analytics` unchanged (they read `transactions`; recurring invoices land there too).

### 5.2 Edge functions
- **`create-payment-intent`** (modify): payload `+ isAnonymous, paymentMethod ('card'|'apple_pay'|'google_pay'|'paypal'), action?:'quote'`; min/max guard; per‑method fee table; `payment_method_types` from method; `receipt_email`, `description`, `statement_descriptor_suffix`; persist `is_anonymous`, `payment_method`; response `+ fee, amountCharged`. Optional: `idempotencyKey` header from client (uuid per attempt) → `stripe.paymentIntents.create(params, { idempotencyKey })`.
- **`stripe-webhook`** (modify): 
  - `payment_intent.succeeded`: fetch `latest_charge.balance_transaction` (expand) → `net_received = balance_transaction.net/100`.
  - `payment_intent.canceled` → `failed` (`failure_reason='canceled'`).
  - `charge.refunded`: full vs partial (`amount_refunded`).
  - `invoice.paid` → upsert `transactions` (`stripe_invoice_id` idempotency) with `status='succeeded'`, `subscription_id`, `is_anonymous` copied, + `transaction_items`; update `donation_subscriptions.status='active', current_period_end`.
  - `invoice.payment_failed` → `donation_subscriptions.status='past_due'`.
  - `customer.subscription.updated|deleted` → sync `status`, `cancel_at_period_end`, `canceled_at`, `current_period_end`.
  - Store processed `event.id` in a small `stripe_events(id text pk, type, created_at)` table for hard idempotency (insert‑or‑skip at the top).
- **`create-subscription`** (new, JWT): §4.2. Returns `{ clientSecret, customerId, ephemeralKeySecret, subscriptionId }`. Ephemeral key: `stripe.ephemeralKeys.create({customer}, {apiVersion: '<pin>'})`.
- **`cancel-subscription`** (new, JWT): owner check → `stripe.subscriptions.update(id, {cancel_at_period_end:true})` (or immediate) → row update.
- Pin `apiVersion` in `new Stripe(key, { apiVersion: '2024-06-20', … })` — the newer Stripe API (2025‑03+) removed `latest_invoice.payment_intent`; either pin the older version or read `latest_invoice.confirmation_secret.client_secret`.
- `config.toml`: register `create-subscription`, `cancel-subscription` (`verify_jwt = true`).

### 5.3 Stripe Dashboard events to subscribe
`payment_intent.succeeded`, `payment_intent.payment_failed`, `payment_intent.canceled`, `charge.refunded`, `invoice.paid`, `invoice.payment_failed`, `customer.subscription.updated`, `customer.subscription.deleted`.

---

## 6. Flutter work items

### 6.1 Platform / bootstrap
- `main.dart`: before `applySettings()` set `stripe.Stripe.merchantIdentifier = 'merchant.com.nourcommunity.nour'`, `stripe.Stripe.urlScheme = 'nour'`.
- Android: `MainActivity : FlutterFragmentActivity`; `styles.xml` (all variants) `NormalTheme parent="Theme.MaterialComponents.DayNight.NoActionBar"` (`LaunchTheme` too or keep splash theme but NormalTheme must be AppCompat‑derived); `app/build.gradle` add `implementation "androidx.appcompat:appcompat:1.7.0"` + `com.google.android.material:material:1.12.0` if not pulled transitively; manifest: wallet meta‑data + `nour` scheme intent‑filter.
- iOS: `Info.plist` add `nour` to `CFBundleURLSchemes`; Xcode → Signing & Capabilities → **Apple Pay** (merchant ID) → adds `com.apple.developer.in-app-payments` to `Runner.entitlements`.
- `AppDelegate`/`MainActivity` nothing else (flutter_stripe handles the return URL when `urlScheme` is set).

### 6.2 Data layer (`features/payments/data`)
- `tx_enums.dart`: `+ PaymentMethodKind {card, applePay, googlePay, paypal}`, `DonationFrequency {oneTime, monthly, yearly}`, `SubscriptionStatus`.
- `models`: `donation_subscription_model.dart`, `fee_quote.dart`; `TransactionModel += isAnonymous, paymentMethod, subscriptionId`.
- `payment_remote_datasource.dart`: `createPaymentIntent(+isAnonymous,+method)` returns `fee/amountCharged`; `quoteFee(amount, method)`; `createSubscription(...)`; `cancelSubscription(id)`; `getMySubscriptions()`; `watchTransactionStatus` unchanged; `pollTransactionStatus(id, every 5s, max 2min)`.
- `stripe_payment_service.dart`: split into `presentCardSheet(clientSecret, {customerId, ephemeralKey})`, `confirmApplePay(clientSecret, amount, label)`, `confirmGooglePay(...)`, `confirmPayPal(clientSecret)`, `isApplePaySupported()`, `isGooglePaySupported()`; dark `PaymentSheetAppearance` matching `UIColorsToken`.
- `payment_repo.dart`: wire the above.

### 6.3 Impact detail (`features/impact`)
- `impact_project_model.dart` `+ images, presetAmounts, tiers` (embed `impact_project_tiers(*)` in `_projectDetailColumns`, ordered by `position`).
- New `impact_project_tier_model.dart`.
- `impact_project_detail_page.dart`: `_CoverCarousel` (PageView + dots; reuse the dots widget in `project_story_card_widget.dart`), `_TiersSection` ("Your donation provides", tap → `AmountSheet.show(preselectedAmount: tier.amount)`), CTA label *Donate now*, remove `_Badge` dead code.

### 6.4 Donation flow UI (`features/payments/ui`)
- `donation_flow_state.dart` (autoDispose provider scoped to one flow — created when the amount sheet opens, disposed after reward): `frequency, amount, isZakat, isAnonymous, coverFees, method, quote, phase, transactionId/subscriptionId`.
- `donation_amount_sheet.dart` (replaces `donation_sheet.dart`): segmented `Yearly / Monthly / One time` (hide when `!allowRecurring`), preset list, "Or", manual input, *Checkout* → `nav.toCheckout(projectId)`, footer text.
- `checkout_page.dart` (`@RoutePage`, path `checkout/:projectId`): My donation card (image/title/subtitle/stepper/avatar), Donation options (Zakat row if eligible; Anonymous; Cover fees with quoted `+X€`), Payment method radio list (Apple Pay only on iOS + supported; Google Pay only on Android + supported; PayPal hidden if recurring & not supported), *Checkout* CTA (`isBusy` while preparing/processing), inline processing overlay ("Confirming your payment…").
- `donation_reward_page.dart` (`@RoutePage`, path `donation-reward`, args: amount, currency, projectId): reward scaffold, coins asset, texts, "You donated", project card, *Alhamdulilah* → pop to detail + `refresh()`.
- `my_donations_page.dart` (profile → "My donations"): tabs *History* (`getHistory()`, status chips, receipt link) / *Recurring* (`getMySubscriptions()`, cancel). Not in mocks — recommended, cheap.
- Routing: `RoutePaths.checkout`, `RoutePaths.donationReward`, `RoutePaths.myDonations`; `NavigationServices.toCheckout/toDonationReward/toMyDonations`; add to `generalSubPages` in `app_router.dart` so they push inside the Impact tab.
- Lifecycle: `AppLifecycleListener.onResume` → if `phase == processing` → `fetchTransactionStatus` (PayPal / Apple Pay return).
- l10n (en + fr minimum, others fallback): `donate_frequency_yearly/monthly/one_time`, `donate_how_much`, `donate_or`, `donate_enter_manually`, `donate_checkout`, `donate_footer_partners`, `donate_footer_transparent`, `checkout_title`, `checkout_my_donation`, `checkout_options`, `checkout_anonymous`, `checkout_anonymous_hint`, `checkout_cover_fees(fee)`, `checkout_cover_fees_hint`, `checkout_zakat`, `checkout_zakat_hint`, `checkout_payment_method`, `checkout_method_paypal/card/apple_pay/google_pay`, `reward_title` ("Jazak Allahu Khayr"), `reward_message`, `reward_you_donated`, `reward_project`, `reward_via(org)`, `reward_button` ("Alhamdulilah"), `impact_tiers_title` ("Your donation provides"), `donations_history_*`, `subscription_*`.
- Assets: coins illustration (`assets/images/donation_coins.png` @1x/2x/3x or Lottie), rays background (can be a `CustomPainter` gradient — reuse from reward pages if it exists).
- Analytics events: `donation_started`, `checkout_viewed`, `payment_method_selected`, `donation_succeeded`, `donation_failed`, `subscription_created`, `subscription_canceled`.

### 6.5 Delete / deprecate
- `donation_sheet.dart` (`_StatusView`, `_QuickChip`) → replaced. Keep `DonationPresenter` core (`pay`, `_trackTransaction`) but move into `donation_flow_provider.dart` with method dispatch + polling.

---

## 7. Phased delivery

| Phase | Content | Est. |
|---|---|---|
| **P0 – Unblock** | Amir config (§8), Android/iOS platform fixes, deploy functions, verify current sheet pays with `4242…` end‑to‑end (webhook → succeeded → collected_amount) | 0.5 d + config |
| **P1 – Backend fixes & V2 schema** | Migration §5.1 (tiers, gallery, presets, anonymity, subscription tables, trigger fix, cron), webhook fixes (§5.2), `create-payment-intent` v2 (quote, method, anonymity, receipts), seed tiers | 1.5 d |
| **P2 – Detail page** | Carousel + tiers section + CTA | 0.5 d |
| **P3 – One‑time flow UI** | Amount sheet → Checkout page (card / Apple Pay / Google Pay / PayPal) → Reward page, polling + resume handling, l10n, analytics | 2.5 d |
| **P4 – Recurring** | `create-subscription` / `cancel-subscription`, invoice webhooks, PaymentSheet with customer + ephemeral key, Recurring tab in *My donations* | 2 d |
| **P5 – Polish** | *My donations* history, real donor avatars, ajr for donation, admin: subscriptions list + refunds button (`stripe.refunds.create` via edge fn) | 1–1.5 d |

Testing per phase (test mode): `4242 4242 4242 4242` success, `4000 0000 0000 9995` decline, `4000 0025 0000 3155` 3DS; Apple Pay sandbox tester account; Google Pay test env; PayPal sandbox (Stripe test mode auto‑approves); `stripe trigger payment_intent.succeeded` / `stripe listen --forward-to` for local; replay webhook → no double count; refund from Dashboard → reverse; abandon a sheet → row becomes `failed` after cron.

---

## 8. What **you** (Amir) must configure

Backend / Stripe
1. Stripe Dashboard → Developers → API keys: copy `pk_test_…` and `sk_test_…`.
2. `cd backend && supabase secrets set STRIPE_SECRET_KEY=sk_test_… STRIPE_WEBHOOK_SECRET=whsec_…` (webhook secret after step 4).
3. `supabase db push` (existing `20260808` + `20260809` if not yet applied — check `supabase migration list`), then `supabase functions deploy create-payment-intent && supabase functions deploy stripe-webhook --no-verify-jwt` (later: `create-subscription`, `cancel-subscription`).
4. Stripe → Developers → Webhooks → Add endpoint `https://gawzqxnhliggvyebldmb.supabase.co/functions/v1/stripe-webhook`, events listed in §5.3 → copy signing secret → step 2.
5. Stripe → Settings → Payment methods: enable **Cards**, **Apple Pay**, **Google Pay**, **PayPal** (PayPal requires an EU Stripe account + activation; if it is not offered, tell me → we hide the PayPal row).
6. Stripe → Settings → Business: statement descriptor `NOUR COMMUNITY`; branding (logo/colour) for receipts.
7. Enable `pg_cron` in Supabase Dashboard → Database → Extensions (for the abandoned‑intent cleanup).

App
8. `nour_app/.env`: `STRIPE_PUBLISHABLE_KEY=pk_test_…`.
9. Apple: developer.apple.com → Identifiers → Merchant IDs → create `merchant.com.nourcommunity.nour`; Stripe → Settings → Payment methods → Apple Pay → add the merchant ID (download CSR from Stripe, create Apple Pay Payment Processing Certificate, upload). Xcode → Runner → Signing & Capabilities → + Apple Pay → tick the merchant ID.
10. Google Pay: test mode nothing; prod: Google Pay & Wallet Console → integrate app, screenshots review.
11. Send me the coins / rays artwork (or confirm I generate a placeholder) — brand kit folder has no coins asset.
12. Later for live: swap `pk_live/sk_live`, recreate webhook in live mode, update `STRIPE_WEBHOOK_SECRET`.

---

## 9. Open questions (answer before P3)

- **Q1 Zakat entry point.** Mocks show no zakat toggle. Proposal: Checkout → "Donation options" → *"This is my Zakat al‑Mal"* row (only if `eligible_for_zakat`; disables recurring + forces cover‑fees hint "Zakat arrives in full"). Alternative: keep zakat only in the Zakat Calculator flow (multi‑project split, one payment). Which?
- **Q2 Recurring scope.** Monthly + yearly for donations only (never zakat)? Should a recurring donation be per project (proposal) or a general "Nour fund"?
- **Q3 Ajr for donations.** Grant ajr on `succeeded` (e.g. flat 100, or amount‑independent to avoid "buying" ajr)? Requires enum extension. Yes/no?
- **Q4 Fee display.** Mock shows a flat "+0.25€"; the real Stripe fee is `1.5 % + 0.25` (EU cards) / `2.9 % + 0.35` (PayPal). Show real quoted fee (recommended) or a flat rounded amount?
- **Q5 Amount stepper step** on Checkout: 5 € / 10 € / 1 €?
- **Q6 Preset amounts** per project (`preset_amounts`) or derived from tiers when tiers exist?
- **Q7 Anonymity default** off (mock shows it checked — is that just the mock state?).
- **Q8 PayPal**: is it enabled on your Stripe account (EU)? If not, drop it or accept the (heavier) native PayPal SDK path.
