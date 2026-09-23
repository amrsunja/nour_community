-- =============================================================================
-- Tax receipts — multi-country regime registry, protected right, audit trail.
-- See docs/TAX_RECEIPTS_MULTI_COUNTRY.md
--
-- What this fixes:
--   1. can_issue_tax_receipts was writable by any mosque admin (absent from the
--      column guard) → now protected, movable only through an RPC that checks
--      the country regime, the legal identifiers and the signatory.
--   2. The French template was applied to every country → a per-country regime
--      registry; no supported regime means no tax document at all.
--   3. The private bucket mosque-receipts had NO storage policy → every signed
--      URL created client-side returned 403.
--   4. Receipt numbering used count(*) + 1 → atomic counter.
--   5. Nothing recorded who declared the right, when, under which legal text.
--   6. The donor's postal address (mandatory in FR) existed nowhere.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. SECURITY FIX — public.is_trusted_context() returned NULL, not false.
--
-- The 20260907 version ends with:
--     or current_setting('nour.trusted', true) = 'on'
-- current_setting(..., true) yields NULL when the GUC was never set, so the
-- comparison is NULL and the whole expression collapses to
--     false OR false OR NULL  ->  NULL
-- Every guard then evaluates `if not NULL and not false` -> NULL, the IF body
-- is skipped, and the update goes through. In practice: in any session where
-- nour.trusted had not been set, an authenticated mosque admin could write the
-- moderation, legal and counter columns the guard exists to protect
-- (status, donations_enabled, rna, siren, followers_count, ...).
--
-- Two-layer fix: coalesce inside the helper, and coalesce again at every call
-- site so a NULL can never re-open the guard.
-- -----------------------------------------------------------------------------
create or replace function public.is_trusted_context()
returns boolean
language plpgsql
stable
set search_path = public
as $$
declare
  jwt_claims     text := current_setting('request.jwt.claims', true);
  effective_role text := coalesce(
    current_setting('request.jwt.claim.role', true),
    current_setting('role', true),
    current_user
  );
begin
  return coalesce(
    jwt_claims is null
      or effective_role in ('service_role', 'postgres', 'supabase_admin')
      or coalesce(current_setting('nour.trusted', true), 'off') = 'on',
    false
  );
end $$;

comment on function public.is_trusted_context() is
  'True when running without a request JWT (SQL editor / cron), as service_role/postgres, or inside a server RPC that set nour.trusted=on. Never returns NULL: a NULL would silently disable every column guard.';

-- The campaign counter guard shares the helper; re-assert it with the same
-- NULL-proof call shape.
create or replace function public.fn_mosque_campaigns_guard()
returns trigger language plpgsql as $$
begin
  if not coalesce(public.is_trusted_context(), false) and not coalesce(public.is_admin(), false) then
    if new.collected_amount is distinct from old.collected_amount
       or new.donors_count is distinct from old.donors_count then
      raise exception 'column protected';
    end if;
  end if;
  return new;
end $$;

-- -----------------------------------------------------------------------------
-- 1. Regime registry
-- -----------------------------------------------------------------------------
do $$ begin
  create type public.tax_regime_kind as enum ('receipt', 'reclaim_by_charity', 'none');
exception when duplicate_object then null; end $$;

create table if not exists public.tax_regimes (
  country_code           text primary key,
  kind                   public.tax_regime_kind not null default 'none',
  -- true only when a renderer exists AND the template was legally validated
  supported              boolean not null default false,
  template_key           text,
  template_version       text,
  legal_ref              text,
  locale                 text not null default 'en',
  currency               text not null default 'EUR',
  -- public.mosques columns that must be non-empty before the right is granted
  required_fields        text[] not null default '{}',
  -- [{"any_of":["rna","siren"],"patterns":{"rna":"^W\\d{9}$"}}]
  required_ids           jsonb  not null default '[]'::jsonb,
  requires_signature     boolean not null default false,
  requires_donor_address boolean not null default false,
  min_amount             numeric(12,2),
  annual_only            boolean not null default false,
  verifiable_registry    text,
  notes                  text,
  updated_at             timestamptz not null default now()
);

