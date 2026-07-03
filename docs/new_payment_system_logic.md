# New Payment System Logic — Zakat & Donations

**Status:** design spec · **Stack:** Supabase (Postgres + Edge Functions) · Flutter (`flutter_stripe`) · Stripe
**Scope:** how users pay zakat and donations, how payments are confirmed, how the app tracks them, and how the app owner (admin) reverses collected funds to partner organizations.

---

## 1. Guiding principles

1. **The server is the source of truth for money, never the client.** The Flutter app never decides a price and never writes a transaction row. It asks the backend to create a payment, then displays state.
2. **A payment counts only after Stripe confirms it via webhook.** A successful `PaymentSheet` in the app is *not* proof of payment — it only means the user finished the UI step. The webhook is the single authority that flips a transaction to `succeeded`.
3. **`impact_projects.collected_amount` increases only on the `pending → succeeded` transition**, never on row insert. This closes the current hole where any client could inflate a project's progress with a fake insert.
4. **Idempotency everywhere.** Stripe can deliver a webhook more than once; a unique `stripe_pi_id` plus a status guard guarantees a payment is applied exactly once.
5. **Zakat and Sadaqa (donations) are tracked separately end to end** — different `type`, separate reporting, never mixed in a payout. Stripe fees are never deducted from the body of the zakat.
6. **Partners are not app users.** A partner organization is just a row in `partner_organizations`. Money is collected on Nour's own Stripe account and reversed manually (bank / Wise) — tracked in a `payouts` ledger.

---

## 2. Data model

### 2.1 New enums

```sql
-- payment lifecycle
do $$ begin
  create type public.tx_status as enum ('pending','processing','succeeded','failed','refunded');
exception when duplicate_object then null; end $$;

-- transaction / payout kind
do $$ begin
  create type public.tx_type as enum ('zakat','donation');
exception when duplicate_object then null; end $$;

-- how a manual payout was sent
do $$ begin
  create type public.payout_method as enum ('bank','wise','cash','other');
exception when duplicate_object then null; end $$;

-- payout lifecycle
do $$ begin
  create type public.payout_status as enum ('pending','sent','confirmed');
exception when duplicate_object then null; end $$;
```

> This replaces the two naïve tables in `20260515000800_transactions.sql` (`zakat_transactions`, `donation_transactions`) with a single, status-aware `transactions` table plus a child `transaction_items` table. Keeping them separate was viable, but one table with a `type` column removes duplicated triggers and makes multi-project zakat natural.

### 2.2 `transactions` — one row per Stripe PaymentIntent

```sql
create table public.transactions (
  id                bigserial primary key,
  user_id           uuid not null references public.profiles(id) on delete restrict,
  type              public.tx_type not null,
  status            public.tx_status not null default 'pending',
  currency          public.currency_type not null default 'EUR',

  amount_total      numeric(12,2) not null check (amount_total > 0), -- body: what reaches the projects
  fee_covered       numeric(12,2) not null default 0,                -- Stripe fee, only if the donor opted to cover it
  amount_charged    numeric(12,2) not null,                          -- actually charged card = amount_total + fee_covered
  net_received      numeric(12,2),                                   -- after Stripe fee (filled from webhook)

  stripe_pi_id      text unique,                                     -- PaymentIntent id — idempotency key
  stripe_event_id   text,                                            -- last processed Stripe event id
  failure_reason    text,

  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index tx_user_idx    on public.transactions(user_id);
create index tx_status_idx  on public.transactions(status);
create index tx_created_idx on public.transactions(created_at desc);

drop trigger if exists trg_transactions_updated_at on public.transactions;
create trigger trg_transactions_updated_at
  before update on public.transactions
  for each row execute function public.set_updated_at();
```

Field semantics:

