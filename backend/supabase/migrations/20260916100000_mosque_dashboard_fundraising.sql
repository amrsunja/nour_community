-- =============================================================================
-- Dashboard fundraising summary — P3.2
--
-- The admin dashboard "Fundraising" card now carries a header: total raised over
-- a selectable period + the number of distinct donors over that same period.
-- `fn_mosque_dashboard_stats` gains `p_period` ('year' | 'days30' | 'all') and
-- returns `fundraising_*`. The old 1-arg signature is dropped so a 1-arg call
-- resolves to the new function through its default.
-- =============================================================================

drop function if exists public.fn_mosque_dashboard_stats(bigint);

create or replace function public.fn_mosque_dashboard_stats(
  p_mosque_id bigint,
  p_period    text default 'year'
)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  r      jsonb;
  v_from timestamptz;
  v_per  text := coalesce(nullif(p_period, ''), 'year');
begin
  if not (public.is_mosque_admin(p_mosque_id) or public.is_admin()) then raise exception 'forbidden'; end if;

  v_from := case v_per
              when 'days30' then now() - interval '30 days'
              when 'all'    then '-infinity'::timestamptz
              else date_trunc('year', now())          -- 'year'
            end;

  with tx as (
    select t.user_id, t.amount_total, t.currency, t.created_at
      from public.transactions t
     where t.mosque_id = p_mosque_id
       and t.status = 'succeeded'
       and t.type in ('mosque_sadaqa', 'mosque_campaign', 'mosque_membership')
       and t.created_at >= v_from
  )
  select jsonb_build_object(
    'followers_total', m.followers_count,
    'followers_7d', (select count(*) from public.mosque_followers f where f.mosque_id = m.id and f.created_at > now() - interval '7 days'),
    'members_total', m.members_count,
    'members_7d', (select count(*) from public.mosque_members x where x.mosque_id = m.id and x.status = 'active' and x.created_at > now() - interval '7 days'),
    'members_left_7d', (select count(*) from public.mosque_members x where x.mosque_id = m.id and x.status = 'left' and x.updated_at > now() - interval '7 days'),
    'views_30d', (select count(*) from public.mosque_profile_views v where v.mosque_id = m.id and v.day > current_date - 30),
    'followers_30d', (select count(*) from public.mosque_followers f where f.mosque_id = m.id and f.created_at > now() - interval '30 days'),
    'growth_series', (select coalesce(jsonb_agg(jsonb_build_object('day', s.d, 'followers', s.c) order by s.d), '[]'::jsonb)
                        from (select f.created_at::date d, count(*) c from public.mosque_followers f
                               where f.mosque_id = m.id and f.created_at > now() - interval '30 days' group by 1) s),
    'notif_open_rate', (select case when count(*) = 0 then null
                                    else round(100.0 * count(*) filter (where l.opened_at is not null) / count(*), 1) end
                          from public.notifications_log l where l.mosque_id = m.id and l.sent_at > now() - interval '30 days'),
    'pending_events', (select count(*) from public.mosque_posts p where p.mosque_id = m.id and p.type = 'event' and p.status = 'published' and p.event_date >= current_date),
    'campaigns_active', (select count(*) from public.mosque_campaigns c where c.mosque_id = m.id and c.status = 'active'),
    'campaigns_ending_soon', (select count(*) from public.mosque_campaigns c where c.mosque_id = m.id and c.status = 'active' and c.ends_at < now() + interval '7 days'),
    'campaigns', (select coalesce(jsonb_agg(jsonb_build_object(
                     'id', c.id, 'title', c.title, 'goal_amount', c.goal_amount, 'collected_amount', c.collected_amount,
                     'donors_count', c.donors_count, 'ends_at', c.ends_at) order by c.ends_at), '[]'::jsonb)
                    from public.mosque_campaigns c where c.mosque_id = m.id and c.status = 'active'),
    -- Fundraising header ------------------------------------------------------
    'fundraising_period', v_per,
    'fundraising_total', coalesce((select sum(amount_total) from tx), 0),
    'fundraising_donors', (select count(distinct user_id) from tx),
    'fundraising_currency', coalesce(
        (select t.currency::text from tx t order by t.created_at desc limit 1),
        (select c.currency::text from public.mosque_campaigns c
          where c.mosque_id = m.id order by c.created_at desc limit 1),
        'EUR')
  ) into r from public.mosques m where m.id = p_mosque_id;

  return r;
end $$;

grant execute on function public.fn_mosque_dashboard_stats(bigint, text) to authenticated;
