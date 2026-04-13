# Shared

Cross-cutting contracts shared between the Flutter client and the Node.js game server.

```
schemas/    JSON Schemas for WebSocket protocol messages
```

The WebSocket protocol (11 client→server and 15 server→client message types) is the source of truth for the Flutter ↔ game server contract. Both sides generate or validate against these schemas.

## Envelope

Every WS message uses this envelope:

```json
{ "type": "room:create", "payload": { ... }, "seq": 42 }
```

- `type` — one of the 26 message types (see `schemas/ws-protocol.json`)
- `payload` — per-type, schema-validated
- `seq` — monotonic sequence number, replay-attack protection

## Message Types

### Client → Server (11)
`room:create` · `room:join` · `queue:join` · `game:call_grand_tichu` · `game:pass_grand_tichu` · `game:call_tichu` · `game:exchange_cards` · `game:play_cards` · `game:pass` · `game:give_dragon` · `game:confirm_score`

### Server → Client (15)
`room:created` · `room:player_joined` · `game:deal_first_eight` · `game:deal_remaining_six` · `game:grand_tichu_called` · `game:tichu_called` · `game:exchange_complete` · `game:wish_made` · `game:cards_played` · `game:player_passed` · `game:trick_won` · `game:wish_fulfilled` · `game:player_finished` · `game:round_result` · `game:game_over`

### Game Phase State Machine
`DEAL_FIRST_8 → GRAND_TICHU_WINDOW → DEAL_REMAINING_6 → EXCHANGE → PLAY → ROUND_SCORING → NEXT_ROUND | GAME_OVER`
