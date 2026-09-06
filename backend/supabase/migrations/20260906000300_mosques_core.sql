-- =============================================================================
-- Mosques module (P2) — core content.
--   prayer times (+ overrides, copy RPC, effective RPC), followers, user
--   mosques, profile views, imams, posts (+ interactions, limits, counters),
--   members, campaigns skeleton (for stats), search RPC, community RPC,
--   dashboard stats RPC, storage buckets, RLS, realtime, cron jobs.
-- See docs/MOSQUES_MODULE_IMPLEMENTATION.md §4.4 → §4.13
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Prayer times (one row per mosque per day) + overrides
-- -----------------------------------------------------------------------------
create table if not exists public.mosque_prayer_times (
  id            bigserial primary key,
  mosque_id     bigint not null references public.mosques(id) on delete cascade,
  day           date   not null,
  fajr          time not null,
  dhuhr         time not null,
  asr           time not null,
  maghrib       time not null,
  isha          time not null,
  sunrise       time,
  jumua         time,
  jumua_2       time,
  jumua_3       time,
  iqama_offsets jsonb not null default '{"fajr":10,"dhuhr":10,"asr":10,"maghrib":0,"isha":10}'::jsonb,
  source        text not null default 'manual',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (mosque_id, day)
);
create index if not exists mosque_prayer_times_lookup on public.mosque_prayer_times(mosque_id, day);
drop trigger if exists trg_mpt_updated_at on public.mosque_prayer_times;
create trigger trg_mpt_updated_at before update on public.mosque_prayer_times
  for each row execute function public.set_updated_at();

create table if not exists public.mosque_prayer_overrides (
  id         bigserial primary key,
  mosque_id  bigint not null references public.mosques(id) on delete cascade,
  day        date not null,
  slot       public.prayer_slot not null,
  time       time not null,
  reason     text,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (mosque_id, day, slot)
);

create or replace function public.fn_copy_mosque_prayer_times(
  p_mosque_id bigint, p_from date, p_to_start date, p_to_end date
) returns int
language plpgsql security definer set search_path = public as $$
declare v_src public.mosque_prayer_times%rowtype; v_d date; v_n int := 0;
begin
  if not public.is_mosque_admin(p_mosque_id) then raise exception 'forbidden'; end if;
  if p_to_end < p_to_start or p_to_end - p_to_start > 366 then raise exception 'invalid_range'; end if;
  select * into v_src from public.mosque_prayer_times where mosque_id = p_mosque_id and day = p_from;
  if not found then raise exception 'source_day_empty'; end if;
  v_d := p_to_start;
  while v_d <= p_to_end loop
    if v_d <> p_from then
      insert into public.mosque_prayer_times
        (mosque_id, day, fajr, dhuhr, asr, maghrib, isha, sunrise, jumua, jumua_2, jumua_3, iqama_offsets, source)
      values
        (p_mosque_id, v_d, v_src.fajr, v_src.dhuhr, v_src.asr, v_src.maghrib, v_src.isha, v_src.sunrise,
         v_src.jumua, v_src.jumua_2, v_src.jumua_3, v_src.iqama_offsets, 'copied')
      on conflict (mosque_id, day) do update set
        fajr = excluded.fajr, dhuhr = excluded.dhuhr, asr = excluded.asr, maghrib = excluded.maghrib,
        isha = excluded.isha, sunrise = excluded.sunrise, jumua = excluded.jumua, jumua_2 = excluded.jumua_2,
        jumua_3 = excluded.jumua_3, iqama_offsets = excluded.iqama_offsets, source = 'copied';
      v_n := v_n + 1;
    end if;
    v_d := v_d + 1;
  end loop;
  return v_n;
end $$;
grant execute on function public.fn_copy_mosque_prayer_times(bigint, date, date, date) to authenticated;

