-- 0002_estimation.sql
-- Phase A: Estimation scoring companion schema.
-- 3 tables synced via Supabase Realtime. No game server needed.

-- Game sessions
create table public.estimation_games (
  id             uuid primary key default uuid_generate_v4(),
  room_code      text unique not null check (char_length(room_code) = 4),
  player_count   int  not null check (player_count between 2 and 4),
  max_cards      int  not null generated always as (floor(52::numeric / player_count)) stored,
  current_round  int  not null default 1,
  total_rounds   int  not null generated always as (2 * floor(52::numeric / player_count)::int - 1) stored,
  status         text not null default 'waiting' check (status in ('waiting', 'active', 'finished')),
  phase          text not null default 'predicting' check (phase in ('predicting', 'playing', 'submitting', 'validating')),
  dealer_seat    int  not null default 0,
  created_at     timestamptz not null default now()
);

create index estimation_games_room_code_idx on public.estimation_games (room_code);
create index estimation_games_status_idx    on public.estimation_games (status);

-- Players in a game (seat + running total)
create table public.estimation_players (
  id           uuid primary key default uuid_generate_v4(),
  game_id      uuid not null references public.estimation_games (id) on delete cascade,
  player_id    uuid not null references public.players (id) on delete cascade,
  seat         int  not null check (seat between 0 and 3),
  total_score  int  not null default 0,
  joined_at    timestamptz not null default now(),
  unique (game_id, player_id),
  unique (game_id, seat)
);

create index estimation_players_game_id_idx on public.estimation_players (game_id);

-- One row per player per round
create table public.estimation_rounds (
  id              uuid primary key default uuid_generate_v4(),
  game_id         uuid not null references public.estimation_games (id) on delete cascade,
  player_id       uuid not null references public.players (id) on delete cascade,
  round_number    int  not null check (round_number >= 1),
  cards_this_round int not null check (cards_this_round >= 1),
  prediction      int,
  actual_tricks   int,
  score           int,
  validated       bool not null default false,
  unique (game_id, player_id, round_number)
);

create index estimation_rounds_game_id_idx on public.estimation_rounds (game_id);

-- Enable Realtime on all three tables so clients can subscribe.
alter publication supabase_realtime add table public.estimation_games;
alter publication supabase_realtime add table public.estimation_players;
alter publication supabase_realtime add table public.estimation_rounds;

-- RLS
alter table public.estimation_games   enable row level security;
alter table public.estimation_players enable row level security;
alter table public.estimation_rounds  enable row level security;

-- A player can see a game if they are a participant.
create policy "estimation_games_select_participants"
  on public.estimation_games for select
  using (
    exists (
      select 1 from public.estimation_players ep
      where ep.game_id = estimation_games.id and ep.player_id = auth.uid()
    )
  );

-- A player can create a new game (they'll add themselves to estimation_players right after).
create policy "estimation_games_insert_auth"
  on public.estimation_games for insert
  with check (auth.uid() is not null);

-- A participant can update the game state (phase transitions, etc.).
create policy "estimation_games_update_participants"
  on public.estimation_games for update
  using (
    exists (
      select 1 from public.estimation_players ep
      where ep.game_id = estimation_games.id and ep.player_id = auth.uid()
    )
  );

create policy "estimation_players_select_participants"
  on public.estimation_players for select
  using (
    exists (
      select 1 from public.estimation_players ep
      where ep.game_id = estimation_players.game_id and ep.player_id = auth.uid()
    )
  );

create policy "estimation_players_insert_self"
  on public.estimation_players for insert
  with check (player_id = auth.uid());

create policy "estimation_players_update_self"
  on public.estimation_players for update
  using (player_id = auth.uid());

create policy "estimation_rounds_select_participants"
  on public.estimation_rounds for select
  using (
    exists (
      select 1 from public.estimation_players ep
      where ep.game_id = estimation_rounds.game_id and ep.player_id = auth.uid()
    )
  );

create policy "estimation_rounds_insert_participants"
  on public.estimation_rounds for insert
  with check (
    exists (
      select 1 from public.estimation_players ep
      where ep.game_id = estimation_rounds.game_id and ep.player_id = auth.uid()
    )
  );

create policy "estimation_rounds_update_self_or_peer"
  on public.estimation_rounds for update
  using (
    exists (
      select 1 from public.estimation_players ep
      where ep.game_id = estimation_rounds.game_id and ep.player_id = auth.uid()
    )
  );
