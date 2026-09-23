-- -----------------------------------------------------------------------------
-- mosques.email becomes a required, always-valid contact address.
--
-- Why: mosque-stripe-onboarding sent `email: ''` to Stripe (the column held an
-- empty string, so the `?? me.email` fallback never fired) → 502 email_invalid.
--
-- Rules:
--   * seeded from the registering admin's auth.users.email at fn_register_mosque
--   * a blank/whitespace/invalid value from a client never lands: the trigger
--     falls back to the previous value, then to the owner's auth email
--   * NOT NULL + CHECK enforce it at rest
--   * the mosque admin may still change it to any valid address
-- -----------------------------------------------------------------------------

-- 1. Owner auth email helper (auth.users is not readable by authenticated).
create or replace function public.fn_mosque_owner_email(p_mosque_id bigint, p_created_by uuid)
returns text
language sql
security definer
stable
set search_path = public, auth
as $$
  select u.email::text
    from auth.users u
   where u.id = coalesce(
           (select ma.user_id
              from public.mosque_admins ma
             where ma.mosque_id = p_mosque_id and ma.role = 'owner'
             order by ma.created_at
             limit 1),
           p_created_by)
   limit 1;
$$;

comment on function public.fn_mosque_owner_email(bigint, uuid) is
  'auth email of the mosque owner (falls back to mosques.created_by). Default contact address for a mosque.';

revoke execute on function public.fn_mosque_owner_email(bigint, uuid) from public, anon, authenticated;

-- 2. Normalising trigger: trim, reject blank/garbage by falling back.
create or replace function public.fn_mosques_normalize_email()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_email text := nullif(btrim(new.email), '');
begin
  if v_email is null or v_email !~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]{2,}$' then
    v_email := case when tg_op = 'UPDATE' then nullif(btrim(old.email), '') end;
  end if;

  if v_email is null then
    v_email := nullif(btrim(public.fn_mosque_owner_email(new.id, new.created_by)), '');
  end if;

  if v_email is null then
    raise exception 'mosque_email_required'
      using hint = 'No valid email supplied and the mosque owner has no auth email.';
  end if;

  new.email := lower(v_email);
  return new;
end $$;

-- 3. Backfill before tightening the column.
update public.mosques m
   set email = lower(btrim(public.fn_mosque_owner_email(m.id, m.created_by)))
 where (nullif(btrim(m.email), '') is null
        or btrim(m.email) !~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]{2,}$')
   and nullif(btrim(public.fn_mosque_owner_email(m.id, m.created_by)), '') is not null;

update public.mosques set email = lower(btrim(email))
 where email is not null and email <> lower(btrim(email));

-- Orphans (no owner, no auth email) would block the NOT NULL: surface them loudly.
do $$
declare v_orphans bigint;
begin
  select count(*) into v_orphans from public.mosques
   where nullif(btrim(email), '') is null;
  if v_orphans > 0 then
    raise exception 'Cannot enforce mosques.email NOT NULL: % row(s) have no resolvable email. Fix them first.', v_orphans;
  end if;
end $$;

-- 4. Constraints.
alter table public.mosques
  alter column email set not null;

alter table public.mosques
  drop constraint if exists mosques_email_format_chk;
alter table public.mosques
  add constraint mosques_email_format_chk
  check (email ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]{2,}$');

drop trigger if exists trg_mosques_normalize_email on public.mosques;
create trigger trg_mosques_normalize_email
  before insert or update of email on public.mosques
  for each row execute function public.fn_mosques_normalize_email();

-- 5. fn_register_mosque seeds the contact email from the signed-up admin.
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
set search_path = public, auth
as $$
declare
  v_uid       uuid := auth.uid();
  v_mosque_id bigint;
  v_profile   public.profiles%rowtype;
  v_is_anon   boolean;
  v_email     text;
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

  select coalesce(is_anonymous, false), lower(btrim(email::text))
    into v_is_anon, v_email
    from auth.users where id = v_uid;
  if v_is_anon then raise exception 'anonymous_not_allowed'; end if;
  if nullif(v_email, '') is null then raise exception 'account_email_required'; end if;

  if p_legal_name is null or length(trim(p_legal_name)) < 2 then raise exception 'invalid_legal_name'; end if;
  if p_siren is null or p_siren !~ '^\d{9}$' then raise exception 'invalid_siren'; end if;
  if p_legal_status <> 'other' and (p_rna is null or p_rna !~ '^W\d{9}$') then raise exception 'invalid_rna'; end if;

  insert into public.mosques (
    name, legal_name, legal_status, rna, siren, country_code, default_language, status, created_by, email)
  values (
    trim(p_legal_name), trim(p_legal_name), p_legal_status, nullif(trim(p_rna), ''), p_siren,
    upper(coalesce(p_country_code, 'FR')), coalesce(p_language, 'fr'), 'pending_review', v_uid, v_email)
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
