-- =============================================================================
-- Mosques module (P3) — donations via Stripe Connect (direct charges).
--   * mosque_stripe_accounts, mosque_donation_settings, campaign updates,
--     mosque_receipts
--   * transactions / donation_subscriptions: ADDITIVE columns (mosque_id,
--     mosque_campaign_id, membership_id, stripe_account_id), relaxed checks
--   * fn_apply_tx_to_mosque (campaign progress), stats / donors RPCs, RLS
-- See docs/MOSQUES_MODULE_IMPLEMENTATION.md §10
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. New tables
-- -----------------------------------------------------------------------------
create table if not exists public.mosque_stripe_accounts (
  mosque_id         bigint primary key references public.mosques(id) on delete cascade,
  stripe_account_id text not null unique,
  status            public.stripe_account_status not null default 'not_started',
  charges_enabled   boolean not null default false,
  payouts_enabled   boolean not null default false,
  details_submitted boolean not null default false,
  requirements      jsonb not null default '{}'::jsonb,
  onboarded_at      timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);
drop trigger if exists trg_msa_updated_at on public.mosque_stripe_accounts;
create trigger trg_msa_updated_at before update on public.mosque_stripe_accounts
  for each row execute function public.set_updated_at();

create table if not exists public.mosque_donation_settings (
  mosque_id              bigint primary key references public.mosques(id) on delete cascade,
  title                  text not null default 'Support the mosque',
  description            text,
  suggested_amounts      int[] not null default '{10,50,100,150}',
  allow_one_time         boolean not null default true,
  allow_monthly          boolean not null default true,
  allow_yearly           boolean not null default true,
  show_tax_badge         boolean not null default false,
  membership_fee_amounts int[] not null default '{60,120,240}',
  updated_at             timestamptz not null default now()
);
drop trigger if exists trg_mds_updated_at on public.mosque_donation_settings;
create trigger trg_mds_updated_at before update on public.mosque_donation_settings
  for each row execute function public.set_updated_at();

-- Tax badge only when the mosque declared it may issue receipts.
create or replace function public.fn_mds_guard() returns trigger language plpgsql as $$
begin
  if new.show_tax_badge and not exists (select 1 from public.mosques m where m.id = new.mosque_id and m.can_issue_tax_receipts) then
    new.show_tax_badge := false;
  end if;
  return new;
end $$;
drop trigger if exists trg_mds_guard on public.mosque_donation_settings;
create trigger trg_mds_guard before insert or update on public.mosque_donation_settings
  for each row execute function public.fn_mds_guard();

create table if not exists public.mosque_campaign_updates (
  id          bigserial primary key,
  campaign_id bigint not null references public.mosque_campaigns(id) on delete cascade,
  mosque_id   bigint not null references public.mosques(id) on delete cascade,
  body        text not null,
  image_url   text,
  created_at  timestamptz not null default now()
);
create index if not exists mcu_idx on public.mosque_campaign_updates(campaign_id, created_at desc);

create table if not exists public.mosque_receipts (
  id             bigserial primary key,
  mosque_id      bigint not null references public.mosques(id) on delete cascade,
  user_id        uuid   not null references public.profiles(id) on delete cascade,
  transaction_id bigint references public.transactions(id) on delete set null,
  year           int not null,
  number         text not null,
  amount         numeric(12,2) not null,
  storage_path   text not null,
  emailed_at     timestamptz,
  created_at     timestamptz not null default now(),
  unique (mosque_id, number)
);
create index if not exists mosque_receipts_user_idx on public.mosque_receipts(user_id, created_at desc);
create index if not exists mosque_receipts_mosque_idx on public.mosque_receipts(mosque_id, year);

-- Campaign limit: max 3 active (devis B3).
create or replace function public.fn_mosque_campaigns_limit() returns trigger language plpgsql as $$
declare v_count int;
begin
  if new.status <> 'active' then return new; end if;
  if tg_op = 'UPDATE' and old.status = 'active' then return new; end if;
  select count(*) into v_count from public.mosque_campaigns
   where mosque_id = new.mosque_id and status = 'active' and id <> coalesce(new.id, 0);
  if v_count >= 3 then raise exception 'campaign_limit_reached'; end if;
  return new;
