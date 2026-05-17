-- =============================================================================
-- Storage buckets: avatars, project-stories, audio
-- =============================================================================

insert into storage.buckets (id, name, public)
values
  ('avatars',        'avatars',        true),
  ('project-stories','project-stories',true),
  ('audio',          'audio',          true)
on conflict (id) do nothing;

-- -----------------------------------------------------------------------------
-- avatars: public read, authenticated user can write their own folder.
-- Convention: object path = "<auth.uid()>/filename"
-- -----------------------------------------------------------------------------
drop policy if exists "avatars: public read"        on storage.objects;
create policy "avatars: public read"
  on storage.objects for select
  using (bucket_id = 'avatars');

drop policy if exists "avatars: user can upload"    on storage.objects;
create policy "avatars: user can upload"
  on storage.objects for insert
  with check (
    bucket_id = 'avatars'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "avatars: user can update"    on storage.objects;
create policy "avatars: user can update"
  on storage.objects for update
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "avatars: user can delete"    on storage.objects;
create policy "avatars: user can delete"
  on storage.objects for delete
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- -----------------------------------------------------------------------------
-- project-stories: public read, admin write
-- -----------------------------------------------------------------------------
drop policy if exists "project-stories: public read" on storage.objects;
create policy "project-stories: public read"
  on storage.objects for select
  using (bucket_id = 'project-stories');

drop policy if exists "project-stories: admin write" on storage.objects;
create policy "project-stories: admin write"
  on storage.objects for insert
  with check (
    bucket_id = 'project-stories'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
  );

drop policy if exists "project-stories: admin update" on storage.objects;
create policy "project-stories: admin update"
  on storage.objects for update
  using (
    bucket_id = 'project-stories'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
  );

drop policy if exists "project-stories: admin delete" on storage.objects;
create policy "project-stories: admin delete"
  on storage.objects for delete
  using (
    bucket_id = 'project-stories'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
  );

-- -----------------------------------------------------------------------------
-- audio: public read, admin write
-- -----------------------------------------------------------------------------
drop policy if exists "audio: public read" on storage.objects;
create policy "audio: public read"
  on storage.objects for select
  using (bucket_id = 'audio');

drop policy if exists "audio: admin write" on storage.objects;
create policy "audio: admin write"
  on storage.objects for insert
  with check (
    bucket_id = 'audio'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
  );

drop policy if exists "audio: admin update" on storage.objects;
create policy "audio: admin update"
  on storage.objects for update
  using (
    bucket_id = 'audio'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
  );

drop policy if exists "audio: admin delete" on storage.objects;
create policy "audio: admin delete"
  on storage.objects for delete
  using (
    bucket_id = 'audio'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
  );
