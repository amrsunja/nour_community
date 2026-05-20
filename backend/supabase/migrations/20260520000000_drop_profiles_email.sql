-- =============================================================================
-- Drop profiles.email
-- The canonical email lives in auth.users; the duplicated column on
-- public.profiles is removed. Applies to already-provisioned databases.
-- =============================================================================

drop index if exists public.profiles_email_idx;

alter table public.profiles
  drop column if exists email;

-- Recreate the new-user handler without the email reference.
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name',
             new.raw_user_meta_data ->> 'full_name')
  )
  on conflict (id) do nothing;

  -- Quran progress is created here because there's a single row per user
  insert into public.quran_progress (user_id, current_surah_number, current_ayah_number)
  values (new.id, 1, 1)
  on conflict (user_id) do nothing;

  -- Dua progress (single row per user)
  insert into public.dua_progress (user_id, current_dua_id)
  values (new.id, null)
  on conflict (user_id) do nothing;

  return new;
end;
$$;
