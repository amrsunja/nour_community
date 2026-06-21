-- =============================================================================
-- Global ayah like counts (read-only RPCs)
--
-- `favorite_ayahs` has no parent "ayahs" table to hang a `likes_count` column
-- on (ayahs are bundled client-side), and RLS scopes direct SELECTs to the
-- owner. These SECURITY DEFINER functions expose ONLY aggregate counts across
-- all users — never individual rows — so the client can show "X likes" for an
-- ayah without leaking who liked it.
--
-- No new tables: this reuses the existing public.favorite_ayahs table.
-- =============================================================================

-- Count of likes for a single ayah. Params are `integer` so PostgREST can map
-- JSON numbers directly; we compare against the smallint columns transparently.
create or replace function public.fn_ayah_likes_count(
  p_surah_number integer,
  p_ayah_number  integer
)
returns bigint
language sql
stable
security definer
set search_path = public
as $$
  select count(*)::bigint
  from public.favorite_ayahs
  where surah_number = p_surah_number
    and ayah_number  = p_ayah_number;
$$;

-- Per-ayah like counts for an entire surah: returns one row per ayah that has
-- at least one like, as (ayah_number, likes_count).
create or replace function public.fn_surah_ayah_likes(
  p_surah_number integer
)
returns table (ayah_number smallint, likes_count bigint)
language sql
stable
security definer
set search_path = public
as $$
  select ayah_number, count(*)::bigint as likes_count
  from public.favorite_ayahs
  where surah_number = p_surah_number
  group by ayah_number;
$$;

-- Allow signed-in users to call the aggregates. EXECUTE on functions is granted
-- to PUBLIC by default, but we keep it explicit and scoped to `authenticated`.
revoke execute on function public.fn_ayah_likes_count(integer, integer) from public;
revoke execute on function public.fn_surah_ayah_likes(integer) from public;
grant execute on function public.fn_ayah_likes_count(integer, integer) to authenticated;
grant execute on function public.fn_surah_ayah_likes(integer) to authenticated;