end $$;
drop trigger if exists trg_mosque_campaigns_limit on public.mosque_campaigns;
create trigger trg_mosque_campaigns_limit before insert or update of status on public.mosque_campaigns
  for each row execute function public.fn_mosque_campaigns_limit();

-- -----------------------------------------------------------------------------
-- 2. Reuse the existing ledger — ADDITIVE only
-- -----------------------------------------------------------------------------
alter table public.transactions
  add column if not exists mosque_id          bigint references public.mosques(id) on delete restrict,
  add column if not exists mosque_campaign_id bigint references public.mosque_campaigns(id) on delete restrict,
  add column if not exists membership_id      bigint references public.mosque_members(id) on delete set null,
  add column if not exists stripe_account_id  text;
create index if not exists tx_mosque_idx on public.transactions(mosque_id, status, created_at desc) where mosque_id is not null;
create index if not exists tx_campaign_idx on public.transactions(mosque_campaign_id) where mosque_campaign_id is not null;

alter table public.donation_subscriptions alter column impact_project_id drop not null;
alter table public.donation_subscriptions drop constraint if exists donation_subscriptions_type_check;
alter table public.donation_subscriptions
  add column if not exists mosque_id         bigint references public.mosques(id) on delete restrict,
  add column if not exists membership_id     bigint references public.mosque_members(id) on delete set null,
  add column if not exists stripe_account_id text;
do $$ begin
  alter table public.donation_subscriptions
    add constraint donation_subscriptions_target_chk check (
      (impact_project_id is not null and mosque_id is null) or (impact_project_id is null and mosque_id is not null));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table public.donation_subscriptions
    add constraint donation_subscriptions_type_chk check (type in ('donation','mosque_sadaqa','mosque_membership'));
exception when duplicate_object then null; end $$;
create index if not exists donation_subscriptions_mosque_idx on public.donation_subscriptions(mosque_id) where mosque_id is not null;

do $$ begin
  alter table public.mosque_members
    add constraint mosque_members_fee_fk foreign key (fee_subscription_id) references public.donation_subscriptions(id) on delete set null;
exception when duplicate_object then null; end $$;

-- -----------------------------------------------------------------------------
-- 3. Campaign progress trigger (mirrors fn_apply_tx_to_projects; mosque tx
--    have no transaction_items so the impact trigger is a no-op for them)
-- -----------------------------------------------------------------------------
create or replace function public.fn_apply_tx_to_mosque() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_succ boolean; v_ref boolean;
begin
  if new.mosque_campaign_id is null then return new; end if;
  if tg_op = 'INSERT' then
    v_succ := new.status = 'succeeded'; v_ref := false;
  else
    v_succ := new.status = 'succeeded' and old.status is distinct from 'succeeded';
    v_ref  := new.status = 'refunded'  and old.status = 'succeeded';
  end if;
  perform set_config('nour.trusted', 'on', true);
  if v_succ then
    update public.mosque_campaigns c
       set collected_amount = c.collected_amount + new.amount_total,
           donors_count = c.donors_count + case when exists (
             select 1 from public.transactions t
              where t.user_id = new.user_id and t.status = 'succeeded' and t.id <> new.id
                and t.mosque_campaign_id = new.mosque_campaign_id) then 0 else 1 end
     where c.id = new.mosque_campaign_id;
  elsif v_ref then
    update public.mosque_campaigns c
       set collected_amount = greatest(0, c.collected_amount - new.amount_total)
     where c.id = new.mosque_campaign_id;
  end if;
  return new;
end $$;
drop trigger if exists trg_tx_apply_mosque on public.transactions;
create trigger trg_tx_apply_mosque after insert or update of status on public.transactions
  for each row execute function public.fn_apply_tx_to_mosque();

-- -----------------------------------------------------------------------------
-- 4. RLS
-- -----------------------------------------------------------------------------
alter table public.mosque_stripe_accounts enable row level security;
drop policy if exists msa_admin_read on public.mosque_stripe_accounts;
create policy msa_admin_read on public.mosque_stripe_accounts for select to authenticated
  using (public.is_mosque_admin(mosque_id) or public.is_admin());
-- writes: service role only (edge functions)

alter table public.mosque_donation_settings enable row level security;
drop policy if exists mds_public_read on public.mosque_donation_settings;
create policy mds_public_read on public.mosque_donation_settings for select to authenticated
  using (exists (select 1 from public.mosques m where m.id = mosque_id and (m.status = 'approved' or public.is_mosque_member_admin(m.id) or public.is_admin())));
