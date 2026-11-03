-- =============================================================================
-- Mosque donation verification (App Store guideline 3.2.1(vi) / Benevity).
--   * mosque_donation_verifications: one request per mosque, read through RLS,
--     written only through the two RPCs below.
--   * mosques.donations_enabled can only be true while the request is approved.
--     Enforced by a trigger, so the Stripe webhook / onboarding function (which
--     write charges_enabled straight into the column) cannot re-open donations.
--   * Every mosque starts unverified: donations already enabled are switched off
--     until the Nour admin validates the mosque's request.
--   * Lint fix: RLS on mosque_receipt_counters.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Requests
-- -----------------------------------------------------------------------------
create table if not exists public.mosque_donation_verifications (
  mosque_id           bigint primary key references public.mosques(id) on delete cascade,
  status              text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  benevity_charity_id text not null,
  legal_name          text not null,
  certificate_url     text,
  notes               text,
  submitted_by        uuid references auth.users(id) on delete set null,
  submitted_at        timestamptz not null default now(),
  review_note         text,
  reviewed_by         uuid references auth.users(id) on delete set null,
  reviewed_at         timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
drop trigger if exists trg_mdv_updated_at on public.mosque_donation_verifications;
create trigger trg_mdv_updated_at before update on public.mosque_donation_verifications
  for each row execute function public.set_updated_at();

alter table public.mosque_donation_verifications enable row level security;
revoke all on table public.mosque_donation_verifications from anon, authenticated;
grant select on table public.mosque_donation_verifications to authenticated;
drop policy if exists mdv_read on public.mosque_donation_verifications;
create policy mdv_read on public.mosque_donation_verifications for select to authenticated
  using (public.is_mosque_admin(mosque_id) or public.is_admin());

-- -----------------------------------------------------------------------------
-- 2. donations_enabled requires an approved request
-- -----------------------------------------------------------------------------
create or replace function public.fn_mosques_require_donation_verification()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.donations_enabled and not exists (
    select 1 from public.mosque_donation_verifications v
     where v.mosque_id = new.id and v.status = 'approved'
  ) then
    new.donations_enabled := false;
  end if;
  return new;
end $$;

drop trigger if exists trg_mosques_require_donation_verification on public.mosques;
create trigger trg_mosques_require_donation_verification
  before insert or update of donations_enabled on public.mosques
  for each row execute function public.fn_mosques_require_donation_verification();

update public.mosques set donations_enabled = false where donations_enabled;

-- -----------------------------------------------------------------------------
-- 3. Mosque admin: submit (or resubmit) a request
-- -----------------------------------------------------------------------------
create or replace function public.fn_mosque_request_donation_verification(
  p_mosque_id           bigint,
  p_benevity_charity_id text,
  p_legal_name          text,
  p_certificate_url     text default null,
  p_notes               text default null
) returns public.mosque_donation_verifications
language plpgsql security definer set search_path = public as $$
declare
  v_id   text := nullif(btrim(coalesce(p_benevity_charity_id, '')), '');
  v_name text := nullif(btrim(coalesce(p_legal_name, '')), '');
  v_url  text := nullif(btrim(coalesce(p_certificate_url, '')), '');
  v_row  public.mosque_donation_verifications;
begin
  if not public.is_mosque_admin(p_mosque_id) then raise exception 'forbidden'; end if;
  if not exists (select 1 from public.mosques where id = p_mosque_id and status = 'approved') then
    raise exception 'mosque_not_approved';
  end if;
  if v_id is null or length(v_id) > 100 then raise exception 'donation_verification_invalid_id'; end if;
  if v_name is null or length(v_name) > 200 then raise exception 'donation_verification_invalid_name'; end if;
  if v_url is not null and (v_url !~* '^https?://' or length(v_url) > 500) then
    raise exception 'donation_verification_invalid_url';
  end if;
  if length(p_notes) > 1000 then raise exception 'donation_verification_invalid_notes'; end if;

  insert into public.mosque_donation_verifications as t
    (mosque_id, status, benevity_charity_id, legal_name, certificate_url, notes, submitted_by)
  values
    (p_mosque_id, 'pending', v_id, v_name, v_url, nullif(btrim(coalesce(p_notes, '')), ''), auth.uid())
  on conflict (mosque_id) do update
    set status = 'pending',
        benevity_charity_id = excluded.benevity_charity_id,
        legal_name = excluded.legal_name,
        certificate_url = excluded.certificate_url,
        notes = excluded.notes,
        submitted_by = excluded.submitted_by,
        submitted_at = now(),
        review_note = null,
        reviewed_by = null,
        reviewed_at = null
    where t.status <> 'approved'
  returning t.* into v_row;

  -- The conflict branch skips an approved row: an edit must not silently
  -- downgrade (or re-validate) a mosque that is already receiving donations.
  if not found then raise exception 'donation_verification_already_approved'; end if;
  return v_row;
end $$;

revoke all on function public.fn_mosque_request_donation_verification(bigint, text, text, text, text) from public;
grant execute on function public.fn_mosque_request_donation_verification(bigint, text, text, text, text) to authenticated;

-- -----------------------------------------------------------------------------
-- 4. Nour admin: list + validate / cancel
-- -----------------------------------------------------------------------------
create or replace function public.fn_admin_donation_verifications(p_status text default null)
returns table (
  mosque_id bigint, mosque_name text, country_code text, status text,
  benevity_charity_id text, legal_name text, certificate_url text, notes text,
  submitted_at timestamptz, review_note text, reviewed_at timestamptz,
  owner_email text, owner_name text, charges_enabled boolean
)
language plpgsql stable security definer set search_path = public as $$
begin
  if not public.is_admin() then raise exception 'forbidden'; end if;
  return query
  select v.mosque_id, m.name, m.country_code, v.status,
         v.benevity_charity_id, v.legal_name, v.certificate_url, v.notes,
         v.submitted_at, v.review_note, v.reviewed_at,
         u.email::text, p.name, coalesce(s.charges_enabled, false)
    from public.mosque_donation_verifications v
    join public.mosques m on m.id = v.mosque_id
    left join public.mosque_admins a on a.mosque_id = v.mosque_id and a.role = 'owner'
    left join auth.users u on u.id = a.user_id
    left join public.profiles p on p.id = a.user_id
    left join public.mosque_stripe_accounts s on s.mosque_id = v.mosque_id
   where p_status is null or v.status = p_status
   order by v.submitted_at desc;
end $$;

revoke all on function public.fn_admin_donation_verifications(text) from public;
grant execute on function public.fn_admin_donation_verifications(text) to authenticated;

create or replace function public.fn_admin_review_donation_verification(
  p_mosque_id bigint,
  p_approve   boolean,
  p_note      text default null
) returns void
language plpgsql security definer set search_path = public as $$
declare
  v_charges boolean;
begin
  if not public.is_admin() then raise exception 'forbidden'; end if;

  update public.mosque_donation_verifications
     set status = case when p_approve then 'approved' else 'rejected' end,
         review_note = nullif(btrim(coalesce(p_note, '')), ''),
         reviewed_by = auth.uid(),
         reviewed_at = now()
   where mosque_id = p_mosque_id;
  if not found then raise exception 'not_found'; end if;

  select coalesce(charges_enabled, false) into v_charges
    from public.mosque_stripe_accounts where mosque_id = p_mosque_id;
  v_charges := coalesce(v_charges, false);

  -- Validating a mosque whose Stripe account is already chargeable opens
  -- donations now; otherwise the Connect webhook does it once onboarding ends.
  perform set_config('nour.trusted', 'on', true);
  update public.mosques
     set donations_enabled = p_approve and v_charges, updated_at = now()
   where id = p_mosque_id;
  perform set_config('nour.trusted', 'off', true);

  if p_approve and v_charges then
    insert into public.mosque_donation_settings (mosque_id) values (p_mosque_id) on conflict (mosque_id) do nothing;
    insert into public.mosque_campaign_settings (mosque_id) values (p_mosque_id) on conflict (mosque_id) do nothing;
  end if;
end $$;

revoke all on function public.fn_admin_review_donation_verification(bigint, boolean, text) from public;
grant execute on function public.fn_admin_review_donation_verification(bigint, boolean, text) to authenticated;

-- -----------------------------------------------------------------------------
-- 5. Supabase lint: RLS Disabled in Public (mosque_receipt_counters)
-- -----------------------------------------------------------------------------
-- Internal counter: its only access is fn_next_mosque_receipt_number, a SECURITY
-- DEFINER function run by its owner (which RLS does not apply to) and called by
-- generate-mosque-receipt with the service role. No policy on purpose: PostgREST
-- clients have no reason to read or write receipt numbers.
alter table public.mosque_receipt_counters enable row level security;
revoke all on table public.mosque_receipt_counters from anon, authenticated;
