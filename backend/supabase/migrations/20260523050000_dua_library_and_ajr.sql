-- =============================================================================
-- Dua library: title + ordering columns, and the ajr RPCs
--
-- The duas feature is a single ordered library (no collections). The base
-- `public.duas` table (see 20260515000400_duas.sql) shipped without a display
-- title or an explicit order, so we add:
--   * title_en / title_fr / title_ar  — short heading shown above the dua
--     (e.g. "After salah"); nullable so existing rows aren't broken.
--   * position                        — 1-based display order (order by
--     position, then id as a stable tie-breaker).
--
-- Ajr RPCs mirror the Hadith / Daily-Ayah design (ajr_log INSERTs are blocked
-- by RLS with check(false), so these SECURITY DEFINER functions are the only
-- sanctioned write path):
--
--   * fn_award_dua_ajr(p_dua_id, p_ajr) — idempotent per (user, dua). Awards
--     ajr the first time a specific dua in the library is completed. source =
--     'dua', source_id = dua id. Mirrors fn_award_hadith_ajr.
--
--   * fn_daily_dua_status() — read-only: all-time dua ajr total + whether the
--     user already completed *today's* daily dua (a 'dua' ajr row with a NULL
--     source_id for the current UTC day).
--
--   * fn_award_daily_dua_ajr(p_ajr) — idempotent per UTC day. Logs the daily
--     dua quick action (source = 'dua', source_id = NULL) and marks the
--     daily_activity 'quick_action' for streak logic. Mirrors
--     fn_award_daily_ayah_ajr.
--
-- No new tables: reuses public.ajr_log + public.daily_activity.
-- =============================================================================

-- ── Schema additions ────────────────────────────────────────────────────────
alter table public.duas add column if not exists title_en text;
alter table public.duas add column if not exists title_fr text;
alter table public.duas add column if not exists title_ar text;
alter table public.duas add column if not exists position int not null default 0;

create index if not exists duas_position_idx on public.duas(position);

-- ── Per-dua ajr (library reading) ────────────────────────────────────────────
create or replace function public.fn_award_dua_ajr(
  p_dua_id bigint,
  p_ajr integer default null
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
  if v_user is null then
    raise exception 'not authenticated';
  end if;

  -- Resolve the ajr value: explicit arg wins, otherwise the dua's own ajr.
  select coalesce(p_ajr, ajr, 5) into v_ajr
  from public.duas
  where id = p_dua_id;

  if v_ajr is null then
    v_ajr := coalesce(p_ajr, 5);
  end if;
  if v_ajr <= 0 then
    v_ajr := 5;
  end if;

  -- Already awarded for this dua? (idempotent — no double award on re-read)
  select exists (
    select 1 from public.ajr_log
    where user_id = v_user
      and source = 'dua'
      and source_id = p_dua_id
  ) into v_done;

  if not v_done then
    insert into public.ajr_log (user_id, earned_ajr, source, source_id)
    values (v_user, v_ajr, 'dua', p_dua_id);

    perform public.fn_mark_daily_activity(v_user, 'quick_action');
  end if;

  return coalesce((
    select sum(earned_ajr)::bigint
    from public.ajr_log
    where user_id = v_user and source = 'dua'
  ), 0);
end;
$$;

-- ── Daily Dua quick action ───────────────────────────────────────────────────
create or replace function public.fn_daily_dua_status()
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
        and source = 'dua'
    ), 0) as total_ajr,
    exists (
      select 1
      from public.ajr_log
      where user_id = auth.uid()
        and source = 'dua'
        and source_id is null
        and (created_at at time zone 'utc')::date = (now() at time zone 'utc')::date
    ) as done_today;
$$;

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
  v_done boolean;
begin
  if v_user is null then
    raise exception 'not authenticated';
  end if;

  if v_ajr <= 0 then
    v_ajr := 5;
  end if;

  -- Already completed today's daily dua? (source_id IS NULL marks the daily
  -- quick action, distinct from per-dua library reads which carry a source_id)
  select exists (
    select 1 from public.ajr_log
    where user_id = v_user
      and source = 'dua'
      and source_id is null
      and (created_at at time zone 'utc')::date = (now() at time zone 'utc')::date
  ) into v_done;

  if not v_done then
    insert into public.ajr_log (user_id, earned_ajr, source, source_id)
    values (v_user, v_ajr, 'dua', null);

    perform public.fn_mark_daily_activity(v_user, 'quick_action');
  end if;

  return coalesce((
    select sum(earned_ajr)::bigint
    from public.ajr_log
    where user_id = v_user and source = 'dua'
  ), 0);
end;
$$;

-- ── Grants ───────────────────────────────────────────────────────────────────
revoke execute on function public.fn_award_dua_ajr(bigint, integer)    from public;
revoke execute on function public.fn_daily_dua_status()                from public;
revoke execute on function public.fn_award_daily_dua_ajr(integer)      from public;
grant  execute on function public.fn_award_dua_ajr(bigint, integer)    to authenticated;
grant  execute on function public.fn_daily_dua_status()                to authenticated;
grant  execute on function public.fn_award_daily_dua_ajr(integer)      to authenticated;
