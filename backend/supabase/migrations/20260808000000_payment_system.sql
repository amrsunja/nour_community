-- =============================================================================
-- Nour Community :: New Payment System (Zakat & Donations)
-- -----------------------------------------------------------------------------
-- Supersedes the naïve transaction model in 20260515000800_transactions.sql.
-- Introduces a single status-aware `transactions` table (+ `transaction_items`)
-- driven by Stripe webhooks, and a manual `payouts` ledger (owner -> partner)
-- with disbursement proofs for donor transparency.
--
-- Guiding principles (see docs/new_payment_system_logic.md):
--   * The server is the source of truth for money, never the client.
--   * A payment counts only after Stripe confirms it via webhook.
--   * `impact_projects.collected_amount` moves ONLY on status transitions.
--   * Idempotency everywhere (unique stripe_pi_id + status guards).
--   * Zakat and Donations are tracked separately end to end.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. Drop the legacy transaction model (tables + trigger fn).
--    Only transaction-related objects are dropped — profiles, dhikrs, impact
--    catalog, etc. are untouched.
-- -----------------------------------------------------------------------------
drop trigger if exists trg_zakat_tx_bump    on public.zakat_transactions;
drop trigger if exists trg_donation_tx_bump on public.donation_transactions;
drop table   if exists public.zakat_transactions    cascade;
drop table   if exists public.donation_transactions cascade;
drop function if exists public.fn_bump_project_collected() cascade;

-- -----------------------------------------------------------------------------
-- 1. Enums
-- -----------------------------------------------------------------------------
do $$ begin
  create type public.tx_status as enum ('pending','processing','succeeded','failed','refunded');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.tx_type as enum ('zakat','donation');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.payout_method as enum ('bank','wise','cash','other');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.payout_status as enum ('pending','sent','confirmed');
exception when duplicate_object then null; end $$;