-- Effective times of one day: scheduled row merged with overrides.
create or replace function public.fn_mosque_prayer_times_effective(p_mosque_id bigint, p_day date)
returns table (slot public.prayer_slot, scheduled time, effective time, iqama_offset int, is_override boolean)
language sql stable security invoker as $$
  with base as (
    select t.* from public.mosque_prayer_times t where t.mosque_id = p_mosque_id and t.day = p_day
  ), slots as (
    select 'fajr'::public.prayer_slot s, b.fajr t, (b.iqama_offsets->>'fajr')::int o from base b
    union all select 'dhuhr', b.dhuhr, (b.iqama_offsets->>'dhuhr')::int from base b
    union all select 'asr', b.asr, (b.iqama_offsets->>'asr')::int from base b
    union all select 'maghrib', b.maghrib, (b.iqama_offsets->>'maghrib')::int from base b
    union all select 'isha', b.isha, (b.iqama_offsets->>'isha')::int from base b
  )
  select s.s, s.t, coalesce(o.time, s.t), coalesce(s.o, 0), o.id is not null
    from slots s
    left join public.mosque_prayer_overrides o
      on o.mosque_id = p_mosque_id and o.day = p_day and o.slot = s.s;
$$;
grant execute on function public.fn_mosque_prayer_times_effective(bigint, date) to authenticated;

-- -----------------------------------------------------------------------------
-- 2. Followers, user mosques, profile views
-- -----------------------------------------------------------------------------
create table if not exists public.mosque_followers (
  mosque_id  bigint not null references public.mosques(id) on delete cascade,
  user_id    uuid   not null references public.profiles(id) on delete cascade,
  notify     boolean not null default true,
  created_at timestamptz not null default now(),
  primary key (mosque_id, user_id)
);
create index if not exists mosque_followers_user_idx on public.mosque_followers(user_id);

create table if not exists public.user_mosques (
  user_id    uuid   not null references public.profiles(id) on delete cascade,
  mosque_id  bigint not null references public.mosques(id) on delete cascade,
  rank       smallint not null check (rank in (1, 2)),
  created_at timestamptz not null default now(),
  primary key (user_id, mosque_id),
  unique (user_id, rank)
);

create or replace function public.fn_set_user_mosques(p_principal bigint, p_secondary bigint default null)
returns void language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'unauthorized'; end if;
  if p_secondary is not null and p_secondary = p_principal then raise exception 'same_mosque'; end if;
  delete from public.user_mosques where user_id = v_uid;
  if p_principal is not null then
    insert into public.user_mosques (user_id, mosque_id, rank) values (v_uid, p_principal, 1);
  end if;
  if p_secondary is not null then
    insert into public.user_mosques (user_id, mosque_id, rank) values (v_uid, p_secondary, 2);
  end if;
end $$;
grant execute on function public.fn_set_user_mosques(bigint, bigint) to authenticated;

create table if not exists public.mosque_profile_views (
  mosque_id bigint not null references public.mosques(id) on delete cascade,
  user_id   uuid   not null references public.profiles(id) on delete cascade,
  day       date   not null default current_date,
  primary key (mosque_id, user_id, day)
);
create or replace function public.fn_track_mosque_view(p_mosque_id bigint) returns void
language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then return; end if;
  insert into public.mosque_profile_views (mosque_id, user_id) values (p_mosque_id, auth.uid())
  on conflict do nothing;
  if found then update public.mosques set views_count = views_count + 1 where id = p_mosque_id; end if;
end $$;
grant execute on function public.fn_track_mosque_view(bigint) to authenticated;

create or replace function public.fn_mosque_followers_count() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' then
    update public.mosques set followers_count = followers_count + 1 where id = new.mosque_id;
  elsif tg_op = 'DELETE' then
    update public.mosques set followers_count = greatest(0, followers_count - 1) where id = old.mosque_id;
  end if;
  return null;
end $$;
drop trigger if exists trg_mosque_followers_count on public.mosque_followers;
create trigger trg_mosque_followers_count after insert or delete on public.mosque_followers
  for each row execute function public.fn_mosque_followers_count();

