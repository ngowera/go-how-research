-- Run this once if login reports: infinite recursion detected in policy for relation "projects".
-- These SECURITY DEFINER helpers inspect related tables without re-entering RLS.
create or replace function private.is_project_owner(pid text, uid text) returns boolean
language sql security definer set search_path='' as $$
  select exists(select 1 from public.projects where id=pid and owner_id=uid);
$$;
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
revoke all on function private.is_project_owner(text,text), private.is_admin(text),
  private.is_project_member(text,text,text[]), private.can_view_requester(text,text)
  from public, anon, authenticated;
grant execute on function private.is_project_owner(text,text), private.is_admin(text),
  private.is_project_member(text,text,text[]), private.can_view_requester(text,text)
  to authenticated;

-- Remove recursive variants.
drop policy if exists project_members_select on public.project_members;
drop policy if exists project_access_requests_select on public.project_access_requests;
drop policy if exists project_access_requests_update on public.project_access_requests;
drop policy if exists users_collaboration_select on public.users;
drop policy if exists projects_select on public.projects;
drop policy if exists projects_update on public.projects;
drop policy if exists projects_delete on public.projects;
drop policy if exists questionnaires_select on public.questionnaires;
drop policy if exists questionnaires_admin on public.questionnaires;
drop policy if exists questions_select on public.questions;
drop policy if exists responses_select on public.responses;
drop policy if exists participants_select on public.participants;

create policy project_members_select on public.project_members for select to authenticated
  using(user_id=(select auth.uid())::text or private.is_project_owner(project_id,(select auth.uid())::text));
create policy project_access_requests_select on public.project_access_requests for select to authenticated
  using(requester_id=(select auth.uid())::text or private.is_project_owner(project_id,(select auth.uid())::text));
create policy project_access_requests_update on public.project_access_requests for update to authenticated
  using(private.is_project_owner(project_id,(select auth.uid())::text))
  with check(private.is_project_owner(project_id,(select auth.uid())::text));
create policy users_collaboration_select on public.users for select to authenticated
  using(id=(select auth.uid())::text or private.can_view_requester(id,(select auth.uid())::text));
create policy projects_select on public.projects for select to authenticated
  using(owner_id=(select auth.uid())::text or supervisor_id=(select auth.uid())::text
    or private.is_project_member(id,(select auth.uid())::text));
create policy projects_update on public.projects for update to authenticated
  using(owner_id=(select auth.uid())::text or private.is_admin((select auth.uid())::text))
  with check(owner_id=(select auth.uid())::text or private.is_admin((select auth.uid())::text));
create policy projects_delete on public.projects for delete to authenticated
  using(owner_id=(select auth.uid())::text or private.is_admin((select auth.uid())::text));
create policy questionnaires_select on public.questionnaires for select to authenticated using(exists(
  select 1 from public.projects p where p.id=project_id and
  (p.owner_id=(select auth.uid())::text or p.supervisor_id=(select auth.uid())::text
   or private.is_project_member(p.id,(select auth.uid())::text))));
create policy questionnaires_admin on public.questionnaires for all to authenticated
  using(private.is_admin((select auth.uid())::text))
  with check(private.is_admin((select auth.uid())::text));
create policy questions_select on public.questions for select to authenticated using(exists(
  select 1 from public.questionnaires q join public.projects p on p.id=q.project_id
  where q.id=questionnaire_id and
  (p.owner_id=(select auth.uid())::text or p.supervisor_id=(select auth.uid())::text
   or private.is_project_member(p.id,(select auth.uid())::text))));
create policy responses_select on public.responses for select to authenticated using(exists(
  select 1 from public.questionnaires q join public.projects p on p.id=q.project_id
  where q.id=questionnaire_id and
  (p.owner_id=(select auth.uid())::text or p.supervisor_id=(select auth.uid())::text
   or private.is_project_member(p.id,(select auth.uid())::text))));
create policy participants_select on public.participants for select to authenticated using(exists(
  select 1 from public.projects p where p.id=project_id and
  (p.owner_id=(select auth.uid())::text or p.supervisor_id=(select auth.uid())::text
   or private.is_project_member(p.id,(select auth.uid())::text))));
