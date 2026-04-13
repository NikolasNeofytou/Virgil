# WebSocket Message Types

Full inventory of the 11 client→server and 15 server→client message types. Each will get its own JSON Schema in this folder as Phase B progresses.

## Client → Server

| Type | Payload | Description |
|---|---|---|
| `room:create` | `{ gameType }` | Create a private room |
| `room:join` | `{ roomCode }` | Join existing room |
| `queue:join` | `{}` | Enter matchmaking |
| `game:call_grand_tichu` | `{}` | After seeing first 8 cards |
| `game:pass_grand_tichu` | `{}` | Decline Grand Tichu |
| `game:call_tichu` | `{}` | Before first card played |
| `game:exchange_cards` | `{ left, partner, right }` | Pass 1 card to each player |
| `game:play_cards` | `{ cards[], phoenixValue?, wish? }` | Play a combination |
| `game:pass` | `{}` | Pass on current trick |
| `game:give_dragon` | `{ to: 'left' \| 'right' }` | Gift Dragon trick |
| `game:confirm_score` | `{}` | Accept round scoring |

## Server → Client

| Type | Payload | Description |
|---|---|---|
| `room:created` | `{ roomCode, gameId }` | Room ready |
| `room:player_joined` | `{ seat, player }` | Player sat down |
| `game:deal_first_eight` | `{ cards[8] }` | Private: only to this player |
| `game:deal_remaining_six` | `{ cards[6] }` | After GT window |
| `game:grand_tichu_called` | `{ seat }` | Someone called GT |
| `game:tichu_called` | `{ seat }` | Someone called Tichu |
| `game:exchange_complete` | `{ received[] }` | Cards received from exchange |
| `game:wish_made` | `{ rank }` | Mahjong wish broadcast |
| `game:cards_played` | `{ seat, cards, comboType, cardsRemaining }` | Cards played to table |
| `game:player_passed` | `{ seat }` | Player passed |
| `game:trick_won` | `{ winningSeat, points, dragonGiftRequired }` | Trick resolved |
| `game:wish_fulfilled` | `{}` | Wished rank played |
| `game:player_finished` | `{ seat, position }` | Player went out |
| `game:round_result` | `{ full scoring breakdown }` | End-of-round |
| `game:game_over` | `{ winningTeam, finalScore, eloChanges, xpAwarded }` | Game complete |

## Game phase state machine

```
DEAL_FIRST_8
  → GRAND_TICHU_WINDOW
  → DEAL_REMAINING_6
  → EXCHANGE
  → PLAY
  → ROUND_SCORING
  → NEXT_ROUND | GAME_OVER
```
