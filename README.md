# Tichu Cyprus

A modern mobile Tichu card game & scoring companion for the Cyprus community.

**Platform:** iOS + Android (Flutter)
**Architecture:** Flutter/Flame client · Node.js WebSocket game server · Supabase
**Languages:** Greek (default) · English

## Build Phases

- **Phase A — Estimation Scoring Companion** (~1-2 weeks): A real-time peer-validated scoring companion for IRL trick-prediction card games. Runs entirely on Supabase Realtime.
- **Phase B — Tichu Online** (~10-14 weeks): Full real-time 4-player online Tichu with authoritative Node.js game server, ELO matchmaking, friends, and replays.

See [`tichu-cyprus-project-plan-v2.docx.pdf`](./tichu-cyprus-project-plan-v2.docx.pdf) for the full spec.

## Monorepo Layout

```
app/        Flutter mobile app (lib/game, lib/screens, lib/providers, lib/services)
server/     Node.js + TypeScript game server (src/game, src/ws, src/matchmaking)
supabase/   Migrations, seed data, Edge Functions
shared/     JSON schemas for client/server protocols
docs/       ADRs, wireframes, game rules reference
```

## Getting Started

Phase A only needs `app/` + `supabase/`. Phase B adds `server/`.

- Flutter app: see [`app/README.md`](./app/README.md)
- Game server: see [`server/README.md`](./server/README.md)
- Supabase: see [`supabase/README.md`](./supabase/README.md)
