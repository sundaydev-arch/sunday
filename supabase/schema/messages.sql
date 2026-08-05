-- Contact inbox: anon INSERT only (no SELECT/UPDATE/DELETE for anon).
-- Schema contract for forks — apply with your Supabase SQL workflow.

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 1 and 120),
  email text not null check (char_length(trim(email)) between 3 and 254),
  message text not null check (char_length(trim(message)) between 1 and 5000),
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists messages_created_at_idx
  on public.messages (created_at desc);

-- Lock down privileges (Supabase often grants broad defaults)
revoke all on table public.messages from anon, authenticated;
grant insert on table public.messages to anon;

alter table public.messages enable row level security;

drop policy if exists "anon_insert_messages" on public.messages;
drop policy if exists "anon_select_messages" on public.messages;
drop policy if exists "anon_update_messages" on public.messages;
drop policy if exists "anon_delete_messages" on public.messages;
drop policy if exists "authenticated_all_messages" on public.messages;
drop policy if exists "Enable read access for all users" on public.messages;
drop policy if exists "Enable insert for all users" on public.messages;

create policy "anon_insert_messages"
  on public.messages
  for insert
  to anon
  with check (true);

comment on table public.messages is
  'Contact form submissions. RLS: anon INSERT only. Read via Dashboard or service_role.';
