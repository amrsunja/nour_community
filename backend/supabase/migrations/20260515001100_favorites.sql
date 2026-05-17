-- =============================================================================
-- Favorites (one table per target type) + likes_count maintenance triggers
-- =============================================================================

-- Ayah favorite: ayahs are local to the app (no FK), so we store the surah/ayah numbers.
create table if not exists public.favorite_ayahs (
  id            bigserial primary key,
  user_id       uuid not null references public.profiles(id) on delete cascade,
  surah_number  smallint not null check (surah_number between 1 and 114),
  ayah_number   smallint not null check (ayah_number > 0),
  created_at    timestamptz not null default now()
);
create unique index if not exists favorite_ayahs_uniq
  on public.favorite_ayahs(user_id, surah_number, ayah_number);
create index if not exists favorite_ayahs_user_idx on public.favorite_ayahs(user_id);

create table if not exists public.favorite_duas (
  id          bigserial primary key,
  user_id     uuid   not null references public.profiles(id) on delete cascade,
  dua_id      bigint not null references public.duas(id) on delete cascade,
  created_at  timestamptz not null default now()
);
create unique index if not exists favorite_duas_uniq on public.favorite_duas(user_id, dua_id);

create table if not exists public.favorite_adhkars (
  id          bigserial primary key,
  user_id     uuid   not null references public.profiles(id) on delete cascade,
  adhkar_id   bigint not null references public.adhkars(id) on delete cascade,
  created_at  timestamptz not null default now()
);
create unique index if not exists favorite_adhkars_uniq on public.favorite_adhkars(user_id, adhkar_id);

create table if not exists public.favorite_hadiths (
  id          bigserial primary key,
  user_id     uuid   not null references public.profiles(id) on delete cascade,
  hadith_id   bigint not null references public.hadiths(id) on delete cascade,
  created_at  timestamptz not null default now()
);
create unique index if not exists favorite_hadiths_uniq on public.favorite_hadiths(user_id, hadith_id);

create table if not exists public.favorite_impact_projects (
  id                bigserial primary key,
  user_id           uuid   not null references public.profiles(id) on delete cascade,
  impact_project_id bigint not null references public.impact_projects(id) on delete cascade,
  created_at        timestamptz not null default now()
);
create unique index if not exists favorite_impact_projects_uniq
  on public.favorite_impact_projects(user_id, impact_project_id);

-- -----------------------------------------------------------------------------
-- likes_count maintenance
-- -----------------------------------------------------------------------------
create or replace function public.fn_likes_count_bump()
returns trigger
language plpgsql
as $$
declare
  v_table text := tg_argv[0];  -- 'duas' | 'adhkars' | 'hadiths'
  v_col   text := tg_argv[1];  -- 'dua_id' | 'adhkar_id' | 'hadith_id'
  v_id    bigint;
  v_delta int;
begin
  if tg_op = 'INSERT' then
    v_id    := (to_jsonb(new) ->> v_col)::bigint;
    v_delta := 1;
  else
    v_id    := (to_jsonb(old) ->> v_col)::bigint;
    v_delta := -1;
  end if;

  execute format(
    'update public.%I set likes_count = greatest(0, likes_count + $1) where id = $2',
    v_table
  ) using v_delta, v_id;

  return null;
end;
$$;

drop trigger if exists trg_favorite_duas_count on public.favorite_duas;
create trigger trg_favorite_duas_count
  after insert or delete on public.favorite_duas
  for each row execute function public.fn_likes_count_bump('duas', 'dua_id');

drop trigger if exists trg_favorite_adhkars_count on public.favorite_adhkars;
create trigger trg_favorite_adhkars_count
  after insert or delete on public.favorite_adhkars
  for each row execute function public.fn_likes_count_bump('adhkars', 'adhkar_id');

drop trigger if exists trg_favorite_hadiths_count on public.favorite_hadiths;
create trigger trg_favorite_hadiths_count
  after insert or delete on public.favorite_hadiths
  for each row execute function public.fn_likes_count_bump('hadiths', 'hadith_id');