- `amount_total` — the **body** of the gift; this is what is distributed to projects and what the partner is owed. For zakat this is the amount that must arrive in full.
- `fee_covered` — non-zero only when the donor chose "cover the processing fee". Kept separate so zakat accounting stays clean.
- `amount_charged` = `amount_total + fee_covered` — the number sent to Stripe (in minor units).
- `net_received` — what actually landed after Stripe's cut; filled by the webhook for reconciliation.
- `stripe_pi_id` — `unique`, the anchor for idempotent webhook handling.

### 2.3 `transaction_items` — per-project breakdown

```sql
create table public.transaction_items (
  id                bigserial primary key,
  transaction_id    bigint not null references public.transactions(id) on delete cascade,
  impact_project_id bigint not null references public.impact_projects(id) on delete restrict,
  amount            numeric(12,2) not null check (amount > 0)
);

create index tx_items_tx_idx      on public.transaction_items(transaction_id);
create index tx_items_project_idx on public.transaction_items(impact_project_id);
```

One transaction can fund several projects. This is exactly the zakat-calculator case: the user splits one amount across multiple eligible projects and pays **once** (one Stripe fee instead of N). A single-project donation is simply a transaction with one item.

Invariant: `sum(transaction_items.amount) == transactions.amount_total`.

### 2.4 `payouts` — manual reversal ledger (owner → partner)

```sql
create table public.payouts (
  id                bigserial primary key,
  organization_id   bigint not null references public.partner_organizations(id) on delete restrict,
  impact_project_id bigint references public.impact_projects(id) on delete restrict, -- null = general to org
  type              public.tx_type not null,           -- zakat and donation are NEVER mixed in one payout
  amount            numeric(12,2) not null check (amount > 0),
  currency          public.currency_type not null default 'EUR',
  method            public.payout_method not null,
  status            public.payout_status not null default 'pending',
  reference         text,                              -- bank/Wise transfer reference
  proof_url         text,                              -- receipt scan in storage — transparency
  note              text,
  created_by        uuid not null references public.profiles(id) on delete restrict, -- admin who recorded it
  executed_at       timestamptz,                       -- when the transfer actually happened
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index payouts_org_idx     on public.payouts(organization_id);
create index payouts_project_idx on public.payouts(impact_project_id);
create index payouts_type_idx    on public.payouts(type);

drop trigger if exists trg_payouts_updated_at on public.payouts;
create trigger trg_payouts_updated_at
  before update on public.payouts
  for each row execute function public.set_updated_at();
```

`proof_url` (a receipt in a storage bucket) is the backbone of trust for the umma: every reversal to a partner is traceable with an amount, method, date, and document.

### 2.5 (Optional) `payout_items` — full audit trail

For gold-standard transparency, link each payout to the specific `transaction_items` it settled, so you can prove *"these donations were sent in this transfer."* Optional for v1, recommended for zakat.

```sql
create table public.payout_items (
  id                  bigserial primary key,
  payout_id           bigint not null references public.payouts(id) on delete cascade,
  transaction_item_id bigint not null references public.transaction_items(id) on delete restrict
);
```

---

## 3. Triggers — keeping `collected_amount` honest

The old trigger bumped `collected_amount` on every insert. It is replaced by a trigger that reacts to **status transitions** only.

```sql
create or replace function public.fn_apply_tx_to_projects()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- pending/processing -> succeeded : credit each project
  if new.status = 'succeeded' and old.status is distinct from 'succeeded' then
    update public.impact_projects p
       set collected_amount = collected_amount + i.amount
      from public.transaction_items i
     where i.transaction_id = new.id
       and p.id = i.impact_project_id;

  -- succeeded -> refunded : reverse the credit
  elsif new.status = 'refunded' and old.status = 'succeeded' then
    update public.impact_projects p
       set collected_amount = greatest(0, collected_amount - i.amount)
      from public.transaction_items i
     where i.transaction_id = new.id
       and p.id = i.impact_project_id;
  end if;

  return new;
end $$;

drop trigger if exists trg_tx_apply on public.transactions;
create trigger trg_tx_apply
  after update of status on public.transactions
  for each row execute function public.fn_apply_tx_to_projects();
```

