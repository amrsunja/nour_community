-- =============================================================================
-- Fix: likes_count never updates when a user likes a hadith / dua / adhkar.
--
-- public.fn_likes_count_bump (favorites → catalog likes_count maintenance) was
-- created as a plain function, so it runs with the *invoking* (authenticated)
-- user's privileges. The catalog tables (hadiths, duas, adhkars) are
-- admin-write only under RLS:
--
--   create policy <t>_admin_write on public.<t>
--     for all to authenticated using (public.is_admin()) with check (public.is_admin());
--
-- An UPDATE that fails the USING clause matches zero rows and raises no error,
-- so the favorite row is inserted but likes_count is never bumped.
--
-- Making the trigger function SECURITY DEFINER (running as the owner, which
-- bypasses RLS) is the same pattern used by is_admin(), fn_mark_daily_activity()
-- and the fn_award_* RPCs. The triggers reference the function by name, so
-- redefining it here is sufficient — no need to recreate the triggers.
-- =============================================================================

create or replace function public.fn_likes_count_bump()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_table text := tg_argv[0];  -- 'duas' | 'adhkars' | 'hadiths'
  v_col   text := tg_argv[1];  -- 'dua_id' | 'adhkar_id' | 'hadith_id'
  v_id    bigint;
  v_delta int;
begin
  if tg_op = 'INSERT' then
    v_id    := (to_jsonb(new) ->> v_col)::bigint;
    v_delta := 1;
  else
    v_id    := (to_jsonb(old) ->> v_col)::bigint;
    v_delta := -1;
  end if;

  execute format(
    'update public.%I set likes_count = greatest(0, likes_count + $1) where id = $2',
    v_table
  ) using v_delta, v_id;

  return null;
end;
$$;
