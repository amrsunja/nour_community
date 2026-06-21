-- =============================================================================
-- adhkar_subcategories: recommended reading time-range (nullable)
-- Stored as minutes-of-day [start, end). When start > end the window wraps
-- past midnight (e.g. "Before sleep" 21:00 -> 03:00 => 1260 -> 180).
-- Both NULL  => no time recommendation (never surfaced in the "Recommended now"
-- card). Range membership is evaluated client-side against the user's local
-- (device-timezone) wall-clock minutes.
-- =============================================================================

alter table public.adhkar_subcategories
  add column if not exists recommended_start_minute smallint,
  add column if not exists recommended_end_minute   smallint;

alter table public.adhkar_subcategories
  drop constraint if exists adhkar_subcat_recommended_minute_range;

alter table public.adhkar_subcategories
  add constraint adhkar_subcat_recommended_minute_range check (
    (recommended_start_minute is null and recommended_end_minute is null)
    or (
      recommended_start_minute between 0 and 1439
      and recommended_end_minute between 0 and 1439
    )
  );
