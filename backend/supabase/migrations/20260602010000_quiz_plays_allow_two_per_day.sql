-- =============================================================================
-- Quiz: allow up to 2 plays per user per day.
-- The old unique index enforced exactly one row per (user_id, play_date),
-- which blocked a second daily play. Drop it; the per-day cap (2) is now
-- enforced in the getQuiz / submitQuiz edge functions via a row count.
-- =============================================================================

drop index if exists public.quiz_plays_user_day_uniq;

-- Keep an index for the daily lookups (count by user + day) without uniqueness.
create index if not exists quiz_plays_user_day_idx
  on public.quiz_plays(user_id, play_date);
