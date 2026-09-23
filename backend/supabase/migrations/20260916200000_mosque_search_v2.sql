-- -----------------------------------------------------------------------------
-- Mosque search V2 — "type anything that reminds you of the mosque".
--
-- Before: fn_search_mosques did 4 independent ILIKE '%q%' on name / city /
-- address_line / postal_code. A multi-word query ("grande mosquee paris"),
-- an accent ("mosquée"), a typo ("mulhous") or a legal name returned nothing,
-- and results were ordered by distance only — relevance was ignored.
--
-- After:
--   * mosques.search_text — one normalised (lower + unaccent) haystack built by
--     trigger from name, legal_name, slug, city, postal_code, address_line,
--     description, country (code + FR/EN names), khutbah languages (code +
--     names) and the imams' names/roles. GIN trigram indexed.
--   * Query is normalised the same way and split into tokens. EVERY token must
--     match the haystack as a word prefix, an infix, or fuzzily
--     (pg_trgm word_similarity, ≥ 4 chars only) → typo tolerance.
--   * Relevance score (exact name > name prefix > city/postal prefix > token
--     quality > global trigram similarity), rounded to 1 decimal so that
--     equally relevant mosques are then ordered by distance — otherwise the
--     trigram noise would put a far mosque ahead of the one next door.
--
-- Additive: same function name and parameters, same columns + a trailing
-- `score`. No column is dropped or renamed, no policy touched.
-- -----------------------------------------------------------------------------

-- Accent folding: optional on Supabase, unaccent_safe() already degrades.
do $$ begin
  create extension if not exists unaccent with schema extensions;
exception when others then
  raise notice 'unaccent unavailable — search stays accent-sensitive';
end $$;

-- -----------------------------------------------------------------------------
-- 1. Normalisation helpers
-- -----------------------------------------------------------------------------

create or replace function public.unaccent_lower(p text)
returns text language sql immutable as $$
  select lower(public.unaccent_safe(coalesce(p, '')));
$$;

comment on function public.unaccent_lower(text) is
  'lower(unaccent(p)) with a NULL-safe empty-string fallback. Used by the mosque search haystack and by query normalisation.';

-- Country code → the words a user may type for it (code + FR + EN + native).
create or replace function public.fn_country_search_terms(p_code text)
returns text language sql immutable as $$
  select case upper(coalesce(p_code, ''))
    when 'FR' then 'fr france'
    when 'BE' then 'be belgique belgium belgie'
    when 'CH' then 'ch suisse switzerland schweiz'
    when 'LU' then 'lu luxembourg'
    when 'NL' then 'nl pays-bas pays bas netherlands nederland holland'
    when 'DE' then 'de allemagne germany deutschland'
    when 'ES' then 'es espagne spain espana'
    when 'IT' then 'it italie italy italia'
    when 'PT' then 'pt portugal'
    when 'GB' then 'gb uk royaume-uni royaume uni united kingdom angleterre england'
    when 'SE' then 'se suede sweden sverige'
    when 'NO' then 'no norvege norway'
    when 'DK' then 'dk danemark denmark'
    when 'CA' then 'ca canada'
    when 'US' then 'us usa etats-unis etats unis united states'
    when 'MA' then 'ma maroc morocco'
    when 'DZ' then 'dz algerie algeria'
    when 'TN' then 'tn tunisie tunisia'
    when 'TR' then 'tr turquie turkey turkiye'
    else lower(coalesce(p_code, ''))
  end;
$$;

-- ISO-639-1 khutbah language → searchable words.
create or replace function public.fn_language_search_terms(p_code text)
returns text language sql immutable as $$
  select case lower(coalesce(p_code, ''))
    when 'fr' then 'fr francais french'
    when 'ar' then 'ar arabe arabic'
    when 'en' then 'en anglais english'
    when 'tr' then 'tr turc turkish'
    when 'ur' then 'ur ourdou urdu'
    when 'bn' then 'bn bengali bangla'
    when 'nl' then 'nl neerlandais dutch'
    when 'de' then 'de allemand german'
    when 'es' then 'es espagnol spanish'
    when 'ru' then 'ru russe russian'
    when 'id' then 'id indonesien indonesian'
    when 'ms' then 'ms malais malay'
    when 'so' then 'so somali somalien'
    when 'wo' then 'wo wolof'
    when 'ber' then 'ber berbere amazigh tamazight'
    else lower(coalesce(p_code, ''))
  end;
