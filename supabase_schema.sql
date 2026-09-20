-- GoHow Research — complete Supabase setup
-- Paste this whole file into Dashboard > SQL Editor, then Run.
begin;
create schema if not exists private;

create table if not exists public.users (
 id text primary key, email text not null unique, name text not null,
 role text not null default 'student' check(role in ('student','supervisor','admin','enumerator','ethicsOfficer')),
 institution_id text, avatar_url text, created_at timestamptz not null default now()
);
create table if not exists public.projects (
 id text primary key, title text not null check(length(trim(title))>0), description text not null default '',
 objectives text not null default '', research_questions jsonb not null default '[]' check(jsonb_typeof(research_questions)='array'),
 methodology text not null default '', population text not null default '', sample_size integer not null default 0 check(sample_size>=0),
 sites jsonb not null default '[]' check(jsonb_typeof(sites)='array'),
 status text not null default 'draft' check(status in ('draft','active','completed','archived','paused')),
 owner_id text not null, supervisor_id text, start_date timestamptz, end_date timestamptz,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 check(end_date is null or start_date is null or end_date>=start_date)
);
create table if not exists public.questionnaires (
 id text primary key, project_id text not null references public.projects(id) on delete cascade,
 title text not null check(length(trim(title))>0), description text not null default '', version integer not null default 1 check(version>0),
 is_approved boolean not null default false, is_published boolean not null default false,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.questions (
 id text primary key, questionnaire_id text not null references public.questionnaires(id) on delete cascade,
 order_index integer not null check(order_index>=0), question_type text not null check(question_type in
 ('text','number','singleChoice','multipleChoice','likertScale','rating','date','matrix','yesNo','thumbs')),
 question_text text not null check(length(trim(question_text))>0), help_text text, is_required boolean not null default false,
 options_json jsonb not null default '[]' check(jsonb_typeof(options_json)='array'), min_value double precision, max_value double precision,
 skip_logic_json jsonb, rows_json jsonb not null default '[]' check(jsonb_typeof(rows_json)='array'),
 columns_json jsonb not null default '[]' check(jsonb_typeof(columns_json)='array'),
 check(min_value is null or max_value is null or max_value>=min_value), unique(questionnaire_id,order_index)
);
create table if not exists public.responses (
 id text primary key, questionnaire_id text not null references public.questionnaires(id) on delete cascade,
 participant_id text not null, responses_json jsonb not null default '{}' check(jsonb_typeof(responses_json)='object'),
 collected_at timestamptz not null default now(), latitude double precision check(latitude is null or latitude between -90 and 90),
 longitude double precision check(longitude is null or longitude between -180 and 180)
);
create table if not exists public.participants (
 id text primary key, project_id text not null references public.projects(id) on delete cascade,
 code text not null check(length(trim(code))>0), name text not null default '', phone text, email text,
 has_consented boolean not null default false, consent_date timestamptz, notes text,
 created_at timestamptz not null default now(), unique(project_id,code)
);

create index if not exists projects_owner_idx on public.projects(owner_id);
create index if not exists projects_supervisor_idx on public.projects(supervisor_id);
create index if not exists questionnaires_project_idx on public.questionnaires(project_id);
create index if not exists questions_questionnaire_idx on public.questions(questionnaire_id);
create index if not exists responses_questionnaire_idx on public.responses(questionnaire_id);
create index if not exists responses_participant_idx on public.responses(participant_id);
create index if not exists participants_project_idx on public.participants(project_id);

create or replace function private.set_updated_at() returns trigger language plpgsql security invoker set search_path='' as $$
begin new.updated_at=now(); return new; end $$;
drop trigger if exists projects_set_updated_at on public.projects;
create trigger projects_set_updated_at before update on public.projects for each row execute function private.set_updated_at();
drop trigger if exists questionnaires_set_updated_at on public.questionnaires;
create trigger questionnaires_set_updated_at before update on public.questionnaires for each row execute function private.set_updated_at();

create or replace function private.handle_new_auth_user() returns trigger language plpgsql security definer set search_path='' as $$
begin
 insert into public.users(id,email,name,role,avatar_url,created_at) values(
  new.id::text,coalesce(new.email,''),
  coalesce(nullif(new.raw_user_meta_data->>'name',''),split_part(coalesce(new.email,''),'@',1),'User'),
  case when new.raw_user_meta_data->>'role' in ('student','supervisor','admin','enumerator','ethicsOfficer')
       then new.raw_user_meta_data->>'role' else 'student' end,
  new.raw_user_meta_data->>'avatar_url',coalesce(new.created_at,now()))
 on conflict(id) do update set email=excluded.email,name=excluded.name,avatar_url=excluded.avatar_url;
 return new;
end $$;
revoke all on function private.handle_new_auth_user() from public,anon,authenticated;
revoke all on function private.set_updated_at() from public,anon,authenticated;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert or update of email,raw_user_meta_data on auth.users
for each row execute function private.handle_new_auth_user();

alter table public.users enable row level security;
alter table public.projects enable row level security;
alter table public.questionnaires enable row level security;
alter table public.questions enable row level security;
alter table public.responses enable row level security;
alter table public.participants enable row level security;
grant usage on schema public to authenticated;
grant select,insert,update,delete on public.users,public.projects,public.questionnaires,public.questions,public.responses,public.participants to authenticated;
revoke all on public.users,public.projects,public.questionnaires,public.questions,public.responses,public.participants from anon;

do $$ declare r record; begin for r in select policyname,tablename from pg_policies where schemaname='public' and tablename in
('users','projects','questionnaires','questions','responses','participants') loop
 execute format('drop policy if exists %I on public.%I',r.policyname,r.tablename); end loop; end $$;

create policy users_select on public.users for select to authenticated using(id=(select auth.uid())::text);
create policy users_insert on public.users for insert to authenticated with check(id=(select auth.uid())::text);
create policy users_update on public.users for update to authenticated using(id=(select auth.uid())::text) with check(id=(select auth.uid())::text);
create policy projects_select on public.projects for select to authenticated
 using(owner_id=(select auth.uid())::text or supervisor_id=(select auth.uid())::text);
create policy projects_insert on public.projects for insert to authenticated with check(owner_id=(select auth.uid())::text);
create policy projects_update on public.projects for update to authenticated using(owner_id=(select auth.uid())::text) with check(owner_id=(select auth.uid())::text);
create policy projects_delete on public.projects for delete to authenticated using(owner_id=(select auth.uid())::text);

create policy questionnaires_select on public.questionnaires for select to authenticated using(exists(
 select 1 from public.projects p where p.id=project_id and (p.owner_id=(select auth.uid())::text or p.supervisor_id=(select auth.uid())::text)));
create policy questionnaires_owner on public.questionnaires for all to authenticated using(exists(
 select 1 from public.projects p where p.id=project_id and p.owner_id=(select auth.uid())::text)) with check(exists(
 select 1 from public.projects p where p.id=project_id and p.owner_id=(select auth.uid())::text));
create policy questionnaires_supervisor_update on public.questionnaires for update to authenticated using(exists(
 select 1 from public.projects p where p.id=project_id and p.supervisor_id=(select auth.uid())::text)) with check(exists(
 select 1 from public.projects p where p.id=project_id and p.supervisor_id=(select auth.uid())::text));

create policy questions_select on public.questions for select to authenticated using(exists(
 select 1 from public.questionnaires q join public.projects p on p.id=q.project_id where q.id=questionnaire_id and
 (p.owner_id=(select auth.uid())::text or p.supervisor_id=(select auth.uid())::text)));
create policy questions_owner on public.questions for all to authenticated using(exists(
 select 1 from public.questionnaires q join public.projects p on p.id=q.project_id where q.id=questionnaire_id and p.owner_id=(select auth.uid())::text)) with check(exists(
 select 1 from public.questionnaires q join public.projects p on p.id=q.project_id where q.id=questionnaire_id and p.owner_id=(select auth.uid())::text));

create policy responses_select on public.responses for select to authenticated using(exists(
 select 1 from public.questionnaires q join public.projects p on p.id=q.project_id where q.id=questionnaire_id and
 (p.owner_id=(select auth.uid())::text or p.supervisor_id=(select auth.uid())::text)));
create policy responses_owner on public.responses for all to authenticated using(exists(
 select 1 from public.questionnaires q join public.projects p on p.id=q.project_id where q.id=questionnaire_id and p.owner_id=(select auth.uid())::text)) with check(exists(
 select 1 from public.questionnaires q join public.projects p on p.id=q.project_id where q.id=questionnaire_id and p.owner_id=(select auth.uid())::text));

create policy participants_select on public.participants for select to authenticated using(exists(
 select 1 from public.projects p where p.id=project_id and (p.owner_id=(select auth.uid())::text or p.supervisor_id=(select auth.uid())::text)));
create policy participants_owner on public.participants for all to authenticated using(exists(
 select 1 from public.projects p where p.id=project_id and p.owner_id=(select auth.uid())::text)) with check(exists(
 select 1 from public.projects p where p.id=project_id and p.owner_id=(select auth.uid())::text));
commit;

-- Expected: six rows, all rowsecurity=true; each table should have policies.
select tablename,rowsecurity from pg_tables where schemaname='public' and tablename in
('users','projects','questionnaires','questions','responses','participants') order by tablename;
select tablename,count(*) policy_count from pg_policies where schemaname='public' and tablename in
('users','projects','questionnaires','questions','responses','participants') group by tablename order by tablename;

-- Project collaboration migration.
create table if not exists public.project_members (
 id text primary key default gen_random_uuid()::text,
 project_id text not null references public.projects(id) on delete cascade,
 user_id text not null references public.users(id) on delete cascade,
 project_role text not null check(project_role in ('studentCollaborator','supervisor','fieldEnumerator','ethicsReviewer')),
 created_at timestamptz not null default now(), unique(project_id,user_id)
);
create table if not exists public.project_access_requests (
 id text primary key default gen_random_uuid()::text,
 project_id text not null references public.projects(id) on delete cascade,
 requester_id text not null references public.users(id) on delete cascade,
 requested_role text not null check(requested_role in ('studentCollaborator','supervisor','fieldEnumerator','ethicsReviewer')),
 status text not null default 'pending' check(status in ('pending','approved','rejected')),
 created_at timestamptz not null default now(), responded_at timestamptz,
 unique(project_id,requester_id,status)
);
create table if not exists public.notifications (
 id text primary key default gen_random_uuid()::text,
 recipient_id text not null references public.users(id) on delete cascade,
 kind text not null, title text not null, body text not null, related_id text,
 read_at timestamptz, created_at timestamptz not null default now()
);
create index if not exists project_members_user_idx on public.project_members(user_id);
create index if not exists access_requests_project_idx on public.project_access_requests(project_id);

create or replace function private.handle_project_access_request() returns trigger
language plpgsql security definer set search_path='' as $$
declare project_owner text; requester_name text;
begin
 select owner_id into project_owner from public.projects where id=new.project_id;
 select name into requester_name from public.users where id=new.requester_id;
 insert into public.notifications(recipient_id,kind,title,body,related_id)
 values(project_owner,'project_access_request','Project access request',coalesce(requester_name,'A researcher') || ' requested ' || new.requested_role || ' access to your project.',new.id);
 return new;
end $$;

create or replace function private.apply_project_access_request() returns trigger
language plpgsql security definer set search_path='' as $$
declare project_title text;
begin
 if new.status='approved' and old.status is distinct from new.status then
      insert into public.project_members(project_id,user_id,project_role) values(new.project_id,new.requester_id,new.requested_role)
      on conflict(project_id,user_id) do update set project_role=excluded.project_role;
               if new.requested_role='supervisor' then
                    update public.projects set supervisor_id=new.requester_id, updated_at=now() where id=new.project_id;
               end if;
      select title into project_title from public.projects where id=new.project_id;
      insert into public.notifications(recipient_id,kind,title,body,related_id)
      values(new.requester_id,'project_access_approved','Project access approved','You now have ' || new.requested_role || ' access to ' || coalesce(project_title,new.project_id) || '.',new.project_id);
 elsif new.status='rejected' and old.status is distinct from new.status then
      insert into public.notifications(recipient_id,kind,title,body,related_id)
      values(new.requester_id,'project_access_rejected','Project access declined','Your request to join project ' || new.project_id || ' was declined.',new.project_id);
 end if;
 return new;
end $$;

drop trigger if exists project_access_request_created on public.project_access_requests;
create trigger project_access_request_created after insert on public.project_access_requests for each row execute function private.handle_project_access_request();
drop trigger if exists project_access_request_status_changed on public.project_access_requests;
create trigger project_access_request_status_changed after update of status on public.project_access_requests for each row execute function private.apply_project_access_request();

alter table public.project_members enable row level security;
alter table public.project_access_requests enable row level security;
alter table public.notifications enable row level security;
grant select,insert,update on public.project_members,public.project_access_requests,public.notifications to authenticated;
revoke all on public.project_members,public.project_access_requests,public.notifications from anon;

create or replace function private.is_project_owner(pid text, uid text) returns boolean
language sql security definer set search_path='' as $$
     select exists(select 1 from public.projects where id=pid and owner_id=uid);
$$;
revoke all on function private.is_project_owner(text,text) from public, anon, authenticated;
grant execute on function private.is_project_owner(text,text) to authenticated;

drop policy if exists project_members_select on public.project_members;
create policy project_members_select on public.project_members for select to authenticated using(user_id=(select auth.uid())::text or private.is_project_owner(project_id,(select auth.uid())::text));
drop policy if exists project_access_requests_insert on public.project_access_requests;
create policy project_access_requests_insert on public.project_access_requests for insert to authenticated with check(requester_id=(select auth.uid())::text);
drop policy if exists project_access_requests_select on public.project_access_requests;
create policy project_access_requests_select on public.project_access_requests for select to authenticated using(requester_id=(select auth.uid())::text or private.is_project_owner(project_id,(select auth.uid())::text));
drop policy if exists project_access_requests_update on public.project_access_requests;
create policy project_access_requests_update on public.project_access_requests for update to authenticated using(private.is_project_owner(project_id,(select auth.uid())::text)) with check(private.is_project_owner(project_id,(select auth.uid())::text));
drop policy if exists notifications_select on public.notifications;
create policy notifications_select on public.notifications for select to authenticated using(recipient_id=(select auth.uid())::text);
drop policy if exists notifications_update on public.notifications;
-- Prevent a recipient from reassigning a notification to another account.
create policy notifications_update on public.notifications for update to authenticated
 using(recipient_id=(select auth.uid())::text)
 with check(recipient_id=(select auth.uid())::text);

-- RLS helpers must be security definer so policies do not recursively invoke
-- each other through projects, users, and project_members.
create or replace function private.is_admin(uid text) returns boolean
language sql security definer set search_path='' as $$
     select exists(select 1 from public.users where id=uid and role='admin');
$$;
create or replace function private.is_project_member(pid text, uid text, requested_roles text[] default null) returns boolean
language sql security definer set search_path='' as $$
     select exists(select 1 from public.project_members where project_id=pid and user_id=uid
          and (requested_roles is null or project_role=any(requested_roles)));
$$;
create or replace function private.can_view_requester(requester text, viewer text) returns boolean
language sql security definer set search_path='' as $$
     select exists(select 1 from public.project_access_requests r join public.projects p on p.id=r.project_id
          where r.requester_id=requester and p.owner_id=viewer);
$$;
create or replace function private.is_project_owner(pid text, uid text) returns boolean
language sql security definer set search_path='' as $$
     select exists(select 1 from public.projects where id=pid and owner_id=uid);
$$;
revoke all on function private.is_admin(text) from public, anon, authenticated;
revoke all on function private.is_project_member(text,text,text[]) from public, anon, authenticated;
revoke all on function private.can_view_requester(text,text) from public, anon, authenticated;
revoke all on function private.is_project_owner(text,text) from public, anon, authenticated;
grant execute on function private.is_admin(text) to authenticated;
grant execute on function private.is_project_member(text,text,text[]) to authenticated;
grant execute on function private.can_view_requester(text,text) to authenticated;
grant execute on function private.is_project_owner(text,text) to authenticated;

drop policy if exists users_collaboration_select on public.users;
create policy users_collaboration_select on public.users for select to authenticated using(
 id=(select auth.uid())::text or private.can_view_requester(id,(select auth.uid())::text));

drop policy if exists projects_select on public.projects;
create policy projects_select on public.projects for select to authenticated using(owner_id=(select auth.uid())::text or supervisor_id=(select auth.uid())::text or private.is_project_member(id,(select auth.uid())::text));
drop policy if exists projects_update on public.projects;
create policy projects_update on public.projects for update to authenticated using(owner_id=(select auth.uid())::text or private.is_admin((select auth.uid())::text)) with check(owner_id=(select auth.uid())::text or private.is_admin((select auth.uid())::text));
drop policy if exists projects_delete on public.projects;
create policy projects_delete on public.projects for delete to authenticated using(owner_id=(select auth.uid())::text or private.is_admin((select auth.uid())::text));

drop policy if exists questionnaires_select on public.questionnaires;
create policy questionnaires_select on public.questionnaires for select to authenticated using(exists(
 select 1 from public.projects p where p.id=project_id and (p.owner_id=(select auth.uid())::text or p.supervisor_id=(select auth.uid())::text or private.is_project_member(p.id,(select auth.uid())::text))));
drop policy if exists questionnaires_admin on public.questionnaires;
create policy questionnaires_admin on public.questionnaires for all to authenticated using(private.is_admin((select auth.uid())::text)) with check(private.is_admin((select auth.uid())::text));
drop policy if exists questions_select on public.questions;
create policy questions_select on public.questions for select to authenticated using(exists(
 select 1 from public.questionnaires q join public.projects p on p.id=q.project_id where q.id=questionnaire_id and
 (p.owner_id=(select auth.uid())::text or p.supervisor_id=(select auth.uid())::text or private.is_project_member(p.id,(select auth.uid())::text))));
drop policy if exists responses_select on public.responses;
create policy responses_select on public.responses for select to authenticated using(exists(
 select 1 from public.questionnaires q join public.projects p on p.id=q.project_id where q.id=questionnaire_id and
 (p.owner_id=(select auth.uid())::text or p.supervisor_id=(select auth.uid())::text or exists(select 1 from public.project_members m where m.project_id=p.id and m.user_id=(select auth.uid())::text))));
drop policy if exists participants_select on public.participants;
create policy participants_select on public.participants for select to authenticated using(exists(
 select 1 from public.projects p where p.id=project_id and (p.owner_id=(select auth.uid())::text or p.supervisor_id=(select auth.uid())::text or exists(select 1 from public.project_members m where m.project_id=p.id and m.user_id=(select auth.uid())::text))));

-- Role permissions: shared members can read analytics data, while collection
-- roles may submit responses without gaining project edit or delete access.
drop policy if exists responses_collect on public.responses;
create policy responses_collect on public.responses for insert to authenticated with check(exists(
 select 1 from public.questionnaires q join public.projects p on p.id=q.project_id
 where q.id=questionnaire_id and exists(
      select 1 from public.project_members m where m.project_id=p.id and m.user_id=(select auth.uid())::text
      and m.project_role in ('studentCollaborator','fieldEnumerator'))));

drop policy if exists questionnaires_supervisor_update on public.questionnaires;
create policy questionnaires_supervisor_update on public.questionnaires for update to authenticated using(exists(
 select 1 from public.projects p where p.id=project_id and (
      p.supervisor_id=(select auth.uid())::text or exists(
           select 1 from public.project_members m where m.project_id=p.id and m.user_id=(select auth.uid())::text
          and m.project_role in ('supervisor'))))) with check(exists(
 select 1 from public.projects p where p.id=project_id and (
      p.supervisor_id=(select auth.uid())::text or exists(
           select 1 from public.project_members m where m.project_id=p.id and m.user_id=(select auth.uid())::text
          and m.project_role in ('supervisor')))));

-- Exact usage is exposed only to the protected storage-usage Edge Function.
create or replace function public.get_storage_usage()
returns table(database_bytes bigint, storage_bytes bigint)
language sql security definer set search_path='' as $$
     select pg_database_size(current_database()),
          coalesce((select sum((metadata->>'size')::bigint) from storage.objects where metadata ? 'size'), 0)::bigint;
$$;
revoke all on function public.get_storage_usage() from public, anon, authenticated;
grant execute on function public.get_storage_usage() to service_role;
