-- =============================================================================
-- Profiles (1:1 with auth.users) + onboarding fields
-- =============================================================================

create table if not exists public.profiles (
  id                       uuid primary key references auth.users(id) on delete cascade,
  name                     text,
  avatar_url               text,
  gender                   public.gender_type,
  level                    public.level_type,
  language                 public.language_type default 'en',
  onboarding_completed     boolean not null default false,
  last_onboarding_screen   smallint not null default 0,
  daily_practice_time      smallint not null default 5,  -- minutes
  -- Aggregate counters maintained by triggers
  current_streak           smallint not null default 0,  -- 0..7
  last_streak_date         date,
  earned_ajr_count         bigint  not null default 0,
  is_admin                 boolean not null default false,
  created_at               timestamptz not null default now(),
  updated_at               timestamptz not null default now()
);

create index if not exists profiles_language_idx    on public.profiles(language);
create index if not exists profiles_level_idx       on public.profiles(level);

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- Auto-create profile + per-user progress rows on auth.users insert
-- (Quran, Hadith collections, Dua progress rows are created lazily on first
--  read because hadith_collection_id list is dynamic — handled later.)
-- -----------------------------------------------------------------------------
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name',
             new.raw_user_meta_data ->> 'full_name')
  )
  on conflict (id) do nothing;

  -- Quran progress is created here because there's a single row per user
  insert into public.quran_progress (user_id, current_surah_number, current_ayah_number)
  values (new.id, 1, 1)
  on conflict (user_id) do nothing;

  -- Dua progress (single row per user)
  insert into public.dua_progress (user_id, current_dua_id)
  values (new.id, null)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists trg_on_auth_user_created on auth.users;
create trigger trg_on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();