Because the credit is gated on `succeeded`, a fake `pending` row is worthless — it never touches `collected_amount` until the webhook (which only the real Stripe payment can trigger) promotes it.

---

## 4. Row Level Security

The core rule: **clients can only READ their own transactions.** All money writes happen in Edge Functions running with the `service_role` key, which bypasses RLS. There is deliberately **no INSERT/UPDATE policy** for `authenticated` on `transactions`.

```sql
alter table public.transactions      enable row level security;
alter table public.transaction_items enable row level security;
alter table public.payouts           enable row level security;

-- Users read their own transactions; admins read all.
create policy tx_self_read on public.transactions
  for select to authenticated
  using (user_id = auth.uid() or public.is_admin());

create policy tx_items_self_read on public.transaction_items
  for select to authenticated
  using (
    exists (
      select 1 from public.transactions t
      where t.id = transaction_id
        and (t.user_id = auth.uid() or public.is_admin())
    )
  );

-- NOTE: no insert/update/delete policies for authenticated => the client cannot write money rows.

-- Payouts are admin-only, in every direction.
create policy payouts_admin_all on public.payouts
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());
```

This reuses the existing `public.is_admin()` helper (a row in `profiles` with `is_admin = true`), consistent with the rest of the schema.

---

## 5. End-to-end flow

```
APP                     create-payment-intent          STRIPE              stripe-webhook            DB
 │  items + JWT ───────────────►                                                                     │
 │                        validate projects (service_role) ───────────────────────────────────────► │ INSERT tx(pending)+items
 │                        PaymentIntent.create ─────────►│                                            │
 │                        ◄──── client_secret ──────────│                                             │
 │  ◄── clientSecret + txId                                                                           │
 │  PaymentSheet (card/ApplePay/GPay) ──────────────────►│ processes the charge                       │
 │  ◄── ok / cancel  (NOT the source of truth)           │                                            │
 │  shows "processing…"                                  │ payment_intent.succeeded ────────────────► │ verify sig + idempotency
 │                                                       │                             UPDATE tx → succeeded
 │                                                       │                             (trigger bumps collected_amount)
 │  ◄════ Realtime: tx.status = succeeded ═══════════════════════════════════════════════════════════ │
 │  shows success
```

### Phase 1 — Initiation (`create-payment-intent`)

The client sends the chosen items (project + amount) and its Supabase JWT. The function:

1. Resolves the user from the JWT.
2. Uses the `service_role` client to load the referenced projects and **validate them server-side**: active, currency match, and — when `type = 'zakat'` — `eligible_for_zakat = true`. Amounts must be `> 0`.
3. Computes `amount_total`, optional `fee_covered`, and `amount_charged`.
4. Inserts a `pending` transaction + its items.
5. Creates a Stripe `PaymentIntent` in **minor units** (`amount_charged * 100`) with `metadata { transaction_id, user_id, type }`.
6. Stores `stripe_pi_id` on the transaction and returns `{ clientSecret, transactionId }`.

### Phase 2 — Payment (`PaymentSheet`)

The app initializes and presents Stripe's native `PaymentSheet` with the `clientSecret`. The user pays by card, Apple Pay, or Google Pay. When `presentPaymentSheet()` returns without throwing, the app shows **"Processing…"** — not success — and starts listening for the real status.

### Phase 3 — Confirmation (`stripe-webhook`)

Stripe calls the webhook function. It:

1. Verifies the signature with `STRIPE_WEBHOOK_SECRET` (using the **raw** request body).
2. On `payment_intent.succeeded`: updates the matching transaction to `succeeded`, but only `WHERE status <> 'succeeded'` (idempotency guard). The `trg_tx_apply` trigger then credits each project's `collected_amount`.
3. On `payment_intent.payment_failed`: sets `failed`.
4. On `charge.refunded`: sets `refunded`; the trigger reverses the credit.
5. Always returns `2xx` so Stripe does not retry a handled event.

