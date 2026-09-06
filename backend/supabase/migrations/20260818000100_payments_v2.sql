-- =============================================================================
-- Payments V2 (2/3): schema for the redesigned donation flow.
-- See docs/PAYMENTS_V2_PLAN.md.
--
--   * impact_projects: image gallery, preset amounts, Stripe product id
--   * impact_project_tiers ("Your donation provides")
--   * profiles.stripe_customer_id
--   * donation_subscriptions (recurring — monthly / yearly, per project)
--   * transactions: subscription link, invoice id, anonymity, payment method,
--     partial refunds, client idempotency key
--   * stripe_events (hard webhook idempotency)
--   * fn_apply_tx_to_projects v2: INSERT-aware, distinct donors, ajr award
--   * fn_project_recent_donors (non-anonymous avatars for the progress card)
--   * abandoned-intent cleanup (pg_cron when available)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. impact_projects additions
-- -----------------------------------------------------------------------------
alter table public.impact_projects
  add column if not exists images            text[]  not null default '{}',
  add column if not exists preset_amounts    int[]   not null default '{10,50,100,150}',
  add column if not exists stripe_product_id text;

comment on column public.impact_projects.images is
  'Gallery shown in the detail carousel (cover first). cover_image_url stays the list thumbnail / fallback.';
comment on column public.impact_projects.preset_amounts is
  'Quick amounts offered in the "Donate how much?" sheet.';

-- Backfill: every project starts with its cover as the only gallery image.
update public.impact_projects
   set images = array[cover_image_url]
 where cover_image_url is not null
   and cardinality(images) = 0;

