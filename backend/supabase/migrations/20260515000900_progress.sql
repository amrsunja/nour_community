-- =============================================================================
-- Per-user progress tables
-- =============================================================================

-- Quran progress: one row per user, always exists (created by handle_new_auth_user)
create table if not exists public.quran_progress (
  id                    bigserial primary key,
  user_id               uuid not null unique references public.profiles(id) on delete cascade,
  current_surah_number  smallint not null default 1 check (current_surah_number between 1 and 114),
  current_ayah_number   smallint not null default 1,
  updated_at            timestamptz not null default now()
);

drop trigger if exists trg_quran_progress_updated_at on public.quran_progress;
create trigger trg_quran_progress_updated_at
  before update on public.quran_progress
  for each row execute function public.set_updated_at();

-- Daily dhikr progress: many rows per user (one per dhikr per day)
create table if not exists public.dhikr_progress (
  id                bigserial primary key,
  user_id           uuid   not null references public.profiles(id) on delete cascade,
  dhikr_id          bigint not null references public.dhikrs(id) on delete cascade,
  current_count     int    not null default 0 check (current_count >= 0),
  is_completed      boolean not null default false,  -- true once current_count >= min_count
  progress_date     date   not null default (now() at time zone 'utc')::date,
  ajr_awarded       boolean not null default false,  -- guards against duplicate ajr grants
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);
create unique index if not exists dhikr_progress_user_dhikr_day_uniq
  on public.dhikr_progress(user_id, dhikr_id, progress_date);
create index if not exists dhikr_progress_user_day_idx
  on public.dhikr_progress(user_id, progress_date);

drop trigger if exists trg_dhikr_progress_updated_at on public.dhikr_progress;
create trigger trg_dhikr_progress_updated_at
  before update on public.dhikr_progress
  for each row execute function public.set_updated_at();

-- Hadith progress: one row per user per collection
create table if not exists public.hadith_progress (
  id                     bigserial primary key,
  user_id                uuid   not null references public.profiles(id) on delete cascade,
  hadith_collection_id   bigint not null references public.hadith_collections(id) on delete cascade,
  current_hadith_id      bigint references public.hadiths(id) on delete set null,
  updated_at             timestamptz not null default now()
);
create unique index if not exists hadith_progress_user_collection_uniq
  on public.hadith_progress(user_id, hadith_collection_id);

drop trigger if exists trg_hadith_progress_updated_at on public.hadith_progress;
create trigger trg_hadith_progress_updated_at
  before update on public.hadith_progress
  for each row execute function public.set_updated_at();

-- Dua progress: one row per user (created by handle_new_auth_user)
create table if not exists public.dua_progress (
  id              bigserial primary key,
  user_id         uuid not null unique references public.profiles(id) on delete cascade,
  current_dua_id  bigint references public.duas(id) on delete set null,
  updated_at      timestamptz not null default now()
);

drop trigger if exists trg_dua_progress_updated_at on public.dua_progress;
create trigger trg_dua_progress_updated_at
  before update on public.dua_progress
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- Auto-create hadith_progress rows when a new hadith_collection is added
-- (so every existing user gets a tracking row).
-- -----------------------------------------------------------------------------
create or replace function public.fn_seed_hadith_progress_for_new_collection()
returns trigger
language plpgsql
as $$
begin
  insert into public.hadith_progress (user_id, hadith_collection_id, current_hadith_id)
  select p.id, new.id, null from public.profiles p
  on conflict (user_id, hadith_collection_id) do nothing;
  return new;
end;
$$;

drop trigger if exists trg_seed_hadith_progress_for_new_collection on public.hadith_collections;
create trigger trg_seed_hadith_progress_for_new_collection
  after insert on public.hadith_collections
  for each row execute function public.fn_seed_hadith_progress_for_new_collection();

-- And when a new profile is created, seed rows for every existing collection.
create or replace function public.fn_seed_hadith_progress_for_new_user()
returns trigger
language plpgsql
as $$
begin
  insert into public.hadith_progress (user_id, hadith_collection_id, current_hadith_id)
  select new.id, hc.id, null from public.hadith_collections hc
  on conflict (user_id, hadith_collection_id) do nothing;
  return new;
end;
$$;

drop trigger if exists trg_seed_hadith_progress_for_new_user on public.profiles;
create trigger trg_seed_hadith_progress_for_new_user
  after insert on public.profiles
  for each row execute function public.fn_seed_hadith_progress_for_new_user();
