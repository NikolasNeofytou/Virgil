# Estimation (Oh Hell) — Rules Reference

The Phase A companion tracks this exact ruleset.

## Players
2–4.

## Round structure

The card count per round goes up then back down: `1, 2, 3 ... N ... 3, 2, 1`.

With 4 players and a 52-card deck:
- `N = floor(52 / player_count) = 13`
- Total rounds `= 2N − 1 = 25`

| Players | Max cards | Total rounds |
|--------:|----------:|-------------:|
| 2 | 26 | 51 |
| 3 | 17 | 33 |
| 4 | 13 | 25 |

Formula: `cards_this_round = round_number ≤ max_cards ? round_number : 2 × max_cards − round_number`.

## Each round

1. Every player privately predicts how many tricks they will win (0 to N).
2. Predictions CAN sum to N (no restriction on the last bidder).
3. Predictions are hidden until all players lock in, then revealed simultaneously.
4. Players play the round with real cards.
5. Each player enters how many tricks they actually won.
6. Total tricks submitted must equal N (sanity check, blocks advancement on mismatch).
7. Peer validation: 3/4 must confirm (or unanimous in 2-3 player games).

## Scoring

- **+1 point** per trick won.
- **+10 bonus** if tricks won **exactly equals** the prediction.
- Missed prediction: only trick points, no bonus.

## Game end

Game ends after all rounds complete. Highest total wins.
