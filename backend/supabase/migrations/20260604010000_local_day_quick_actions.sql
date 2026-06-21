-- =============================================================================
-- Fix: daily Ayah / daily Dua quick actions lose their daily ajr near the
-- UTC/local-midnight boundary.
--
-- Root cause (same class as 20260604000000): the "already done today" guard and
-- the status RPC bucketed by the UTC date
--   (created_at at time zone 'utc')::date = (now() at time zone 'utc')::date
-- while the user experiences the day in their LOCAL timezone. In MENA the day
-- only rolls at ~03:00 local, so a fresh local day couldn't earn its ajr until
-- UTC midnight (and done_today stayed stale).
--
-- Fix: the daily quick actions now key off the client's LOCAL date, stamped on
-- the ajr_log row via `earned_on` (already used by dhikr) and read back through
-- coalesce(earned_on, created_at-utc) so legacy rows still resolve sensibly.
-- The streak/daily_activity bucketing (fn_mark_daily_activity) already receives
-- the local date from 20260604000000 — unchanged here, dhikr reward path is not
-- touched.
-- =============================================================================

-- ── Daily Ayah ───────────────────────────────────────────────────────────────
drop function if exists public.fn_award_daily_ayah_ajr(integer, date);
create or replace function public.fn_award_daily_ayah_ajr(
  p_ajr        integer default 5,
  p_local_date date    default null
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_ajr  integer := coalesce(p_ajr, 5);
  v_day  date := coalesce(p_local_date, (now() at time zone 'utc')::date);
  v_done boolean;
begin
  if v_user is null then raise exception 'not authenticated'; end if;
  if v_ajr <= 0 then v_ajr := 5; end if;

  select exists (
    select 1 from public.ajr_log
    where user_id = v_user
      and source = 'ayah'
      and coalesce(earned_on, (created_at at time zone 'utc')::date) = v_day
  ) into v_done;

  if not v_done then
    insert into public.ajr_log (user_id, earned_ajr, source, source_id, earned_on)
    values (v_user, v_ajr, 'ayah', null, v_day);
    perform public.fn_mark_daily_activity(v_user, 'quick_action', v_day);
  end if;

  return coalesce((
    select sum(earned_ajr)::bigint from public.ajr_log
    where user_id = v_user and source = 'ayah'
  ), 0);
end;
$$;
grant execute on function public.fn_award_daily_ayah_ajr(integer, date) to authenticated;

drop function if exists public.fn_daily_ayah_status();
create or replace function public.fn_daily_ayah_status(
  p_local_date date default null
)
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
      where user_id = auth.uid() and source = 'ayah'
    ), 0) as total_ajr,
    exists (
      select 1
      from public.ajr_log
      where user_id = auth.uid()
        and source = 'ayah'
        and coalesce(earned_on, (created_at at time zone 'utc')::date)
            = coalesce(p_local_date, (now() at time zone 'utc')::date)
    ) as done_today;
$$;
grant execute on function public.fn_daily_ayah_status(date) to authenticated;

-- ── Daily Dua ────────────────────────────────────────────────────────────────
-- (source_id IS NULL marks the daily quick action, distinct from per-dua reads.)
drop function if exists public.fn_award_daily_dua_ajr(integer, date);
create or replace function public.fn_award_daily_dua_ajr(
  p_ajr        integer default 5,
  p_local_date date    default null
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_ajr  integer := coalesce(p_ajr, 5);
  v_day  date := coalesce(p_local_date, (now() at time zone 'utc')::date);
  v_done boolean;
begin
  if v_user is null then raise exception 'not authenticated'; end if;
  if v_ajr <= 0 then v_ajr := 5; end if;

  select exists (
    select 1 from public.ajr_log
    where user_id = v_user
      and source = 'dua'
      and source_id is null
      and coalesce(earned_on, (created_at at time zone 'utc')::date) = v_day
  ) into v_done;

  if not v_done then
    insert into public.ajr_log (user_id, earned_ajr, source, source_id, earned_on)
    values (v_user, v_ajr, 'dua', null, v_day);
    perform public.fn_mark_daily_activity(v_user, 'quick_action', v_day);
  end if;

  return coalesce((
    select sum(earned_ajr)::bigint from public.ajr_log
    where user_id = v_user and source = 'dua'
  ), 0);
end;
$$;
grant execute on function public.fn_award_daily_dua_ajr(integer, date) to authenticated;

drop function if exists public.fn_daily_dua_status();
create or replace function public.fn_daily_dua_status(
  p_local_date date default null
)
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
      where user_id = auth.uid() and source = 'dua'
    ), 0) as total_ajr,
    exists (
      select 1
      from public.ajr_log
      where user_id = auth.uid()
        and source = 'dua'
        and source_id is null
        and coalesce(earned_on, (created_at at time zone 'utc')::date)
            = coalesce(p_local_date, (now() at time zone 'utc')::date)
    ) as done_today;
$$;
grant execute on function public.fn_daily_dua_status(date) to authenticated;