$$;

-- -----------------------------------------------------------------------------
-- 2. mosques.search_text (trigger-maintained haystack)
-- -----------------------------------------------------------------------------

alter table public.mosques add column if not exists search_text text;

comment on column public.mosques.search_text is
  'Normalised search haystack (lower + unaccent). Maintained by trg_mosques_search_text and trg_mosque_imams_search_text — never write it from a client.';

create or replace function public.fn_mosque_search_text(
  p_name        text,
  p_legal_name  text,
  p_slug        text,
  p_city        text,
  p_postal      text,
  p_address     text,
  p_description text,
  p_country     text,
  p_languages   text[],
  p_imams       text
) returns text language sql immutable as $$
  select nullif(
    btrim(
      regexp_replace(
        public.unaccent_lower(
          concat_ws(' ',
            p_name,
            nullif(p_legal_name, p_name),
            replace(coalesce(p_slug, ''), '-', ' '),
            p_city,
            p_postal,
            p_address,
            p_description,
            public.fn_country_search_terms(p_country),
            (select string_agg(public.fn_language_search_terms(l), ' ')
               from unnest(coalesce(p_languages, '{}'::text[])) as l),
            p_imams
          )
        ),
        '\s+', ' ', 'g'
      )
    ), ''
  );
$$;

create or replace function public.fn_mosques_set_search_text()
returns trigger language plpgsql as $$
begin
  new.search_text := public.fn_mosque_search_text(
    new.name, new.legal_name, new.slug, new.city, new.postal_code,
    new.address_line, new.description, new.country_code, new.khutbah_languages,
    (select string_agg(concat_ws(' ', i.full_name, i.role), ' ')
       from public.mosque_imams i where i.mosque_id = new.id)
  );
  return new;
end $$;

drop trigger if exists trg_mosques_search_text on public.mosques;
create trigger trg_mosques_search_text
  before insert or update on public.mosques
  for each row execute function public.fn_mosques_set_search_text();

-- Imams live in their own table: touch the parent so the BEFORE trigger above
-- rebuilds the haystack. SECURITY DEFINER because a manager may not hold an
-- UPDATE grant on every column path.
create or replace function public.fn_mosque_imams_touch_search_text()
returns trigger language plpgsql security definer set search_path = public as $$
declare v_id bigint := coalesce(new.mosque_id, old.mosque_id);
begin
  if v_id is not null then
    update public.mosques set search_text = null where id = v_id;
  end if;
  return null;
end $$;

drop trigger if exists trg_mosque_imams_search_text on public.mosque_imams;
create trigger trg_mosque_imams_search_text
  after insert or update or delete on public.mosque_imams
  for each row execute function public.fn_mosque_imams_touch_search_text();

-- Backfill (the BEFORE UPDATE trigger recomputes each row).
update public.mosques set search_text = null;

create index if not exists mosques_search_text_trgm
  on public.mosques using gin (search_text extensions.gin_trgm_ops);

-- -----------------------------------------------------------------------------
-- 3. Token scoring
-- -----------------------------------------------------------------------------

-- 1.0 word prefix · 0.7 infix · word_similarity for ≥ 4-char typos · 0 otherwise.
create or replace function public.fn_search_token_score(p_token text, p_doc text)
returns double precision language sql immutable as $$
  select case
    when p_token is null or p_token = '' or p_doc is null then 0::double precision
    when p_doc like p_token || '%' or p_doc like '% ' || p_token || '%' then 1.0::double precision
    when p_doc like '%' || p_token || '%' then 0.7::double precision
    when length(p_token) >= 4 then extensions.word_similarity(p_token, p_doc)::double precision
    else 0::double precision
  end;
$$;

-- -----------------------------------------------------------------------------
-- 4. fn_search_mosques
-- -----------------------------------------------------------------------------

drop function if exists public.fn_search_mosques(text, double precision, double precision, int, int);

