# Tichu Cyprus — Development Checklist

## A1 — Scaffold + Auth + Rooms [DONE]
- [x] Monorepo scaffold (app/, server/, supabase/, shared/, docs/)
- [x] Supabase project live with migrations (players + estimation tables)
- [x] Flutter app running on emulator with dark/gold theme
- [x] Email OTP sign-in flow (6-digit code)
- [x] Username picker screen
- [x] 4-tab bottom nav (Play, Friends, Leaderboard, Profile)
- [x] Profile tab with stats + locale toggle
- [x] Score Companion card on Play tab
- [x] Create room (pick player count, get 4-char code)
- [x] Join room (enter code)
- [x] Room lobby with realtime player list, usernames, host badge, leave/back
- [x] Start game button (host only, when full)

## A2 — Core Companion Flow [DONE]
- [x] Prediction screen (NumberPicker, lock-in, wait for others, simultaneous reveal)
- [x] Play phase screen (passive — show all predictions as reference, dealer badge, round progress)
- [x] Submit results screen (NumberPicker for tricks won, sanity check: total must equal N)
- [x] Validation screen (name, predicted, actual, score — Confirm/Dispute, 3/4 threshold)
- [x] Round progression logic (up-then-down card count, auto-advance round, rotate dealer)
- [x] Auto-scoring (tricks + bonus if prediction === actual)
- [x] Game over detection (after last round)
- [x] Wire phase transitions via Supabase Realtime (ref.listen + auto-advance)
- [x] Email + password sign-in fallback (OTP rate limit workaround)
- [x] Fix RLS recursion + SELECT permissions for INSERT RETURNING
- [x] Handle "already joined" gracefully in joinGameByCode

## Aesthetic Overhaul [DONE]
- [x] Refined Linear/Notion-inspired dark theme (near-black surfaces, muted gold)
- [x] Global `ThemeData` config (inputs, buttons, navbar, dialogs, segmented, progress)
- [x] Inter typography scale with negative letter-spacing
- [x] `AppBackground` subtle radial gold glow wrapper
- [x] Sign-in / username picker / home / tabs / lobby / game screens all polished
- [x] `_LockedCard` + `_SubmittedCard` prominent displays after lock-in
- [x] Scalable dot progress bar (compresses for 51-round games)
- [x] "εσύ" badge on your own player row
- [x] `AnimatedSwitcher` between game phases

## Day 3+ — Leaderboard · Animations · Memorable Moments
See [`docs/roadmap/day-3-leaderboard-animations-memories.md`](./docs/roadmap/day-3-leaderboard-animations-memories.md) for the full plan.

Highlights:
- **Track 1 (Leaderboard):** stats view, top-10, your rank, in-game live scoreboard, score graph
- **Track 2 (Animations):** score count-up, gold shimmer, tile bounce, prediction reveal flip, rank change, page transitions, error shake, confetti
- **Track 3 (Memorable Moments):** BeReal-style winner photo, fun awards, session name, shareable summary card, game history, sound + haptics, memorable quotes

## A3 — Final Polish
- [ ] i18n setup (Greek default + English toggle)
- [ ] Deep linking for auth (magic links + OAuth redirects)
- [ ] Google/Apple OAuth provider setup
- [ ] Sentry error tracking integration
- [ ] TestFlight / internal testing build via Fastlane

## B1 — Game Engine (Server)
- [ ] Complete Tichu game engine (all rules, 56-card deck, special cards, scoring)
- [ ] Authoritative Node.js game server with move validation
- [ ] WebSocket protocol (11 client→server, 15 server→client message types)
- [ ] Game phase state machine (deal→GT window→deal→exchange→play→scoring)
- [ ] Unit tests for game logic

## B2 — Game Board UI
- [ ] Flame game rendering (landscape, 4-seat card table)
- [ ] Card fan (your hand at bottom)
- [ ] Card exchange overlay
- [ ] Play area (center trick)
- [ ] Tichu/Grand Tichu call UI
- [ ] Mahjong wish selector
- [ ] Dragon gift choice
- [ ] Connect Flutter client to WebSocket server

## B3 — Matchmaking + Friends
- [ ] Private rooms (create room, share 4-char code, join)
- [ ] Auto-matchmaking with ELO-based skill pairing
- [ ] Friends list (online first, search/add, pending requests)
- [ ] Invite friend to room
- [ ] Push notifications (FCM)

## B4 — Premium Visuals
- [ ] Card animations (deal, play to table, trick capture)
- [ ] Animated cinematic scoring tally (Balatro-style card flip)
- [ ] Point floaters (+5, +10 on high-value captures)
- [ ] Tichu badge glow
- [ ] Sound effects and haptics

## B5 — Progression + Community
- [ ] XP and leveling system
- [ ] Ranked seasons with ELO leaderboard and seasonal resets
- [ ] Player stats and match history with round-by-round breakdown
- [ ] i18n (Greek + English)
- [ ] Push notifications for friend requests, game invites

## B6 — Polish + Ship
- [ ] Reconnection handling (dropped connections rejoin mid-game)
- [ ] Edge case testing
- [ ] Beta test (TestFlight + Play Store internal)
- [ ] Submit to App Store + Play Store
- [ ] CI/CD (GitHub Actions + Fastlane)
- [ ] Monitoring (Sentry, UptimeRobot, PostHog)
