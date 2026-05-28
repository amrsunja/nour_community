-- =============================================================================
-- Streak & daily-dhikr reward signals (realtime, once-per-day)
--
-- Design (per product decision): reuse `daily_activity` as the single realtime
-- source of truth instead of a separate queue table.
--
--   * dhikr_count          : live sum of today's dhikr_progress.current_count
--                            (drives the "Dikr completed" stat — shows the true
--                            total even past the 33 goal).
--   * dhikr_ajr            : live sum of today's dhikr ajr (from ajr_log).
--   * streak_reward_seen   : claim guard — the streak-day reward is shown once
--                            per day, the day the streak is counted.
--   * dhikr_reward_seen    : claim guard — the daily-dhikr reward is shown once
--                            per day, when dhikr_count first crosses the goal.
--
-- The Flutter app subscribes to its own `daily_activity` row + `profiles` row
-- over Realtime, then atomically *claims* a reward with a conditional UPDATE
-- (set <x>_reward_seen = true WHERE <x>_reward_seen = false). The conditional
-- update is idempotent, so a realtime double-fire or a cold-start re-fetch can
-- never show the same reward twice. RLS (daily_activity_self_update) already
-- restricts the claim to the row's owner.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1) New columns
-- -----------------------------------------------------------------------------
alter table public.daily_activity
  add column if not exists dhikr_count        int     not null default 0,
  add column if not exists dhikr_ajr          int     not null default 0,
  add column if not exists streak_reward_seen boolean not null default false,
  add column if not exists dhikr_reward_seen  boolean not null default false;

-- -----------------------------------------------------------------------------
-- 2) Keep daily_activity dhikr totals in sync with the live progress.
--    Recomputes from the source rows (set-based, idempotent) and upserts the
--    day row so totals exist even before the first dhikr is *completed*.
-- -----------------------------------------------------------------------------
-- Bucketed by the *UTC* calendar date so the row is the SAME one
-- fn_mark_daily_activity (streak) writes to — the reward coordinator reads a
-- single daily_activity row per day and must see streak + dhikr signals
-- together. (In the common case the user's local day == UTC day; the dhikr
-- feature's local-day bucketing only diverges in the narrow UTC-midnight
-- window, which the existing streak system already keys by UTC.)
create or replace function public.fn_sync_daily_dhikr_totals(
  p_user_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_today date := (now() at time zone 'utc')::date;
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
   where user_id  = p_user_id
     and source   = 'dhikr'
     and earned_on = v_today;

  insert into public.daily_activity (user_id, activity_date, dhikr_count, dhikr_ajr)
  values (p_user_id, v_today, v_count, v_ajr)
  on conflict (user_id, activity_date)
  do update set dhikr_count = excluded.dhikr_count,
                dhikr_ajr   = excluded.dhikr_ajr;
end;
$$;

-- -----------------------------------------------------------------------------
-- 3) Redefine the dhikr AFTER trigger (latest revision from
--    20260523040000_dhikr_local_day_ajr.sql) and append the totals sync so the
--    daily_activity row reflects the goal the instant it is crossed. The sync
--    runs *after* the ajr_log rows are written, so dhikr_ajr is accurate.
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
  v_target int;   -- cycles implied by current_count
  v_logged int;   -- cycles already logged for this dhikr on this local day
  v_first  boolean;
begin
  select min_count, ajr into v_min, v_ajr
    from public.dhikrs where id = new.dhikr_id;

  if v_min is null or v_min <= 0 then
    return null;
  end if;

  v_target := new.current_count / v_min;  -- integer division = floor

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
    perform public.fn_mark_daily_activity(new.user_id, 'dhikr');
  end if;

  -- Keep the day's running totals current for the reward signals. Runs on
  -- every progress change (not only on completion) so dhikr_count tracks the
  -- live tally and dhikr_reward_seen can be evaluated the moment 33 is reached.
  perform public.fn_sync_daily_dhikr_totals(new.user_id);

  return null;  -- AFTER trigger: return value ignored
end;
$$;

drop trigger if exists trg_dhikr_progress_after_change on public.dhikr_progress;
create trigger trg_dhikr_progress_after_change
  after insert or update on public.dhikr_progress
  for each row execute function public.fn_dhikr_progress_after_change();

-- -----------------------------------------------------------------------------
-- 4) Enable Realtime for the two tables the reward coordinator subscribes to.
--    Realtime honours RLS, so users only receive their own row changes.
--    Guarded so a re-run (or a table already in the publication) is a no-op.
-- -----------------------------------------------------------------------------
do $$
begin
  begin
    alter publication supabase_realtime add table public.daily_activity;
  exception
    when duplicate_object then null;  -- already in publication
  end;

  begin
    alter publication supabase_realtime add table public.profiles;
  exception
    when duplicate_object then null;
  end;
end $$;

-- REPLICA IDENTITY FULL: makes the full row available on UPDATE/DELETE in the
-- WAL so Realtime can apply RLS (user_id = auth.uid()) and deliver complete
-- payloads for the changed columns the client filters on.
alter table public.daily_activity replica identity full;
alter table public.profiles       replica identity full;

-- -----------------------------------------------------------------------------
-- 5) Backfill today's totals for existing rows so the first realtime payload
--    after deploy is already accurate.
-- -----------------------------------------------------------------------------
update public.daily_activity da
   set dhikr_count = coalesce((
         select sum(dp.current_count) from public.dhikr_progress dp
          where dp.user_id = da.user_id
            and dp.progress_date = da.activity_date), 0),
       dhikr_ajr = coalesce((
         select sum(al.earned_ajr) from public.ajr_log al
          where al.user_id = da.user_id
            and al.source = 'dhikr'
            and al.earned_on = da.activity_date), 0)
 where da.activity_date = (now() at time zone 'utc')::date;