create or replace function public.fn_search_mosques(
  p_query     text default null,
  p_lat       double precision default null,
  p_lng       double precision default null,
  p_radius_km int default 50,
  p_limit     int default 30
) returns table (
  id bigint, name text, slug text, logo_url text, cover_url text,
  address_line text, city text, postal_code text,
  lat double precision, lng double precision, distance_km double precision,
  followers_count int, members_count int, timezone text,
  fajr time, dhuhr time, asr time, maghrib time, isha time, sunrise time, jumua time,
  has_times boolean, score double precision
) language sql stable security invoker as $$
  with q as (
    -- lower + unaccent + collapse whitespace + strip LIKE wildcards.
    select nullif(
             btrim(regexp_replace(
               regexp_replace(public.unaccent_lower(coalesce(p_query, '')), '[%_\\]', ' ', 'g'),
               '\s+', ' ', 'g')),
             '') as nq
  ),
  qt as (
    select nq,
           coalesce(
             array_remove(
               regexp_split_to_array(regexp_replace(nq, '[^a-z0-9]+', ' ', 'g'), ' '),
               ''),
             '{}'::text[]) as toks
      from q
  ),
  me as (
    select case when p_lat is null or p_lng is null then null
                else extensions.st_setsrid(extensions.st_makepoint(p_lng, p_lat), 4326)::extensions.geography
           end as g
  )
  select m.id, m.name, m.slug, m.logo_url, m.cover_images[1],
         m.address_line, m.city, m.postal_code,
         extensions.st_y(m.location::extensions.geometry),
         extensions.st_x(m.location::extensions.geometry),
         case when me.g is null or m.location is null then null
              else extensions.st_distance(m.location, me.g) / 1000.0 end,
         m.followers_count, m.members_count, m.timezone,
         t.fajr, t.dhuhr, t.asr, t.maghrib, t.isha, t.sunrise, t.jumua,
         t.id is not null,
         coalesce(r.score, 0)::double precision
    from public.mosques m
    cross join qt
    cross join me
    left join public.mosque_prayer_times t
      on t.mosque_id = m.id and t.day = (now() at time zone m.timezone)::date
    left join lateral (
      select avg(s) as tok_score, min(s) as worst
        from (
          select public.fn_search_token_score(tok, m.search_text) as s
            from unnest(qt.toks) as tok
        ) x
    ) tm on true
    left join lateral (
      select round((
          coalesce(tm.tok_score, 0) * 3.0
        + case when public.unaccent_lower(m.name) = qt.nq                        then 4.0 else 0 end
        + case when public.unaccent_lower(m.name) like qt.nq || '%'              then 2.5 else 0 end
        + case when public.unaccent_lower(coalesce(m.city, '')) = qt.nq          then 2.5 else 0 end
        + case when public.unaccent_lower(coalesce(m.city, '')) like qt.nq || '%' then 1.5 else 0 end
        + case when coalesce(m.postal_code, '') like qt.nq || '%'                then 2.0 else 0 end
        + coalesce(extensions.similarity(m.search_text, qt.nq), 0) * 0.25
      )::numeric, 1) as score
    ) r on true
   where m.status = 'approved'
     -- Every token must match somewhere in the haystack.
     and (qt.nq is null or coalesce(tm.worst, 0) >= 0.45)
     -- Radius only bounds the "near you" listing; a text search is global
     -- (the client passes p_radius_km = null as soon as the field is filled).
     and (me.g is null or m.location is null or p_radius_km is null
          or extensions.st_dwithin(m.location, me.g, p_radius_km * 1000))
   order by
     coalesce(r.score, 0) desc,
     (case when me.g is null or m.location is null then 1 else 0 end),
     (case when me.g is null or m.location is null then null
           else extensions.st_distance(m.location, me.g) end) nulls last,
     m.followers_count desc,
     m.id
   limit greatest(1, least(coalesce(p_limit, 30), 100));
$$;

grant execute on function public.fn_search_mosques(text, double precision, double precision, int, int) to authenticated;

comment on function public.fn_search_mosques(text, double precision, double precision, int, int) is
  'Fuzzy, accent-insensitive, multi-token mosque search over name / legal name / slug / city / postal code / address / description / country / khutbah languages / imams, ranked by relevance then distance.';
