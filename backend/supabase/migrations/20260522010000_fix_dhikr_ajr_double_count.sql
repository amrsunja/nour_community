-- =============================================================================
-- Fix: dhikr ajr was logged 2–3× per save.
--
-- Root cause: fn_dhikr_progress_after_change ran as a single
-- BEFORE INSERT OR UPDATE trigger. A Supabase upsert is
-- `INSERT ... ON CONFLICT DO UPDATE`; on a conflicting row Postgres fires the
-- BEFORE INSERT trigger (on the *proposed* row) AND the BEFORE UPDATE trigger.
-- The ajr_log insert done in the discarded BEFORE-INSERT pass is NOT rolled
-- back, so a single save inserted ajr more than once (made worse by the stale
-- sessions_awarded = 0 default on the proposed insert row).
--
-- Fix: split responsibilities.
--   * BEFORE trigger — only derives is_completed (idempotent, safe to fire twice)
--   * AFTER trigger  — does the ajr_log writes. AFTER triggers fire exactly once
--     per upsert (only AFTER UPDATE on conflict, only AFTER INSERT otherwise).
--     The count of rows already logged today is the high-water mark, so even a
--     stray double-fire could never double-grant.
-- =============================================================================

-- Drop any legacy tracking columns (no longer used; ajr_log is the source of truth).
alter table public.dhikr_progress drop column if exists sessions_awarded;
alter table public.dhikr_progress drop column if exists ajr_awarded;

-- Remove the old combined BEFORE trigger (whichever revision is live).
drop trigger if exists trg_dhikr_progress_after_change on public.dhikr_progress;

-- -----------------------------------------------------------------------------
-- 1) BEFORE: derive is_completed only.
-- -----------------------------------------------------------------------------
create or replace function public.fn_dhikr_set_completed()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_min smallint;
begin
  select min_count into v_min from public.dhikrs where id = new.dhikr_id;
  if v_min is not null and v_min > 0 then
    new.is_completed := new.current_count >= v_min;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_dhikr_set_completed on public.dhikr_progress;
create trigger trg_dhikr_set_completed
  before insert or update on public.dhikr_progress
  for each row execute function public.fn_dhikr_set_completed();

-- -----------------------------------------------------------------------------
-- 2) AFTER: one ajr_log row per newly-completed cycle (fires once per upsert).
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
  v_today  date := (now() at time zone 'utc')::date;
  v_target int;   -- cycles implied by current_count
  v_logged int;   -- cycles already logged for this dhikr today
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
     and (created_at at time zone 'utc')::date = v_today;

  v_first := (v_logged = 0 and v_target > 0);

  while v_logged < v_target loop
    insert into public.ajr_log(user_id, earned_ajr, source, source_id)
    values (new.user_id, v_ajr, 'dhikr', new.dhikr_id);
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
