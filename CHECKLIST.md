# Virgil — Development Checklist

> **a guide for the table** — score companion + (eventually) full Tichu online for the Cyprus card-game scene.

## A1 — Scaffold + Auth + Rooms [DONE]
- [x] Monorepo scaffold (app/, server/, supabase/, shared/, docs/)
- [x] Supabase project live with migrations (players + estimation tables)
- [x] Flutter app running on iOS simulator
- [x] Email OTP sign-in flow (6-digit code + magic-link click — see Day 4 deep-linking)
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
- [x] Play phase screen — predictions visible inline, dealer badge, round progress
- [x] Validation screen (name, predicted, actual, score — Confirm/Dispute, 3/4 threshold)
- [x] Round progression logic (up-then-down card count, auto-advance round, rotate dealer)
- [x] Auto-scoring (tricks + bonus if prediction === actual)
- [x] Game-over detection
- [x] Wire phase transitions via Supabase Realtime (ref.listen + auto-advance)
- [x] Email + password sign-in fallback (OTP rate-limit workaround)
- [x] Fix RLS recursion + SELECT permissions for INSERT RETURNING
- [x] Handle "already joined" gracefully in joinGameByCode

## Virgil identity rebrand [DONE]
- [x] Paper-and-ink palette (`paper`, `ink`, `terra`, `olive`, `inkSoft`, `inkFaint`)
- [x] Gloock numerals · Caveat handwriting · Kalam body · JetBrains Mono labels
- [x] Masthead motif (eyebrow + double rule + Gloock title + Caveat tagline) on every entry screen
- [x] Sign-in screen says "Virgil · a guide for the table"
- [x] Repaint of entry + tab screens, tile components, NumberPicker, score chips
- [x] Splash ink-bleed entry animation
- [x] `virgil_icons.dart` icon set
- [x] Web preview harness (`preview_main.dart`) for design QA

## Sequential bidding + per-trick tracking [DONE]
- [x] Migration 0005_sequential_flow — `round_starter_seat`, `current_trick_number`, `current_leader_seat`, `estimation_tricks` table
- [x] Short-straw dealer + starter draw at game start (`ShortStrawDraw` widget)
- [x] Sequential bidding UX — only the current bidder sees the picker, others see a waiting card
- [x] Per-trick winner proposal + peer confirmation (3/4 for 4-player, unanimous otherwise)
- [x] Migration 0006_cap_max_cards — capped at 7 cards/round (14 rounds total, peak doubled)
- [x] `actual_tricks` derived from `estimation_tricks` count when round finalizes
- [x] `ScoreTally` running-totals strip + score-tick + "+N" floater motion

## Friends [DONE]
- [x] Migration 0007_friendships_delete — DELETE policy + Realtime publish
- [x] Friends tab — pending requests, accepted list, search/add by username
- [x] Add / accept / decline / cancel flows
- [x] Realtime updates on friendship status changes

## Resume + rematch [DONE]
- [x] Migration 0008_rematch — `rematch_of` pointer with unique index
- [x] `activeEstimationGameProvider` — surfaces unfinished games on the Play tab
- [x] "Συνέχισε" receipt on Play tab → resumes lobby or game
- [x] "Νέο παιχνίδι" rematch button on game-over → both players converge on the same new room, same seats, fresh scores

## Motion [DONE]
- [x] Reveal sweep on validating phase (180ms stagger per player)
- [x] Score tick animation in `ScoreTally` (number tween + Caveat "+N" floater)
- [x] Winner reveal — laurel grow, ribbon unfurl, typewriter name (4.2s scene on game-over)
- [x] Splash ink-bleed entry

## Day 3 — Leaderboard · Animations · Memorable Moments [DONE]
See [`docs/roadmap/day-3-leaderboard-animations-memories.md`](./docs/roadmap/day-3-leaderboard-animations-memories.md).

- [x] Migration 0009_estimation_stats — `winner_player_id`, `ended_at`, `session_name`, `estimation_stats` view
- [x] `finalizeRound()` stamps winner + ended_at on game completion
- [x] `gameAwardsProvider` — 6 awards (🎯 Best Predictor · 😅 Biggest Upset · 🔥 Hot Streak · 💀 Dead Reckoner · 🐢 Slow Starter · ⚡ Clean Sweep)
- [x] Awards section on game-over panel (paper card per award, staggered fade-in 4.4s after laurel reveal)
- [x] Session-name input on lobby (host-editable, 48-char max, 500ms debounced realtime sync) + read-only label for non-hosts
- [x] Session-name header on game-over (falls back to `παιχνίδι {date}`)
- [x] Leaderboard tab — your stats receipt + Top 10 list + your-rank footer, paper-and-ink, fade-in stagger
- [x] `LiveScoreboardSheet` — DraggableScrollableSheet pull-up from game app bar with rankings + accuracy + round-by-round line chart (CustomPainter)
- [x] `ShakeOnError` wrapper — wired into sign-in / username picker / join-room error paths with heavy haptic
- [x] `AppRoute.build()` page transitions — fade + 12px slide replaces every `MaterialPageRoute`
- [x] `flutter_animate ^4.5.0` dependency

Dropped as redundant (Virgil already had equivalents): `_AnimatedScoreChip` (score_tally covers it), `_FlipReveal` (sequential bidding doesn't need it), NumberPicker bounce (Virgil's terracotta stamp ring is the lock-in motion), `ShimmerNumber` on locked card (no static locked card in sequential flow).

## Day 4 — Magic-link deep-linking · Virgil narrator · dev script [DONE]

**Original plan superseded.** Sound + BeReal + TestFlight all hit blockers (no
sound assets sourced, no real device for camera validation, no Apple Developer
account). Pivoted to three unblocked, sim-testable wins. See
[`docs/roadmap/day-4-photos-sound-testflight.md`](./docs/roadmap/day-4-photos-sound-testflight.md)
for the original (now archived) plan.

