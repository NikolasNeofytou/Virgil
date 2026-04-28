-- 0012_estimation_moments.sql
-- "Στιγμές · MOMENTS" — short hand-written notes attached to a game
-- (optionally pinned to a specific round). Surfaced on the game-over
-- summary panel and re-openable from Profile → "Τα παιχνίδια μου".
--
-- 140 chars, Twitter-length. Authored by any participant; visible to all
-- participants; deletable only by the author.

create table public.estimation_moments (
  id           uuid primary key default uuid_generate_v4(),
  game_id      uuid not null references public.estimation_games (id) on delete cascade,
  round_number int  check (round_number is null or round_number >= 1),
  author_id    uuid not null references public.players (id) on delete cascade,
  body         text not null check (char_length(body) between 1 and 140),
  created_at   timestamptz not null default now()
);

create index estimation_moments_game_id_idx
  on public.estimation_moments (game_id);

alter table public.estimation_moments enable row level security;

-- SELECT: any participant in the game can see all moments for that game.
create policy estimation_moments_select on public.estimation_moments
  for select
  using (
    exists (
      select 1 from public.estimation_players ep
      where ep.game_id = estimation_moments.game_id
        and ep.player_id = auth.uid()
    )
  );

-- INSERT: a participant may add moments only as themselves.
create policy estimation_moments_insert on public.estimation_moments
  for insert
  with check (
    author_id = auth.uid()
    and exists (
      select 1 from public.estimation_players ep
      where ep.game_id = estimation_moments.game_id
        and ep.player_id = auth.uid()
    )
  );

-- DELETE: an author may remove their own moments. Editing is intentionally
-- not supported in v1 — delete + re-add covers typo cleanup.
create policy estimation_moments_delete on public.estimation_moments
  for delete
  using (author_id = auth.uid());

-- Publish on Realtime so streams in the Flutter app see live inserts.
alter publication supabase_realtime add table public.estimation_moments;
