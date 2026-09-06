-- =============================================================================
-- Grant email_exists to `anon`.
--
-- 20260525000000 revoked execute from anon, but the sign-in page can
-- legitimately run WITHOUT a session: signInAnonymously() at app start can
-- fail (offline start, anonymous sign-in rate limit = 30/h per IP, revoked
-- refresh token). The client then calls the RPC with only the anon apikey ->
-- role `anon` -> 42501 "permission denied for function email_exists", which
-- aborted Google/Apple/email login.
--
-- The function already accepts account enumeration by design (see the note in
-- the original migration) and returns only a boolean, so exposing it to anon
-- adds no new information leak beyond what `authenticated` (which every
-- anonymous session has) could already query.
-- =============================================================================

grant execute on function public.email_exists(text) to anon;
