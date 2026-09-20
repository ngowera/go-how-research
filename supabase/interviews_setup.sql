-- Run once in Supabase SQL Editor after supabase_schema.sql.
begin;
create table if not exists public.interviews (
  id text primary key,
  project_id text not null references public.projects(id) on delete cascade,
  participant_id text not null references public.participants(id),
  owner_id text not null,
  title text not null check(length(trim(title)) > 0),
  storage_path text not null unique,
  mime_type text not null check(mime_type in ('audio/wav','audio/mpeg','audio/mp4','audio/webm','audio/ogg','audio/flac')),
  byte_size integer not null check(byte_size > 0 and byte_size <= 18000000),
  recording_consent boolean not null default false check(recording_consent),
  recorded_at timestamptz not null default now(),
  transcript text,
  transcript_reviewed boolean not null default false,
  transcribed_at timestamptz,
  status text not null default 'uploading' check(status in ('uploading','uploaded','transcribed')),
  check(storage_path = owner_id || '/' || project_id || '/' || id || '/audio')
);
create index if not exists interviews_project_idx on public.interviews(project_id);
create index if not exists interviews_participant_idx on public.interviews(participant_id);
alter table public.interviews enable row level security;
grant select,insert,update,delete on public.interviews to authenticated;
revoke all on public.interviews from anon;
drop policy if exists interviews_read on public.interviews;
create policy interviews_read on public.interviews for select to authenticated using(exists(
 select 1 from public.projects p where p.id=project_id and (p.owner_id=auth.uid()::text or p.supervisor_id=auth.uid()::text)));
drop policy if exists interviews_write on public.interviews;
create policy interviews_write on public.interviews for insert to authenticated with check(
 owner_id=auth.uid()::text and exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid()::text)
 and exists(select 1 from public.participants p where p.id=participant_id and p.project_id=interviews.project_id));
drop policy if exists interviews_update on public.interviews;
create policy interviews_update on public.interviews for update to authenticated using(owner_id=auth.uid()::text)
 with check(owner_id=auth.uid()::text and exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid()::text)
 and exists(select 1 from public.participants p where p.id=participant_id and p.project_id=interviews.project_id));
drop policy if exists interviews_delete on public.interviews;
create policy interviews_delete on public.interviews for delete to authenticated using(owner_id=auth.uid()::text);

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
 values('interview-audio','interview-audio',false,18000000,array['audio/wav','audio/mpeg','audio/mp4','audio/webm','audio/ogg','audio/flac'])
 on conflict(id) do update set public=false,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;
drop policy if exists interview_audio_read on storage.objects;
create policy interview_audio_read on storage.objects for select to authenticated using(bucket_id='interview-audio' and exists(
 select 1 from public.interviews i where i.storage_path=name and
 (i.owner_id=auth.uid()::text or exists(select 1 from public.projects p where p.id=i.project_id and p.supervisor_id=auth.uid()::text))));
drop policy if exists interview_audio_insert on storage.objects;
create policy interview_audio_insert on storage.objects for insert to authenticated with check(bucket_id='interview-audio' and exists(
 select 1 from public.interviews i where i.storage_path=name and i.owner_id=auth.uid()::text)
 and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists interview_audio_update on storage.objects;
create policy interview_audio_update on storage.objects for update to authenticated using(bucket_id='interview-audio' and exists(
 select 1 from public.interviews i where i.storage_path=name and i.owner_id=auth.uid()::text)
 and owner_id=auth.uid()::text and (storage.foldername(name))[1]=auth.uid()::text)
 with check(bucket_id='interview-audio' and exists(select 1 from public.interviews i where i.storage_path=name and i.owner_id=auth.uid()::text)
 and owner_id=auth.uid()::text and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists interview_audio_delete on storage.objects;
create policy interview_audio_delete on storage.objects for delete to authenticated using(bucket_id='interview-audio' and exists(
 select 1 from public.interviews i where i.storage_path=name and i.owner_id=auth.uid()::text)
 and owner_id=auth.uid()::text and (storage.foldername(name))[1]=auth.uid()::text);
commit;
