-- =============================================================================
-- P3.1 — Fundraising (campaign) settings
-- -----------------------------------------------------------------------------
-- Campaigns used to borrow `mosque_donation_settings` (the Sadaqa card). They
-- are a different product and now own their configuration:
--
--   * mosque_campaign_settings : mosque-wide fundraising defaults (the
--     "Fundraising settings" admin page). A new campaign is seeded from them.
--   * mosque_campaigns         : per-campaign override of those defaults
--     (amounts + allowed frequencies + tax badge).
--   * donation_subscriptions   : a recurring gift can now target a campaign.
--
-- Additive only — nothing in the Sadaqa path changes.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Mosque-wide fundraising defaults
-- -----------------------------------------------------------------------------
create table if not exists public.mosque_campaign_settings (
  mosque_id         bigint primary key references public.mosques(id) on delete cascade,
  suggested_amounts int[] not null default '{10,50,100,150}',
  -- Recurring is opt-in: a campaign is time-bound, so a mosque enables monthly
  -- / yearly campaign gifts deliberately (same default as mosque_campaigns).
  allow_one_time    boolean not null default true,
  allow_monthly     boolean not null default false,
  allow_yearly      boolean not null default false,
  show_tax_badge    boolean not null default false,
  updated_at        timestamptz not null default now()
);

drop trigger if exists trg_mcs_updated_at on public.mosque_campaign_settings;
create trigger trg_mcs_updated_at before update on public.mosque_campaign_settings
  for each row execute function public.set_updated_at();

-- Same invariants as the Sadaqa card: the badge needs `can_issue_tax_receipts`,
-- at least one frequency stays on, amounts are sorted / deduped / capped at 6.
create or replace function public.fn_mcs_guard() returns trigger language plpgsql as $$
begin
  if new.show_tax_badge and not exists (
    select 1 from public.mosques m where m.id = new.mosque_id and m.can_issue_tax_receipts
  ) then
    new.show_tax_badge := false;
  end if;

  if not (new.allow_one_time or new.allow_monthly or new.allow_yearly) then
    new.allow_one_time := true;
  end if;

  new.suggested_amounts := coalesce(
    (select array_agg(a) from (select distinct a from unnest(new.suggested_amounts) a where a > 0 order by a limit 6) s),
    '{10,50,100,150}'::int[]);

  return new;
end $$;

drop trigger if exists trg_mcs_guard on public.mosque_campaign_settings;
create trigger trg_mcs_guard before insert or update on public.mosque_campaign_settings
  for each row execute function public.fn_mcs_guard();

-- -----------------------------------------------------------------------------
-- 2. Per-campaign overrides
-- -----------------------------------------------------------------------------
-- Column defaults keep EXISTING campaigns one-time only (that is what they are
-- today); new campaigns are seeded from mosque_campaign_settings by the app.
alter table public.mosque_campaigns
  add column if not exists allow_one_time boolean not null default true,
  add column if not exists allow_monthly  boolean not null default false,
  add column if not exists allow_yearly   boolean not null default false,
  add column if not exists show_tax_badge boolean not null default false;

create or replace function public.fn_mosque_campaign_guard() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.show_tax_badge and not exists (
    select 1 from public.mosques m where m.id = new.mosque_id and m.can_issue_tax_receipts
  ) then
    new.show_tax_badge := false;
  end if;

  if not (new.allow_one_time or new.allow_monthly or new.allow_yearly) then
    new.allow_one_time := true;
  end if;

  -- Empty / invalid payload → fall back on the mosque's fundraising defaults.
  new.suggested_amounts := coalesce(
    (select array_agg(a) from (select distinct a from unnest(new.suggested_amounts) a where a > 0 order by a limit 6) s),
    (select s.suggested_amounts from public.mosque_campaign_settings s where s.mosque_id = new.mosque_id),
    '{10,50,100,150}'::int[]);

  return new;
end $$;

drop trigger if exists trg_mosque_campaign_guard on public.mosque_campaigns;
create trigger trg_mosque_campaign_guard before insert or update on public.mosque_campaigns
  for each row execute function public.fn_mosque_campaign_guard();

-- -----------------------------------------------------------------------------
-- 3. Recurring gifts can target a campaign
-- -----------------------------------------------------------------------------
alter table public.donation_subscriptions
  add column if not exists mosque_campaign_id bigint references public.mosque_campaigns(id) on delete restrict;

alter table public.donation_subscriptions drop constraint if exists donation_subscriptions_type_chk;
do $$ begin
  alter table public.donation_subscriptions
    add constraint donation_subscriptions_type_chk
    check (type in ('donation','mosque_sadaqa','mosque_membership','mosque_campaign'));
exception when duplicate_object then null; end $$;

do $$ begin
  alter table public.donation_subscriptions
    add constraint donation_subscriptions_campaign_chk
    check (mosque_campaign_id is null or mosque_id is not null);
exception when duplicate_object then null; end $$;

create index if not exists donation_subscriptions_campaign_idx
  on public.donation_subscriptions(mosque_campaign_id) where mosque_campaign_id is not null;

-- -----------------------------------------------------------------------------
-- 4. RLS (mirrors mosque_donation_settings)
-- -----------------------------------------------------------------------------
alter table public.mosque_campaign_settings enable row level security;

drop policy if exists mcs_public_read on public.mosque_campaign_settings;
create policy mcs_public_read on public.mosque_campaign_settings for select to authenticated
  using (exists (select 1 from public.mosques m
                  where m.id = mosque_id
                    and (m.status = 'approved' or public.is_mosque_member_admin(m.id) or public.is_admin())));

drop policy if exists mcs_admin_write on public.mosque_campaign_settings;
create policy mcs_admin_write on public.mosque_campaign_settings for all to authenticated
  using (public.is_mosque_admin(mosque_id) or public.is_admin())
  with check (public.is_mosque_admin(mosque_id) or public.is_admin());

-- -----------------------------------------------------------------------------
-- 5. Backfill
-- -----------------------------------------------------------------------------
-- Every mosque that already sells Sadaqa gets a fundraising row seeded from the
-- amounts / badge it already uses; recurring stays off until an admin enables it.
insert into public.mosque_campaign_settings (mosque_id, suggested_amounts, show_tax_badge)
select s.mosque_id, s.suggested_amounts, s.show_tax_badge
  from public.mosque_donation_settings s
on conflict (mosque_id) do nothing;

insert into public.mosque_campaign_settings (mosque_id)
select m.id from public.mosques m where m.donations_enabled
on conflict (mosque_id) do nothing;