-- -----------------------------------------------------------------------------
-- 3. Imams
-- -----------------------------------------------------------------------------
create table if not exists public.mosque_imams (
  id         bigserial primary key,
  mosque_id  bigint not null references public.mosques(id) on delete cascade,
  full_name  text not null,
  role       text,
  since_year int,
  bio        text,
  photo_url  text,
  position   int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists mosque_imams_mosque_idx on public.mosque_imams(mosque_id, position);
drop trigger if exists trg_mosque_imams_updated_at on public.mosque_imams;
create trigger trg_mosque_imams_updated_at before update on public.mosque_imams
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- 4. Posts + interactions
-- -----------------------------------------------------------------------------
create table if not exists public.mosque_posts (
  id                bigserial primary key,
  mosque_id         bigint not null references public.mosques(id) on delete cascade,
  type              public.mosque_post_type not null,
  status            public.mosque_post_status not null default 'published',
  audience          public.mosque_post_audience not null default 'public',
  title             text not null,
  body              text,
  cover_url         text,
  is_urgent         boolean not null default false,
  event_date        date,
  event_time        time,
  event_end_time    time,
  location          text,
  after_prayer      public.prayer_slot,
  language          text,
  volunteers_needed int,
  published_at      timestamptz not null default now(),
  expires_at        timestamptz,
  archived_at       timestamptz,
  views_count       int not null default 0,
  attendees_count   int not null default 0,
  applicants_count  int not null default 0,
  duas_count        int not null default 0,
  notified_at       timestamptz,
  created_by        uuid references public.profiles(id) on delete set null,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);
create index if not exists mosque_posts_feed_idx
  on public.mosque_posts(mosque_id, status, is_urgent desc, published_at desc);
create index if not exists mosque_posts_event_idx
  on public.mosque_posts(event_date) where type in ('event','janaza','volunteering');
drop trigger if exists trg_mosque_posts_updated_at on public.mosque_posts;
create trigger trg_mosque_posts_updated_at before update on public.mosque_posts
  for each row execute function public.set_updated_at();

-- Active limits (specs A4): announcements ≤ 2, events ≤ 3.
create or replace function public.fn_mosque_posts_limits() returns trigger language plpgsql as $$
declare v_limit int; v_count int;
begin
  if new.status <> 'published' then return new; end if;
  if tg_op = 'UPDATE' and old.status = 'published' and old.type = new.type then return new; end if;
  v_limit := case new.type when 'announcement' then 2 when 'event' then 3 else null end;
  if v_limit is not null then
    select count(*) into v_count from public.mosque_posts
     where mosque_id = new.mosque_id and type = new.type and status = 'published'
       and id <> coalesce(new.id, 0);
    if v_count >= v_limit then raise exception 'post_limit_reached:%', new.type; end if;
  end if;
  if new.type = 'event' and new.event_date is null then raise exception 'event_date_required'; end if;
  return new;
end $$;
drop trigger if exists trg_mosque_posts_limits on public.mosque_posts;
create trigger trg_mosque_posts_limits before insert or update of status, type on public.mosque_posts
  for each row execute function public.fn_mosque_posts_limits();

create table if not exists public.mosque_post_attendees (
  post_id bigint not null references public.mosque_posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id));
create table if not exists public.mosque_post_applicants (
  post_id bigint not null references public.mosque_posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  message text,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id));
create table if not exists public.mosque_post_duas (
  post_id bigint not null references public.mosque_posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id));
create table if not exists public.mosque_post_views (
  post_id bigint not null references public.mosque_posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  primary key (post_id, user_id));

create or replace function public.fn_mosque_post_counters() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_col   text := tg_argv[0];
  v_delta int  := case tg_op when 'INSERT' then 1 else -1 end;
  v_post  bigint := case tg_op when 'INSERT' then new.post_id else old.post_id end;
begin
  execute format('update public.mosque_posts set %I = greatest(0, %I + $1) where id = $2', v_col, v_col)
    using v_delta, v_post;
  -- "Say a dua" earns ajr once per post (source mosque_dua).
  if tg_table_name = 'mosque_post_duas' and tg_op = 'INSERT' then
    insert into public.ajr_log (user_id, earned_ajr, source, source_id)
    select new.user_id, 5, 'mosque_dua', new.post_id
     where not exists (
       select 1 from public.ajr_log
        where user_id = new.user_id and source = 'mosque_dua' and source_id = new.post_id);
  end if;
  return null;
end $$;
drop trigger if exists trg_attendees_count on public.mosque_post_attendees;
create trigger trg_attendees_count after insert or delete on public.mosque_post_attendees
  for each row execute function public.fn_mosque_post_counters('attendees_count');
drop trigger if exists trg_applicants_count on public.mosque_post_applicants;
create trigger trg_applicants_count after insert or delete on public.mosque_post_applicants
  for each row execute function public.fn_mosque_post_counters('applicants_count');
drop trigger if exists trg_duas_count on public.mosque_post_duas;
create trigger trg_duas_count after insert or delete on public.mosque_post_duas
  for each row execute function public.fn_mosque_post_counters('duas_count');
