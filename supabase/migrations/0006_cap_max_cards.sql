-- 0006_cap_max_cards.sql
-- Cap the Estimation game at 7 cards per hand. A proper session is the
-- classic 1→7→1 ladder with the peak doubled, i.e. 14 rounds total.
--
--   round 1  → 1 card
--   round 7  → 7 cards
--   round 8  → 7 cards (peak doubled)
--   round 14 → 1 card
--
-- Previously the schema derived max_cards = floor(52 / player_count), which
-- meant 2-player games ran 51 rounds (painful). The deck size of 52 is now
-- only an upper bound on the per-player hand via `least(7, ...)`.

alter table public.estimation_games
  drop column max_cards,
  drop column total_rounds;

alter table public.estimation_games
  add column max_cards int not null generated always as (
    least(7, floor(52::numeric / player_count)::int)
  ) stored,
  add column total_rounds int not null generated always as (
    2 * least(7, floor(52::numeric / player_count)::int)
  ) stored;
