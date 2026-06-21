-- =============================================================================
-- Quiz: question bank + per-user daily plays
-- =============================================================================

create table if not exists public.quiz_questions (
  id                     bigserial primary key,
  level                  public.level_type not null,
  question_en            text not null,
  question_fr            text not null,
  question_ar            text not null,
  arabic_text            text,
  transcription_en       text,
  transcription_fr       text,
  subtitle_en            text,
  subtitle_fr            text,
  subtitle_ar            text,
  option_a_en            text not null,
  option_a_fr            text not null,
  option_a_ar            text not null,
  option_b_en            text not null,
  option_b_fr            text not null,
  option_b_ar            text not null,
  option_c_en            text not null,
  option_c_fr            text not null,
  option_c_ar            text not null,
  option_d_en            text not null,
  option_d_fr            text not null,
  option_d_ar            text not null,
  congratulation_en      text,
  congratulation_fr      text,
  congratulation_ar      text,
  correct_option_index   smallint not null check (correct_option_index between 1 and 4),
  ajr                    smallint not null default 5,
  bonus_ajr              smallint,
  is_active              boolean  not null default true,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);
create index if not exists quiz_questions_level_idx on public.quiz_questions(level);

drop trigger if exists trg_quiz_questions_updated_at on public.quiz_questions;
create trigger trg_quiz_questions_updated_at
  before update on public.quiz_questions
  for each row execute function public.set_updated_at();

-- Tracks daily quiz attempts (one play = 1 row per user per day).
-- Used by getQuiz edge function to compute `already_played`.
create table if not exists public.quiz_plays (
  id              bigserial primary key,
  user_id         uuid not null references public.profiles(id) on delete cascade,
  play_date       date not null default (now() at time zone 'utc')::date,
  question_ids    bigint[] not null default '{}',
  correct_count   smallint not null default 0,
  total_count     smallint not null default 4,
  earned_ajr      int not null default 0,
  bonus_awarded   boolean not null default false,
  created_at      timestamptz not null default now()
);
create unique index if not exists quiz_plays_user_day_uniq
  on public.quiz_plays(user_id, play_date);
