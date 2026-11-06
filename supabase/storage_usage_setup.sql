-- Run once in the database SQL editor to enable per-account media totals.
drop function if exists public.get_storage_usage();

create or replace function public.get_storage_usage(p_user_id uuid)
returns table(
  database_bytes bigint,
  storage_bytes bigint,
  image_bytes bigint,
  recording_bytes bigint,
  video_bytes bigint,
  other_file_bytes bigint
)
language sql
security definer
set search_path = ''
as $$
  select
    pg_database_size(current_database()),
    coalesce(sum((o.metadata->>'size')::bigint), 0)::bigint,
    coalesce(sum((o.metadata->>'size')::bigint) filter
      (where coalesce(o.metadata->>'mimetype', '') like 'image/%'), 0)::bigint,
    coalesce(sum((o.metadata->>'size')::bigint) filter
      (where coalesce(o.metadata->>'mimetype', '') like 'audio/%'), 0)::bigint,
    coalesce(sum((o.metadata->>'size')::bigint) filter
      (where coalesce(o.metadata->>'mimetype', '') like 'video/%'), 0)::bigint,
    coalesce(sum((o.metadata->>'size')::bigint) filter
      (where coalesce(o.metadata->>'mimetype', '') not like 'image/%'
        and coalesce(o.metadata->>'mimetype', '') not like 'audio/%'
        and coalesce(o.metadata->>'mimetype', '') not like 'video/%'), 0)::bigint
  from storage.objects o
  where o.bucket_id in ('project-assets', 'interview-audio')
    and o.name like p_user_id::text || '/%';
$$;

revoke all on function public.get_storage_usage(uuid)
  from public, anon, authenticated;
grant execute on function public.get_storage_usage(uuid) to service_role;
