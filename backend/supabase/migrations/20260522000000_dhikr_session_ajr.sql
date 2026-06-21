-- =============================================================================
-- Dhikr ajr: one ajr_log row per *completed cycle*, multiple times per day.
--
--   A cycle = a full round of `dhikr.min_count` reps.
--   floor(current_count / min_count) cycles → that many ajr_log rows.
--   e.g. min_count=33: 33→1 row, 66→2 rows, 99→3 rows.
--
-- No tracking column on dhikr_progress: the number of ajr_log rows already
-- recorded for (user, dhikr, today) IS the high-water mark. This makes it
-- reset-safe — zeroing current_count never deletes rows nor re-grants ajr,
-- and counting back up only logs genuinely new cycles.
--
-- profile.earned_ajr_count keeps updating automatically: every inserted
-- ajr_log row still fires fn_apply_ajr_to_profile (unchanged) once.
-- =============================================================================

-- Drop the per-session tracking column added in the prior revision, and the
-- legacy one-shot guard — neither is needed anymore.
alter table public.dhikr_progress drop column if exists sessions_awarded;
alter table public.dhikr_progress drop column if exists ajr_awarded;

-- -----------------------------------------------------------------------------
-- Completion trigger (BEFORE insert/update on dhikr_progress):
--   * is_completed reflects current_count >= min_count
--   * inserts one ajr_log row for each cycle not yet recorded today
--   * marks daily_activity.dhikr_done on the day's first cycle
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
  v_target int;   -- cycles implied by the new current_count
  v_logged int;   -- cycles already logged for this dhikr today
  v_first  boolean;
begin
  select min_count, ajr into v_min, v_ajr
    from public.dhikrs where id = new.dhikr_id;

  if v_min is null or v_min <= 0 then
    return new;
  end if;

  new.is_completed := new.current_count >= v_min;

  v_target := new.current_count / v_min;  -- integer division = floor

  select count(*) into v_logged
    from public.ajr_log
   where user_id  = new.user_id
     and source   = 'dhikr'
     and source_id = new.dhikr_id
     and (created_at at time zone 'utc')::date = v_today;

  v_first := (v_logged = 0 and v_target > 0);

  -- One ajr_log row per newly-completed cycle. fn_apply_ajr_to_profile fires
  -- per row and bumps earned_ajr_count by v_ajr each time.
  while v_logged < v_target loop
    insert into public.ajr_log(user_id, earned_ajr, source, source_id)
    values (new.user_id, v_ajr, 'dhikr', new.dhikr_id);
    v_logged := v_logged + 1;
  end loop;

  -- Streak credit on the day's first completed cycle for this dhikr.
  if v_first then
    perform public.fn_mark_daily_activity(new.user_id, 'dhikr');
  end if;

  return new;
end;
$$;

drop trigger if exists trg_dhikr_progress_after_change on public.dhikr_progress;
create trigger trg_dhikr_progress_after_change
  before insert or update on public.dhikr_progress
  for each row execute function public.fn_dhikr_progress_after_change();
