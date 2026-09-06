-- =============================================================================
-- Mosques module (P0) — accounts.
--   * profiles.account_type ('user' default → every existing row unchanged)
--   * app_config feature flags
--   * mosques + mosque_admins skeleton, is_mosque_admin helpers
--   * fn_register_mosque (called once by a freshly signed-up mosque manager)
--   * fn_my_mosque (admin reads his mosque regardless of status)
--   * RLS
-- See docs/MOSQUES_MODULE_IMPLEMENTATION.md §3 / §4.2 / §4.3 / §4.10 / §4.14
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. profiles additions
-- -----------------------------------------------------------------------------
alter table public.profiles
  add column if not exists account_type public.account_type not null default 'user',
  add column if not exists country_code  text,
  add column if not exists push_prefs    jsonb not null default '{}'::jsonb;

create index if not exists profiles_account_type_idx
  on public.profiles(account_type) where account_type = 'mosque';

comment on column public.profiles.account_type is
  'user = worshipper (default, all legacy rows); mosque = mosque manager account (never anonymous).';

-- account_type may only change from a trusted context (no JWT / service role /
-- nour.trusted flag set by server RPCs) or by a Nour admin.
create or replace function public.fn_protect_account_type()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  jwt_claims text := current_setting('request.jwt.claims', true);
  effective_role text := coalesce(
    current_setting('request.jwt.claim.role', true),
    current_setting('role', true),
    current_user
  );
  v_trusted boolean;
begin
  if new.account_type is distinct from old.account_type then
    v_trusted := jwt_claims is null
      or effective_role in ('service_role', 'postgres', 'supabase_admin')
      or current_setting('nour.trusted', true) = 'on';
    if not (v_trusted or public.is_admin()) then
      raise exception 'account_type can only be changed by the server';
    end if;
  end if;
  return new;
end $$;

drop trigger if exists trg_profiles_protect_account_type on public.profiles;
create trigger trg_profiles_protect_account_type
  before update on public.profiles
  for each row execute function public.fn_protect_account_type();

-- -----------------------------------------------------------------------------
-- 2. app_config (remote feature flags)
-- -----------------------------------------------------------------------------
create table if not exists public.app_config (
  key        text primary key,
  value      jsonb not null,
  updated_at timestamptz not null default now()
);
alter table public.app_config enable row level security;
drop policy if exists app_config_read on public.app_config;
create policy app_config_read on public.app_config for select to authenticated using (true);
drop policy if exists app_config_admin on public.app_config;
create policy app_config_admin on public.app_config for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

insert into public.app_config (key, value) values
  ('mosques_enabled', 'true'::jsonb),
  ('mosque_donations_enabled', 'false'::jsonb),
  ('mosque_membership_fee_enabled', 'true'::jsonb),
  ('mosque_broadcasts_per_week', '2'::jsonb)
on conflict (key) do nothing;

-- -----------------------------------------------------------------------------
-- 3. mosques + mosque_admins
-- -----------------------------------------------------------------------------
create table if not exists public.mosques (
  id                 bigserial primary key,
  -- identity / legal (from onboarding)
  name               text not null,
  legal_name         text,
  legal_status       public.mosque_legal_status,
  rna                text,
  siren              text,
  country_code       text not null default 'FR',
  default_language   text not null default 'fr',
  status             public.mosque_status not null default 'pending_review',
  review_note        text,
  reviewed_by        uuid references public.profiles(id) on delete set null,
  reviewed_at        timestamptz,
  created_by         uuid references public.profiles(id) on delete set null,
  -- public profile
  slug               text unique,
  logo_url           text,
  cover_images       text[] not null default '{}',
  description        text,
  address_line       text,
  city               text,
  postal_code        text,
  location           extensions.geography(point, 4326),
  phone              text,
  email              text,
  website            text,
  socials            jsonb not null default '{}'::jsonb,
  capacity_total     int,
  capacity_men       int,
  capacity_women     int,
  founded_year       int,
  services           public.mosque_service[] not null default '{}',
  khutbah_languages  text[] not null default '{}',
  timezone           text not null default 'Europe/Paris',
  opening_status     text,
  -- donations (P3)
  donations_enabled      boolean not null default false,
  can_issue_tax_receipts boolean not null default false,
  -- denormalised counters
  followers_count    int not null default 0,
  members_count      int not null default 0,
  views_count        bigint not null default 0,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

create index if not exists mosques_status_idx   on public.mosques(status);
create index if not exists mosques_location_gix on public.mosques using gist(location);
create index if not exists mosques_name_trgm    on public.mosques using gin (name extensions.gin_trgm_ops);
create index if not exists mosques_city_trgm    on public.mosques using gin (city extensions.gin_trgm_ops);
create unique index if not exists mosques_siren_uniq
  on public.mosques(siren) where siren is not null and status <> 'rejected';

drop trigger if exists trg_mosques_updated_at on public.mosques;
create trigger trg_mosques_updated_at
  before update on public.mosques
  for each row execute function public.set_updated_at();

create table if not exists public.mosque_admins (
  mosque_id  bigint not null references public.mosques(id) on delete cascade,
  user_id    uuid   not null references public.profiles(id) on delete cascade,
  role       public.mosque_admin_role not null default 'manager',
  created_at timestamptz not null default now(),
  primary key (mosque_id, user_id)
);
create index if not exists mosque_admins_user_idx on public.mosque_admins(user_id);

-- Admin of an APPROVED mosque (used by every write policy).
create or replace function public.is_mosque_admin(p_mosque_id bigint)
returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.mosque_admins a
    join public.mosques m on m.id = a.mosque_id
    where a.mosque_id = p_mosque_id and a.user_id = auth.uid() and m.status = 'approved');
