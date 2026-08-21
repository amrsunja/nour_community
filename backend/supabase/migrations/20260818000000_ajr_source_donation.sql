-- =============================================================================
-- Payments V2 (1/3): extend ajr_source with 'donation'.
-- Kept in its own migration: a new enum value cannot be referenced inside the
-- transaction that adds it, and the next migration's trigger awards ajr with
-- source = 'donation'.
-- =============================================================================
alter type public.ajr_source add value if not exists 'donation';
