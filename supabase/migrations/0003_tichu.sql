-- 0003_tichu.sql
-- Phase B: Tichu online schema.
-- Written by the authoritative Node.js game server only at end-of-round / end-of-game.

create table public.games (
  id            uuid primary key default uuid_generate_v4(),
  room_code     text,
  game_type     text not null check (game_type in ('casual', 'ranked')),
  status        text not null default 'waiting' check (status in ('waiting', 'active', 'finished', 'abandoned')),
  team_a_score  int  not null default 0,
  team_b_score  int  not null default 0,
  winning_team  text check (winning_team in ('a', 'b')),
  target_score  int  not null default 1000,
  started_at    timestamptz,
  ended_at      timestamptz,
  created_at    timestamptz not null default now()
);

create index games_status_idx    on public.games (status);
create index games_room_code_idx on public.games (room_code);

create table public.game_players (
  id          uuid primary key default uuid_generate_v4(),
  game_id     uuid not null references public.games (id) on delete cascade,
  player_id   uuid not null references public.players (id) on delete cascade,
  seat        text not null check (seat in ('north', 'south', 'east', 'west')),
  team        text not null check (team in ('a', 'b')),
  elo_before  int,
  unique (game_id, player_id),
  unique (game_id, seat)
);

create index game_players_game_id_idx   on public.game_players (game_id);
create index game_players_player_id_idx on public.game_players (player_id);

create table public.rounds (
  id                  uuid primary key default uuid_generate_v4(),
  game_id             uuid not null references public.games (id) on delete cascade,
  round_number        int  not null,
  team_a_card_points  int  not null default 0,
  team_b_card_points  int  not null default 0,
  team_a_total        int  not null default 0,
  team_b_total        int  not null default 0,
  one_two_finish      text check (one_two_finish in ('team_a', 'team_b')),
  finish_order        text[],
  created_at          timestamptz not null default now(),
  unique (game_id, round_number)
);

create index rounds_game_id_idx on public.rounds (game_id);

create table public.tichu_calls (
  id          uuid primary key default uuid_generate_v4(),
  round_id    uuid not null references public.rounds (id) on delete cascade,
  player_id   uuid not null references public.players (id) on delete cascade,
  call_type   text not null check (call_type in ('tichu', 'grand_tichu')),
  successful  bool not null
);

create index tichu_calls_round_id_idx on public.tichu_calls (round_id);

-- Full replay data. Write-once, read for replays.
create table public.round_logs (
  id         uuid primary key default uuid_generate_v4(),
  round_id   uuid not null references public.rounds (id) on delete cascade,
  dealt_hands jsonb not null,
  exchanges  jsonb not null,
  tricks     jsonb[] not null
);

create index round_logs_round_id_idx on public.round_logs (round_id);

create table public.friendships (
  id             uuid primary key default uuid_generate_v4(),
  requester_id   uuid not null references public.players (id) on delete cascade,
  addressee_id   uuid not null references public.players (id) on delete cascade,
  status         text not null default 'pending' check (status in ('pending', 'accepted', 'blocked')),
  created_at     timestamptz not null default now(),
  unique (requester_id, addressee_id),
  check (requester_id <> addressee_id)
);

create index friendships_requester_idx on public.friendships (requester_id);
create index friendships_addressee_idx on public.friendships (addressee_id);

create table public.elo_history (
  id          uuid primary key default uuid_generate_v4(),
  player_id   uuid not null references public.players (id) on delete cascade,
  game_id     uuid not null references public.games (id) on delete cascade,
  elo_before  int not null,
  elo_after   int not null,
  created_at  timestamptz not null default now()
);

create index elo_history_player_idx on public.elo_history (player_id, created_at desc);

-- RLS: server writes with service role (bypasses RLS). Clients only read.
alter table public.games        enable row level security;
alter table public.game_players enable row level security;
alter table public.rounds       enable row level security;
alter table public.tichu_calls  enable row level security;
alter table public.round_logs   enable row level security;
alter table public.friendships  enable row level security;
alter table public.elo_history  enable row level security;

create policy "games_select_public"         on public.games        for select using (true);
create policy "game_players_select_public"  on public.game_players for select using (true);
create policy "rounds_select_public"        on public.rounds       for select using (true);
create policy "tichu_calls_select_public"   on public.tichu_calls  for select using (true);
create policy "round_logs_select_public"    on public.round_logs   for select using (true);
create policy "elo_history_select_public"   on public.elo_history  for select using (true);

-- Friendships: both parties can see their own rows.
create policy "friendships_select_own"
  on public.friendships for select
  using (auth.uid() in (requester_id, addressee_id));

create policy "friendships_insert_own"
  on public.friendships for insert
  with check (auth.uid() = requester_id);

create policy "friendships_update_own"
  on public.friendships for update
  using (auth.uid() in (requester_id, addressee_id));
