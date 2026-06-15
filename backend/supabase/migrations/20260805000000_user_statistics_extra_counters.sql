-- =============================================================================
-- Profile statistics RPC — extra counters
-- =============================================================================
-- Extends fn_user_statistics with four additional, low-cost aggregates so the
-- profile "Statistics" page can surface more interesting (but simple) numbers:
--
--   active_days   distinct calendar days (UTC) with any ajr activity
--   ayahs_read    count of ajr_log rows with source = 'ayah'
--   hadiths_read  count of ajr_log rows with source = 'hadith'
--   duas_recited  count of ajr_log rows with source = 'dua'
--
-- Same scoping/contract as before: scoped to auth.uid(), p_from lower bound
-- (null = all time). Column order of the original three is preserved so the
-- existing client keeps working; new columns are appended.
-- -----------------------------------------------------------------------------
-- Return type (OUT columns) changed, so CREATE OR REPLACE fails with 42P13.
-- Drop first, then recreate.
drop function if exists public.fn_user_statistics(timestamptz);

create or replace function public.fn_user_statistics(p_from timestamptz default null)
returns table (
  earned_ajr      bigint,
  dhikr_completed bigint,
  completed_deeds bigint,
  active_days     bigint,
  ayahs_read      bigint,
  hadiths_read    bigint,
  duas_recited    bigint
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
    ), 0)::bigint as completed_deeds,

    coalesce((
      select count(distinct (created_at at time zone 'utc')::date)
        from public.ajr_log
       where user_id = auth.uid()
         and (p_from is null or created_at >= p_from)
    ), 0)::bigint as active_days,

    coalesce((
      select count(*)
        from public.ajr_log
       where user_id = auth.uid()
         and source = 'ayah'
         and (p_from is null or created_at >= p_from)
    ), 0)::bigint as ayahs_read,

    coalesce((
      select count(*)
        from public.ajr_log
       where user_id = auth.uid()
         and source = 'hadith'
         and (p_from is null or created_at >= p_from)
    ), 0)::bigint as hadiths_read,

    coalesce((
      select count(*)
        from public.ajr_log
       where user_id = auth.uid()
         and source = 'dua'
         and (p_from is null or created_at >= p_from)
    ), 0)::bigint as duas_recited;
$$;

grant execute on function public.fn_user_statistics(timestamptz) to authenticated;
