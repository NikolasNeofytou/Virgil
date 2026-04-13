-- 0001_players.sql
-- Shared players table. Used by both Phase A (Estimation) and Phase B (Tichu).
-- One row per authenticated user. Linked to auth.users via id.

create extension if not exists "uuid-ossp";

create table public.players (
  id            uuid primary key references auth.users (id) on delete cascade,
  username      text unique not null check (char_length(username) between 3 and 24),
  display_name  text,
  avatar_url    text,
  locale        text not null default 'el' check (locale in ('el', 'en')),
  elo           int  not null default 1200,
  xp            int  not null default 0,
  level         int  not null default 1,
  games_played  int  not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create index players_username_idx on public.players (lower(username));
create index players_elo_idx      on public.players (elo desc);

-- Auto-create a players row on new auth user.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.players (id, username, display_name, locale)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'username', 'player_' || substr(new.id::text, 1, 8)),
    new.raw_user_meta_data ->> 'display_name',
    coalesce(new.raw_user_meta_data ->> 'locale', 'el')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- RLS
alter table public.players enable row level security;

create policy "players_select_all"
  on public.players for select
  using (true);

create policy "players_update_self"
  on public.players for update
  using (auth.uid() = id)
  with check (auth.uid() = id);
