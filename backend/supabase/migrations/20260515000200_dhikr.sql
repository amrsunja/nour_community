-- =============================================================================
-- Dhikr catalog
-- =============================================================================

create table if not exists public.dhikrs (
  id                bigserial primary key,
  arabic_text       text not null,
  transcription_en  text not null,
  transcription_fr  text not null,
  translation_en    text not null,
  translation_fr    text not null,
  min_count         smallint not null default 33,
  ajr               smallint not null default 5,
  is_active         boolean  not null default true,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

drop trigger if exists trg_dhikrs_updated_at on public.dhikrs;
create trigger trg_dhikrs_updated_at
  before update on public.dhikrs
  for each row execute function public.set_updated_at();
