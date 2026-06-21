-- =============================================================================
-- Nour Community :: Enums & Extensions
-- =============================================================================

create extension if not exists "uuid-ossp" with schema extensions;
create extension if not exists "pgcrypto" with schema extensions;
create extension if not exists "pg_trgm" with schema extensions;

-- -----------------------------------------------------------------------------
-- Core enums (referenced by README)
-- -----------------------------------------------------------------------------
do $$ begin
  create type public.level_type as enum ('begining', 'growing', 'established', 'returning');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.gender_type as enum ('male', 'female');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.language_type as enum ('en', 'fr', 'ar');
exception when duplicate_object then null; end $$;

-- Currency used for transactions (extendable)
do $$ begin
  create type public.currency_type as enum ('EUR', 'USD', 'GBP');
exception when duplicate_object then null; end $$;

-- Ajr source categories (drives ajr_log filtering)
do $$ begin
  create type public.ajr_source as enum (
    'dhikr',
    'adhkar',
    'dua',
    'ayah',
    'hadith',
    'quiz',
    'quiz_bonus',
    'manual'
  );
exception when duplicate_object then null; end $$;

-- Favorite target type (polymorphic helper, kept for indexing)
do $$ begin
  create type public.favorite_target as enum (
    'ayah',
    'dua',
    'adhkar',
    'hadith',
    'impact_project'
  );
exception when duplicate_object then null; end $$;

-- -----------------------------------------------------------------------------
-- Standard updated_at trigger
-- -----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;
