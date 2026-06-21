-- =============================================================================
-- adhkar_subcategories.img_url + app_images public storage bucket
-- =============================================================================

alter table public.adhkar_subcategories
  add column if not exists img_url text;

-- -----------------------------------------------------------------------------
-- app_images: public read, admin write
-- -----------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('app_images', 'app_images', true)
on conflict (id) do nothing;

drop policy if exists "app_images: public read" on storage.objects;
create policy "app_images: public read"
  on storage.objects for select
  using (bucket_id = 'app_images');

drop policy if exists "app_images: admin write" on storage.objects;
create policy "app_images: admin write"
  on storage.objects for insert
  with check (
    bucket_id = 'app_images'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
  );

drop policy if exists "app_images: admin update" on storage.objects;
create policy "app_images: admin update"
  on storage.objects for update
  using (
    bucket_id = 'app_images'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
  );

drop policy if exists "app_images: admin delete" on storage.objects;
create policy "app_images: admin delete"
  on storage.objects for delete
  using (
    bucket_id = 'app_images'
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
  );