-- -----------------------------------------------------------------------------
-- 2.2 transactions — one row per Stripe PaymentIntent
-- -----------------------------------------------------------------------------
create table if not exists public.transactions (
  id                bigserial primary key,
  user_id           uuid not null references public.profiles(id) on delete restrict,
  type              public.tx_type not null,
  status            public.tx_status not null default 'pending',
  currency          public.currency_type not null default 'EUR',

  amount_total      numeric(12,2) not null check (amount_total > 0), -- body: what reaches the projects
  fee_covered       numeric(12,2) not null default 0,                -- Stripe fee, only if donor opted to cover it
  amount_charged    numeric(12,2) not null,                          -- card charge = amount_total + fee_covered
  net_received      numeric(12,2),                                   -- after Stripe fee (from webhook)

  stripe_pi_id      text unique,                                     -- PaymentIntent id — idempotency key
  stripe_event_id   text,                                            -- last processed Stripe event id
  failure_reason    text,

  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index if not exists tx_user_idx    on public.transactions(user_id);
create index if not exists tx_status_idx  on public.transactions(status);
create index if not exists tx_created_idx on public.transactions(created_at desc);
create index if not exists tx_type_idx    on public.transactions(type);

drop trigger if exists trg_transactions_updated_at on public.transactions;
create trigger trg_transactions_updated_at
  before update on public.transactions
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- 2.3 transaction_items — per-project breakdown
--     Invariant: sum(transaction_items.amount) == transactions.amount_total
-- -----------------------------------------------------------------------------
create table if not exists public.transaction_items (
  id                bigserial primary key,
  transaction_id    bigint not null references public.transactions(id) on delete cascade,
  impact_project_id bigint not null references public.impact_projects(id) on delete restrict,
  amount            numeric(12,2) not null check (amount > 0)
);

create index if not exists tx_items_tx_idx      on public.transaction_items(transaction_id);
create index if not exists tx_items_project_idx on public.transaction_items(impact_project_id);

-- -----------------------------------------------------------------------------
-- 2.4 payouts — manual reversal ledger (owner -> partner)
--     Zakat and Donation are NEVER mixed in one payout (see `type`).
-- -----------------------------------------------------------------------------
create table if not exists public.payouts (
  id                bigserial primary key,
  organization_id   bigint not null references public.partner_organizations(id) on delete restrict,
  impact_project_id bigint references public.impact_projects(id) on delete restrict, -- null = general to org
  type              public.tx_type not null,
  amount            numeric(12,2) not null check (amount > 0),
  currency          public.currency_type not null default 'EUR',
  method            public.payout_method not null,
  status            public.payout_status not null default 'pending',
  reference         text,                              -- bank/Wise transfer reference
  proof_url         text,                              -- receipt object path in the payout-proofs bucket
  note              text,
  created_by        uuid not null references public.profiles(id) on delete restrict, -- admin who recorded it
  executed_at       timestamptz,                       -- when the transfer actually happened
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index if not exists payouts_org_idx     on public.payouts(organization_id);
create index if not exists payouts_project_idx on public.payouts(impact_project_id);
create index if not exists payouts_type_idx    on public.payouts(type);
create index if not exists payouts_status_idx  on public.payouts(status);

drop trigger if exists trg_payouts_updated_at on public.payouts;
create trigger trg_payouts_updated_at
  before update on public.payouts
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- 2.5 payout_items — full audit trail (which transaction_items each payout settled)
-- -----------------------------------------------------------------------------
create table if not exists public.payout_items (
  id                  bigserial primary key,
  payout_id           bigint not null references public.payouts(id) on delete cascade,
  transaction_item_id bigint not null references public.transaction_items(id) on delete restrict
);

create index if not exists payout_items_payout_idx on public.payout_items(payout_id);
create index if not exists payout_items_txitem_idx on public.payout_items(transaction_item_id);

-- =============================================================================
-- 3. Triggers — keep collected_amount (and donors_count) honest
--    Credit/debit projects ONLY on status transitions, never on insert.
-- =============================================================================
create or replace function public.fn_apply_tx_to_projects()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- pending/processing -> succeeded : credit each project + bump donors_count.
  if new.status = 'succeeded' and old.status is distinct from 'succeeded' then
    update public.impact_projects p
       set collected_amount = collected_amount + i.amount,
           donors_count     = donors_count + 1
      from public.transaction_items i
     where i.transaction_id = new.id
       and p.id = i.impact_project_id;

  -- succeeded -> refunded : reverse the credit + donors_count.
  elsif new.status = 'refunded' and old.status = 'succeeded' then
    update public.impact_projects p
       set collected_amount = greatest(0, collected_amount - i.amount),
           donors_count     = greatest(0, donors_count - 1)
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

-- =============================================================================
-- 4. Row Level Security
--    Clients can only READ their own transactions. All money writes happen in
--    Edge Functions running with service_role (bypasses RLS). There is
--    deliberately NO insert/update policy for authenticated on transactions.
-- =============================================================================
alter table public.transactions      enable row level security;
alter table public.transaction_items enable row level security;
alter table public.payouts           enable row level security;
alter table public.payout_items      enable row level security;

-- Users read their own transactions; admins read all.
drop policy if exists tx_self_read on public.transactions;
create policy tx_self_read on public.transactions
  for select to authenticated
  using (user_id = auth.uid() or public.is_admin());

drop policy if exists tx_items_self_read on public.transaction_items;
create policy tx_items_self_read on public.transaction_items
  for select to authenticated
  using (
    exists (
      select 1 from public.transactions t
      where t.id = transaction_id
        and (t.user_id = auth.uid() or public.is_admin())
    )
  );

-- NOTE: no insert/update/delete policies for authenticated => clients cannot
-- write money rows. Edge Functions use service_role which bypasses RLS.

-- Payouts: admin can do everything.
drop policy if exists payouts_admin_all on public.payouts;
create policy payouts_admin_all on public.payouts
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- Transparency: any authenticated user may READ CONFIRMED payouts (the public
-- disbursement proofs shown on project pages). Pending/sent stay admin-only.
drop policy if exists payouts_public_confirmed_read on public.payouts;
create policy payouts_public_confirmed_read on public.payouts
  for select to authenticated
  using (status = 'confirmed');

-- payout_items: admin-only (internal audit trail).
drop policy if exists payout_items_admin_all on public.payout_items;
create policy payout_items_admin_all on public.payout_items
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- =============================================================================
-- 5. Reporting view — what is owed per project, split by type
--    outstanding = collected(succeeded) - confirmed payouts
-- =============================================================================
create or replace view public.v_project_balances
  with (security_invoker = on) as
select
  p.id                                as project_id,
  p.organization_id,
  t.type,
  coalesce(sum(ti.amount) filter (where t.status = 'succeeded'), 0) as collected,
  coalesce((select sum(po.amount) from public.payouts po
            where po.impact_project_id = p.id
              and po.type = t.type
              and po.status = 'confirmed'), 0)                       as paid_out,
  coalesce(sum(ti.amount) filter (where t.status = 'succeeded'), 0)
    - coalesce((select sum(po.amount) from public.payouts po
                where po.impact_project_id = p.id
                  and po.type = t.type
                  and po.status = 'confirmed'), 0)                   as outstanding
from public.impact_projects p
join public.transaction_items ti on ti.impact_project_id = p.id
join public.transactions t       on t.id = ti.transaction_id
group by p.id, p.organization_id, t.type;

-- The view runs with the querying user's privileges (security invoker). Only
-- admins can meaningfully read cross-user aggregates because transaction_items
-- RLS limits non-admins to their own rows.
comment on view public.v_project_balances is
  'Per-project, per-type collected/paid_out/outstanding. Admin reporting for payouts.';

-- =============================================================================
-- 6. Admin analytics RPC — global + per-project donation aggregates.
--    SECURITY DEFINER so it can aggregate across all users, but it hard-gates
--    on public.is_admin() so only admins get data.
-- =============================================================================
create or replace function public.fn_admin_project_analytics()
returns table (
  project_id       bigint,
  organization_id  bigint,
  type             public.tx_type,
  donors_count     bigint,
  total_donated    numeric,
  paid_out         numeric,
  outstanding      numeric
)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'forbidden: admin only';
  end if;

  return query
  select
    p.id,
    p.organization_id,
    t.type,
    count(distinct t.user_id) filter (where t.status = 'succeeded')      as donors_count,
    coalesce(sum(ti.amount)   filter (where t.status = 'succeeded'), 0)  as total_donated,
    coalesce((select sum(po.amount) from public.payouts po
              where po.impact_project_id = p.id
                and po.type = t.type
                and po.status = 'confirmed'), 0)                          as paid_out,
    coalesce(sum(ti.amount)   filter (where t.status = 'succeeded'), 0)
      - coalesce((select sum(po.amount) from public.payouts po
                  where po.impact_project_id = p.id
                    and po.type = t.type
                    and po.status = 'confirmed'), 0)                      as outstanding
  from public.impact_projects p
  join public.transaction_items ti on ti.impact_project_id = p.id
  join public.transactions t       on t.id = ti.transaction_id
  group by p.id, p.organization_id, t.type;
end $$;

grant execute on function public.fn_admin_project_analytics() to authenticated;

-- =============================================================================
-- 7. Storage — private `payout-proofs` bucket for disbursement receipts.
--    Admin-write; authenticated read (so signed URLs can be minted for the
--    transparency section). Not world-public like project-stories.
-- =============================================================================
insert into storage.buckets (id, name, public)
values ('payout-proofs', 'payout-proofs', false)
on conflict (id) do nothing;

drop policy if exists "payout-proofs: authenticated read" on storage.objects;
create policy "payout-proofs: authenticated read"
  on storage.objects for select to authenticated
  using (bucket_id = 'payout-proofs');

drop policy if exists "payout-proofs: admin write" on storage.objects;
create policy "payout-proofs: admin write"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'payout-proofs'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
  );

drop policy if exists "payout-proofs: admin update" on storage.objects;
create policy "payout-proofs: admin update"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'payout-proofs'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
  );

