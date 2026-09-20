-- Public access goes through the questionnaire-link Edge Function only.
create table if not exists public.questionnaire_links (
  id uuid primary key default gen_random_uuid(),
  questionnaire_id text not null unique references public.questionnaires(id) on delete cascade,
  token uuid not null unique default gen_random_uuid(),
  slug text not null unique check(slug ~ '^[a-z0-9][a-z0-9-]{5,59}$'),
  active boolean not null default false,
  collect_name boolean not null default true,
  collect_contact boolean not null default false,
  consent_text text not null default 'I have read the study information and voluntarily agree to participate.',
  expires_at timestamptz not null default now() + interval '30 days',
  max_responses integer not null default 10000 check(max_responses between 1 and 100000),
  created_at timestamptz not null default now()
);
create table if not exists public.questionnaire_link_receipts (
  link_id uuid not null references public.questionnaire_links(id) on delete cascade,
  submission_id uuid not null,
  response_id text not null references public.responses(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(link_id,submission_id)
);
alter table public.questionnaire_links enable row level security;
alter table public.questionnaire_link_receipts enable row level security;
revoke all on public.questionnaire_links,public.questionnaire_link_receipts from anon,authenticated;
grant all on public.questionnaire_links,public.questionnaire_link_receipts to service_role;

-- Atomic insert, callable only by the server. RLS is not bypassed by this function.
create or replace function public.submit_questionnaire_link(
  p_token uuid, p_submission_id uuid, p_name text, p_phone text, p_email text,
  p_answers jsonb, p_fingerprint text
) returns jsonb language plpgsql security invoker set search_path = '' as $$
declare
  l public.questionnaire_links%rowtype;
  q public.questionnaires%rowtype;
  existing text;
  participant text := gen_random_uuid()::text;
  response text := gen_random_uuid()::text;
  code text;
  fingerprint text;
begin
  select * into l from public.questionnaire_links where token=p_token for update;
  if not found then raise exception 'Link unavailable'; end if;
  select response_id into existing from public.questionnaire_link_receipts
    where link_id=l.id and submission_id=p_submission_id;
  if found then return jsonb_build_object('submitted',true,'receipt',existing); end if;
  if not l.active or l.expires_at <= now() then raise exception 'Link closed or expired'; end if;
  if (select count(*) from public.questionnaire_link_receipts where link_id=l.id) >= l.max_responses
    then raise exception 'Response limit reached'; end if;
  select * into q from public.questionnaires where id=l.questionnaire_id for share;
  select md5(coalesce(jsonb_agg(to_jsonb(x) order by x.order_index,x.id)::text,'[]'))
    into fingerprint from public.questions x where questionnaire_id=q.id;
  if fingerprint <> p_fingerprint then raise exception 'Questions changed. Reload before submitting.'; end if;
  if jsonb_typeof(p_answers) <> 'object' or octet_length(p_answers::text)>100000
    then raise exception 'Invalid answers'; end if;
  if l.collect_name and length(trim(coalesce(p_name,'')))=0 then raise exception 'Name required'; end if;
  code := 'WEB-' || participant;
  insert into public.participants(id,project_id,code,name,phone,email,has_consented,consent_date,notes)
    values(participant,q.project_id,code,case when l.collect_name then left(p_name,200) else '' end,
      case when l.collect_contact then left(p_phone,50) else null end,
      case when l.collect_contact then left(p_email,254) else null end,true,now(),
      'Online questionnaire consent: ' || l.consent_text);
  insert into public.responses(id,questionnaire_id,participant_id,responses_json,collected_at)
    values(response,q.id,participant,p_answers,now());
  insert into public.questionnaire_link_receipts(link_id,submission_id,response_id)
    values(l.id,p_submission_id,response);
  return jsonb_build_object('submitted',true,'receipt',response);
end $$;
revoke all on function public.submit_questionnaire_link(uuid,uuid,text,text,text,jsonb,text) from public,anon,authenticated;
grant execute on function public.submit_questionnaire_link(uuid,uuid,text,text,text,jsonb,text) to service_role;

create or replace function public.questionnaire_link_fingerprint(p_questionnaire_id text)
returns text language sql security invoker set search_path = '' as $$
  select md5(coalesce(jsonb_agg(to_jsonb(x) order by x.order_index,x.id)::text,'[]'))
  from public.questions x where questionnaire_id=p_questionnaire_id
$$;
revoke all on function public.questionnaire_link_fingerprint(text) from public,anon,authenticated;
grant execute on function public.questionnaire_link_fingerprint(text) to service_role;