comment on table public.tax_regimes is
  'One row per country. Drives whether a tax receipt may be issued at all, what the issuer must provide, and which renderer the edge function picks.';
comment on column public.tax_regimes.supported is
  'NEVER set true before a local accountant/lawyer validated the concrete template.';

drop trigger if exists trg_tax_regimes_updated_at on public.tax_regimes;
create trigger trg_tax_regimes_updated_at before update on public.tax_regimes
  for each row execute function public.set_updated_at();

insert into public.tax_regimes
  (country_code, kind, supported, template_key, template_version, legal_ref, locale, currency,
   required_fields, required_ids, requires_signature, requires_donor_address, min_amount,
   annual_only, verifiable_registry, notes)
values
  ('FR', 'receipt', true, 'fr-cerfa-11580-05', '05',
   'CGI art. 200, 238 bis et 978', 'fr', 'EUR',
   '{legal_name,address_line,postal_code,city}',
   '[{"any_of":["rna","siren"],"patterns":{"rna":"^W[0-9]{9}$","siren":"^[0-9]{9}$"}}]'::jsonb,
   true, true, null, false, null,
   'Own layout allowed if every mandatory mention is present. Annual totals declared on form 2070-SD.'),

  -- Known regimes, no validated renderer yet: the app shows "not available yet".
  ('BE', 'receipt', false, null, null, 'CIR 92 art. 145/33', 'fr', 'EUR',
   '{legal_name,address_line,postal_code,city}', '[]'::jsonb, true, true, 40, true, null,
   'Agrement SPF Finances required; 40 EUR/year minimum; the association files the data itself.'),
  ('DE', 'receipt', false, null, null, 'Par. 10b EStG, Par. 50 EStDV', 'de', 'EUR',
   '{legal_name,address_line,postal_code,city}', '[]'::jsonb, true, true, null, false, 'bzst',
   'The official Muster is BINDING: deviating from it voids the confirmation. Check the BZSt Zuwendungsempfaengerregister before enabling.'),
  ('NL', 'receipt', false, null, null, 'ANBI', 'nl', 'EUR',
   '{legal_name,address_line,postal_code,city}', '[]'::jsonb, false, true, null, false, null,
   'ANBI registration required.'),
  ('GB', 'reclaim_by_charity', false, null, null, 'Gift Aid', 'en', 'GBP',
   '{}', '[]'::jsonb, false, false, null, false, null,
   'No donor receipt exists. HMRC pays +25% to the charity against a Gift Aid Declaration signed by the donor. Needs its own feature, never this function.'),
  ('US', 'receipt', false, null, null, 'IRC 170, IRS Pub. 1771', 'en', 'USD',
   '{legal_name,address_line,postal_code,city}', '[]'::jsonb, false, true, 250, false, 'irs_teos',
   'Written acknowledgement mandatory from $250 and must state that no goods or services were provided.'),
  ('CA', 'receipt', false, null, null, 'ITA 118.1 (CRA)', 'en', 'CAD',
   '{legal_name,address_line,postal_code,city}', '[]'::jsonb, true, true, null, false, null,
   'CRA registration number and the canada.ca charity URL are mandatory on the receipt.')
on conflict (country_code) do nothing;

alter table public.tax_regimes enable row level security;
drop policy if exists tax_regimes_read on public.tax_regimes;
create policy tax_regimes_read on public.tax_regimes for select to authenticated using (true);
drop policy if exists tax_regimes_write on public.tax_regimes;
create policy tax_regimes_write on public.tax_regimes for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- -----------------------------------------------------------------------------
-- 2. Issuer data: generic identifiers + signatory
-- -----------------------------------------------------------------------------
alter table public.mosques
  add column if not exists legal_registrations jsonb not null default '{}'::jsonb,
  add column if not exists signatory_name      text,
  add column if not exists signatory_role      text,
  add column if not exists signature_path      text;

