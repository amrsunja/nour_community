-- =============================================================================
-- Ajr log + streak system
-- =============================================================================

create table if not exists public.ajr_log (
  id           bigserial primary key,
  user_id      uuid not null references public.profiles(id) on delete cascade,
  earned_ajr   int not null check (earned_ajr > 0),
  source       public.ajr_source not null,
  source_id    bigint,        -- reference id in source table (dhikr_id, dua_id, etc.)
  created_at   timestamptz not null default now()
);
create index if not exists ajr_log_user_idx          on public.ajr_log(user_id);
create index if not exists ajr_log_user_created_idx  on public.ajr_log(user_id, created_at desc);
create index if not exists ajr_log_source_idx       on public.ajr_log(source);

-- -----------------------------------------------------------------------------
-- Track which "quick action" (ayah/dua/quiz) the user completed each day
-- for streak logic. Daily-streak rule: 1 daily dhikr completed AND
-- 1 quick action completed.
-- -----------------------------------------------------------------------------
create table if not exists public.daily_activity (
  id                bigserial primary key,
  user_id           uuid not null references public.profiles(id) on delete cascade,
  activity_date     date not null default (now() at time zone 'utc')::date,
  dhikr_done        boolean not null default false,
  quick_action_done boolean not null default false,
  streak_counted    boolean not null default false,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);
create unique index if not exists daily_activity_user_day_uniq
  on public.daily_activity(user_id, activity_date);

drop trigger if exists trg_daily_activity_updated_at on public.daily_activity;
create trigger trg_daily_activity_updated_at
  before update on public.daily_activity
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- Update profile aggregate counters when ajr is logged
-- -----------------------------------------------------------------------------
create or replace function public.fn_apply_ajr_to_profile()
returns trigger
language plpgsql
as $$
begin
  update public.profiles
     set earned_ajr_count = earned_ajr_count + new.earned_ajr
   where id = new.user_id;
  return new;
end;
$$;

drop trigger if exists trg_ajr_log_apply on public.ajr_log;
create trigger trg_ajr_log_apply
  after insert on public.ajr_log
  for each row execute function public.fn_apply_ajr_to_profile();

-- -----------------------------------------------------------------------------
-- Helper: mark a quick action / dhikr completion on today's daily_activity
-- and re-evaluate streak.
-- -----------------------------------------------------------------------------
create or replace function public.fn_mark_daily_activity(
  p_user_id uuid,
  p_mark    text  -- 'dhikr' | 'quick_action'
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_today        date := (now() at time zone 'utc')::date;
  v_yesterday    date := v_today - 1;
  v_row          public.daily_activity%rowtype;
  v_profile      public.profiles%rowtype;
  v_should_count boolean := false;
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
      -- broken: restart
      v_profile.current_streak := 1;
    elsif v_profile.last_streak_date = v_yesterday then
      v_profile.current_streak := least(7, v_profile.current_streak + 1);
    else
      -- last_streak_date = today (defensive)
      v_profile.current_streak := v_profile.current_streak;
    end if;

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
-- Dhikr completion trigger:
--   * Sets is_completed when current_count >= min_count
--   * Awards ajr exactly once via ajr_log (with ajr_awarded guard)
--   * Marks daily_activity.dhikr_done
-- -----------------------------------------------------------------------------
create or replace function public.fn_dhikr_progress_after_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_min   smallint;
  v_ajr   smallint;
begin
  select min_count, ajr into v_min, v_ajr
    from public.dhikrs where id = new.dhikr_id;

  if v_min is null then
    return new;
  end if;

  if new.current_count >= v_min and not new.is_completed then
    new.is_completed := true;
  end if;

  -- Award ajr exactly once (the first time it crosses min_count)
  if new.is_completed and not new.ajr_awarded then
    insert into public.ajr_log(user_id, earned_ajr, source, source_id)
    values (new.user_id, v_ajr, 'dhikr', new.dhikr_id);

    new.ajr_awarded := true;

    perform public.fn_mark_daily_activity(new.user_id, 'dhikr');
  end if;

  return new;
end;
$$;

drop trigger if exists trg_dhikr_progress_after_change on public.dhikr_progress;
create trigger trg_dhikr_progress_after_change
  before insert or update on public.dhikr_progress
  for each row execute function public.fn_dhikr_progress_after_change();

-- -----------------------------------------------------------------------------
-- Reset stale streak nightly (single-shot SQL — frontend can also call this
-- on app open; recommended to schedule via pg_cron if available).
-- -----------------------------------------------------------------------------
create or replace function public.fn_reset_stale_streaks()
returns void
language sql
as $$
  update public.profiles
     set current_streak = 0
   where last_streak_date is not null
     and last_streak_date < ((now() at time zone 'utc')::date - 1);
$$;
