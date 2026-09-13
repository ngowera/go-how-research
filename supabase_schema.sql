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
 ('text','number','singleChoice','multipleChoice','likertScale','rating','date','matrix','yesNo')),
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