- [x] Magic-link via custom `virgil://login-callback/` URL scheme
  - `app_links` package, iOS `CFBundleURLTypes` + Android intent-filter
  - `DeepLinkService` exchanges incoming URI for a session via Supabase PKCE
  - `auth_service` redirect target updated from legacy `cy.tichucyprus://`
  - Sign-in screen flipped back to magic-link as primary; password kept as fallback
  - Verified end-to-end via Mailpit round-trip on a real iOS simulator
- [x] Virgil narrator on game-over panel
  - `GameNarrator.narrate()` — pure-dart, 2–3 sentence Greek narration with
    body variants picked by game shape (close / streak / comeback /
    wire-to-wire / blowout / default-quiet)
  - Opener and closer pools seeded by `gameId` for variety across games but
    determinism within a game
  - Renders as "ΝΑΡΡΗΣΗ · NIGHT NOTE" paper card between standings and
    awards on `GameOverPanel`, fades in at 4.2s as the WinnerCertificate settles
  - 14 unit tests covering each body variant, edge cases, and singular/plural
    Greek grammar
- [x] `scripts/dev-two-sims.sh` — one-shot local-dev script that starts
  Supabase, boots two iOS simulators, and spawns two `flutter run` Terminal tabs

The "auto-highlights" item from the in-progress checklist became the narrator —
a sweep of `GameAwardsCalculator` showed Day 3 already shipped the discrete
callouts (Best Predictor, Hot Streak, Clean Sweep, Dead Reckoner, Biggest Upset,
Slow Starter), so the genuinely-new thing was the narrator's connective tissue.

## Day 5 — Start-game guard · Shareable card · Confetti [DONE]

Three small, sim-testable PRs landed in one session.

- [x] Block 1 — Server-side guard against starting an under-full room
  - Postgres `BEFORE UPDATE` trigger on `estimation_games` refuses
    `'waiting' → 'active'` when `count(estimation_players) < player_count`
  - Defense-in-depth `StateError` in `EstimationService.startGame()`
  - Lobby's existing button-disabled guard (`_isFull`) remains primary UX
  - Migration `0010_start_game_guard.sql`; verified end-to-end via psql
- [x] Block 2 — Shareable summary card
  - `EstimationShareCard` static widget — winner block, standings,
    night note, awards — at 360 logical px, captured at `pixelRatio: 3.0`
    for a 1080-wide PNG
  - Off-screen `Overlay` + `RepaintBoundary` so the card never flashes
    onto the user's view during capture
  - "Κοινοποίηση" button on `GameOverPanel`; `share_plus` hands the
    PNG to the system share sheet
  - Deps: `share_plus ^10.1.4`, `path_provider ^2.1.4`
- [x] Block 3 — Confetti synced with the laurel reveal
  - `ConfettiController` fires at 4.2s (matches `WinnerCertificate`
    completion) in Virgil's terra/olive/paperEdge palette
  - Wrapped panel in `Stack(fit: StackFit.expand)`; `IgnorePointer` so
    confetti never blocks taps
  - Dep: `confetti ^0.7.0`

## Day 6+ — Backlog
- [ ] Game history screen (Profile tab → "Τα παιχνίδια μου")
- [ ] Memorable quotes (140-char inline notes per game)
- [ ] Rank-change animation on cross-game leaderboard
- [ ] Sound + haptics (waiting on Freesound clips)

## A3 — Final Polish
- [ ] i18n setup (Greek default + English toggle)
- [x] Deep linking for auth (magic links via `virgil://` custom scheme — Day 4)
- [ ] Universal Links via `apple-app-site-association` (needs Apple Developer account)
- [ ] Google / Apple OAuth provider setup
- [ ] Sentry error tracking integration
- [ ] Fastlane CI + automated TestFlight builds (needs Apple Developer account)

## Phase B — Tichu Online
*(Phase A scope ends after A3. Phase B is months out.)*

### B1 — Game Engine (Server)
- [ ] Complete Tichu game engine (all rules, 56-card deck, special cards, scoring)
- [ ] Authoritative Node.js game server with move validation
- [ ] WebSocket protocol (11 client→server, 15 server→client message types)
- [ ] Game phase state machine (deal→GT window→deal→exchange→play→scoring)
- [ ] Unit tests for game logic

### B2 — Game Board UI
- [ ] Flame game rendering (landscape, 4-seat card table)
- [ ] Card fan (your hand at bottom)
- [ ] Card exchange overlay
- [ ] Play area (center trick)
- [ ] Tichu / Grand Tichu call UI
- [ ] Mahjong wish selector
- [ ] Dragon gift choice
- [ ] Connect Flutter client to WebSocket server

### B3 — Matchmaking + Friends
- [ ] Auto-matchmaking with ELO-based skill pairing
- [ ] Invite friend to room
- [ ] Push notifications (FCM)

### B4 — Premium Visuals
- [ ] Card animations (deal, play to table, trick capture)
- [ ] Cinematic Balatro-style scoring tally
- [ ] Point floaters
- [ ] Tichu badge glow

### B5 — Progression + Community
- [ ] XP and leveling
- [ ] Ranked seasons with seasonal resets
- [ ] Round-by-round match history
- [ ] Push notifications for friend requests, game invites

### B6 — Polish + Ship
- [ ] Reconnection handling (dropped connections rejoin mid-game)
- [ ] Edge case testing
- [ ] Beta test (TestFlight + Play Store internal)
- [ ] Submit to App Store + Play Store
- [ ] CI/CD (GitHub Actions + Fastlane)
- [ ] Monitoring (Sentry, UptimeRobot, PostHog)
