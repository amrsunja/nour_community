-- =============================================================================
-- Push infrastructure (P1 — devis Poste 1).
--   * device_tokens        — FCM tokens per user/device
--   * notifications_log    — every push sent (+ opened_at for open-rate stats)
--   * fn_mark_notification_opened
--   * mosque_notification_quota + fn_mosque_broadcast_quota (server-side limit)
-- See docs/MOSQUES_MODULE_IMPLEMENTATION.md §5.1 / §5.2 / §6
-- =============================================================================

create table if not exists public.device_tokens (
  id           bigserial primary key,
  user_id      uuid not null references public.profiles(id) on delete cascade,
  token        text not null unique,
  platform     text not null check (platform in ('ios','android')),
  app_version  text,
  locale       text,
  timezone     text,
  last_seen_at timestamptz not null default now(),
  created_at   timestamptz not null default now()
);
create index if not exists device_tokens_user_idx on public.device_tokens(user_id);
alter table public.device_tokens enable row level security;
drop policy if exists device_tokens_self on public.device_tokens;
create policy device_tokens_self on public.device_tokens for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Upsert helper: a token that moves to another account (shared device) is
-- re-attached to the new user instead of failing on the unique constraint.
create or replace function public.fn_register_device_token(
  p_token text, p_platform text, p_app_version text default null,
  p_locale text default null, p_timezone text default null
) returns void
language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'unauthorized'; end if;
  insert into public.device_tokens (user_id, token, platform, app_version, locale, timezone)
  values (auth.uid(), p_token, p_platform, p_app_version, p_locale, p_timezone)
  on conflict (token) do update set
    user_id = excluded.user_id, platform = excluded.platform, app_version = excluded.app_version,
    locale = excluded.locale, timezone = excluded.timezone, last_seen_at = now();
end $$;
grant execute on function public.fn_register_device_token(text, text, text, text, text) to authenticated;

create table if not exists public.notifications_log (
  id          bigserial primary key,
  user_id     uuid not null references public.profiles(id) on delete cascade,
  kind        public.push_kind not null,
  title       text not null,
  body        text,
  data        jsonb not null default '{}'::jsonb,
  mosque_id   bigint references public.mosques(id) on delete set null,
  post_id     bigint,
  campaign_id bigint,
  status      text not null default 'sent',   -- sent | failed
  error       text,
  sent_at     timestamptz not null default now(),
  opened_at   timestamptz
);
create index if not exists notifications_log_user_idx   on public.notifications_log(user_id, sent_at desc);
create index if not exists notifications_log_mosque_idx on public.notifications_log(mosque_id, sent_at desc);
alter table public.notifications_log enable row level security;
drop policy if exists notifications_log_self_read on public.notifications_log;
create policy notifications_log_self_read on public.notifications_log for select to authenticated
  using (user_id = auth.uid());

create or replace function public.fn_mark_notification_opened(p_id bigint)
returns void language sql security definer set search_path = public as $$
  update public.notifications_log set opened_at = coalesce(opened_at, now())
   where id = p_id and user_id = auth.uid();
$$;
grant execute on function public.fn_mark_notification_opened(bigint) to authenticated;

-- One row per mosque broadcast; the rolling 7-day count is the quota.
create table if not exists public.mosque_notification_quota (
  id          bigserial primary key,
  mosque_id   bigint not null references public.mosques(id) on delete cascade,
  post_id     bigint,
  campaign_id bigint,
  sent_at     timestamptz not null default now(),
  recipients  int not null default 0
);
create index if not exists mnq_idx on public.mosque_notification_quota(mosque_id, sent_at desc);
alter table public.mosque_notification_quota enable row level security;
drop policy if exists mnq_admin_read on public.mosque_notification_quota;
create policy mnq_admin_read on public.mosque_notification_quota for select to authenticated
  using (public.is_mosque_admin(mosque_id) or public.is_admin());

create or replace function public.fn_mosque_broadcast_quota(p_mosque_id bigint)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare v_limit int; v_used int; v_next timestamptz;
begin
  if not (public.is_mosque_admin(p_mosque_id) or public.is_admin()) then raise exception 'forbidden'; end if;
  select coalesce((value)::int, 2) into v_limit from public.app_config where key = 'mosque_broadcasts_per_week';
  v_limit := coalesce(v_limit, 2);
  select count(*), min(sent_at) + interval '7 days'
    into v_used, v_next
    from public.mosque_notification_quota
   where mosque_id = p_mosque_id and sent_at > now() - interval '7 days';
  return jsonb_build_object(
    'used', v_used, 'limit', v_limit,
    'remaining', greatest(0, v_limit - v_used),
    'next_allowed_at', case when v_used >= v_limit then v_next else null end);
end $$;
grant execute on function public.fn_mosque_broadcast_quota(bigint) to authenticated;

-- Push preference update (self) — plain column update is allowed by the
-- existing profiles self-update policy; helper kept for symmetry.
create or replace function public.fn_set_push_prefs(p_prefs jsonb)
returns void language sql security definer set search_path = public as $$
  update public.profiles set push_prefs = coalesce(p_prefs, '{}'::jsonb) where id = auth.uid();
$$;
grant execute on function public.fn_set_push_prefs(jsonb) to authenticated;
