-- Run once in Supabase SQL Editor after supabase_schema.sql and
-- public_questionnaires_setup.sql. It is safe to run again.
begin;

-- This upgrade also introduces the thumbs up/down question type. Existing
-- projects retain the original generated check constraint until it is replaced.
alter table public.questions drop constraint if exists questions_question_type_check;
alter table public.questions add constraint questions_question_type_check
  check(question_type in (
    'text','number','singleChoice','multipleChoice','likertScale','rating',
    'date','matrix','yesNo','thumbs'
  ));

-- UPDATE policies need both USING and WITH CHECK so a recipient cannot change
-- notification ownership while marking an item as read.
drop policy if exists notifications_update on public.notifications;
create policy notifications_update on public.notifications
for update to authenticated
using(recipient_id=(select auth.uid())::text)
with check(recipient_id=(select auth.uid())::text);

-- Public submissions are written by the questionnaire-link Edge Function.
-- Create an owner-only notification in the same transaction as the response.
create or replace function private.notify_online_questionnaire_submission()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  recipient text;
  participant_name text;
  questionnaire_title text;
  online_submission boolean;
begin
  select p.owner_id, q.title
    into recipient, questionnaire_title
  from public.questionnaires q
  join public.projects p on p.id = q.project_id
  where q.id = new.questionnaire_id;

  -- Match current UUID references and older WEB-* code references.
  select nullif(trim(pt.name), ''),
         coalesce(pt.notes, '') like 'Online questionnaire consent:%'
    into participant_name, online_submission
  from public.participants pt
  where pt.id = new.participant_id or pt.code = new.participant_id
  order by (pt.id = new.participant_id) desc
  limit 1;

  if recipient is not null and coalesce(online_submission, false) then
    insert into public.notifications(
      recipient_id, kind, title, body, related_id
    ) values (
      recipient,
      'questionnaire_submission',
      'New questionnaire response',
      coalesce(participant_name, 'A participant') ||
        ' submitted ' || coalesce(questionnaire_title, 'their questionnaire') || '.',
      new.id
    );
  end if;
  return new;
end
$$;

revoke all on function private.notify_online_questionnaire_submission()
  from public, anon, authenticated;

drop trigger if exists online_questionnaire_response_created
  on public.responses;
create trigger online_questionnaire_response_created
after insert on public.responses
for each row execute function private.notify_online_questionnaire_submission();

-- Postgres Changes only emits tables in the Realtime publication. RLS on
-- notifications still limits each authenticated client to its own rows.
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'notifications'
  ) then
    alter publication supabase_realtime add table public.notifications;
  end if;
end
$$;

commit;

-- Expected: one row with rowsecurity=true and one publication row.
select tablename, rowsecurity
from pg_tables
where schemaname = 'public' and tablename = 'notifications';
select pubname, schemaname, tablename
from pg_publication_tables
where pubname = 'supabase_realtime'
  and schemaname = 'public'
  and tablename = 'notifications';
