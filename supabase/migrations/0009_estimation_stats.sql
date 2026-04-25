-- 0009_estimation_stats.sql
-- Day 3 Track 1: leaderboard foundation.
--
-- 1. Add game-completion fields used by the leaderboard, awards, and shareable
--    summary card: winner_player_id, ended_at, session_name.
-- 2. Expose a `public.estimation_stats` view aggregating per-player wins,
--    games, lifetime points, average score, and prediction accuracy across
--    all FINISHED games.

-- 1. Game-completion + memorable-moments columns
alter table public.estimation_games
  add column if not exists winner_player_id uuid references public.players (id) on delete set null,
  add column if not exists ended_at         timestamptz,
  add column if not exists session_name     text check (session_name is null or char_length(session_name) <= 48);

create index if not exists estimation_games_winner_player_id_idx
  on public.estimation_games (winner_player_id);

create index if not exists estimation_games_ended_at_idx
  on public.estimation_games (ended_at desc);

-- 2. Aggregate stats view, restricted to finished games.
--
-- Joined to estimation_players so each row represents a (player, game)
-- participation. We aggregate per player. Wins are counted from the parent
-- game's winner_player_id (so each finished game contributes at most one win
-- per player, regardless of how many seats they had — they only have one).
create or replace view public.estimation_stats as
select
  ep.player_id,
  pl.username,
  pl.avatar_url,
  count(*)::int                                                              as games_played,
  count(*) filter (where g.winner_player_id = ep.player_id)::int             as wins,
  sum(ep.total_score)::int                                                   as lifetime_points,
  avg(ep.total_score)::float                                                 as avg_score_per_game,
  (
    select count(*)::float
    from public.estimation_rounds r
    where r.player_id  = ep.player_id
      and r.prediction is not null
      and r.actual_tricks is not null
      and r.prediction = r.actual_tricks
  ) / nullif(
    (
      select count(*)::float
      from public.estimation_rounds r
      where r.player_id  = ep.player_id
        and r.prediction is not null
        and r.actual_tricks is not null
    ),
    0
  )                                                                          as accuracy
from public.estimation_players ep
join public.estimation_games   g  on g.id = ep.game_id
join public.players            pl on pl.id = ep.player_id
where g.status = 'finished'
group by ep.player_id, pl.username, pl.avatar_url;

comment on view public.estimation_stats is
  'Per-player aggregate stats across all finished estimation games. Joined with public.players for username/avatar in the leaderboard tab.';

grant select on public.estimation_stats to authenticated, anon;
