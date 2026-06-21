-- =============================================================================
-- Hadith ajr
--
-- Reading a hadith and tapping "I'm done" awards ajr the first time that
-- specific hadith is completed. ajr_log INSERTs are locked down by RLS
-- (with check (false)), so the client cannot write there directly — this
-- SECURITY DEFINER RPC is the only sanctioned path. Mirrors the Daily Ayah
-- design (see 20260523010000_daily_ayah_ajr.sql).
--
--   * fn_award_hadith_ajr(p_hadith_id, p_ajr) — idempotent per (user, hadith).
--     Logs ajr to ajr_log (source = 'hadith', source_id = hadith id), which
--     fires fn_apply_ajr_to_profile to bump profiles.earned_ajr_count, and
--     marks the daily_activity 'quick_action' for streak logic. Returns the
--     user's all-time hadith ajr total. When p_ajr is null the hadith's own
--     `ajr` column is used.
--
-- No new tables: reuses public.ajr_log + public.daily_activity. Idempotency is
-- enforced by checking for an existing (source='hadith', source_id) row.
-- =============================================================================

create or replace function public.fn_award_hadith_ajr(
  p_hadith_id bigint,
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

  -- Resolve the ajr value: explicit arg wins, otherwise the hadith's own ajr.
  select coalesce(p_ajr, ajr, 5) into v_ajr
  from public.hadiths
  where id = p_hadith_id;

  if v_ajr is null then
    v_ajr := coalesce(p_ajr, 5);
  end if;
  if v_ajr <= 0 then
    v_ajr := 5;
  end if;

  -- Already awarded for this hadith? (idempotent — no double award on re-read)
  select exists (
    select 1 from public.ajr_log
    where user_id = v_user
      and source = 'hadith'
      and source_id = p_hadith_id
  ) into v_done;

  if not v_done then
    insert into public.ajr_log (user_id, earned_ajr, source, source_id)
    values (v_user, v_ajr, 'hadith', p_hadith_id);

    perform public.fn_mark_daily_activity(v_user, 'quick_action');
  end if;

  return coalesce((
    select sum(earned_ajr)::bigint
    from public.ajr_log
    where user_id = v_user and source = 'hadith'
  ), 0);
end;
$$;

revoke execute on function public.fn_award_hadith_ajr(bigint, integer) from public;
grant execute on function public.fn_award_hadith_ajr(bigint, integer) to authenticated;
