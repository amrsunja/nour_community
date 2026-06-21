-- =============================================================================
-- Adhkar (categories -> subcategories -> adhkars)
-- =============================================================================

create table if not exists public.adhkar_categories (
  id          bigserial primary key,
  title_en    text not null,
  title_fr    text not null,
  title_ar    text not null,
  position    int  not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table if not exists public.adhkar_subcategories (
  id                     bigserial primary key,
  adhkar_category_id     bigint not null references public.adhkar_categories(id) on delete cascade,
  title_en               text not null,
  title_fr               text not null,
  title_ar               text not null,
  position               int  not null default 0,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);
create index if not exists adhkar_subcategories_category_idx
  on public.adhkar_subcategories(adhkar_category_id);

create table if not exists public.adhkars (
  id                      bigserial primary key,
  adhkar_subcategory_id   bigint not null references public.adhkar_subcategories(id) on delete cascade,
  arabic_text             text not null,
  transcription_en        text,
  transcription_fr        text,
  translation_en          text,
  translation_fr          text,
  when_en                 text,
  when_fr                 text,
  when_ar                 text,
  reference_en            text,
  reference_fr            text,
  reference_ar            text,
  min_count               smallint not null default 1,
  ajr                     smallint not null default 5,
  likes_count             bigint   not null default 0,
  is_active               boolean  not null default true,
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now()
);
create index if not exists adhkars_subcategory_idx on public.adhkars(adhkar_subcategory_id);

drop trigger if exists trg_adhkar_categories_updated_at on public.adhkar_categories;
create trigger trg_adhkar_categories_updated_at
  before update on public.adhkar_categories
  for each row execute function public.set_updated_at();

drop trigger if exists trg_adhkar_subcategories_updated_at on public.adhkar_subcategories;
create trigger trg_adhkar_subcategories_updated_at
  before update on public.adhkar_subcategories
  for each row execute function public.set_updated_at();

drop trigger if exists trg_adhkars_updated_at on public.adhkars;
create trigger trg_adhkars_updated_at
  before update on public.adhkars
  for each row execute function public.set_updated_at();
