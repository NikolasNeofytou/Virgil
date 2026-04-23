-- 0008_rematch.sql
-- Adds a `rematch_of` pointer on `estimation_games` so two players who
-- just finished a game can tap "Νέο παιχνίδι" independently and both
-- converge on a single new game row (same seats, fresh scores).
--
-- Unique index enforces at most one rematch per finished game.

alter table public.estimation_games
  add column if not exists rematch_of uuid
    references public.estimation_games (id) on delete set null;

create unique index if not exists estimation_games_rematch_of_unique
  on public.estimation_games (rematch_of)
  where rematch_of is not null;

comment on column public.estimation_games.rematch_of is
  'The finished game this one was spun up as a rematch of. NULL for '
  'games created fresh.';