comment on column public.mosques.legal_registrations is
  'Per-country legal identifiers. FR {"rna","siren"}, DE {"vereinsregister"}, GB {"charity_number"}, US {"ein"}. Shape declared by tax_regimes.required_ids. Protected column.';
comment on column public.mosques.signature_path is
  'Object path in the private bucket mosque-legal: <mosqueId>/signature/<file>.';

-- Backfill the generic container from the French columns.
update public.mosques m
   set legal_registrations = coalesce(m.legal_registrations, '{}'::jsonb)
                             || case when coalesce(m.rna, '')   <> '' then jsonb_build_object('rna', m.rna)   else '{}'::jsonb end
                             || case when coalesce(m.siren, '') <> '' then jsonb_build_object('siren', m.siren) else '{}'::jsonb end
 where coalesce(m.rna, '') <> '' or coalesce(m.siren, '') <> '';

-- -----------------------------------------------------------------------------
-- 3. Column guard: the right and the legal identifiers become protected
-- -----------------------------------------------------------------------------
create or replace function public.fn_mosques_guard_columns()
returns trigger language plpgsql as $$
begin
  if not coalesce(public.is_trusted_context(), false) and not coalesce(public.is_admin(), false) then
    if new.status is distinct from old.status
       or new.review_note is distinct from old.review_note
       or new.reviewed_by is distinct from old.reviewed_by
       or new.reviewed_at is distinct from old.reviewed_at
       or new.siren is distinct from old.siren
       or new.rna is distinct from old.rna
       or new.legal_registrations is distinct from old.legal_registrations
       or new.legal_status is distinct from old.legal_status
       or new.donations_enabled is distinct from old.donations_enabled
       or new.can_issue_tax_receipts is distinct from old.can_issue_tax_receipts
       or new.followers_count is distinct from old.followers_count
       or new.members_count is distinct from old.members_count
       or new.views_count is distinct from old.views_count then
      raise exception 'column protected';
    end if;
  end if;

  if new.status is distinct from old.status and new.reviewed_at is not distinct from old.reviewed_at then
    new.reviewed_at := now();
    if new.reviewed_by is not distinct from old.reviewed_by then
      new.reviewed_by := auth.uid();
    end if;
  end if;

  if new.slug is null then
    new.slug := public.fn_mosque_slug(new.name, new.id);
  end if;
  return new;
end $$;

-- -----------------------------------------------------------------------------
-- 4. Declaration audit (append-only)
-- -----------------------------------------------------------------------------
create table if not exists public.mosque_tax_declarations (
  id                       bigserial primary key,
  mosque_id                bigint not null references public.mosques(id) on delete cascade,
  user_id                  uuid references public.profiles(id) on delete set null,
  enabled                  boolean not null,
  country_code             text,
  template_key             text,
  template_version         text,
  legal_ref                text,
  declaration_text_version text,
  legal_name               text,
  legal_registrations      jsonb not null default '{}'::jsonb,
  signatory_name           text,
  signatory_role           text,
  created_at               timestamptz not null default now()
);
create index if not exists mosque_tax_decl_idx
  on public.mosque_tax_declarations(mosque_id, created_at desc);

comment on table public.mosque_tax_declarations is
  'Immutable trace of every attestation sur l''honneur. Written only by fn_mosque_set_tax_receipts.';

alter table public.mosque_tax_declarations enable row level security;
drop policy if exists mosque_tax_decl_read on public.mosque_tax_declarations;
create policy mosque_tax_decl_read on public.mosque_tax_declarations for select to authenticated
  using (public.is_mosque_admin(mosque_id) or public.is_admin());
-- No client INSERT / UPDATE / DELETE by design.

