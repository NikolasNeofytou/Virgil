# ADR 0003 — Two Backends: Supabase Realtime + Authoritative Node.js Game Server

**Status:** Accepted
**Date:** 2026-04-09

## Context

Phase A (Estimation companion) is a shared-state problem: everyone sees the same rows, no hidden information after prediction lock-in, no cheating risk. Phase B (Tichu online) is a game-logic problem: hidden cards, move validation, trick resolution, anti-cheat. These two problems have very different technical needs.

## Decision

We use **two backends**, chosen for their respective problems:

1. **Supabase (Postgres + Realtime + Auth + Storage)** — the permanent store and the only backend Phase A uses. Phase B also uses it for profiles, friends, history, ELO, match results.
2. **Node.js + TypeScript game server on Railway, raw WebSockets (`ws`)** — authoritative in-memory game state. Validates every move. During a live game, the DB is never touched; only written at end-of-round and end-of-game.

This separation gives Phase A a 1-2 week ship window (no game server to write) and Phase B sub-100ms gameplay response times.

## Consequences

- Phase A ships fast and gives us a real user base to validate auth, rooms, friends, and theme before Phase B.
- Phase B adds the game server without touching Phase A code — everything in Phase A carries forward.
- We need the Supabase service-role key on the game server for end-of-round writes; it must never ship in the Flutter app.
- Two deployment targets (Supabase cloud + Railway) but both are cheap: ~$5/month total.
