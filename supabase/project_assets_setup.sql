-- Project-scoped Data Capture assets. Run after supabase_schema.sql.
begin;
create table if not exists public.project_assets (
  id text primary key,
  project_id text not null references public.projects(id) on delete cascade,
  owner_id text not null,
  asset_type text not null check (asset_type in ('image','video','document')),
  title text not null,
  comment text,
  storage_path text not null unique,
  mime_type text not null,
  byte_size bigint not null check (byte_size > 0),
  captured_at timestamptz not null default now(),
  status text not null default 'uploading' check (status in ('uploading','ready'))
);
alter table public.project_assets enable row level security;
grant select, insert, update, delete on public.project_assets to authenticated;
drop policy if exists project_assets_read on public.project_assets;
create policy project_assets_read on public.project_assets for select to authenticated using (
  owner_id=auth.uid()::text or exists(select 1 from public.projects p where p.id=project_id and p.supervisor_id=auth.uid()::text));
drop policy if exists project_assets_insert on public.project_assets;
create policy project_assets_insert on public.project_assets for insert to authenticated with check (
  owner_id=auth.uid()::text and exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid()::text));
drop policy if exists project_assets_update on public.project_assets;
create policy project_assets_update on public.project_assets for update to authenticated using (owner_id=auth.uid()::text) with check (owner_id=auth.uid()::text);
drop policy if exists project_assets_delete on public.project_assets;
create policy project_assets_delete on public.project_assets for delete to authenticated using (owner_id=auth.uid()::text);
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values
 ('project-assets','project-assets',false,10485760,array['image/jpeg','image/png','image/webp','video/mp4','video/quicktime','application/pdf','application/msword','application/vnd.openxmlformats-officedocument.wordprocessingml.document','application/vnd.ms-excel','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'])
on conflict(id) do update set public=false,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;
drop policy if exists project_assets_object_read on storage.objects;
create policy project_assets_object_read on storage.objects for select to authenticated using (bucket_id='project-assets' and exists(select 1 from public.project_assets a where a.storage_path=name and (a.owner_id=auth.uid()::text or exists(select 1 from public.projects p where p.id=a.project_id and p.supervisor_id=auth.uid()::text))));
drop policy if exists project_assets_object_insert on storage.objects;
create policy project_assets_object_insert on storage.objects for insert to authenticated with check (bucket_id='project-assets' and (storage.foldername(name))[1]=auth.uid()::text and exists(select 1 from public.project_assets a where a.storage_path=name and a.owner_id=auth.uid()::text));
drop policy if exists project_assets_object_delete on storage.objects;
create policy project_assets_object_delete on storage.objects for delete to authenticated using (bucket_id='project-assets' and exists(select 1 from public.project_assets a where a.storage_path=name and a.owner_id=auth.uid()::text));
commit;
