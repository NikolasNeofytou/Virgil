# Tichu — Rules Reference (summary)

Phase B implements the full Tichu ruleset. This file is a quick reference; the authoritative game engine lives in `server/src/game/`.

## Basics

- 4 players, 2 teams: North+South = Team A, East+West = Team B.
- 56-card deck: standard 52 + 4 special cards (Mahjong, Dog, Phoenix, Dragon).
- Game plays to a target score (default **1000**).

## Round flow

1. Deal first 8 cards. Each player may call **Grand Tichu** (±200) before seeing more.
2. Deal remaining 6 cards (14 total per player).
3. Each player may call **Tichu** (±100) before playing their first card.
4. Card exchange: each player passes 1 card to each other player (left, partner, right).
5. Player holding the Mahjong leads the first trick and may wish for a rank.
6. Play proceeds with combinations (singles, pairs, triples, stairs, full houses, straights, bombs).
7. Round ends when 3 of 4 players have gone out.

## Card points

- Each **5** = 5 points
- Each **10** or **King** = 10 points
- **Dragon** = +25, **Phoenix** = −25
- Total card points per round = 100.

## Scoring special cases

- **Tichu**: +100 if the caller goes out first, −100 otherwise.
- **Grand Tichu**: +200 / −200.
- **1-2 finish**: if both partners on a team go out 1st and 2nd, the team scores a flat **200** for the round (no card counting).
- **Last player**: their remaining hand goes to the opponents; cards they won go to the opposing team.

## Special cards

- **Mahjong (1)** — lead first, can wish for a rank (must be played if possible).
- **Dog** — passes lead to partner; cannot be beaten.
- **Phoenix** — wild in singles (value = previous + 0.5), wild rank filler in combos. −25 points.
- **Dragon** — highest single. Trick winner must gift the trick to an opponent. +25 points.

## Bombs

- **4 of a kind** — beats any non-bomb.
- **Straight flush (≥5 same suit, consecutive)** — beats 4-of-a-kind; longer beats shorter; higher beats lower.
- Bombs can be played out of turn.
