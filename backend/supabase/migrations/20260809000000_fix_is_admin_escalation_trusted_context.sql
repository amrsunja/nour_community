-- -----------------------------------------------------------------------------
-- Fix: fn_prevent_is_admin_escalation blocked ALL is_admin changes.
--
-- Root cause: public.is_admin() resolves the caller via auth.uid(). In trusted
-- server-side contexts (Supabase SQL editor, service_role key, superuser, cron)
-- there is no JWT, so auth.uid() is NULL and is_admin() returns false. The
-- trigger therefore rejected legitimate admin grants performed from the console.
--
-- New behaviour:
--   * Allow is_admin changes from trusted contexts (no request JWT, or the
--     current role is service_role / postgres / supabase_admin).
--   * Still block client-side (anon / authenticated) escalation unless the
--     caller is already an admin.
-- -----------------------------------------------------------------------------

create or replace function public.fn_prevent_is_admin_escalation()
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
  is_trusted_context boolean;
begin
  if new.is_admin is distinct from old.is_admin then
    is_trusted_context :=
      jwt_claims is null                                   -- no request context (SQL editor / cron)
      or effective_role in ('service_role', 'postgres', 'supabase_admin');

    if not (is_trusted_context or public.is_admin()) then
      raise exception 'is_admin can only be changed by an admin';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_profiles_no_admin_escalation on public.profiles;
create trigger trg_profiles_no_admin_escalation
  before update on public.profiles
  for each row execute function public.fn_prevent_is_admin_escalation();