drop policy if exists mds_admin_write on public.mosque_donation_settings;
create policy mds_admin_write on public.mosque_donation_settings for all to authenticated
  using (public.is_mosque_admin(mosque_id) or public.is_admin()) with check (public.is_mosque_admin(mosque_id) or public.is_admin());

alter table public.mosque_campaign_updates enable row level security;
drop policy if exists mcu_read on public.mosque_campaign_updates;
create policy mcu_read on public.mosque_campaign_updates for select to authenticated
  using (exists (select 1 from public.mosques m where m.id = mosque_id and (m.status = 'approved' or public.is_mosque_member_admin(m.id) or public.is_admin())));
drop policy if exists mcu_admin_write on public.mosque_campaign_updates;
create policy mcu_admin_write on public.mosque_campaign_updates for all to authenticated
  using (public.is_mosque_admin(mosque_id) or public.is_admin()) with check (public.is_mosque_admin(mosque_id) or public.is_admin());

-- Campaigns: readers see active + closed; admin policy already exists (P2).
drop policy if exists mosque_campaigns_read on public.mosque_campaigns;
create policy mosque_campaigns_read on public.mosque_campaigns for select to authenticated
  using (public.is_mosque_admin(mosque_id) or public.is_admin()
         or (status in ('active','closed') and exists (select 1 from public.mosques m where m.id = mosque_id and m.status = 'approved')));

alter table public.mosque_receipts enable row level security;
drop policy if exists mosque_receipts_self on public.mosque_receipts;
create policy mosque_receipts_self on public.mosque_receipts for select to authenticated using (user_id = auth.uid());
drop policy if exists mosque_receipts_admin on public.mosque_receipts;
create policy mosque_receipts_admin on public.mosque_receipts for select to authenticated
  using (public.is_mosque_admin(mosque_id) or public.is_admin());

-- Mosque admins read their mosque's ledger (donor identity via RPC below).
drop policy if exists tx_mosque_admin_read on public.transactions;
create policy tx_mosque_admin_read on public.transactions for select to authenticated
  using (mosque_id is not null and public.is_mosque_admin(mosque_id));
drop policy if exists subs_mosque_admin_read on public.donation_subscriptions;
create policy subs_mosque_admin_read on public.donation_subscriptions for select to authenticated
  using (mosque_id is not null and public.is_mosque_admin(mosque_id));

-- -----------------------------------------------------------------------------
-- 5. RPCs
-- -----------------------------------------------------------------------------
create or replace function public.fn_mosque_donation_stats(p_mosque_id bigint, p_year int default null)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare v_year int := coalesce(p_year, extract(year from now())::int); r jsonb;
begin
  if not (public.is_mosque_admin(p_mosque_id) or public.is_admin()) then raise exception 'forbidden'; end if;
  with tx as (
    select * from public.transactions
     where mosque_id = p_mosque_id and status = 'succeeded' and type in ('mosque_sadaqa','mosque_campaign','mosque_membership')
  )
  select jsonb_build_object(
    'year', v_year,
    'total_year', coalesce((select sum(amount_total) from tx where extract(year from created_at) = v_year), 0),
    'total_prev_year', coalesce((select sum(amount_total) from tx where extract(year from created_at) = v_year - 1), 0),
    'support_amount', coalesce((select sum(amount_total) from tx where extract(year from created_at) = v_year and type in ('mosque_sadaqa','mosque_membership')), 0),
    'campaigns_amount', coalesce((select sum(amount_total) from tx where extract(year from created_at) = v_year and type = 'mosque_campaign'), 0),
    'donors', (select count(distinct user_id) from tx where extract(year from created_at) = v_year),
    'recurring_active', (select count(*) from public.donation_subscriptions s where s.mosque_id = p_mosque_id and s.status = 'active'),
    'avg_gift', coalesce((select round(avg(amount_total), 2) from tx where extract(year from created_at) = v_year), 0),
    'month_gifts', (select count(*) from tx where date_trunc('month', created_at) = date_trunc('month', now()) and type = 'mosque_sadaqa'),
    'month_amount', coalesce((select sum(amount_total) from tx where date_trunc('month', created_at) = date_trunc('month', now()) and type = 'mosque_sadaqa'), 0),
    'monthly_donors', (select count(*) from public.donation_subscriptions s where s.mosque_id = p_mosque_id and s.status = 'active' and s.interval = 'month')
  ) into r;
  return r;
