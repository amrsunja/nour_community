-- =============================================================================
-- Profile statistics RPC
-- =============================================================================
-- Single round-trip aggregate for the profile "Statistics" page. Scoped to the
-- caller via auth.uid() (security definer + RLS-equivalent uid filter).
--
--   p_from = null            -> all time
--   p_from = now() - 7 days  -> last 7 days
--   p_from = start of today  -> today
--
-- Returns one row:
--   earned_ajr      sum of ajr_log.earned_ajr
--   dhikr_completed count of completed dhikr (ajr_log rows with source = 'dhikr')
--   completed_deeds count of donated projects (donation_transactions rows)
-- -----------------------------------------------------------------------------
create or replace function public.fn_user_statistics(p_from timestamptz default null)
returns table (
  earned_ajr      bigint,
  dhikr_completed bigint,
  completed_deeds bigint
)
language sql
stable
security definer
set search_path = public
as $$
  select
    coalesce((
      select sum(earned_ajr)
        from public.ajr_log
       where user_id = auth.uid()
         and (p_from is null or created_at >= p_from)
    ), 0)::bigint as earned_ajr,

    coalesce((
      select count(*)
        from public.ajr_log
       where user_id = auth.uid()
         and source = 'dhikr'
         and (p_from is null or created_at >= p_from)
    ), 0)::bigint as dhikr_completed,

    coalesce((
      select count(*)
        from public.donation_transactions
       where user_id = auth.uid()
         and (p_from is null or created_at >= p_from)
    ), 0)::bigint as completed_deeds;
$$;

grant execute on function public.fn_user_statistics(timestamptz) to authenticated;
