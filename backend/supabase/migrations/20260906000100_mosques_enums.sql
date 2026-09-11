-- =============================================================================
-- Mosques module (P0) — enums & extensions.
-- Enum additions live in their own migration: `alter type … add value` cannot be
-- used in the same transaction as the first use of the new value.
-- See docs/MOSQUES_MODULE_IMPLEMENTATION.md §4.1
-- =============================================================================

do $$ begin
  create extension if not exists postgis with schema extensions;
exception when others then
  raise notice 'postgis not available (%). Enable it in Supabase Dashboard > Database > Extensions.', sqlerrm;
end $$;

do $$ begin create type public.account_type as enum ('user','mosque'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_status as enum ('pending_review','approved','rejected','suspended'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_legal_status as enum ('association_1901','association_1905','other'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_admin_role as enum ('owner','manager'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_service as enum (
  'parking','disabled_access','ablution_room','women_space','adult_classes','children_classes',
  'quran_classes','arabic_classes','eid_prayer','janaza','iftar_ramadan','library','new_muslims_support');
exception when duplicate_object then null; end $$;
do $$ begin create type public.prayer_slot as enum ('fajr','dhuhr','asr','maghrib','isha'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_post_type as enum ('announcement','event','volunteering','highlight','janaza'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_post_status as enum ('draft','published','archived'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_post_audience as enum ('public','followers'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_campaign_status as enum ('draft','active','closed','cancelled'); exception when duplicate_object then null; end $$;
do $$ begin create type public.stripe_account_status as enum ('not_started','onboarding','active','restricted','disabled'); exception when duplicate_object then null; end $$;
do $$ begin create type public.push_kind as enum (
  'mosque_post','mosque_event','mosque_campaign','mosque_broadcast','mosque_status',
  'dua_ameen','family_milestone','system');
exception when duplicate_object then null; end $$;

-- Existing enums: ADD VALUES ONLY (never reorder / rename).
alter type public.tx_type add value if not exists 'mosque_sadaqa';
alter type public.tx_type add value if not exists 'mosque_campaign';
alter type public.tx_type add value if not exists 'mosque_membership';
alter type public.ajr_source add value if not exists 'donation';
alter type public.ajr_source add value if not exists 'mosque_dua';