### Phase 4 — Tracking (Realtime)

The app subscribes to its own transaction row via Supabase Realtime. When the webhook flips `status` to `succeeded`, Postgres pushes the change and the UI shows success. A 30–60s timeout fallback re-checks with a direct `select` in case the app was backgrounded. History screens and the project's `collected_amount` read the same tables via normal RLS-protected selects.

---

## 6. Edge Function — `create-payment-intent`

`backend/supabase/functions/create-payment-intent/index.ts`

```ts
import Stripe from "https://esm.sh/stripe@16?target=deno";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  httpClient: Stripe.createFetchHttpClient(),
});

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  // 1. Authenticated user (from the caller's JWT)
  const authHeader = req.headers.get("Authorization")!;
  const userClient = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader } } },
  );
  const { data: { user } } = await userClient.auth.getUser();
  if (!user) return json({ error: "unauthorized" }, 401);

  // 2. Client payload — amounts are donor-chosen but must be validated
  const { type, currency, items, coverFees } = await req.json();
  // items: [{ project_id: number, amount: number }]
  if (!["zakat", "donation"].includes(type) || !Array.isArray(items) || items.length === 0) {
    return json({ error: "bad_request" }, 400);
  }

  // 3. service_role client — bypasses RLS to read projects & write the transaction
  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const ids = items.map((i: any) => i.project_id);
  const { data: projects, error: pErr } = await admin
    .from("impact_projects")
    .select("id, is_active, eligible_for_zakat, currency")
    .in("id", ids);
  if (pErr) return json({ error: "db_error" }, 500);

  // 4. Server-side validation — never trust the client
  for (const it of items) {
    const p = projects?.find((x) => x.id === it.project_id);
    if (!p || !p.is_active)      return json({ error: "project_inactive" }, 422);
    if (p.currency !== currency) return json({ error: "currency_mismatch" }, 422);
    if (type === "zakat" && !p.eligible_for_zakat)
                                 return json({ error: "not_zakat_eligible" }, 422);
    if (!(it.amount > 0))        return json({ error: "bad_amount" }, 422);
  }

  const amountTotal   = round2(items.reduce((s: number, i: any) => s + i.amount, 0));
  const fee           = coverFees ? round2(amountTotal * 0.015 + 0.25) : 0; // EU card approx.
  const amountCharged = round2(amountTotal + fee);

  // 5. Create the pending transaction + items
  const { data: tx, error: txErr } = await admin.from("transactions").insert({
    user_id: user.id, type, currency,
    amount_total: amountTotal, fee_covered: fee, amount_charged: amountCharged,
    status: "pending",
  }).select("id").single();
  if (txErr) return json({ error: "db_error" }, 500);

  const { error: itErr } = await admin.from("transaction_items").insert(
    items.map((i: any) => ({
      transaction_id: tx.id, impact_project_id: i.project_id, amount: round2(i.amount),
    })),
  );
  if (itErr) return json({ error: "db_error" }, 500);

  // 6. Stripe PaymentIntent in minor units, linked back to our tx via metadata
  const pi = await stripe.paymentIntents.create({
    amount: Math.round(amountCharged * 100),
    currency: currency.toLowerCase(),
    automatic_payment_methods: { enabled: true },
    metadata: { transaction_id: String(tx.id), user_id: user.id, type },
  });

  await admin.from("transactions").update({ stripe_pi_id: pi.id }).eq("id", tx.id);

  return json({ clientSecret: pi.client_secret, transactionId: tx.id });
});

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status, headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
const round2 = (n: number) => Math.round(n * 100) / 100;
```

---

## 7. Edge Function — `stripe-webhook`

`backend/supabase/functions/stripe-webhook/index.ts`

