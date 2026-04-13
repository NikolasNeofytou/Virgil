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

## A2 — Core Companion Flow
- [ ] Prediction screen (stepper 0→N, lock-in, wait for others, simultaneous reveal)
- [ ] Play phase screen (passive — show all predictions as reference, dealer badge, round progress)
- [ ] Submit results screen (stepper 0→N for tricks won, sanity check: total must equal N)
- [ ] Validation screen (show all results: name, predicted, actual, score — Confirm/Dispute buttons, 3/4 threshold)
- [ ] Round progression logic (up-then-down card count, auto-advance round, rotate dealer)
- [ ] Auto-scoring (tricks + bonus if prediction === actual)
- [ ] Game over detection (after last round)
- [ ] Wire phase transitions via Supabase Realtime (predicting→playing→submitting→validating→next round)

## A3 — Polish + Scoreboard
- [ ] Live leaderboard with animated rank changes
- [ ] Score graph (line chart, one line per player across rounds)
- [ ] Prediction accuracy tracker (hit rate per player)
- [ ] Dealer rotation indicator on play screen
- [ ] Game summary screen (winner highlight, fun awards: "Best Predictor", "Biggest Upset")
- [ ] Game history stored in Supabase
- [ ] Premium dark theme polish (glass-morphic panels, subtle animations)
- [ ] i18n setup (Greek default + English)
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
