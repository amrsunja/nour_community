-- =============================================================================
-- Security hardening: derive the "local day" on the SERVER, not from a
-- client-supplied date.
--
-- The 20260604000000 / 20260604010000 fixes made the day correct (local, not
-- UTC) but did so by trusting a client-sent date (p_local_date / local_date).
-- A malicious client could then send a different date on every call to bypass
-- the once-per-day guards (unbounded daily-ayah / daily-dua ajr, unlimited quiz
-- plays, inflated streak).
--
-- Fix: the client reports only its current UTC offset in minutes (stored on the
-- profile, clamped to a real-world range). The day is computed server-side as
--   ((now() at utc) + offset)::date
-- An attacker can at most shift their own day by the offset they declare, and
-- since any valid offset lands the local date within UTC ±1, the abuse is
-- mathematically bounded to ~one extra claim per real day (and changing the
-- offset is itself a tracked write) — no more unbounded farming.
--
-- The dhikr reward path is NOT touched: fn_mark_daily_activity /
-- fn_sync_daily_dhikr_totals keep their signatures; callers now feed them the
-- server-derived date instead of a client one.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1) Per-profile UTC offset (minutes). Real offsets span UTC-12:00..+14:00.
-- -----------------------------------------------------------------------------
alter table public.profiles
  add column if not exists tz_offset_minutes integer not null default 0;

-- Single source of truth for "what local calendar day is it for this user".
create or replace function public.fn_local_date(p_user_id uuid)
returns date
language sql
stable
security definer
set search_path = public
as $$
  select ((now() at time zone 'utc')
          + make_interval(mins => coalesce(
              (select tz_offset_minutes from public.profiles where id = p_user_id), 0
            )))::date;
$$;
grant execute on function public.fn_local_date(uuid) to authenticated;

-- Client reports its device offset (DateTime.now().timeZoneOffset.inMinutes).
-- Clamped to the valid real-world range so a garbage value can't move the day.
create or replace function public.fn_set_tz_offset(p_minutes integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_off  integer := greatest(-720, least(840, coalesce(p_minutes, 0)));
begin
  if v_user is null then raise exception 'not authenticated'; end if;
  update public.profiles set tz_offset_minutes = v_off where id = v_user;
end;
$$;
grant execute on function public.fn_set_tz_offset(integer) to authenticated;

-- -----------------------------------------------------------------------------
-- 2) Daily Ayah — derive the day server-side; drop the client date param.
-- -----------------------------------------------------------------------------
drop function if exists public.fn_award_daily_ayah_ajr(integer, date);
drop function if exists public.fn_award_daily_ayah_ajr(integer);
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
  v_day  date;
  v_done boolean;