$$;

-- Admin of a mosque in ANY status (owner reads his own pending mosque).
create or replace function public.is_mosque_member_admin(p_mosque_id bigint)
returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.mosque_admins
    where mosque_id = p_mosque_id and user_id = auth.uid());
$$;

-- unaccent is optional on Supabase; degrade gracefully.
create or replace function public.unaccent_safe(p text)
returns text language plpgsql immutable as $$
begin
  begin
    return extensions.unaccent(p);
  exception when others then
    return p;
  end;
end $$;
-- Slug helper (name → 'annour-center-mulhouse-12').
create or replace function public.fn_mosque_slug(p_name text, p_id bigint)
returns text language sql immutable as $$
  select trim(both '-' from regexp_replace(lower(public.unaccent_safe(p_name)), '[^a-z0-9]+', '-', 'g')) || '-' || p_id::text;
$$;

-- Column guard: mosque admins cannot touch moderation / legal / counters.
create or replace function public.fn_mosques_guard_columns()
returns trigger language plpgsql as $$
begin
  if current_setting('nour.trusted', true) is distinct from 'on' and not public.is_admin() then
    if new.status is distinct from old.status
       or new.review_note is distinct from old.review_note
       or new.reviewed_by is distinct from old.reviewed_by
       or new.reviewed_at is distinct from old.reviewed_at
       or new.siren is distinct from old.siren
       or new.rna is distinct from old.rna
       or new.legal_status is distinct from old.legal_status
       or new.donations_enabled is distinct from old.donations_enabled
       or new.followers_count is distinct from old.followers_count
       or new.members_count is distinct from old.members_count
       or new.views_count is distinct from old.views_count then
      raise exception 'column protected';
    end if;
  end if;
  if new.slug is null then
    new.slug := public.fn_mosque_slug(new.name, new.id);
  end if;
  return new;
end $$;
drop trigger if exists trg_mosques_guard_columns on public.mosques;
create trigger trg_mosques_guard_columns
  before update on public.mosques
  for each row execute function public.fn_mosques_guard_columns();

-- -----------------------------------------------------------------------------
-- 4. RLS
-- -----------------------------------------------------------------------------
alter table public.mosques enable row level security;
drop policy if exists mosques_public_read on public.mosques;
create policy mosques_public_read on public.mosques for select to authenticated
  using (status = 'approved' or public.is_mosque_member_admin(id) or public.is_admin());
drop policy if exists mosques_admin_update on public.mosques;
create policy mosques_admin_update on public.mosques for update to authenticated
  using (public.is_mosque_admin(id) or public.is_admin())
  with check (public.is_mosque_admin(id) or public.is_admin());
-- No client INSERT (fn_register_mosque only). No client DELETE.

alter table public.mosque_admins enable row level security;
drop policy if exists mosque_admins_read on public.mosque_admins;
create policy mosque_admins_read on public.mosque_admins for select to authenticated
  using (user_id = auth.uid() or public.is_mosque_admin(mosque_id) or public.is_admin());
drop policy if exists mosque_admins_owner_write on public.mosque_admins;
create policy mosque_admins_owner_write on public.mosque_admins for all to authenticated
  using (public.is_admin() or exists (
    select 1 from public.mosque_admins o
    where o.mosque_id = mosque_admins.mosque_id and o.user_id = auth.uid() and o.role = 'owner'))
  with check (public.is_admin() or exists (
    select 1 from public.mosque_admins o
    where o.mosque_id = mosque_admins.mosque_id and o.user_id = auth.uid() and o.role = 'owner'));

-- -----------------------------------------------------------------------------
-- 5. fn_register_mosque — one-shot registration by the signed-up manager
-- -----------------------------------------------------------------------------
create or replace function public.fn_register_mosque(
  p_legal_name   text,
  p_legal_status public.mosque_legal_status,
  p_rna          text,
  p_siren        text,
  p_country_code text,
  p_language     text default 'fr'
) returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid       uuid := auth.uid();
  v_mosque_id bigint;
  v_profile   public.profiles%rowtype;
  v_is_anon   boolean;
