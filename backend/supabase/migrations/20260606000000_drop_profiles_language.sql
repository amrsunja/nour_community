-- Language preference is now sourced exclusively from the app's local
-- settings (SQLite). Drop the redundant profiles.language column.

drop index if exists public.profiles_language_idx;

alter table public.profiles drop column if exists language;

-- language_type enum was only used by profiles.language.
drop type if exists public.language_type;