drop trigger if exists trg_post_views_count on public.mosque_post_views;
create trigger trg_post_views_count after insert on public.mosque_post_views
  for each row execute function public.fn_mosque_post_counters('views_count');

-- -----------------------------------------------------------------------------
-- 5. Members
-- -----------------------------------------------------------------------------
create table if not exists public.mosque_members (
  id                  bigserial primary key,
  mosque_id           bigint not null references public.mosques(id) on delete cascade,
  user_id             uuid   not null references public.profiles(id) on delete cascade,
  first_name          text not null,
  last_name           text not null,
  birth_date          date not null,
  profession          text,
  email               text not null,
  phone               text not null,
  volunteer           boolean not null default false,
  consent_at          timestamptz not null default now(),
  status              text not null default 'active' check (status in ('active','left')),
  fee_subscription_id bigint,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (mosque_id, user_id)
);
create index if not exists mosque_members_mosque_idx on public.mosque_members(mosque_id, status);
drop trigger if exists trg_mosque_members_updated_at on public.mosque_members;
create trigger trg_mosque_members_updated_at before update on public.mosque_members
  for each row execute function public.set_updated_at();

create or replace function public.fn_mosque_members_count() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' and new.status = 'active' then
    update public.mosques set members_count = members_count + 1 where id = new.mosque_id;
  elsif tg_op = 'UPDATE' and old.status is distinct from new.status then
    update public.mosques set members_count = greatest(0, members_count + case when new.status = 'active' then 1 else -1 end)
     where id = new.mosque_id;
  elsif tg_op = 'DELETE' and old.status = 'active' then
    update public.mosques set members_count = greatest(0, members_count - 1) where id = old.mosque_id;
  end if;
  return null;
end $$;
drop trigger if exists trg_mosque_members_count on public.mosque_members;
create trigger trg_mosque_members_count after insert or update of status or delete on public.mosque_members
  for each row execute function public.fn_mosque_members_count();

-- -----------------------------------------------------------------------------
-- 6. Campaigns skeleton (fully used in P3; created here for the dashboard RPC)
-- -----------------------------------------------------------------------------
create table if not exists public.mosque_campaigns (
  id                bigserial primary key,
  mosque_id         bigint not null references public.mosques(id) on delete cascade,
  title             text not null,
  description       text,
  cover_url         text,
  goal_amount       numeric(12,2) not null check (goal_amount > 0),
  collected_amount  numeric(12,2) not null default 0,
  donors_count      int not null default 0,
  suggested_amounts int[] not null default '{10,50,100,150}',
  currency          public.currency_type not null default 'EUR',
  status            public.mosque_campaign_status not null default 'active',
  starts_at         timestamptz not null default now(),
  ends_at           timestamptz not null,
  closed_at         timestamptz,
  closed_reason     text,
  reminded_at       timestamptz,
  created_by        uuid references public.profiles(id) on delete set null,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);
create index if not exists mosque_campaigns_idx on public.mosque_campaigns(mosque_id, status, ends_at);
drop trigger if exists trg_mosque_campaigns_updated_at on public.mosque_campaigns;
create trigger trg_mosque_campaigns_updated_at before update on public.mosque_campaigns
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- 7. Search
-- -----------------------------------------------------------------------------
create or replace function public.fn_search_mosques(
  p_query text default null, p_lat double precision default null, p_lng double precision default null,
  p_radius_km int default 50, p_limit int default 30
) returns table (
  id bigint, name text, slug text, logo_url text, cover_url text, address_line text, city text, postal_code text,
  lat double precision, lng double precision, distance_km double precision,
  followers_count int, members_count int, timezone text,
  fajr time, dhuhr time, asr time, maghrib time, isha time, sunrise time, jumua time, has_times boolean
) language sql stable security invoker as $$
  with me as (
    select case when p_lat is null or p_lng is null then null
                else extensions.st_setsrid(extensions.st_makepoint(p_lng, p_lat), 4326)::extensions.geography end g
  )
  select m.id, m.name, m.slug, m.logo_url, m.cover_images[1], m.address_line, m.city, m.postal_code,
         extensions.st_y(m.location::extensions.geometry), extensions.st_x(m.location::extensions.geometry),
         case when me.g is null or m.location is null then null else extensions.st_distance(m.location, me.g) / 1000.0 end,
         m.followers_count, m.members_count, m.timezone,
         t.fajr, t.dhuhr, t.asr, t.maghrib, t.isha, t.sunrise, t.jumua, t.id is not null
    from public.mosques m
    cross join me
    left join public.mosque_prayer_times t
      on t.mosque_id = m.id and t.day = (now() at time zone m.timezone)::date
   where m.status = 'approved'
     and (p_query is null or p_query = ''
          or m.name ilike '%' || p_query || '%' or m.city ilike '%' || p_query || '%'
          or m.address_line ilike '%' || p_query || '%' or m.postal_code ilike p_query || '%')
     and (me.g is null or m.location is null or p_radius_km is null
          or extensions.st_dwithin(m.location, me.g, p_radius_km * 1000))
   order by (case when me.g is null or m.location is null then 1 else 0 end),
            (case when me.g is null or m.location is null then null else extensions.st_distance(m.location, me.g) end) nulls last,
            m.followers_count desc
   limit greatest(1, least(coalesce(p_limit, 30), 100));
