-- =============================================================================
-- Row Level Security policies
-- Roles assumed:
--   anon          -> not signed in (no read/write granted below)
--   authenticated -> signed-in (anonymous OR linked user) — auth.uid() not null
--   admin         -> a row in profiles with is_admin = true
-- =============================================================================

-- Helper: is current user admin?
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select is_admin from public.profiles where id = auth.uid()),
    false
  );
$$;

-- -----------------------------------------------------------------------------
-- Enable RLS on every table
-- -----------------------------------------------------------------------------
alter table public.profiles                  enable row level security;
alter table public.dhikrs                    enable row level security;
alter table public.adhkar_categories         enable row level security;
alter table public.adhkar_subcategories      enable row level security;
alter table public.adhkars                   enable row level security;
alter table public.duas                      enable row level security;
alter table public.hadith_collections        enable row level security;
alter table public.hadiths                   enable row level security;
alter table public.quiz_questions            enable row level security;
alter table public.quiz_plays                enable row level security;
alter table public.project_categories        enable row level security;
alter table public.partner_organizations     enable row level security;
alter table public.impact_projects           enable row level security;
alter table public.project_stories           enable row level security;
alter table public.zakat_transactions        enable row level security;
alter table public.donation_transactions     enable row level security;
alter table public.quran_progress            enable row level security;
alter table public.dhikr_progress            enable row level security;
alter table public.hadith_progress           enable row level security;
alter table public.dua_progress              enable row level security;
alter table public.ajr_log                   enable row level security;
alter table public.daily_activity            enable row level security;
alter table public.favorite_ayahs            enable row level security;
alter table public.favorite_duas             enable row level security;
alter table public.favorite_adhkars          enable row level security;
alter table public.favorite_hadiths          enable row level security;
alter table public.favorite_impact_projects  enable row level security;

-- -----------------------------------------------------------------------------
-- Profiles
--   * Users can read/update their own row.
--   * Admins can read & update any row.
--   * A trigger prevents non-admins from escalating is_admin.
-- -----------------------------------------------------------------------------
drop policy if exists profiles_self_read on public.profiles;
create policy profiles_self_read
  on public.profiles for select to authenticated
  using (id = auth.uid() or public.is_admin());

drop policy if exists profiles_self_update on public.profiles;
create policy profiles_self_update
  on public.profiles for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

drop policy if exists profiles_admin_update on public.profiles;
create policy profiles_admin_update
  on public.profiles for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create or replace function public.fn_prevent_is_admin_escalation()
returns trigger
language plpgsql
as $$
begin
  if new.is_admin is distinct from old.is_admin and not public.is_admin() then
    raise exception 'is_admin can only be changed by an admin';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_profiles_no_admin_escalation on public.profiles;
create trigger trg_profiles_no_admin_escalation
  before update on public.profiles
  for each row execute function public.fn_prevent_is_admin_escalation();

-- -----------------------------------------------------------------------------
-- Public catalog tables: read for any authenticated user, write only admin.
-- -----------------------------------------------------------------------------
do $$
declare
  t text;
  catalog_tables text[] := array[
    'dhikrs',
    'adhkar_categories',
    'adhkar_subcategories',
    'adhkars',
    'duas',
    'hadith_collections',
    'hadiths',
    'quiz_questions',
    'project_categories',
    'partner_organizations',
    'impact_projects',
    'project_stories'
  ];
  read_policy  text;
  write_policy text;
begin
  foreach t in array catalog_tables loop
    read_policy  := t || '_read';
    write_policy := t || '_admin_write';

    execute format('drop policy if exists %I on public.%I', read_policy, t);
    execute format(
      'create policy %I on public.%I for select to authenticated using (true)',
      read_policy, t
    );

    execute format('drop policy if exists %I on public.%I', write_policy, t);
    execute format(
      'create policy %I on public.%I for all to authenticated using (public.is_admin()) with check (public.is_admin())',
      write_policy, t
    );
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- Per-user tables: each user only sees / writes their own rows
-- -----------------------------------------------------------------------------
do $$
declare
  t text;
  user_tables text[] := array[
    'quiz_plays',
    'zakat_transactions',
    'donation_transactions',
    'quran_progress',
    'dhikr_progress',
    'hadith_progress',
    'dua_progress',
    'ajr_log',
    'daily_activity',
    'favorite_ayahs',
    'favorite_duas',
    'favorite_adhkars',
    'favorite_hadiths',
    'favorite_impact_projects'
  ];
  p_read   text;
  p_insert text;
  p_update text;
  p_delete text;
begin
  foreach t in array user_tables loop
    p_read   := t || '_self_read';
    p_insert := t || '_self_insert';
    p_update := t || '_self_update';
    p_delete := t || '_self_delete';

    execute format('drop policy if exists %I on public.%I', p_read, t);
    execute format(
      'create policy %I on public.%I for select to authenticated using (user_id = auth.uid() or public.is_admin())',
      p_read, t
    );

    execute format('drop policy if exists %I on public.%I', p_insert, t);
    execute format(
      'create policy %I on public.%I for insert to authenticated with check (user_id = auth.uid())',
      p_insert, t
    );

    execute format('drop policy if exists %I on public.%I', p_update, t);
    execute format(
      'create policy %I on public.%I for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid())',
      p_update, t
    );

    execute format('drop policy if exists %I on public.%I', p_delete, t);
    execute format(
      'create policy %I on public.%I for delete to authenticated using (user_id = auth.uid())',
      p_delete, t
    );
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- ajr_log: lock down INSERT — only the SECURITY DEFINER triggers / edge
-- functions running as service role may write here.
-- -----------------------------------------------------------------------------
drop policy if exists ajr_log_self_insert on public.ajr_log;
create policy ajr_log_no_user_insert
  on public.ajr_log for insert to authenticated
  with check (false);

-- And forbid user updates/deletes on ajr_log entirely.
drop policy if exists ajr_log_self_update on public.ajr_log;
drop policy if exists ajr_log_self_delete on public.ajr_log;