-- -----------------------------------------------------------------------------
-- 5. Donor fiscal identity (name + postal address are mandatory in most regimes)
-- -----------------------------------------------------------------------------
create table if not exists public.donor_tax_profiles (
  user_id      uuid primary key references public.profiles(id) on delete cascade,
  full_name    text not null,
  address_line text not null,
  postal_code  text not null,
  city         text not null,
  country_code text not null default 'FR',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

drop trigger if exists trg_donor_tax_profiles_updated_at on public.donor_tax_profiles;
create trigger trg_donor_tax_profiles_updated_at before update on public.donor_tax_profiles
  for each row execute function public.set_updated_at();

alter table public.donor_tax_profiles enable row level security;
drop policy if exists donor_tax_profiles_self on public.donor_tax_profiles;
create policy donor_tax_profiles_self on public.donor_tax_profiles for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
-- Mosque admins never read this table directly; only the edge function does.

-- -----------------------------------------------------------------------------
-- 6. Issued documents: kind, provenance, revocation
-- -----------------------------------------------------------------------------
alter table public.mosque_receipts
  add column if not exists kind             text not null default 'tax_receipt',
  add column if not exists country_code     text,
  add column if not exists template_key     text,
  add column if not exists template_version text,
  add column if not exists currency         text not null default 'EUR',
  add column if not exists issuer_snapshot  jsonb not null default '{}'::jsonb,
  add column if not exists revoked_at       timestamptz,
  add column if not exists revoked_reason   text;

do $$ begin
  alter table public.mosque_receipts
    add constraint mosque_receipts_kind_chk check (kind in ('tax_receipt', 'donation_attestation'));
exception when duplicate_object then null; end $$;

-- Idempotency: one live document per scope and kind.
create unique index if not exists mosque_receipts_tx_uniq
  on public.mosque_receipts(transaction_id, kind)
  where transaction_id is not null and revoked_at is null;
create unique index if not exists mosque_receipts_year_uniq
  on public.mosque_receipts(mosque_id, user_id, year, kind)
  where transaction_id is null and revoked_at is null;

-- -----------------------------------------------------------------------------
-- 7. Atomic numbering (count(*) + 1 collides during the yearly batch)
-- -----------------------------------------------------------------------------
create table if not exists public.mosque_receipt_counters (
  mosque_id bigint not null references public.mosques(id) on delete cascade,
  year      int    not null,
  seq       int    not null default 0,
  primary key (mosque_id, year)
);

insert into public.mosque_receipt_counters(mosque_id, year, seq)
select mosque_id, year, count(*)::int from public.mosque_receipts group by 1, 2
on conflict (mosque_id, year) do update
  set seq = greatest(public.mosque_receipt_counters.seq, excluded.seq);

create or replace function public.fn_next_mosque_receipt_number(p_mosque_id bigint, p_year int)
returns text language plpgsql security definer set search_path = public as $$
declare v_seq int;
begin
  insert into public.mosque_receipt_counters(mosque_id, year, seq)
  values (p_mosque_id, p_year, 1)
  on conflict (mosque_id, year) do update
    set seq = public.mosque_receipt_counters.seq + 1
  returning seq into v_seq;
  return p_mosque_id::text || '-' || p_year::text || '-' || lpad(v_seq::text, 4, '0');
end $$;

revoke all on function public.fn_next_mosque_receipt_number(bigint, int) from public;
grant execute on function public.fn_next_mosque_receipt_number(bigint, int) to service_role;

-- -----------------------------------------------------------------------------
-- 8. The ONLY writer of can_issue_tax_receipts
-- -----------------------------------------------------------------------------
create or replace function public.fn_mosque_set_tax_receipts(
  p_mosque_id bigint,
  p_enabled   boolean,
  p_declaration_version text default null
) returns boolean
language plpgsql security definer set search_path = public as $$
declare
  m    public.mosques%rowtype;
  reg  public.tax_regimes%rowtype;
  f    text;
  grp  jsonb;
  k    text;
  v    text;
  pat  text;
  ok   boolean;
begin
  if not (public.is_mosque_admin(p_mosque_id) or public.is_admin()) then
    raise exception 'forbidden';
  end if;

  select * into m from public.mosques where id = p_mosque_id for update;
  if not found then raise exception 'not_found'; end if;

  if p_enabled then
    select * into reg from public.tax_regimes where country_code = upper(coalesce(m.country_code, 'FR'));

    if not found or not reg.supported     then raise exception 'regime_unsupported';       end if;
    if reg.kind <> 'receipt'              then raise exception 'regime_not_receipt_based'; end if;
    if m.status <> 'approved'             then raise exception 'mosque_not_approved';      end if;

    -- Required issuer fields, declared in data rather than hardcoded per country.
    foreach f in array reg.required_fields loop
      if coalesce(to_jsonb(m) ->> f, '') = '' then
        raise exception 'missing_field:%', f;
      end if;
    end loop;

    -- At least one accepted legal identifier per requirement group, matching its pattern.
    for grp in select value from jsonb_array_elements(reg.required_ids) t(value) loop
      ok := false;
      for k in select value from jsonb_array_elements_text(grp -> 'any_of') t(value) loop
        v := coalesce(
               nullif(m.legal_registrations ->> k, ''),
               case k when 'rna' then nullif(m.rna, '') when 'siren' then nullif(m.siren, '') else null end
             );
        if v is not null then
          pat := grp -> 'patterns' ->> k;
          if pat is not null and v !~ pat then
            raise exception 'legal_id_invalid:%', k;
          end if;
          ok := true;
        end if;
      end loop;
      if not ok then raise exception 'legal_id_missing'; end if;
    end loop;

    if reg.requires_signature
       and (coalesce(m.signatory_name, '') = '' or coalesce(m.signature_path, '') = '') then
      raise exception 'signatory_missing';
    end if;
  end if;

  -- The column is protected: open the trusted window for this statement only.
  perform set_config('nour.trusted', 'on', true);

  update public.mosques
     set can_issue_tax_receipts = p_enabled, updated_at = now()
   where id = p_mosque_id;

  -- Losing the right must also remove every "-66%" promise from the public UI.
  if not p_enabled then
    update public.mosque_donation_settings set show_tax_badge = false
     where mosque_id = p_mosque_id and show_tax_badge;
    update public.mosque_campaign_settings  set show_tax_badge = false
     where mosque_id = p_mosque_id and show_tax_badge;
    update public.mosque_campaigns          set show_tax_badge = false
     where mosque_id = p_mosque_id and show_tax_badge;
  end if;

  perform set_config('nour.trusted', 'off', true);

  insert into public.mosque_tax_declarations
    (mosque_id, user_id, enabled, country_code, template_key, template_version, legal_ref,
     declaration_text_version, legal_name, legal_registrations, signatory_name, signatory_role)
  values
    (p_mosque_id, auth.uid(), p_enabled, upper(coalesce(m.country_code, 'FR')),
     reg.template_key, reg.template_version, reg.legal_ref,
     p_declaration_version, m.legal_name,
     coalesce(m.legal_registrations, '{}'::jsonb)
       || case when coalesce(m.rna, '')   <> '' then jsonb_build_object('rna', m.rna)     else '{}'::jsonb end
       || case when coalesce(m.siren, '') <> '' then jsonb_build_object('siren', m.siren) else '{}'::jsonb end,
     m.signatory_name, m.signatory_role);

  return p_enabled;
end $$;

revoke all on function public.fn_mosque_set_tax_receipts(bigint, boolean, text) from public;
grant execute on function public.fn_mosque_set_tax_receipts(bigint, boolean, text) to authenticated;

-- -----------------------------------------------------------------------------
-- 9. Readiness probe for the admin checklist (same rules, no side effect)
-- -----------------------------------------------------------------------------
create or replace function public.fn_mosque_tax_readiness(p_mosque_id bigint)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  m       public.mosques%rowtype;
  reg     public.tax_regimes%rowtype;
  f       text;
  grp     jsonb;
  k       text;
  v       text;
  ok      boolean;
  missing text[] := '{}';
begin
  if not (public.is_mosque_admin(p_mosque_id) or public.is_admin()) then
    raise exception 'forbidden';
  end if;

  select * into m from public.mosques where id = p_mosque_id;
  if not found then raise exception 'not_found'; end if;

  select * into reg from public.tax_regimes where country_code = upper(coalesce(m.country_code, 'FR'));
  if not found then
    return jsonb_build_object('country', upper(coalesce(m.country_code, 'FR')),
                              'kind', 'none', 'supported', false, 'ready', false,
                              'missing', '[]'::jsonb, 'enabled', m.can_issue_tax_receipts);
  end if;

  if reg.supported and reg.kind = 'receipt' then
    if m.status <> 'approved' then missing := missing || 'mosque_not_approved'::text; end if;

    foreach f in array reg.required_fields loop
      if coalesce(to_jsonb(m) ->> f, '') = '' then missing := missing || ('missing_field:' || f)::text; end if;
    end loop;

    for grp in select value from jsonb_array_elements(reg.required_ids) t(value) loop
      ok := false;
      for k in select value from jsonb_array_elements_text(grp -> 'any_of') t(value) loop
        v := coalesce(nullif(m.legal_registrations ->> k, ''),
                      case k when 'rna' then nullif(m.rna, '') when 'siren' then nullif(m.siren, '') else null end);
        if v is not null then ok := true; end if;
      end loop;
      if not ok then missing := missing || 'legal_id_missing'::text; end if;
    end loop;

    if reg.requires_signature
       and (coalesce(m.signatory_name, '') = '' or coalesce(m.signature_path, '') = '') then
      missing := missing || 'signatory_missing'::text;
    end if;
  end if;

  return jsonb_build_object(
    'country',            reg.country_code,
    'kind',               reg.kind,
    'supported',          reg.supported,
    'legal_ref',          reg.legal_ref,
    'template_key',       reg.template_key,
    'template_version',   reg.template_version,
    'requires_signature', reg.requires_signature,
    'min_amount',         reg.min_amount,
    'annual_only',        reg.annual_only,
    'enabled',            m.can_issue_tax_receipts,
    'ready',              reg.supported and reg.kind = 'receipt' and cardinality(missing) = 0,
    'missing',            to_jsonb(missing)
  );
end $$;

revoke all on function public.fn_mosque_tax_readiness(bigint) from public;
grant execute on function public.fn_mosque_tax_readiness(bigint) to authenticated;

-- -----------------------------------------------------------------------------
-- 10. Yearly totals — what a French association needs for form 2070-SD
-- -----------------------------------------------------------------------------
create or replace function public.fn_mosque_tax_year_summary(p_mosque_id bigint, p_year int)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare v jsonb;
begin
  if not (public.is_mosque_admin(p_mosque_id) or public.is_admin()) then
    raise exception 'forbidden';
  end if;
  select jsonb_build_object(
           'year', p_year,
           'receipts_count', count(*),
           'donors_count',   count(distinct user_id),
           'total',          coalesce(sum(amount), 0),
           'currency',       coalesce(min(currency), 'EUR'))
    into v
    from public.mosque_receipts
   where mosque_id = p_mosque_id and year = p_year
     and kind = 'tax_receipt' and revoked_at is null;
  return v;
end $$;

revoke all on function public.fn_mosque_tax_year_summary(bigint, int) from public;
grant execute on function public.fn_mosque_tax_year_summary(bigint, int) to authenticated;

-- -----------------------------------------------------------------------------
-- 11. Donor self-service: which (mosque, year) can I ask a document for?
-- -----------------------------------------------------------------------------
create or replace function public.fn_my_mosque_donation_years()
returns table (
  mosque_id   bigint,
  mosque_name text,
  country_code text,
  can_issue   boolean,
  regime_kind text,
  regime_supported boolean,
  year        int,
  total       numeric,
  currency    text,
  gifts       bigint
)
language sql stable security definer set search_path = public as $$
  select t.mosque_id,
         m.name,
         upper(coalesce(m.country_code, 'FR')),
         m.can_issue_tax_receipts,
         coalesce(r.kind::text, 'none'),
         coalesce(r.supported, false),
         extract(year from t.created_at)::int as year,
         sum(t.amount_total)                  as total,
         coalesce(min(t.currency::text), 'EUR'),
         count(*)
    from public.transactions t
    join public.mosques m on m.id = t.mosque_id
    left join public.tax_regimes r on r.country_code = upper(coalesce(m.country_code, 'FR'))
   where t.user_id = auth.uid()
     and t.mosque_id is not null
     and t.status = 'succeeded'
   group by t.mosque_id, m.name, m.country_code, m.can_issue_tax_receipts, r.kind, r.supported,
            extract(year from t.created_at)
   order by year desc, m.name;
$$;

revoke all on function public.fn_my_mosque_donation_years() from public;
grant execute on function public.fn_my_mosque_donation_years() to authenticated;

-- -----------------------------------------------------------------------------
-- 12. Storage
-- -----------------------------------------------------------------------------
-- 12.a Private bucket for the signature image (never public: it is a signature).
insert into storage.buckets (id, name, public) values ('mosque-legal', 'mosque-legal', false)
on conflict (id) do nothing;

drop policy if exists "mosque-legal: admin read" on storage.objects;
create policy "mosque-legal: admin read" on storage.objects for select to authenticated
  using (bucket_id = 'mosque-legal' and public.fn_storage_mosque_folder_admin(name));
drop policy if exists "mosque-legal: admin insert" on storage.objects;
create policy "mosque-legal: admin insert" on storage.objects for insert to authenticated
  with check (bucket_id = 'mosque-legal' and public.fn_storage_mosque_folder_admin(name));
drop policy if exists "mosque-legal: admin update" on storage.objects;
create policy "mosque-legal: admin update" on storage.objects for update to authenticated
  using (bucket_id = 'mosque-legal' and public.fn_storage_mosque_folder_admin(name));
drop policy if exists "mosque-legal: admin delete" on storage.objects;
create policy "mosque-legal: admin delete" on storage.objects for delete to authenticated
  using (bucket_id = 'mosque-legal' and public.fn_storage_mosque_folder_admin(name));

-- 12.b mosque-receipts had NO policy at all: every client-side createSignedUrl
--      returned 403. Path layout is <mosqueId>/<donorId>/<number>.pdf.
drop policy if exists "mosque-receipts: donor read" on storage.objects;
create policy "mosque-receipts: donor read" on storage.objects for select to authenticated
  using (bucket_id = 'mosque-receipts'
         and (storage.foldername(name))[2] = auth.uid()::text);

drop policy if exists "mosque-receipts: admin read" on storage.objects;
create policy "mosque-receipts: admin read" on storage.objects for select to authenticated
  using (bucket_id = 'mosque-receipts' and public.fn_storage_mosque_folder_admin(name));
-- Writes stay service-role only: documents are produced by the edge function.

-- -----------------------------------------------------------------------------
-- 13. Backfill existing receipts with their provenance
-- -----------------------------------------------------------------------------
update public.mosque_receipts r
   set country_code     = coalesce(r.country_code, upper(coalesce(m.country_code, 'FR'))),
       template_key     = coalesce(r.template_key, 'fr-legacy'),
       template_version = coalesce(r.template_version, 'legacy')
  from public.mosques m
 where m.id = r.mosque_id
   and (r.country_code is null or r.template_key is null);
