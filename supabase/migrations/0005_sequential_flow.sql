-- 0005_sequential_flow.sql
-- Sequential bidding + per-trick tracking for the Estimation score companion.
--
-- Rules encoded here:
--   * Round 1 starter + dealer are drawn at random when the host starts the
--     game (short-straw ritual, purely client-side animation).
--   * Each subsequent round: starter and dealer rotate clockwise by 1 seat.
--   * Predictions happen sequentially starting from the round_starter_seat,
--     going clockwise through all seats. No dealer-last constraint; total
--     predictions may equal cards_this_round.
--   * Tricks ("sub-rounds") are recorded one by one. The leader of trick 1
--     is the round starter; from trick 2 onward the leader is the winner of
--     the previous trick. Trick winners need peer confirmation before the
--     app advances, preventing stray taps from skipping a trick.
--   * `actual_tricks` per player is derived from COUNT(*) over the new
--     `estimation_tricks` table when the round finishes.

-- ── estimation_games: new state columns ──────────────────────────────────────

alter table public.estimation_games
  add column if not exists round_starter_seat  int,
  add column if not exists current_trick_number int not null default 1,
  add column if not exists current_leader_seat  int;

comment on column public.estimation_games.round_starter_seat is
  'Seat that bids first + leads trick 1 in the current round. Rotates clockwise by 1 each round.';
comment on column public.estimation_games.current_trick_number is
  'Active trick within the round (1..cards_this_round).';
comment on column public.estimation_games.current_leader_seat is
  'Seat leading the current trick. Starts at round_starter_seat, then follows trick winners.';

-- ── estimation_tricks: one row per (game, round, trick) ──────────────────────

create table if not exists public.estimation_tricks (
  id                 uuid primary key default uuid_generate_v4(),
  game_id            uuid not null references public.estimation_games (id) on delete cascade,
  round_number       int  not null check (round_number >= 1),
  trick_number       int  not null check (trick_number >= 1),
  leader_seat        int  not null check (leader_seat between 0 and 3),
  -- A pending proposal: someone tapped a winner, waiting on confirmations.
  proposed_winner_id uuid references public.players (id),
  proposed_by_id     uuid references public.players (id),
  -- Players who confirmed the current proposal. Once threshold is met the
  -- proposal is promoted into winner_player_id and this array is frozen.
  confirmed_by_ids   uuid[] not null default '{}',
  -- Final winner, set only after peer confirmation reaches threshold.
  winner_player_id   uuid references public.players (id),
  created_at         timestamptz not null default now(),
  unique (game_id, round_number, trick_number)
);

create index if not exists estimation_tricks_game_round_idx
  on public.estimation_tricks (game_id, round_number);

comment on table public.estimation_tricks is
  'One row per trick ("sub-round"). Proposed winner is locked in only after peer confirmation.';

-- ── Realtime publication ─────────────────────────────────────────────────────

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'estimation_tricks'
  ) then
    alter publication supabase_realtime add table public.estimation_tricks;
  end if;
end $$;

-- ── RLS ──────────────────────────────────────────────────────────────────────

alter table public.estimation_tricks enable row level security;

drop policy if exists "estimation_tricks_select_participants" on public.estimation_tricks;
create policy "estimation_tricks_select_participants"
  on public.estimation_tricks for select
  using (
    exists (
      select 1 from public.estimation_players ep
      where ep.game_id = estimation_tricks.game_id
        and ep.player_id = auth.uid()
    )
  );

drop policy if exists "estimation_tricks_insert_participants" on public.estimation_tricks;
create policy "estimation_tricks_insert_participants"
  on public.estimation_tricks for insert
  with check (
    exists (
      select 1 from public.estimation_players ep
      where ep.game_id = estimation_tricks.game_id
        and ep.player_id = auth.uid()
    )
  );

drop policy if exists "estimation_tricks_update_participants" on public.estimation_tricks;
create policy "estimation_tricks_update_participants"
  on public.estimation_tricks for update
  using (
    exists (
      select 1 from public.estimation_players ep
      where ep.game_id = estimation_tricks.game_id
        and ep.player_id = auth.uid()
    )
  );