end $$;
grant execute on function public.fn_mosque_donation_stats(bigint, int) to authenticated;

-- Donors list for the admin (anonymous gifts are masked).
create or replace function public.fn_mosque_donors(
  p_mosque_id bigint, p_year int default null, p_type text default null, p_limit int default 50, p_offset int default 0
) returns table (
  transaction_id bigint, created_at timestamptz, amount numeric, type public.tx_type, is_anonymous boolean,
  is_recurring boolean, user_id uuid, name text, avatar_url text, email text, campaign_title text, receipt_id bigint
)
language plpgsql stable security definer set search_path = public as $$
begin
  if not (public.is_mosque_admin(p_mosque_id) or public.is_admin()) then raise exception 'forbidden'; end if;
  return query
  select t.id, t.created_at, t.amount_total, t.type, t.is_anonymous, t.subscription_id is not null,
         case when t.is_anonymous then null else t.user_id end,
         case when t.is_anonymous then 'Anonymous' else p.name end,
         case when t.is_anonymous then null else p.avatar_url end,
         case when t.is_anonymous then null else u.email::text end,
         c.title,
         (select r.id from public.mosque_receipts r where r.transaction_id = t.id limit 1)
    from public.transactions t
    left join public.profiles p on p.id = t.user_id
    left join auth.users u on u.id = t.user_id
    left join public.mosque_campaigns c on c.id = t.mosque_campaign_id
   where t.mosque_id = p_mosque_id and t.status = 'succeeded'
     and (p_year is null or extract(year from t.created_at) = p_year)
     and (p_type is null or t.type::text = p_type)
   order by t.created_at desc
   limit greatest(1, least(coalesce(p_limit, 50), 500)) offset greatest(0, coalesce(p_offset, 0));
end $$;
grant execute on function public.fn_mosque_donors(bigint, int, text, int, int) to authenticated;

-- Public: recent non-anonymous donors of a campaign (avatars row).
create or replace function public.fn_mosque_campaign_recent_donors(p_campaign_id bigint, p_limit int default 3)
returns table (user_id uuid, avatar_url text, name text)
language sql stable security definer set search_path = public as $$
  select d.user_id, pr.avatar_url, pr.name
    from (select t.user_id, max(t.created_at) last_at from public.transactions t
           where t.mosque_campaign_id = p_campaign_id and t.status = 'succeeded' and t.is_anonymous = false
           group by t.user_id order by last_at desc limit greatest(1, least(coalesce(p_limit, 3), 10))) d
    join public.profiles pr on pr.id = d.user_id;
$$;
grant execute on function public.fn_mosque_campaign_recent_donors(bigint, int) to authenticated;

-- Donor: own mosque donations (history page).
create or replace function public.fn_my_mosque_donations(p_limit int default 100)
returns table (
  transaction_id bigint, created_at timestamptz, amount numeric, type public.tx_type, status public.tx_status,
  mosque_id bigint, mosque_name text, campaign_title text, subscription_id bigint, receipt_id bigint
)
language sql stable security invoker as $$
  select t.id, t.created_at, t.amount_total, t.type, t.status, t.mosque_id, m.name, c.title, t.subscription_id,
         (select r.id from public.mosque_receipts r where r.transaction_id = t.id limit 1)
    from public.transactions t
    join public.mosques m on m.id = t.mosque_id
    left join public.mosque_campaigns c on c.id = t.mosque_campaign_id
   where t.user_id = auth.uid() and t.mosque_id is not null
   order by t.created_at desc
   limit greatest(1, least(coalesce(p_limit, 100), 500));
$$;
grant execute on function public.fn_my_mosque_donations(int) to authenticated;

-- Campaign ending-soon reminder marker (system push sent by cron via pg_net
-- when available — see docs §10.2; here we only expose the candidates).
create or replace function public.fn_mosque_campaigns_to_remind()
returns table (id bigint, mosque_id bigint, title text)
language sql stable security definer set search_path = public as $$
  select c.id, c.mosque_id, c.title from public.mosque_campaigns c
   where c.status = 'active' and c.reminded_at is null and c.ends_at between now() and now() + interval '2 days';
$$;
revoke execute on function public.fn_mosque_campaigns_to_remind() from public;