drop policy if exists "payout-proofs: admin delete" on storage.objects;
create policy "payout-proofs: admin delete"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'payout-proofs'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
  );

-- =============================================================================
-- 8. Realtime — the app subscribes to its own transaction row to learn when
--    the webhook flips status to `succeeded`.
-- =============================================================================
do $$ begin
  alter publication supabase_realtime add table public.transactions;
exception when duplicate_object then null; end $$;

-- =============================================================================
-- 9. Repoint fn_user_statistics.completed_deeds at the NEW transaction model.
--    The previous definition (20260805000000) counted `donation_transactions`,
--    which this migration drops. Same signature/columns/contract — only the
--    `completed_deeds` source changes: distinct SUCCEEDED transactions for the
--    caller (a completed charitable deed). Kept SECURITY DEFINER + auth.uid()
--    scoping so the profile Statistics page keeps working unchanged.
-- =============================================================================
create or replace function public.fn_user_statistics(p_from timestamptz default null)
returns table (
  earned_ajr      bigint,
  dhikr_completed bigint,
  completed_deeds bigint,
  active_days     bigint,
  ayahs_read      bigint,
  hadiths_read    bigint,
  duas_recited    bigint
)
language sql
stable
security definer
set search_path = public
as $$
  select
    coalesce((
      select sum(earned_ajr)
        from public.ajr_log
       where user_id = auth.uid()
         and (p_from is null or created_at >= p_from)
    ), 0)::bigint as earned_ajr,

    coalesce((
      select count(*)
        from public.ajr_log
       where user_id = auth.uid()
         and source = 'dhikr'
         and (p_from is null or created_at >= p_from)
    ), 0)::bigint as dhikr_completed,

    coalesce((
      select count(*)
        from public.transactions
       where user_id = auth.uid()
         and status = 'succeeded'
         and (p_from is null or created_at >= p_from)
    ), 0)::bigint as completed_deeds,

    coalesce((
      select count(distinct (created_at at time zone 'utc')::date)
        from public.ajr_log
       where user_id = auth.uid()
         and (p_from is null or created_at >= p_from)
    ), 0)::bigint as active_days,

    coalesce((
      select count(*)
        from public.ajr_log
       where user_id = auth.uid()
         and source = 'ayah'
         and (p_from is null or created_at >= p_from)
    ), 0)::bigint as ayahs_read,

    coalesce((
      select count(*)
        from public.ajr_log
       where user_id = auth.uid()
         and source = 'hadith'
         and (p_from is null or created_at >= p_from)
    ), 0)::bigint as hadiths_read,

    coalesce((
      select count(*)
        from public.ajr_log
       where user_id = auth.uid()
         and source = 'dua'
         and (p_from is null or created_at >= p_from)
    ), 0)::bigint as duas_recited;
$$;

grant execute on function public.fn_user_statistics(timestamptz) to authenticated;
