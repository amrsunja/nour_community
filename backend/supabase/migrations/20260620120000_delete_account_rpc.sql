-- =============================================================================
-- delete_account(): permanently deletes the CALLING user's account.
--
-- Deletes the caller's row from auth.users. Every owned row (profiles +
-- everything that references profiles / auth.users with `on delete cascade`)
-- is removed by the cascade, so a single delete tears down the whole account.
--
-- SECURITY DEFINER because the `authenticated` role cannot delete from
-- auth.users. The function only ever targets `auth.uid()`, so a caller can
-- delete their own account and no one else's.
--
-- The client must call auth.signOut() after this returns: the JWT is still
-- valid until expiry but the underlying user no longer exists.
-- =============================================================================

create or replace function public.delete_account()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  delete from auth.users where id = v_uid;
end;
$$;

revoke execute on function public.delete_account() from public, anon;
grant  execute on function public.delete_account() to authenticated;
