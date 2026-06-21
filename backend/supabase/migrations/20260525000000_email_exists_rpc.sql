-- =============================================================================
-- email_exists(p_email): does a PERMANENT (non-anonymous) account already
-- own this email?
--
-- Used by the client to decide the connect flow on an anonymous session:
--   * false -> link the email to the current anonymous user in place
--              (updateUser, instant, no OTP — keeps uid + all data).
--   * true  -> the email belongs to a pre-existing account; sign into it via
--              passwordless OTP (signInWithOtp, shouldCreateUser:false).
--
-- SECURITY DEFINER because auth.users is not readable by the authenticated
-- role. Returns only a boolean — no row data is exposed.
--
-- NOTE: this intentionally reveals whether an email is registered (account
-- enumeration). That is required by the desired UX. Supabase auth rate limits
-- the follow-up OTP/sign-in calls; add app-side throttling if abuse is a risk.
-- =============================================================================

create or replace function public.email_exists(p_email text)
returns boolean
language sql
security definer
set search_path = public, auth
as $$
  select exists (
    select 1
      from auth.users
     where lower(email) = lower(trim(p_email))
       and coalesce(is_anonymous, false) = false
  );
$$;

revoke execute on function public.email_exists(text) from public, anon;
grant  execute on function public.email_exists(text) to authenticated;
