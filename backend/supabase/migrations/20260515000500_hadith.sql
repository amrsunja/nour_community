-- =============================================================================
-- Hadith collections + hadiths
-- =============================================================================

create table if not exists public.hadith_collections (
  id              bigserial primary key,
  title_en        text not null,
  title_fr        text not null,
  title_ar        text not null,
  description_en  text,
  description_fr  text,
  description_ar  text,
  position        int not null default 0,
  is_active       boolean not null default true,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create table if not exists public.hadiths (
  id                      bigserial primary key,
  hadith_collection_id    bigint not null references public.hadith_collections(id) on delete cascade,
  title_en                text not null,
  title_fr                text not null,
  title_ar                text not null,
  description_en          text,
  description_fr          text,
  description_ar          text,
  arabic_text             text not null,
  transcription_en        text,
  transcription_fr        text,
  translation_en          text,
  translation_fr          text,
  reference_en            text,
  reference_fr            text,
  reference_ar            text,
  tafsir_en               text,
  tafsir_fr               text,
  tafsir_ar               text,
  audio_url               text,
  ajr                     smallint not null default 5,
  likes_count             bigint   not null default 0,
  position                int      not null default 0,
  is_active               boolean  not null default true,
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now()
);
create index if not exists hadiths_collection_idx on public.hadiths(hadith_collection_id);

drop trigger if exists trg_hadith_collections_updated_at on public.hadith_collections;
create trigger trg_hadith_collections_updated_at
  before update on public.hadith_collections
  for each row execute function public.set_updated_at();

drop trigger if exists trg_hadiths_updated_at on public.hadiths;
create trigger trg_hadiths_updated_at
  before update on public.hadiths
  for each row execute function public.set_updated_at();
