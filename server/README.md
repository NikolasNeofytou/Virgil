# Tichu Cyprus — Game Server

Authoritative real-time Tichu game server. Node.js + TypeScript, raw WebSockets via `ws`. Deployed to Railway.

**Not used in Phase A.** Phase A uses Supabase Realtime directly from the Flutter client.

## Architecture Principle

During a live game, the database is never touched. The server holds the entire game state in memory for speed. Only when a round or game finishes does it write results to Supabase. This gives sub-100ms response times during gameplay.

## Directory Layout

```
src/
├── index.ts              Entry point, WS server bootstrap
├── game/                 Tichu game engine (rules, deck, scoring)
├── ws/                   WebSocket handlers, message router, protocol
├── matchmaking/          Queue, ELO pairing
├── rooms/                Private room / room code management
├── persistence/          Supabase write-through (end-of-round/game only)
└── util/                 Logger, config, errors
```

## Prerequisites

- Node.js 20+
- npm 10+
- A Supabase project (service role key for writes)

## Setup

```bash
npm install
cp .env.example .env   # fill in SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, PORT
npm run dev
```

## Scripts

- `npm run dev` — watch mode (tsx)
- `npm run build` — compile TS to `dist/`
- `npm start` — run compiled server
- `npm run lint` — ESLint
- `npm run typecheck` — tsc --noEmit
- `npm test` — vitest

## Protocol

See [`../shared/schemas/`](../shared/schemas/) for the WebSocket message protocol (client→server and server→client message types).

## Deployment

Railway. See [`../docs/deployment.md`](../docs/deployment.md).
