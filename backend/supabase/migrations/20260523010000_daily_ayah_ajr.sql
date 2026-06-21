-- =============================================================================
-- Daily Ayah ajr
--
-- The "Daily Ayah" quick action awards ajr (default 5) the first time the user
-- taps "I'm done" on a given UTC day. ajr_log INSERTs are locked down by RLS
-- (with check (false)) so the client cannot write there directly — these
-- SECURITY DEFINER RPCs are the only sanctioned path:
--
--   * fn_award_daily_ayah_ajr(p_ajr) — idempotent per UTC day. Logs ajr to
--     ajr_log (source = 'ayah'), which fires fn_apply_ajr_to_profile to bump
--     profiles.earned_ajr_count, and marks the daily_activity 'quick_action'
--     for streak logic. Returns the user's all-time ayah ajr total.
--
--   * fn_daily_ayah_status() — read-only: all-time ayah ajr total + whether the
--     user already completed today's ayah.
--
-- No new tables: reuses public.ajr_log + public.daily_activity.
-- =============================================================================

create or replace function public.fn_daily_ayah_status()
returns table (total_ajr bigint, done_today boolean)
language sql
stable
security definer
set search_path = public
as $$
  select
    coalesce((
      select sum(earned_ajr)::bigint
      from public.ajr_log
      where user_id = auth.uid()
        and source = 'ayah'
    ), 0) as total_ajr,
    exists (
      select 1
      from public.ajr_log
      where user_id = auth.uid()
        and source = 'ayah'
        and (created_at at time zone 'utc')::date = (now() at time zone 'utc')::date
    ) as done_today;
$$;

create or replace function public.fn_award_daily_ayah_ajr(
  p_ajr integer default 5
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_ajr  integer := coalesce(p_ajr, 5);
  v_done boolean;
begin
  if v_user is null then
    raise exception 'not authenticated';
  end if;

  if v_ajr <= 0 then
    v_ajr := 5;
  end if;

  -- Already completed today? (idempotent — no double award on re-open)
  select exists (
    select 1 from public.ajr_log
    where user_id = v_user
      and source = 'ayah'
      and (created_at at time zone 'utc')::date = (now() at time zone 'utc')::date
  ) into v_done;

  if not v_done then
    insert into public.ajr_log (user_id, earned_ajr, source, source_id)
    values (v_user, v_ajr, 'ayah', null);

    perform public.fn_mark_daily_activity(v_user, 'quick_action');
  end if;

  return coalesce((
    select sum(earned_ajr)::bigint
    from public.ajr_log
    where user_id = v_user and source = 'ayah'
  ), 0);
end;
$$;

revoke execute on function public.fn_daily_ayah_status() from public;
revoke execute on function public.fn_award_daily_ayah_ajr(integer) from public;
grant execute on function public.fn_daily_ayah_status() to authenticated;
grant execute on function public.fn_award_daily_ayah_ajr(integer) to authenticated;