$$;
grant execute on function public.fn_search_mosques(text, double precision, double precision, int, int) to authenticated;

-- Effective prayer days for the user's principal mosque (today .. today+N).
create or replace function public.fn_my_mosque_prayer_days(p_days int default 7)
returns table (mosque_id bigint, mosque_name text, city text, timezone text, day date, row_json jsonb, overrides jsonb)
language sql stable security invoker as $$
  with pm as (
    select m.id, m.name, m.city, m.timezone
      from public.user_mosques um join public.mosques m on m.id = um.mosque_id
     where um.user_id = auth.uid() and um.rank = 1 and m.status = 'approved'
     limit 1
  ), days as (
    select pm.id, pm.name, pm.city, pm.timezone,
           ((now() at time zone pm.timezone)::date + g.i) as day
      from pm, generate_series(0, greatest(0, least(coalesce(p_days, 7), 30))) as g(i)
  )
  select d.id, d.name, d.city, d.timezone, d.day,
         to_jsonb(t) - 'id' - 'mosque_id' - 'created_at' - 'updated_at',
         coalesce((select jsonb_object_agg(o.slot::text, o.time::text)
                     from public.mosque_prayer_overrides o where o.mosque_id = d.id and o.day = d.day), '{}'::jsonb)
    from days d
    left join public.mosque_prayer_times t on t.mosque_id = d.id and t.day = d.day
   order by d.day;
$$;
grant execute on function public.fn_my_mosque_prayer_days(int) to authenticated;

-- -----------------------------------------------------------------------------
-- 8. Community (admin) + dashboard stats
-- -----------------------------------------------------------------------------
create or replace function public.fn_mosque_community(
  p_mosque_id bigint, p_filter text default 'all', p_query text default null,
  p_limit int default 30, p_offset int default 0
) returns table (
  user_id uuid, name text, avatar_url text, kind text, since timestamptz,
  email text, phone text, volunteer boolean, member_id bigint
)
language plpgsql stable security definer set search_path = public as $$
begin
  if not (public.is_mosque_admin(p_mosque_id) or public.is_admin()) then raise exception 'forbidden'; end if;
  return query
  with members as (
    select mm.user_id, coalesce(nullif(trim(mm.first_name || ' ' || mm.last_name), ''), p.name) as name,
           p.avatar_url, 'member'::text as kind, mm.created_at as since, mm.email, mm.phone, mm.volunteer, mm.id as member_id
      from public.mosque_members mm join public.profiles p on p.id = mm.user_id
     where mm.mosque_id = p_mosque_id and mm.status = 'active'
  ), followers as (
    select f.user_id, p.name, p.avatar_url, 'follower'::text, f.created_at, null::text, null::text, false, null::bigint
      from public.mosque_followers f join public.profiles p on p.id = f.user_id
     where f.mosque_id = p_mosque_id
       and not exists (select 1 from members m where m.user_id = f.user_id)
  ), all_rows as (
    select * from members union all select * from followers
  )
  select a.* from all_rows a
   where (p_filter = 'all'
          or (p_filter = 'members' and a.kind = 'member')
          or (p_filter = 'followers' and a.kind = 'follower')
          or (p_filter = 'volunteers' and a.kind = 'member' and a.volunteer))
     and (p_query is null or p_query = ''
          or a.name ilike '%' || p_query || '%' or a.email ilike '%' || p_query || '%' or a.phone ilike '%' || p_query || '%')
   order by a.since desc
   limit greatest(1, least(coalesce(p_limit, 30), 200)) offset greatest(0, coalesce(p_offset, 0));
