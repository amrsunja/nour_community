-- =============================================================================
-- Impact projects: categories, organizations, projects, stories
-- =============================================================================

create table if not exists public.project_categories (
  id          bigserial primary key,
  title_en    text not null,
  title_fr    text not null,
  title_ar    text not null,
  position    int  not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table if not exists public.partner_organizations (
  id          bigserial primary key,
  name_en     text not null,
  name_fr     text not null,
  name_ar     text not null,
  avatar_url  text,
  is_verified boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table if not exists public.impact_projects (
  id                   bigserial primary key,
  organization_id      bigint not null references public.partner_organizations(id) on delete restrict,
  project_category_id  bigint not null references public.project_categories(id) on delete restrict,
  title_en             text not null,
  title_fr             text not null,
  title_ar             text not null,
  subtitle_en          text,
  subtitle_fr          text,
  subtitle_ar          text,
  description_en       text,
  description_fr       text,
  description_ar       text,
  cover_image_url      text,
  required_amount      numeric(12,2) not null check (required_amount >= 0),
  collected_amount     numeric(12,2) not null default 0 check (collected_amount >= 0),
  currency             public.currency_type not null default 'EUR',
  eligible_for_zakat   boolean not null default false,
  is_active            boolean not null default true,
  position             int     not null default 0,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);
create index if not exists impact_projects_org_idx       on public.impact_projects(organization_id);
create index if not exists impact_projects_category_idx  on public.impact_projects(project_category_id);
create index if not exists impact_projects_zakat_idx     on public.impact_projects(eligible_for_zakat);

create table if not exists public.project_stories (
  id                  bigserial primary key,
  impact_project_id   bigint not null references public.impact_projects(id) on delete cascade,
  title_en            text not null,
  title_fr            text not null,
  title_ar            text not null,
  description_en      text,
  description_fr      text,
  description_ar      text,
  images              text[] default '{}',
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
create index if not exists project_stories_project_idx on public.project_stories(impact_project_id);

drop trigger if exists trg_project_categories_updated_at on public.project_categories;
create trigger trg_project_categories_updated_at
  before update on public.project_categories
  for each row execute function public.set_updated_at();

drop trigger if exists trg_partner_organizations_updated_at on public.partner_organizations;
create trigger trg_partner_organizations_updated_at
  before update on public.partner_organizations
  for each row execute function public.set_updated_at();

drop trigger if exists trg_impact_projects_updated_at on public.impact_projects;
create trigger trg_impact_projects_updated_at
  before update on public.impact_projects
  for each row execute function public.set_updated_at();

drop trigger if exists trg_project_stories_updated_at on public.project_stories;
create trigger trg_project_stories_updated_at
  before update on public.project_stories
  for each row execute function public.set_updated_at();