```ts
import Stripe from "https://esm.sh/stripe@16?target=deno";
import { createClient } from "jsr:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  httpClient: Stripe.createFetchHttpClient(),
});
const whSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;
const admin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

Deno.serve(async (req) => {
  const sig  = req.headers.get("stripe-signature")!;
  const body = await req.text(); // raw body is REQUIRED for signature verification

  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(body, sig, whSecret);
  } catch {
    return new Response("bad signature", { status: 400 });
  }

  switch (event.type) {
    case "payment_intent.succeeded": {
      const pi = event.data.object as Stripe.PaymentIntent;
      await admin.from("transactions")
        .update({
          status: "succeeded",
          stripe_event_id: event.id,
          net_received: pi.amount_received != null ? pi.amount_received / 100 : null,
          updated_at: new Date().toISOString(),
        })
        .eq("stripe_pi_id", pi.id)
        .neq("status", "succeeded"); // idempotency guard against duplicate webhooks
      // trigger fn_apply_tx_to_projects credits collected_amount
      break;
    }

    case "payment_intent.payment_failed": {
      const pi = event.data.object as Stripe.PaymentIntent;
      await admin.from("transactions")
        .update({
          status: "failed",
          stripe_event_id: event.id,
          failure_reason: pi.last_payment_error?.message ?? null,
        })
        .eq("stripe_pi_id", pi.id)
        .eq("status", "pending");
      break;
    }

    case "charge.refunded": {
      const ch = event.data.object as Stripe.Charge;
      await admin.from("transactions")
        .update({ status: "refunded", stripe_event_id: event.id })
        .eq("stripe_pi_id", ch.payment_intent as string)
        .eq("status", "succeeded"); // trigger reverses collected_amount
      break;
    }
  }

  return new Response("ok", { status: 200 }); // 2xx => Stripe won't retry
});
```

> The webhook must be deployed with `--no-verify-jwt` because Stripe does not send a Supabase JWT. Security comes from the Stripe **signature** check, not from Supabase auth.

---

## 8. Flutter integration

### 8.1 Start a payment

```dart
enum TxType { zakat, donation }

Future<int> startPayment({
  required TxType type,
  required String currency,
  required List<({int projectId, double amount})> items,
  required bool coverFees,
}) async {
  // 1. Backend creates the PaymentIntent + a pending transaction
  final res = await supabase.functions.invoke('create-payment-intent', body: {
    'type': type.name,
    'currency': currency,
    'coverFees': coverFees,
    'items': items
        .map((i) => {'project_id': i.projectId, 'amount': i.amount})
        .toList(),
  });
  final clientSecret = res.data['clientSecret'] as String;
  final txId = res.data['transactionId'] as int;

  // 2. Native Stripe PaymentSheet
  await Stripe.instance.initPaymentSheet(
    paymentSheetParameters: SetupPaymentSheetParameters(
      paymentIntentClientSecret: clientSecret,
      merchantDisplayName: 'Nour Community',
      // applePay / googlePay configuration goes here
    ),
  );
  await Stripe.instance.presentPaymentSheet(); // throws StripeException on cancel/error

  // 3. Sheet closed OK — NOT a confirmation. The caller now watches txId.
  return txId;
}
```

### 8.2 Track the result via Realtime

```dart
Stream<TxStatus> watchTransaction(int txId) {
  return supabase
      .from('transactions')
      .stream(primaryKey: ['id'])
      .eq('id', txId)
      .map((rows) => TxStatus.values.byName(rows.first['status'] as String));
}
```

```dart
// In the payment controller, after startPayment(...)
final txId = await repo.startPayment(...);
state = const PaymentProcessing();

final sub = repo.watchTransaction(txId).listen((status) {
  switch (status) {
    case TxStatus.succeeded: state = const PaymentSuccess();
    case TxStatus.failed:    state = const PaymentFailed();
    default:                 break; // stay in processing
  }
});

// Fallback if the webhook is slow or the app was backgrounded
Future.delayed(const Duration(seconds: 45), () async {
  if (state is PaymentProcessing) {
    final row = await supabase
        .from('transactions').select('status').eq('id', txId).single();
    // re-evaluate; history will reconcile on next open regardless
  }
});
```

