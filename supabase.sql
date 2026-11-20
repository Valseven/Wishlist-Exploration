-- Run this once in the Supabase SQL Editor for a new project.
create table if not exists public.members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  name text not null unique check (name in ('yayan', 'alca'))
);

create table if not exists public.wishes (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 80),
  theme text not null default 'other',
  note text not null default '',
  done boolean not null default false,
  at bigint not null default (extract(epoch from now()) * 1000)::bigint,
  "doneAt" date
);

create table if not exists public.rv (
  id text primary key,
  w uuid not null references public.wishes(id) on delete cascade,
  p text not null check (p in ('yayan', 'alca')),
  r jsonb not null,
  o numeric(2,1) not null check (o between 1 and 5),
  memo text not null default '',
  at bigint not null default (extract(epoch from now()) * 1000)::bigint,
  unique (w, p)
);

create table if not exists public.activity_history (
  id bigint generated always as identity primary key,
  wish_id uuid references public.wishes(id) on delete set null,
  wish_title text not null,
  action text not null check (action in ('added', 'completed', 'reopened', 'deleted', 'review_saved')),
  actor text not null check (actor in ('yayan', 'alca')),
  happened_at timestamptz not null default now()
);

alter table public.members enable row level security;
alter table public.wishes enable row level security;
alter table public.rv enable row level security;
alter table public.activity_history enable row level security;

-- No public/anonymous access. Signed-in members may read their own membership row.
revoke all on table public.members, public.wishes, public.rv, public.activity_history from anon, authenticated;
grant usage on schema public to authenticated;
grant select on table public.members to authenticated;
grant select, insert, update, delete on table public.wishes, public.rv to authenticated;
grant select, insert on table public.activity_history to authenticated;
grant usage on sequence public.activity_history_id_seq to authenticated;

drop policy if exists "Members can read own membership" on public.members;
create policy "Members can read own membership" on public.members for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Members can read wishes" on public.wishes;
create policy "Members can read wishes" on public.wishes for select to authenticated
  using (exists (select 1 from public.members m where m.user_id = (select auth.uid())));
drop policy if exists "Members can manage wishes" on public.wishes;
create policy "Members can manage wishes" on public.wishes for all to authenticated
  using (exists (select 1 from public.members m where m.user_id = (select auth.uid())))
  with check (exists (select 1 from public.members m where m.user_id = (select auth.uid())));

drop policy if exists "Members can read reviews" on public.rv;
create policy "Members can read reviews" on public.rv for select to authenticated
  using (exists (select 1 from public.members m where m.user_id = (select auth.uid())));
drop policy if exists "Members can add own review" on public.rv;
create policy "Members can add own review" on public.rv for insert to authenticated
  with check (exists (select 1 from public.members m where m.user_id = (select auth.uid()) and m.name = p));
drop policy if exists "Members can edit own review" on public.rv;
create policy "Members can edit own review" on public.rv for update to authenticated
  using (exists (select 1 from public.members m where m.user_id = (select auth.uid()) and m.name = p))
  with check (exists (select 1 from public.members m where m.user_id = (select auth.uid()) and m.name = p));
drop policy if exists "Members can delete own review" on public.rv;
create policy "Members can delete own review" on public.rv for delete to authenticated
  using (exists (select 1 from public.members m where m.user_id = (select auth.uid()) and m.name = p));

drop policy if exists "Members can read activity history" on public.activity_history;
create policy "Members can read activity history" on public.activity_history for select to authenticated
  using (exists (select 1 from public.members m where m.user_id = (select auth.uid())));
drop policy if exists "Members can add attributed activity" on public.activity_history;
create policy "Members can add attributed activity" on public.activity_history for insert to authenticated
  with check (exists (select 1 from public.members m where m.user_id = (select auth.uid()) and m.name = actor));

do $$ begin
  alter publication supabase_realtime add table public.wishes;
exception when duplicate_object then null;
end $$;
do $$ begin
  alter publication supabase_realtime add table public.rv;
exception when duplicate_object then null;
end $$;
do $$ begin
  alter publication supabase_realtime add table public.activity_history;
exception when duplicate_object then null;
end $$;

-- After creating Yayan and Alca in Authentication > Users, add them here.
-- Replace both UUIDs with their auth.users.id values shown in the dashboard.
-- insert into public.members (user_id, name) values
--   ('YAYAN_AUTH_USER_UUID', 'yayan'),
--   ('ALCA_AUTH_USER_UUID', 'alca');