end $$;
grant execute on function public.fn_mosque_community(bigint, text, text, int, int) to authenticated;

create or replace function public.fn_mosque_dashboard_stats(p_mosque_id bigint)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare r jsonb;
begin
  if not (public.is_mosque_admin(p_mosque_id) or public.is_admin()) then raise exception 'forbidden'; end if;
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
                    from public.mosque_campaigns c where c.mosque_id = m.id and c.status = 'active')
  ) into r from public.mosques m where m.id = p_mosque_id;
  return r;
end $$;
grant execute on function public.fn_mosque_dashboard_stats(bigint) to authenticated;

-- -----------------------------------------------------------------------------
-- 9. RLS
-- -----------------------------------------------------------------------------
do $$ declare t text; begin
  foreach t in array array['mosque_prayer_times','mosque_prayer_overrides','mosque_imams','mosque_posts','mosque_campaigns'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists %I_read on public.%I', t, t);
    execute format('create policy %I_read on public.%I for select to authenticated using (exists (select 1 from public.mosques m where m.id = %I.mosque_id and (m.status = ''approved'' or public.is_mosque_member_admin(m.id) or public.is_admin())))', t, t, t);
    execute format('drop policy if exists %I_admin_write on public.%I', t, t);
    execute format('create policy %I_admin_write on public.%I for all to authenticated using (public.is_mosque_admin(mosque_id) or public.is_admin()) with check (public.is_mosque_admin(mosque_id) or public.is_admin())', t, t);
  end loop;
end $$;

-- Posts: non-admins see published rows; followers-only rows need a follow.
drop policy if exists mosque_posts_read on public.mosque_posts;
create policy mosque_posts_read on public.mosque_posts for select to authenticated
  using (
    public.is_mosque_admin(mosque_id) or public.is_admin()
    or (status = 'published'
        and exists (select 1 from public.mosques m where m.id = mosque_id and m.status = 'approved')
        and (audience = 'public'
             or exists (select 1 from public.mosque_followers f where f.mosque_id = mosque_posts.mosque_id and f.user_id = auth.uid()))));

-- Campaign counters are protected (P3 trigger writes them).
create or replace function public.fn_mosque_campaigns_guard() returns trigger language plpgsql as $$
begin
  if current_setting('nour.trusted', true) is distinct from 'on' and not public.is_admin() then
    if new.collected_amount is distinct from old.collected_amount or new.donors_count is distinct from old.donors_count then
      raise exception 'column protected';
    end if;
  end if;
  return new;
end $$;
drop trigger if exists trg_mosque_campaigns_guard on public.mosque_campaigns;
create trigger trg_mosque_campaigns_guard before update on public.mosque_campaigns
  for each row execute function public.fn_mosque_campaigns_guard();

alter table public.mosque_followers enable row level security;
drop policy if exists mosque_followers_self on public.mosque_followers;
create policy mosque_followers_self on public.mosque_followers for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists mosque_followers_admin_read on public.mosque_followers;
create policy mosque_followers_admin_read on public.mosque_followers for select to authenticated
  using (public.is_mosque_admin(mosque_id) or public.is_admin());

alter table public.user_mosques enable row level security;
drop policy if exists user_mosques_self on public.user_mosques;
create policy user_mosques_self on public.user_mosques for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

alter table public.mosque_profile_views enable row level security;   -- definer RPC only
alter table public.mosque_post_views enable row level security;
drop policy if exists mosque_post_views_self on public.mosque_post_views;
create policy mosque_post_views_self on public.mosque_post_views for insert to authenticated
  with check (user_id = auth.uid());
drop policy if exists mosque_post_views_self_read on public.mosque_post_views;
create policy mosque_post_views_self_read on public.mosque_post_views for select to authenticated
  using (user_id = auth.uid());

do $$ declare t text; begin
  foreach t in array array['mosque_post_attendees','mosque_post_applicants','mosque_post_duas'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists %I_self on public.%I', t, t);
    execute format('create policy %I_self on public.%I for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid())', t, t);
    execute format('drop policy if exists %I_admin_read on public.%I', t, t);
    execute format('create policy %I_admin_read on public.%I for select to authenticated using (exists (select 1 from public.mosque_posts p where p.id = %I.post_id and public.is_mosque_admin(p.mosque_id)))', t, t, t);
  end loop;
end $$;

alter table public.mosque_members enable row level security;
drop policy if exists mosque_members_self on public.mosque_members;
create policy mosque_members_self on public.mosque_members for select to authenticated using (user_id = auth.uid());
drop policy if exists mosque_members_self_insert on public.mosque_members;
create policy mosque_members_self_insert on public.mosque_members for insert to authenticated
  with check (user_id = auth.uid()
              and exists (select 1 from public.mosques m where m.id = mosque_id and m.status = 'approved'));
drop policy if exists mosque_members_self_update on public.mosque_members;
create policy mosque_members_self_update on public.mosque_members for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists mosque_members_admin on public.mosque_members;
create policy mosque_members_admin on public.mosque_members for select to authenticated
  using (public.is_mosque_admin(mosque_id) or public.is_admin());
drop policy if exists mosque_members_admin_update on public.mosque_members;
create policy mosque_members_admin_update on public.mosque_members for update to authenticated
  using (public.is_mosque_admin(mosque_id)) with check (public.is_mosque_admin(mosque_id));

-- -----------------------------------------------------------------------------
-- 10. Storage
-- -----------------------------------------------------------------------------
insert into storage.buckets (id, name, public) values ('mosque-media', 'mosque-media', true) on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('mosque-receipts', 'mosque-receipts', false) on conflict (id) do nothing;

create or replace function public.fn_storage_mosque_folder_admin(p_name text) returns boolean
language plpgsql stable security definer set search_path = public as $$
declare v_folder text := (storage.foldername(p_name))[1];
begin
  if v_folder is null or v_folder !~ '^\d+$' then return false; end if;
  return public.is_mosque_admin(v_folder::bigint);
end $$;

drop policy if exists "mosque-media: public read" on storage.objects;
create policy "mosque-media: public read" on storage.objects for select using (bucket_id = 'mosque-media');
drop policy if exists "mosque-media: admin insert" on storage.objects;
create policy "mosque-media: admin insert" on storage.objects for insert
  with check (bucket_id = 'mosque-media' and public.fn_storage_mosque_folder_admin(name));
drop policy if exists "mosque-media: admin update" on storage.objects;
create policy "mosque-media: admin update" on storage.objects for update
  using (bucket_id = 'mosque-media' and public.fn_storage_mosque_folder_admin(name));
drop policy if exists "mosque-media: admin delete" on storage.objects;
create policy "mosque-media: admin delete" on storage.objects for delete
  using (bucket_id = 'mosque-media' and public.fn_storage_mosque_folder_admin(name));

-- -----------------------------------------------------------------------------
-- 11. Realtime + cron
-- -----------------------------------------------------------------------------
do $$ begin alter publication supabase_realtime add table public.mosque_prayer_overrides; exception when duplicate_object then null; end $$;
do $$ begin alter publication supabase_realtime add table public.mosque_campaigns; exception when duplicate_object then null; end $$;

create or replace function public.fn_mosques_housekeeping() returns void
language plpgsql security definer set search_path = public as $$
begin
  -- expired announcements / past events → archived
  update public.mosque_posts set status = 'archived', archived_at = now()
   where status = 'published'
     and ((expires_at is not null and expires_at < now())
          or (type in ('event','janaza') and event_date is not null and event_date < current_date - 1));
  -- old overrides
  delete from public.mosque_prayer_overrides where day < current_date - 1;
  -- campaigns past deadline
  update public.mosque_campaigns set status = 'closed', closed_at = now(), closed_reason = 'deadline'
   where status = 'active' and ends_at < now();
end $$;

do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    perform cron.unschedule(jobid) from cron.job where jobname = 'mosques-housekeeping';
    perform cron.schedule('mosques-housekeeping', '*/10 * * * *', 'select public.fn_mosques_housekeeping()');
  else
    raise notice 'pg_cron not available: schedule select public.fn_mosques_housekeeping() every 10 minutes manually.';
  end if;
end $$;