The user's donation history and the live `collected_amount` on each project card read the same tables through the normal RLS-protected client — no special API needed.

---

## 9. Admin panel — manual payouts

When `profiles.is_admin = true`, the app exposes admin-only tooling driven by the `payouts` table and a reporting view.

### 9.1 Reporting view — what is owed per project

```sql
create or replace view public.v_project_balances as
select
  p.id                                as project_id,
  p.organization_id,
  ti.type,
  coalesce(sum(ti.amount) filter (where t.status = 'succeeded'), 0) as collected,
  coalesce((select sum(po.amount) from public.payouts po
            where po.impact_project_id = p.id
              and po.type = ti.type
              and po.status = 'confirmed'), 0)                       as paid_out,
  coalesce(sum(ti.amount) filter (where t.status = 'succeeded'), 0)
    - coalesce((select sum(po.amount) from public.payouts po
                where po.impact_project_id = p.id
                  and po.type = ti.type
                  and po.status = 'confirmed'), 0)                   as outstanding
from public.impact_projects p
join public.transaction_items ti on ti.impact_project_id = p.id
join public.transactions t       on t.id = ti.transaction_id
group by p.id, p.organization_id, ti.type;
```

`outstanding = collected(succeeded) − confirmed payouts`, split by `type` so zakat and donations are reported separately. This is the number the admin sees as "left to reverse" for each project / organization.

### 9.2 Admin capabilities

- **See what is owed** — reads `v_project_balances`, grouped by organization and by type.
- **Record a payout** — inserts a `payouts` row (allowed only for admins by RLS) with amount, method, reference, and a `proof_url` receipt.
- **Track by project and cause** — zakat vs donation kept strictly separate.
- **Keep proof** — amount, method, date, and receipt are retained for transparency to donors.

Because partners are not app users, everything about a partner's money lives in `partner_organizations` (identity) + `payouts` (money movement). No partner login is ever created.

---

## 10. Shariah & compliance notes

- **Zakat arrives in full.** The zakat body (`amount_total`) is always distributed to projects intact. Fees live in `fee_covered` / `amount_charged` and are either absorbed by Nour or added on top by the donor (`coverFees`), never subtracted from the zakat.
- **No mixing.** Zakat and Sadaqa are separated from payment through payout; a single payout is one `type` only.
- **Delivery proof.** Surface a "funds delivered" state to donors from confirmed payouts — this addresses the fiqh concern of whether the obligation was actually discharged.
- **Legal status (EU).** Nour is EU-registered and collects funds on its own account before reversing them. Collecting on behalf of others may fall under fundraising / payment regulation. Confirm with a local lawyer whether Nour should register as an association/charity or formalize its status as a `wakil` (agent) in its Terms. Build as if the money is in transit and not Nour's revenue.

---

## 11. What YOU need to configure

This section is the hands-on checklist to make the system live.

### 11.1 Stripe Dashboard

1. **Get your API keys** — Stripe Dashboard → *Developers → API keys*:
   - `Publishable key` (`pk_live_…` / `pk_test_…`) → goes into the **Flutter app**.
   - `Secret key` (`sk_live_…` / `sk_test_…`) → goes into **Supabase secrets** (never in the app).
2. **Enable payment methods** — *Settings → Payment methods*: turn on Cards, and Apple Pay / Google Pay if you want them in the PaymentSheet.
3. **Apple Pay / Google Pay setup** (optional but recommended for mobile):
   - Apple Pay: register a Merchant ID in the Apple Developer portal and add it in Stripe → *Settings → Apple Pay*; add the entitlement in Xcode.
   - Google Pay: enable it in Stripe; set your merchant name; no extra keys needed for test mode.
4. **Create the webhook endpoint** — *Developers → Webhooks → Add endpoint*:
   - URL: `https://<PROJECT_REF>.supabase.co/functions/v1/stripe-webhook`
   - Events to send: `payment_intent.succeeded`, `payment_intent.payment_failed`, `charge.refunded`.
   - After creating it, copy the **Signing secret** (`whsec_…`) → goes into Supabase secrets as `STRIPE_WEBHOOK_SECRET`.
