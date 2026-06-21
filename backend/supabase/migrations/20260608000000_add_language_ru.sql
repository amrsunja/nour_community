-- =============================================================================
-- New content language: Russian (ru)
--
-- Mirrors the existing *_en / *_fr / *_ar / *_de … *_ms column pattern on every
-- table that carries localized content. All new columns are NULLABLE on purpose:
--   * existing rows are not broken (no backfill required),
--   * content can be seeded incrementally,
--   * the app falls back to the *_en value when a translation is missing.
-- English (en) stays the default language.
--
-- As with the other added languages, there is intentionally no transcription_ru /
-- translation_ru beyond the en/fr base set the originals defined — these mirror
-- exactly the columns added in 20260607000000.
-- =============================================================================

-- ── dhikrs ──────────────────────────────────────────────────────
alter table public.dhikrs
  add column if not exists transcription_ru text,
  add column if not exists translation_ru text;

-- ── adhkar_categories ───────────────────────────────────────────
alter table public.adhkar_categories
  add column if not exists title_ru text;

-- ── adhkar_subcategories ────────────────────────────────────────
alter table public.adhkar_subcategories
  add column if not exists title_ru text;

-- ── adhkars ─────────────────────────────────────────────────────
alter table public.adhkars
  add column if not exists transcription_ru text,
  add column if not exists translation_ru text,
  add column if not exists when_ru text,
  add column if not exists reference_ru text;

-- ── duas ────────────────────────────────────────────────────────
alter table public.duas
  add column if not exists title_ru text,
  add column if not exists transcription_ru text,
  add column if not exists translation_ru text,
  add column if not exists when_ru text,
  add column if not exists reference_ru text,
  add column if not exists tafsir_ru text;

-- ── hadith_collections ──────────────────────────────────────────
alter table public.hadith_collections
  add column if not exists title_ru text,
  add column if not exists description_ru text;

-- ── hadiths ─────────────────────────────────────────────────────
alter table public.hadiths
  add column if not exists title_ru text,
  add column if not exists description_ru text,
  add column if not exists transcription_ru text,
  add column if not exists translation_ru text,
  add column if not exists reference_ru text,
  add column if not exists tafsir_ru text;

-- ── quiz_questions ──────────────────────────────────────────────
alter table public.quiz_questions
  add column if not exists question_ru text,
  add column if not exists transcription_ru text,
  add column if not exists subtitle_ru text,
  add column if not exists option_a_ru text,
  add column if not exists option_b_ru text,
  add column if not exists option_c_ru text,
  add column if not exists option_d_ru text,
  add column if not exists congratulation_ru text;

-- ── project_categories ──────────────────────────────────────────
alter table public.project_categories
  add column if not exists title_ru text;

-- ── partner_organizations ───────────────────────────────────────
alter table public.partner_organizations
  add column if not exists name_ru text;

-- ── impact_projects ─────────────────────────────────────────────
alter table public.impact_projects
  add column if not exists title_ru text,
  add column if not exists subtitle_ru text,
  add column if not exists description_ru text;

-- ── project_stories ─────────────────────────────────────────────
alter table public.project_stories
  add column if not exists title_ru text,
  add column if not exists description_ru text;