begin
  if v_user is null then raise exception 'not authenticated'; end if;
  if v_ajr <= 0 then v_ajr := 5; end if;
  v_day := public.fn_local_date(v_user);

  select exists (
    select 1 from public.ajr_log
    where user_id = v_user and source = 'ayah'
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
grant execute on function public.fn_award_daily_ayah_ajr(integer) to authenticated;

drop function if exists public.fn_daily_ayah_status(date);
drop function if exists public.fn_daily_ayah_status();
create or replace function public.fn_daily_ayah_status()
returns table (total_ajr bigint, done_today boolean)
language sql
stable
security definer
set search_path = public
as $$
  select
    coalesce((
      select sum(earned_ajr)::bigint from public.ajr_log
      where user_id = auth.uid() and source = 'ayah'
    ), 0) as total_ajr,
    exists (
      select 1 from public.ajr_log
      where user_id = auth.uid() and source = 'ayah'
        and coalesce(earned_on, (created_at at time zone 'utc')::date)
            = public.fn_local_date(auth.uid())
    ) as done_today;
$$;
grant execute on function public.fn_daily_ayah_status() to authenticated;

-- -----------------------------------------------------------------------------
-- 3) Daily Dua (source_id IS NULL) — same treatment.
-- -----------------------------------------------------------------------------
drop function if exists public.fn_award_daily_dua_ajr(integer, date);
drop function if exists public.fn_award_daily_dua_ajr(integer);
create or replace function public.fn_award_daily_dua_ajr(
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
  v_day  date;
  v_done boolean;
begin
  if v_user is null then raise exception 'not authenticated'; end if;
  if v_ajr <= 0 then v_ajr := 5; end if;
  v_day := public.fn_local_date(v_user);

  select exists (
    select 1 from public.ajr_log
    where user_id = v_user and source = 'dua' and source_id is null
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
grant execute on function public.fn_award_daily_dua_ajr(integer) to authenticated;

drop function if exists public.fn_daily_dua_status(date);
drop function if exists public.fn_daily_dua_status();
create or replace function public.fn_daily_dua_status()
returns table (total_ajr bigint, done_today boolean)
language sql
stable
security definer
set search_path = public
as $$
  select
    coalesce((
      select sum(earned_ajr)::bigint from public.ajr_log
      where user_id = auth.uid() and source = 'dua'
    ), 0) as total_ajr,
    exists (
      select 1 from public.ajr_log
      where user_id = auth.uid() and source = 'dua' and source_id is null
        and coalesce(earned_on, (created_at at time zone 'utc')::date)
            = public.fn_local_date(auth.uid())
    ) as done_today;
$$;
grant execute on function public.fn_daily_dua_status() to authenticated;

-- -----------------------------------------------------------------------------
-- 4) Per-dua / per-hadith reads — idempotency is by source_id (lifetime), the
--    only date use is the streak mark. Derive that server-side too; drop the
--    client date param.
-- -----------------------------------------------------------------------------
drop function if exists public.fn_award_dua_ajr(bigint, integer, date);
drop function if exists public.fn_award_dua_ajr(bigint, integer);
create or replace function public.fn_award_dua_ajr(
  p_dua_id bigint,
  p_ajr    integer default null
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_ajr  integer;
  v_done boolean;
begin
  if v_user is null then raise exception 'not authenticated'; end if;

  select coalesce(p_ajr, ajr, 5) into v_ajr from public.duas where id = p_dua_id;
  if v_ajr is null then v_ajr := coalesce(p_ajr, 5); end if;
  if v_ajr <= 0 then v_ajr := 5; end if;

  select exists (
    select 1 from public.ajr_log
    where user_id = v_user and source = 'dua' and source_id = p_dua_id
  ) into v_done;

  if not v_done then
    insert into public.ajr_log (user_id, earned_ajr, source, source_id)
    values (v_user, v_ajr, 'dua', p_dua_id);
    perform public.fn_mark_daily_activity(v_user, 'quick_action', public.fn_local_date(v_user));
  end if;

  return coalesce((
    select sum(earned_ajr)::bigint from public.ajr_log
    where user_id = v_user and source = 'dua'
  ), 0);
end;
$$;
grant execute on function public.fn_award_dua_ajr(bigint, integer) to authenticated;

drop function if exists public.fn_award_hadith_ajr(bigint, integer, date);
drop function if exists public.fn_award_hadith_ajr(bigint, integer);
create or replace function public.fn_award_hadith_ajr(
  p_hadith_id bigint,
  p_ajr       integer default null
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_ajr  integer;
  v_done boolean;
begin
  if v_user is null then raise exception 'not authenticated'; end if;

  select coalesce(p_ajr, ajr, 5) into v_ajr from public.hadiths where id = p_hadith_id;
  if v_ajr is null then v_ajr := coalesce(p_ajr, 5); end if;
  if v_ajr <= 0 then v_ajr := 5; end if;

  select exists (
    select 1 from public.ajr_log
    where user_id = v_user and source = 'hadith' and source_id = p_hadith_id
  ) into v_done;

  if not v_done then
    insert into public.ajr_log (user_id, earned_ajr, source, source_id)
    values (v_user, v_ajr, 'hadith', p_hadith_id);
    perform public.fn_mark_daily_activity(v_user, 'quick_action', public.fn_local_date(v_user));
  end if;

  return coalesce((
    select sum(earned_ajr)::bigint from public.ajr_log
    where user_id = v_user and source = 'hadith'
  ), 0);
end;
$$;
grant execute on function public.fn_award_hadith_ajr(bigint, integer) to authenticated;