5. **Start in Test mode.** Use `pk_test` / `sk_test` and Stripe's test cards (e.g. `4242 4242 4242 4242`) until the whole flow works, then switch to live keys.

### 11.2 Supabase secrets (server side)

Set the secrets the Edge Functions read. `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` are injected automatically by the platform for deployed functions — you only add the Stripe ones:

```bash
cd backend
supabase secrets set \
  STRIPE_SECRET_KEY=sk_test_xxx \
  STRIPE_WEBHOOK_SECRET=whsec_xxx
```

> `SERVICE_ROLE_KEY` is extremely sensitive — it bypasses RLS. It only ever lives in Edge Function env, never in the app or client code.

### 11.3 Apply migrations & deploy functions

```bash
cd backend

# 1. Add a new migration file with the schema from sections 2–4, then:
supabase db push                      # apply to the linked remote project

# 2. Deploy the functions
supabase functions deploy create-payment-intent          # JWT-verified (default)
supabase functions deploy stripe-webhook --no-verify-jwt # Stripe has no Supabase JWT

# 3. Enable Realtime on the transactions table (once)
#    Run in the SQL editor / a migration:
#    alter publication supabase_realtime add table public.transactions;
```

### 11.4 Flutter app config

1. Add the dependency:

   ```yaml
   # pubspec.yaml
   dependencies:
     flutter_stripe: ^11.1.0   # check latest
   ```

2. Initialize Stripe once at startup with the **publishable** key (keep it out of source control — use `--dart-define`):

   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     Stripe.publishableKey = const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
     await Stripe.instance.applySettings();
     runApp(const App());
   }
   ```

   ```bash
   flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_xxx
   ```

3. **Platform requirements** for `flutter_stripe`:
   - **iOS:** minimum deployment target **13.0** (`ios/Podfile` + Xcode). For Apple Pay, add the Merchant ID capability.
   - **Android:** the app's theme must extend an `AppCompat`/`MaterialComponents` theme; `minSdkVersion` ≥ 21.

### 11.5 Go-live checklist

- [ ] Full flow verified end-to-end in **test mode** (pay → webhook → `succeeded` → `collected_amount` bumped → app shows success via Realtime).
- [ ] Refund test: issue a refund in Stripe → transaction becomes `refunded` → `collected_amount` reverses.
- [ ] Duplicate-webhook test: replay the event in Stripe → amount is **not** double-counted.
- [ ] Zakat guard test: attempt zakat on a non-eligible project → rejected by `create-payment-intent`.
- [ ] Swap test keys for **live** keys in Supabase secrets and the app's `--dart-define`.
- [ ] Recreate the webhook endpoint in **live** mode and update `STRIPE_WEBHOOK_SECRET`.
- [ ] Legal status of fund collection confirmed with a lawyer (EU).

---

## 12. Environment variable reference

| Variable | Where | Purpose |
|---|---|---|
| `STRIPE_SECRET_KEY` | Supabase secrets | Server-side Stripe API calls (create PaymentIntent, verify) |
| `STRIPE_WEBHOOK_SECRET` | Supabase secrets | Verify webhook signatures |
| `SUPABASE_URL` | auto (functions) | Base URL for the service-role client |
| `SUPABASE_ANON_KEY` | auto (functions) | Build the per-request user client |
| `SUPABASE_SERVICE_ROLE_KEY` | auto (functions) | Bypass RLS to write money rows |
| `STRIPE_PUBLISHABLE_KEY` | Flutter `--dart-define` | Initialize the client SDK / PaymentSheet |

---

*This document supersedes the transaction model in `20260515000800_transactions.sql`. Introduce the changes as a new migration (do not edit the historical one) and keep zakat and donations separated across the whole pipeline.*
