-- -----------------------------------------------------------------------------
-- Mosque opening status: manual only.
--
-- Until now `mosques.opening_status` was a three-state column: 'open',
-- 'closed', or NULL meaning "derive it from the prayer times" (the client
-- showed the mosque as open between Fajr − 30 min and Isha + 45 min). That
-- automatic window is gone: the Open/Closed pill is whatever the mosque admin
-- set, nothing else.
--
-- The column therefore becomes a two-value, NOT NULL column defaulting to
-- 'open'. Idempotent and safe to re-run.
-- -----------------------------------------------------------------------------

-- 1. Backfill: NULL (auto) and any stray value become 'open'.
update public.mosques
   set opening_status = 'open'
 where opening_status is null
    or opening_status not in ('open', 'closed');

-- 2. Default + NOT NULL (default set first, so existing rows are never broken).
alter table public.mosques alter column opening_status set default 'open';
alter table public.mosques alter column opening_status set not null;

-- 3. Only the two manual states are accepted from now on.
do $$ begin
  alter table public.mosques
    add constraint mosques_opening_status_chk
    check (opening_status in ('open', 'closed'));
exception when duplicate_object then null; end $$;
