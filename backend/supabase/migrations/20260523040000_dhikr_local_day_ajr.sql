-- =============================================================================
-- Dhikr daily scoping: align ajr bucketing with the client's *local* day.
--
-- The client now writes dhikr_progress.progress_date as the device-local
-- calendar date (not UTC), so the daily reset follows the user's wall clock.
-- The ajr trigger previously bucketed "cycles already logged today" by the
-- UTC date of ajr_log.created_at — which drifts from progress_date across the
-- UTC/local-midnight gap and could mis-count cycles near the boundary.
--
-- Fix: stamp each dhikr ajr_log row with `earned_on` = the progress row's own
-- date, and count the high-water mark by that key. This is timezone-proof:
-- the day a cycle belongs to is decided once, by the client, and never
-- re-derived from a UTC timestamp. earned_on stays NULL for non-dhikr sources
-- (they keep their existing created_at-based logic untouched).
-- =============================================================================

alter table public.ajr_log add column if not exists earned_on date;

create index if not exists ajr_log_user_source_earned_on_idx
  on public.ajr_log(user_id, source, earned_on);

-- Best-effort backfill for existing dhikr rows (UTC date is the closest
-- approximation we have for historical rows).
update public.ajr_log
   set earned_on = (created_at at time zone 'utc')::date
 where source = 'dhikr' and earned_on is null;

-- -----------------------------------------------------------------------------
-- AFTER trigger: one ajr_log row per newly-completed cycle, bucketed by the
-- progress row's local day. Fires exactly once per upsert.
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

  return null;  -- AFTER trigger: return value ignored
end;
$$;

drop trigger if exists trg_dhikr_progress_after_change on public.dhikr_progress;
create trigger trg_dhikr_progress_after_change
  after insert or update on public.dhikr_progress
  for each row execute function public.fn_dhikr_progress_after_change();
