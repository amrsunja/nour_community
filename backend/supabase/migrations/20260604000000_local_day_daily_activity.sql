-- =============================================================================
-- Fix: align daily_activity / streak / dhikr-reward bucketing with the client's
-- LOCAL calendar day.
--
-- Bug: dhikr_progress.progress_date is the device-local date, but
-- fn_sync_daily_dhikr_totals + fn_mark_daily_activity bucketed by the UTC date.
-- On any night where local date != UTC date (MENA, ~00:00–03:00 local) the
-- dhikr count was summed for the wrong day (-> 0), today's local row was never
-- created, and the daily-dhikr reward (gate: dhikr_count >= 33) never fired.
-- The streak reward still fired because it keys off the streak_counted flag,
-- not the summed count.
--
-- Resolution: the day becomes an explicit parameter, supplied by the client
-- (the same local date dhikr_progress is stamped with). Quick-action award RPCs
-- forward the client's local date so dhikr_done and quick_action_done land on
-- the SAME local-day row and the streak keeps counting on divergent nights.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1) fn_mark_daily_activity: day is now a parameter (defaults to UTC for any
--    caller that doesn't pass one).
-- -----------------------------------------------------------------------------
drop function if exists public.fn_mark_daily_activity(uuid, text);

create or replace function public.fn_mark_daily_activity(
  p_user_id uuid,
  p_mark    text,                                            -- 'dhikr' | 'quick_action'
  p_day     date default (now() at time zone 'utc')::date
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_today        date := p_day;
  v_yesterday    date := p_day - 1;
  v_row          public.daily_activity%rowtype;
  v_profile      public.profiles%rowtype;
begin
  insert into public.daily_activity (user_id, activity_date)
  values (p_user_id, v_today)
  on conflict (user_id, activity_date) do nothing;

  if p_mark = 'dhikr' then
    update public.daily_activity set dhikr_done = true
     where user_id = p_user_id and activity_date = v_today;
  elsif p_mark = 'quick_action' then
    update public.daily_activity set quick_action_done = true
     where user_id = p_user_id and activity_date = v_today;
  end if;

  select * into v_row from public.daily_activity
   where user_id = p_user_id and activity_date = v_today;

  if v_row.dhikr_done and v_row.quick_action_done and not v_row.streak_counted then
    select * into v_profile from public.profiles where id = p_user_id for update;

    if v_profile.last_streak_date is null or v_profile.last_streak_date < v_yesterday then
      v_profile.current_streak := 1;                         -- broken: restart
    elsif v_profile.last_streak_date = v_yesterday then
      v_profile.current_streak := least(7, v_profile.current_streak + 1);
    end if;                                                  -- = today: keep (defensive)

    update public.profiles
       set current_streak   = v_profile.current_streak,
           last_streak_date = v_today
     where id = p_user_id;

    update public.daily_activity set streak_counted = true
     where user_id = p_user_id and activity_date = v_today;
  end if;
end;
$$;

-- -----------------------------------------------------------------------------
-- 2) fn_sync_daily_dhikr_totals: sum the day the dhikr was actually performed.
-- -----------------------------------------------------------------------------
drop function if exists public.fn_sync_daily_dhikr_totals(uuid);

create or replace function public.fn_sync_daily_dhikr_totals(
  p_user_id uuid,
  p_day     date default (now() at time zone 'utc')::date
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_today date := p_day;
  v_count int;
  v_ajr   int;
begin
  select coalesce(sum(current_count), 0)
    into v_count
    from public.dhikr_progress
   where user_id = p_user_id
     and progress_date = v_today;

  select coalesce(sum(earned_ajr), 0)
    into v_ajr
    from public.ajr_log
   where user_id   = p_user_id
     and source    = 'dhikr'
     and earned_on = v_today;

  insert into public.daily_activity (user_id, activity_date, dhikr_count, dhikr_ajr)
  values (p_user_id, v_today, v_count, v_ajr)
  on conflict (user_id, activity_date)
  do update set dhikr_count = excluded.dhikr_count,
                dhikr_ajr   = excluded.dhikr_ajr;
end;
$$;

-- -----------------------------------------------------------------------------
-- 3) Dhikr AFTER trigger: forward the progress row's local day to both helpers
--    so the day key is decided once, by the client, and never re-derived.
-- -----------------------------------------------------------------------------
create or replace function public.fn_dhikr_progress_after_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_min    smallint;
  v_ajr    smallint;
  v_target int;
  v_logged int;
  v_first  boolean;
begin
  select min_count, ajr into v_min, v_ajr
    from public.dhikrs where id = new.dhikr_id;

  if v_min is null or v_min <= 0 then
    return null;
  end if;

  v_target := new.current_count / v_min;

  select count(*) into v_logged
    from public.ajr_log
   where user_id   = new.user_id
     and source    = 'dhikr'
     and source_id = new.dhikr_id
     and earned_on = new.progress_date;

  v_first := (v_logged = 0 and v_target > 0);

  while v_logged < v_target loop
    insert into public.ajr_log(user_id, earned_ajr, source, source_id, earned_on)
    values (new.user_id, v_ajr, 'dhikr', new.dhikr_id, new.progress_date);
    v_logged := v_logged + 1;
  end loop;

  if v_first then
    perform public.fn_mark_daily_activity(new.user_id, 'dhikr', new.progress_date);
  end if;

  perform public.fn_sync_daily_dhikr_totals(new.user_id, new.progress_date);

  return null;
end;
$$;

drop trigger if exists trg_dhikr_progress_after_change on public.dhikr_progress;
create trigger trg_dhikr_progress_after_change
  after insert or update on public.dhikr_progress
  for each row execute function public.fn_dhikr_progress_after_change();

-- -----------------------------------------------------------------------------
-- 4) Quick-action award RPCs: accept the client's local date and forward it to
--    fn_mark_daily_activity so quick_action_done lands on the SAME local-day
--    row as dhikr_done. (ajr idempotency stays as-is; only the streak/activity
--    bucketing day changes.)
-- -----------------------------------------------------------------------------

