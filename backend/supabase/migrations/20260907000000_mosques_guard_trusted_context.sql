-- -----------------------------------------------------------------------------
-- Fix: fn_mosques_guard_columns / fn_mosque_campaigns_guard rejected updates
-- from the Supabase dashboard ("column protected").
--
-- Root cause: same as 20260809 (fn_prevent_is_admin_escalation). Both guards
-- only honoured the `nour.trusted` GUC or public.is_admin(). In the SQL editor
-- / service_role / cron there is no JWT, so auth.uid() is NULL, is_admin() is
-- false and nour.trusted is unset → every moderation change from the console
-- was blocked.
--
-- Fix: single helper public.is_trusted_context() (no JWT, or role in
-- service_role/postgres/supabase_admin, or nour.trusted = 'on') reused by
-- every column guard. Client-side (anon/authenticated) rules are unchanged:
-- only a Nour admin may touch moderation / legal / counter columns.
-- -----------------------------------------------------------------------------

create or replace function public.is_trusted_context()
returns boolean
language plpgsql
stable
set search_path = public
as $$
declare
  jwt_claims     text := current_setting('request.jwt.claims', true);
  effective_role text := coalesce(
    current_setting('request.jwt.claim.role', true),
    current_setting('role', true),
    current_user
  );
begin
  return jwt_claims is null
      or effective_role in ('service_role', 'postgres', 'supabase_admin')
      or current_setting('nour.trusted', true) = 'on';
end $$;

comment on function public.is_trusted_context() is
  'True when running without a request JWT (SQL editor / cron), as service_role/postgres, or inside a server RPC that set nour.trusted=on.';

-- mosques: moderation / legal / counters
create or replace function public.fn_mosques_guard_columns()
returns trigger language plpgsql as $$
begin
  if not public.is_trusted_context() and not public.is_admin() then
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

  -- Console / trusted reviews: stamp the review timestamp when the caller
  -- flipped status but did not set it (reviewed_by stays NULL = system).
  if new.status is distinct from old.status and new.reviewed_at is not distinct from old.reviewed_at then
    new.reviewed_at := now();
    if new.reviewed_by is not distinct from old.reviewed_by then
      new.reviewed_by := auth.uid();  -- NULL from the dashboard
    end if;
  end if;

  if new.slug is null then
    new.slug := public.fn_mosque_slug(new.name, new.id);
  end if;
  return new;
end $$;

-- mosque_campaigns: counters
create or replace function public.fn_mosque_campaigns_guard()
returns trigger language plpgsql as $$
begin
  if not public.is_trusted_context() and not public.is_admin() then
    if new.collected_amount is distinct from old.collected_amount
       or new.donors_count is distinct from old.donors_count then
      raise exception 'column protected';
    end if;
  end if;
  return new;
end $$;

-- Align the two older guards on the shared helper (behaviour unchanged).
create or replace function public.fn_prevent_is_admin_escalation()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.is_admin is distinct from old.is_admin
     and not (public.is_trusted_context() or public.is_admin()) then
    raise exception 'is_admin can only be changed by an admin';
  end if;
  return new;
end $$;

create or replace function public.fn_protect_account_type()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.account_type is distinct from old.account_type
     and not (public.is_trusted_context() or public.is_admin()) then
    raise exception 'account_type can only be changed by the server';
  end if;
  return new;
end $$;
