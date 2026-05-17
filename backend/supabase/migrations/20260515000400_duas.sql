-- =============================================================================
-- Duas
-- =============================================================================

create table if not exists public.duas (
  id                bigserial primary key,
  arabic_text       text not null,
  transcription_en  text,
  transcription_fr  text,
  translation_en    text,
  translation_fr    text,
  when_en           text,
  when_fr           text,
  when_ar           text,
  reference_en      text,
  reference_fr      text,
  reference_ar      text,
  tafsir_en         text,
  tafsir_fr         text,
  tafsir_ar         text,
  audio_url         text,
  ajr               smallint not null default 5,
  likes_count       bigint   not null default 0,
  is_active         boolean  not null default true,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

drop trigger if exists trg_duas_updated_at on public.duas;
create trigger trg_duas_updated_at
  before update on public.duas
  for each row execute function public.set_updated_at();
