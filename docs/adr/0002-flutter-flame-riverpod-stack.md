# ADR 0002 — Flutter + Flame + Riverpod for the Mobile Client

**Status:** Accepted
**Date:** 2026-04-09

## Context

Tichu Cyprus needs a single codebase that ships to iOS and Android with premium card-game animations (Balatro-inspired). Options considered: React Native, native (Swift + Kotlin), Unity, Flutter.

## Decision

**Flutter 3.x + Flame + Riverpod.**

- **Flutter** — Impeller renderer gives the highest animation ceiling for 2D among cross-platform toolkits, and there's no JS bridge bottleneck.
- **Flame** — Purpose-built 2D game engine on top of Flutter. Sprites, particles, physics, component tree, audio. The Tichu game board (Phase B) needs this.
- **Riverpod** — Compile-time safe, fine-grained provider scoping. Complex game state (lobby, friends, in-game, scoring) stays manageable.

## Consequences

- Single team, single language (Dart), ships to both stores.
- Flame is Phase B only — Phase A uses plain Flutter widgets for the estimation UI.
- We commit to Dart 3.x + null safety + codegen (freezed, json_serializable, riverpod_generator).