-- Daily Ayah
drop function if exists public.fn_award_daily_ayah_ajr(integer);
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
    where user_id = v_user and source = 'ayah'
      and (created_at at time zone 'utc')::date = (now() at time zone 'utc')::date
  ) into v_done;

  if not v_done then
    insert into public.ajr_log (user_id, earned_ajr, source, source_id)
    values (v_user, v_ajr, 'ayah', null);
    perform public.fn_mark_daily_activity(v_user, 'quick_action', v_day);
  end if;

  return coalesce((
    select sum(earned_ajr)::bigint from public.ajr_log
    where user_id = v_user and source = 'ayah'
  ), 0);
end;
$$;
grant execute on function public.fn_award_daily_ayah_ajr(integer, date) to authenticated;

-- Daily Dua
drop function if exists public.fn_award_daily_dua_ajr(integer);
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
    where user_id = v_user and source = 'dua' and source_id is null
      and (created_at at time zone 'utc')::date = (now() at time zone 'utc')::date
  ) into v_done;

  if not v_done then
    insert into public.ajr_log (user_id, earned_ajr, source, source_id)
    values (v_user, v_ajr, 'dua', null);
    perform public.fn_mark_daily_activity(v_user, 'quick_action', v_day);
  end if;

  return coalesce((
    select sum(earned_ajr)::bigint from public.ajr_log
    where user_id = v_user and source = 'dua'
  ), 0);
end;
$$;
grant execute on function public.fn_award_daily_dua_ajr(integer, date) to authenticated;

-- Per-dua library read
drop function if exists public.fn_award_dua_ajr(bigint, integer);
create or replace function public.fn_award_dua_ajr(
  p_dua_id     bigint,
  p_ajr        integer default null,
  p_local_date date    default null
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_ajr  integer;
  v_day  date := coalesce(p_local_date, (now() at time zone 'utc')::date);
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
    perform public.fn_mark_daily_activity(v_user, 'quick_action', v_day);
  end if;

  return coalesce((
    select sum(earned_ajr)::bigint from public.ajr_log
    where user_id = v_user and source = 'dua'
  ), 0);
end;
$$;
grant execute on function public.fn_award_dua_ajr(bigint, integer, date) to authenticated;

-- Hadith read
drop function if exists public.fn_award_hadith_ajr(bigint, integer);
create or replace function public.fn_award_hadith_ajr(
  p_hadith_id  bigint,
  p_ajr        integer default null,
  p_local_date date    default null
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_ajr  integer;
  v_day  date := coalesce(p_local_date, (now() at time zone 'utc')::date);
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
    perform public.fn_mark_daily_activity(v_user, 'quick_action', v_day);
  end if;

  return coalesce((
    select sum(earned_ajr)::bigint from public.ajr_log
    where user_id = v_user and source = 'hadith'
  ), 0);
end;
$$;
grant execute on function public.fn_award_hadith_ajr(bigint, integer, date) to authenticated;