-- -----------------------------------------------------------------------------
-- 2. impact_project_tiers — "Your donation provides"
-- -----------------------------------------------------------------------------
create table if not exists public.impact_project_tiers (
  id                bigserial primary key,
  impact_project_id bigint not null references public.impact_projects(id) on delete cascade,
  amount            numeric(12,2) not null check (amount > 0),
  title_en          text not null,
  title_fr          text not null,
  title_ar          text not null,
  title_de          text, title_nl text, title_tr text, title_id text,
  title_ur          text, title_bn text, title_ms text, title_ru text,
  subtitle_en       text,
  subtitle_fr       text,
  subtitle_ar       text,
  subtitle_de       text, subtitle_nl text, subtitle_tr text, subtitle_id text,
  subtitle_ur       text, subtitle_bn text, subtitle_ms text, subtitle_ru text,
  position          int not null default 0,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index if not exists impact_project_tiers_project_idx
  on public.impact_project_tiers(impact_project_id, position);

drop trigger if exists trg_impact_project_tiers_updated_at on public.impact_project_tiers;
create trigger trg_impact_project_tiers_updated_at
  before update on public.impact_project_tiers
  for each row execute function public.set_updated_at();

alter table public.impact_project_tiers enable row level security;

drop policy if exists impact_project_tiers_read on public.impact_project_tiers;
create policy impact_project_tiers_read on public.impact_project_tiers
  for select to authenticated using (true);

drop policy if exists impact_project_tiers_admin_write on public.impact_project_tiers;
create policy impact_project_tiers_admin_write on public.impact_project_tiers
  for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- -----------------------------------------------------------------------------
-- 3. profiles.stripe_customer_id (one Stripe Customer per user, created lazily
--    by the create-subscription function).
-- -----------------------------------------------------------------------------
alter table public.profiles
  add column if not exists stripe_customer_id text;

create unique index if not exists profiles_stripe_customer_uniq
  on public.profiles(stripe_customer_id) where stripe_customer_id is not null;

-- -----------------------------------------------------------------------------
-- 4. Recurring donations
-- -----------------------------------------------------------------------------
do $$ begin
  create type public.donation_interval as enum ('month','year');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.subscription_status as enum
    ('incomplete','active','past_due','canceled','unpaid','paused');
exception when duplicate_object then null; end $$;

create table if not exists public.donation_subscriptions (
  id                     bigserial primary key,
  user_id                uuid not null references public.profiles(id) on delete restrict,
  impact_project_id      bigint not null references public.impact_projects(id) on delete restrict,
  type                   public.tx_type not null default 'donation' check (type = 'donation'),
  amount                 numeric(12,2) not null check (amount > 0),   -- body per period
  fee_covered            numeric(12,2) not null default 0,            -- per period, if donor covers fees
  currency               public.currency_type not null default 'EUR',
  interval               public.donation_interval not null,
  status                 public.subscription_status not null default 'incomplete',
  is_anonymous           boolean not null default false,
  payment_method         text,                                        -- card|apple_pay|google_pay|paypal
  stripe_subscription_id text unique,
  stripe_customer_id     text,
  current_period_end     timestamptz,
  cancel_at_period_end   boolean not null default false,
  canceled_at            timestamptz,
  client_key             text unique,                                 -- client idempotency key
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);

create index if not exists donation_subscriptions_user_idx
  on public.donation_subscriptions(user_id, created_at desc);
create index if not exists donation_subscriptions_project_idx
  on public.donation_subscriptions(impact_project_id);
create index if not exists donation_subscriptions_status_idx
  on public.donation_subscriptions(status);

drop trigger if exists trg_donation_subscriptions_updated_at on public.donation_subscriptions;
create trigger trg_donation_subscriptions_updated_at
  before update on public.donation_subscriptions
  for each row execute function public.set_updated_at();

alter table public.donation_subscriptions enable row level security;

-- Users read their own subscriptions; admins read all. No client writes.
drop policy if exists donation_subscriptions_self_read on public.donation_subscriptions;
create policy donation_subscriptions_self_read on public.donation_subscriptions
  for select to authenticated
  using (user_id = auth.uid() or public.is_admin());

-- Realtime: the app watches its own subscription row until the first invoice
-- is paid (status -> active).
do $$ begin
  alter publication supabase_realtime add table public.donation_subscriptions;
exception when duplicate_object then null; end $$;

-- -----------------------------------------------------------------------------
-- 5. transactions additions
-- -----------------------------------------------------------------------------
alter table public.transactions
  add column if not exists subscription_id   bigint references public.donation_subscriptions(id) on delete set null,
  add column if not exists stripe_invoice_id text,
  add column if not exists is_anonymous      boolean not null default false,
  add column if not exists payment_method    text,
  add column if not exists amount_refunded   numeric(12,2) not null default 0,
  add column if not exists client_key        text;

create unique index if not exists tx_stripe_invoice_uniq
  on public.transactions(stripe_invoice_id) where stripe_invoice_id is not null;
create unique index if not exists tx_client_key_uniq
  on public.transactions(client_key) where client_key is not null;
create index if not exists tx_subscription_idx
  on public.transactions(subscription_id) where subscription_id is not null;

comment on column public.transactions.is_anonymous is
  'Donor chose "Make this anonymous": excluded from public donor lists/avatars, still counted in aggregates.';

-- -----------------------------------------------------------------------------
-- 6. stripe_events — processed webhook events (hard idempotency, service role only)
-- -----------------------------------------------------------------------------
create table if not exists public.stripe_events (
  id         text primary key,          -- evt_...
  type       text not null,
  created_at timestamptz not null default now()
);
alter table public.stripe_events enable row level security;  -- no policies: service_role only

-- -----------------------------------------------------------------------------
-- 7. fn_apply_tx_to_projects v2
--    * fires on INSERT (rows created directly as `succeeded`, e.g. subscription
--      invoices) and on status UPDATE
--    * donors_count counts DISTINCT donors per project (repeat gifts don't inflate)
--    * awards a fixed ajr once per succeeded transaction (source='donation')
--      and marks the daily quick action for the streak
-- -----------------------------------------------------------------------------
create or replace function public.fn_apply_tx_to_projects()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_became_succeeded boolean := false;
  v_became_refunded  boolean := false;
  c_donation_ajr     constant int := 50;
begin
  if tg_op = 'INSERT' then
    v_became_succeeded := new.status = 'succeeded';
  else
    v_became_succeeded := new.status = 'succeeded' and old.status is distinct from 'succeeded';
    v_became_refunded  := new.status = 'refunded'  and old.status = 'succeeded';
  end if;

  if v_became_succeeded then
    update public.impact_projects p
       set collected_amount = p.collected_amount + i.amount,
           donors_count     = p.donors_count + case
             when exists (
               select 1
                 from public.transactions t2
                 join public.transaction_items i2 on i2.transaction_id = t2.id
                where t2.user_id = new.user_id
                  and t2.status  = 'succeeded'
                  and t2.id     <> new.id
                  and i2.impact_project_id = i.impact_project_id
             ) then 0 else 1 end
      from public.transaction_items i
     where i.transaction_id = new.id
       and p.id = i.impact_project_id;

    -- Ajr for the deed (once per transaction).
    if not exists (
      select 1 from public.ajr_log
       where user_id = new.user_id and source = 'donation' and source_id = new.id
    ) then
      insert into public.ajr_log (user_id, earned_ajr, source, source_id)
      values (new.user_id, c_donation_ajr, 'donation', new.id);

      begin
        perform public.fn_mark_daily_activity(new.user_id, 'quick_action');
      exception when others then
        -- Streak bookkeeping must never block a payment confirmation.
        null;
      end;
    end if;

  elsif v_became_refunded then
    update public.impact_projects p
       set collected_amount = greatest(0, p.collected_amount - i.amount),
           donors_count     = greatest(0, p.donors_count - case
             when exists (
               select 1
                 from public.transactions t2
                 join public.transaction_items i2 on i2.transaction_id = t2.id
                where t2.user_id = new.user_id
                  and t2.status  = 'succeeded'
                  and t2.id     <> new.id
                  and i2.impact_project_id = i.impact_project_id
             ) then 0 else 1 end)
      from public.transaction_items i
     where i.transaction_id = new.id
       and p.id = i.impact_project_id;
  end if;

  return new;
end $$;

drop trigger if exists trg_tx_apply on public.transactions;
create trigger trg_tx_apply
  after insert or update of status on public.transactions
  for each row execute function public.fn_apply_tx_to_projects();

-- -----------------------------------------------------------------------------
-- 8. Recent (non-anonymous) donors for the progress card avatars.
--    SECURITY DEFINER because transactions RLS hides other users' rows.
--    Only exposes avatar + first name of donors who did NOT opt out.
-- -----------------------------------------------------------------------------
create or replace function public.fn_project_recent_donors(
  p_project_id bigint,
  p_limit      int default 3
)
returns table (user_id uuid, avatar_url text, name text)
language sql
stable
security definer
set search_path = public
as $$
  select d.user_id, pr.avatar_url, pr.name
    from (
      select t.user_id, max(t.created_at) as last_at
        from public.transactions t
        join public.transaction_items i on i.transaction_id = t.id
       where i.impact_project_id = p_project_id
         and t.status = 'succeeded'
         and t.is_anonymous = false
       group by t.user_id
       order by last_at desc
       limit greatest(1, least(coalesce(p_limit, 3), 10))
    ) d
    join public.profiles pr on pr.id = d.user_id;
$$;

revoke execute on function public.fn_project_recent_donors(bigint, int) from public;
grant execute on function public.fn_project_recent_donors(bigint, int) to authenticated;

-- -----------------------------------------------------------------------------
-- 9. Abandoned PaymentIntents: a `pending` row older than 24h whose sheet was
--    dismissed / never confirmed becomes `failed` (Stripe never sends an event
--    for an unconfirmed PI). Scheduled with pg_cron when the extension exists.
-- -----------------------------------------------------------------------------
create or replace function public.fn_expire_pending_transactions()
returns int
language plpgsql
security definer
set search_path = public
as $$
declare v_count int;
begin
  update public.transactions
     set status = 'failed',
         failure_reason = coalesce(failure_reason, 'abandoned')
   where status = 'pending'
     and created_at < now() - interval '24 hours';
  get diagnostics v_count = row_count;
  return v_count;
end $$;

revoke execute on function public.fn_expire_pending_transactions() from public;

do $$
begin
  begin
    create extension if not exists pg_cron;
  exception when others then
    raise notice 'pg_cron not available (%). Enable it in Supabase Dashboard > Database > Extensions, then run: select cron.schedule(''payments-expire-pending'', ''17 * * * *'', ''select public.fn_expire_pending_transactions()'');', sqlerrm;
  end;

  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    perform cron.unschedule(jobid) from cron.job where jobname = 'payments-expire-pending';
    perform cron.schedule(
      'payments-expire-pending',
      '17 * * * *',
      'select public.fn_expire_pending_transactions()'
    );
  end if;
end $$;

-- -----------------------------------------------------------------------------
-- 10. Admin: subscriptions overview (for the admin dashboard, optional use).
-- -----------------------------------------------------------------------------
create or replace function public.fn_admin_subscription_summary()
returns table (
  project_id     bigint,
  active_count   bigint,
  monthly_amount numeric,   -- sum of active monthly bodies
  yearly_amount  numeric    -- sum of active yearly bodies
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
  select s.impact_project_id,
         count(*) filter (where s.status = 'active'),
         coalesce(sum(s.amount) filter (where s.status = 'active' and s.interval = 'month'), 0),
         coalesce(sum(s.amount) filter (where s.status = 'active' and s.interval = 'year'), 0)
    from public.donation_subscriptions s
   group by s.impact_project_id;
end $$;

grant execute on function public.fn_admin_subscription_summary() to authenticated;
