-- Go-How RS PayChangu billing and feature entitlements.
create table if not exists public.user_entitlements (
  user_id uuid primary key references auth.users(id) on delete cascade,
  tier text not null default 'free' check (tier in ('free', 'plus', 'pro')),
  valid_until timestamptz,
  free_publish_used_at timestamptz,
  updated_at timestamptz not null default now()
);

create table if not exists public.payment_transactions (
  tx_ref text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  tier text not null check (tier in ('plus', 'pro')),
  amount integer not null check (amount > 0),
  currency text not null default 'MWK' check (currency = 'MWK'),
  status text not null default 'pending' check (status in ('pending', 'successful', 'failed')),
  provider_reference text,
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_entitlements enable row level security;
alter table public.payment_transactions enable row level security;

drop policy if exists "Users read own entitlement" on public.user_entitlements;
create policy "Users read own entitlement" on public.user_entitlements
for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists "Users read own payments" on public.payment_transactions;
create policy "Users read own payments" on public.payment_transactions
for select to authenticated using ((select auth.uid()) = user_id);

grant select on public.user_entitlements to authenticated;
grant select on public.payment_transactions to authenticated;
revoke insert, update, delete on public.user_entitlements from anon, authenticated;
revoke insert, update, delete on public.payment_transactions from anon, authenticated;