begin
  if v_uid is null then raise exception 'unauthorized'; end if;

  select * into v_profile from public.profiles where id = v_uid;
  if not found then raise exception 'profile_not_found'; end if;

  -- Idempotent replay: already a mosque account → return its mosque.
  if v_profile.account_type = 'mosque' then
    select mosque_id into v_mosque_id
      from public.mosque_admins where user_id = v_uid order by created_at limit 1;
    return v_mosque_id;
  end if;

  -- Never convert an existing worshipper silently.
  if v_profile.onboarding_completed then
    raise exception 'profile_is_worshipper';
  end if;

  select coalesce(is_anonymous, false) into v_is_anon from auth.users where id = v_uid;
  if v_is_anon then raise exception 'anonymous_not_allowed'; end if;

  if p_legal_name is null or length(trim(p_legal_name)) < 2 then raise exception 'invalid_legal_name'; end if;
  if p_siren is null or p_siren !~ '^\d{9}$' then raise exception 'invalid_siren'; end if;
  if p_legal_status <> 'other' and (p_rna is null or p_rna !~ '^W\d{9}$') then raise exception 'invalid_rna'; end if;

  insert into public.mosques (
    name, legal_name, legal_status, rna, siren, country_code, default_language, status, created_by)
  values (
    trim(p_legal_name), trim(p_legal_name), p_legal_status, nullif(trim(p_rna), ''), p_siren,
    upper(coalesce(p_country_code, 'FR')), coalesce(p_language, 'fr'), 'pending_review', v_uid)
  returning id into v_mosque_id;

  update public.mosques set slug = public.fn_mosque_slug(name, id) where id = v_mosque_id and slug is null;

  insert into public.mosque_admins (mosque_id, user_id, role) values (v_mosque_id, v_uid, 'owner');

  perform set_config('nour.trusted', 'on', true);   -- transaction-local; allows the account_type change
  update public.profiles
     set account_type = 'mosque',
         onboarding_completed = true,
         country_code = upper(coalesce(p_country_code, country_code))
   where id = v_uid;

  return v_mosque_id;
end $$;

revoke execute on function public.fn_register_mosque(text, public.mosque_legal_status, text, text, text, text) from public;
grant execute on function public.fn_register_mosque(text, public.mosque_legal_status, text, text, text, text) to authenticated;

-- -----------------------------------------------------------------------------
-- 6. fn_my_mosque — the caller's mosque (any status) + role
-- -----------------------------------------------------------------------------
create or replace function public.fn_my_mosque()
returns table (mosque public.mosques, role public.mosque_admin_role)
language sql stable security definer set search_path = public as $$
  select m, a.role
    from public.mosque_admins a
    join public.mosques m on m.id = a.mosque_id
   where a.user_id = auth.uid()
   order by a.created_at
   limit 1;
$$;
grant execute on function public.fn_my_mosque() to authenticated;

-- -----------------------------------------------------------------------------
-- 7. Nour admin moderation RPCs
-- -----------------------------------------------------------------------------
create or replace function public.fn_admin_mosque_requests(p_status public.mosque_status default null)
returns table (
  id bigint, name text, legal_name text, legal_status public.mosque_legal_status, rna text, siren text,
  country_code text, status public.mosque_status, review_note text, created_at timestamptz,
  owner_id uuid, owner_email text, owner_name text, duplicate_siren boolean
)
language plpgsql stable security definer set search_path = public as $$
begin
  if not public.is_admin() then raise exception 'forbidden'; end if;
  return query
  select m.id, m.name, m.legal_name, m.legal_status, m.rna, m.siren, m.country_code, m.status, m.review_note, m.created_at,
         a.user_id, u.email::text, p.name,
         exists (select 1 from public.mosques x where x.siren = m.siren and x.id <> m.id and x.status <> 'rejected')
    from public.mosques m
    left join public.mosque_admins a on a.mosque_id = m.id and a.role = 'owner'
    left join auth.users u on u.id = a.user_id
    left join public.profiles p on p.id = a.user_id
   where p_status is null or m.status = p_status
   order by m.created_at desc;
end $$;
grant execute on function public.fn_admin_mosque_requests(public.mosque_status) to authenticated;

create or replace function public.fn_admin_review_mosque(
  p_mosque_id bigint, p_status public.mosque_status, p_note text default null
) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not public.is_admin() then raise exception 'forbidden'; end if;
  if p_status not in ('approved','rejected','suspended') then raise exception 'invalid_status'; end if;
  perform set_config('nour.trusted', 'on', true);
  update public.mosques
     set status = p_status, review_note = p_note, reviewed_by = auth.uid(), reviewed_at = now()
   where id = p_mosque_id;
end $$;
grant execute on function public.fn_admin_review_mosque(bigint, public.mosque_status, text) to authenticated;

-- Realtime: review status flip → MosqueReviewPage.
do $$ begin
  alter publication supabase_realtime add table public.mosques;
exception when duplicate_object then null; end $$;
