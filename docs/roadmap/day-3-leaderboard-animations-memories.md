# Day 3 — Leaderboard · Animations · Memorable Moments

Three parallel tracks. Execute in order within each track. Total estimated effort: ~14–18 hours across 1–2 days.

## Track 1 — Leaderboard

From empty placeholder to a useful dashboard.

### 1a. Schema additions (one migration)
- [ ] Add `estimation_games.winner_player_id uuid` (nullable)
- [ ] Add `estimation_games.ended_at timestamptz`
- [ ] Add `estimation_games.session_name text` (for Track 3)
- [ ] Update `finalizeRound()` to set `winner_player_id` (= player with max `total_score`) and `ended_at` when status → 'finished'

### 1b. Postgres view: `public.estimation_stats`
```sql
create view public.estimation_stats as
select
  player_id,
  count(*) filter (where winner_player_id = player_id) as wins,
  count(*) as games_played,
  sum(total_score) as lifetime_points,
  avg(total_score) as avg_score_per_game,
  (select count(*) from estimation_rounds
   where player_id = ep.player_id and prediction = actual_tricks)::float
    / nullif((select count(*) from estimation_rounds
              where player_id = ep.player_id), 0) as accuracy
from estimation_players ep
join estimation_games g on g.id = ep.game_id
where g.status = 'finished'
group by player_id;
```

### 1c. Leaderboard tab — 3 sections
- [ ] **Your stats card** — avatar + 4 stat tiles (Games · Wins · Accuracy · Lifetime pts)
- [ ] **Top 10** — ranked list by wins (or lifetime points), your row highlighted if in top 10
- [ ] **"Your rank: #42"** footer if not in top 10
- [ ] **Recent games** — last 5 finished games you joined; tap → game summary

### 1d. In-game live scoreboard
- [ ] Pull-up bottom sheet accessible from any game phase
- [ ] Running totals per player (ranked)
- [ ] Prediction accuracy per player (live hit rate across the current game)
- [ ] Round-by-round score graph (simple line chart, one line per player)
- [ ] Open via a button in the app bar (`Icons.leaderboard_outlined`)

---

## Track 2 — Animations

Built-in `AnimationController` + `AnimatedSwitcher` + `TweenAnimationBuilder`. Optionally evaluate `flutter_animate` package for cleaner syntax.

### 2a. Number count-up for scores *(high impact)*
- [ ] When validating phase reveals scores, animate each player's `+score` from 0 → actual over ~800ms with `Curves.easeOutCubic`
- [ ] Bonus hits (prediction == actual) get an extra sparkle: gold flash + slight scale bounce (1.0 → 1.1 → 1.0)

### 2b. Gold shimmer on the locked value *(atmospheric)*
- [ ] A subtle `LinearGradient` sweep across the big gold number in `_LockedCard` / `_SubmittedCard`
- [ ] Driven by an `AnimationController` on a 3-second loop
- [ ] `ShaderMask` to apply the gradient

### 2c. NumberPicker tile bounce *(tactile)*
- [ ] On tap, selected tile does 1.0 → 0.95 → 1.05 → 1.0 over 200ms
- [ ] Paired with a haptic pulse (see Track 3f)

### 2d. Prediction reveal flip *(satisfying)*
- [ ] When phase flips `predicting` → `playing`, each player's prediction flips open in sequence
- [ ] 80ms stagger between players
- [ ] `RotationTransition` along Y-axis (or `flutter_flip_card` package)
- [ ] Plays like dealing cards

### 2e. Rank change on leaderboard *(clarifying)*
- [ ] When totals update and ranks shuffle, rows animate to new positions
- [ ] `AnimatedList` or `ReorderableListView` with custom transitions
- [ ] Rising players briefly highlight green, falling red

### 2f. Page transitions *(consistency)*
- [ ] Replace `MaterialPageRoute` defaults with a custom `PageRouteBuilder`
- [ ] Subtle fade + 12px upward slide
- [ ] Apply globally via a helper: `AppRoute.build(builder)`

### 2g. Error shake *(feedback)*
- [ ] On wrong OTP / empty username / bad room code
- [ ] Horizontal shake: 2 oscillations over 250ms, ±8px
- [ ] `AnimatedBuilder` + `Transform.translate`

### 2h. Confetti on win *(delight, optional)*
- [ ] Only if *you* won — gold confetti burst from the trophy tile
- [ ] Use `confetti` package
- [ ] 2-second burst, auto-stops

---

## Track 3 — Memorable Moments

The soul of the app. Features that create lasting artifacts.

### 3a. BeReal-style winner photo *(flagship)*
Dual-camera capture at game end. Front camera overlay on back camera, corner-style, single composited JPEG.

**Schema:**
```sql
create table public.estimation_game_photos (
  id uuid primary key default uuid_generate_v4(),
  game_id uuid not null references estimation_games(id) on delete cascade,
  player_id uuid not null references players(id) on delete cascade,
  photo_url text not null,
  is_winner bool not null default false,
  captured_at timestamptz not null default now()
);
```

**Supabase Storage:**
- Bucket: `game-photos` (create via dashboard or SQL)
- Public read, authenticated write
- Compress to ~400KB before upload

**Tech:**
- Flutter `camera` package (mobile only)
- Sequential capture: back cam full frame → front cam inset
- Composite to single JPEG via `dart:ui` `Canvas.drawImage`
- Web fallback: "Take a photo when you're on mobile next time" prompt

**UX:**
- [ ] Game over screen shows countdown: "Capture the moment!"
- [ ] Tap → camera fires both lenses within ~600ms
- [ ] Upload + store reference in `estimation_game_photos`
- [ ] Gallery grid appears on summary
- [ ] Tap any photo → fullscreen
- [ ] Long-press → save to device / share

### 3b. Fun awards *(plan: already scoped)*
Calculated in `finalizeRound()` when the last round completes. Each award is a data object; rendered as cards on the summary screen.

- [ ] 🎯 **Best Predictor** — highest exact-hit rate
- [ ] 😅 **Biggest Upset** — won despite being last mid-game
- [ ] 🔥 **Hot Streak** — most consecutive exact predictions
- [ ] 💀 **Dead Reckoner** — missed every single prediction
- [ ] 🐢 **Slow Starter** — last after round 5, came back
- [ ] ⚡ **Clean Sweep** — 100% prediction accuracy (rare)

Logic reads `estimation_rounds` for the whole game. Extract to a `GameAwardsCalculator` class.

### 3c. Session name
- [ ] Lobby screen: "Name this game" text field (optional, 48 char max)
- [ ] Saved as `estimation_games.session_name`
- [ ] Appears on game over, game history, shareable card
- [ ] Default: `"Παιχνίδι {date}"` if blank

### 3d. Shareable summary card
- [ ] `RepaintBoundary` wrapping a custom widget → `boundary.toImage()` → PNG bytes
- [ ] Design: dark bg, gold accents, session name title, date, winner photo, standings table, awards, room code, "Tichu Cyprus" watermark
- [ ] Button "Μοιράσου" on game over screen → `share_plus` package to open native share sheet
- [ ] Saves to device gallery as fallback

### 3e. Game history screen
- [ ] New screen: `GameHistoryScreen` accessed from Profile tab → "Τα παιχνίδια μου"
- [ ] List of your finished games (chronological desc)
- [ ] Each item: session name, date, winner photo thumbnail, your rank, total points
- [ ] Tap → opens `GameSummaryScreen` with photos, awards, standings
- [ ] Cross-session memory layer — the reason to re-open the app

### 3f. Sound + haptics
**Sounds** (`assets/sounds/`, ~50KB each):
- [ ] `click.mp3` — NumberPicker selection
- [ ] `lock.mp3` — prediction lock-in
- [ ] `tick.mp3` — score count-up ticks
- [ ] `chime.mp3` — bonus hit
- [ ] `swoosh.mp3` — round advance
- [ ] `fanfare.mp3` — game over
- [ ] `shutter.mp3` — camera capture

Use `audioplayers` or `soundpool` package. Cache clips at app start.

**Haptics** (`HapticFeedback.*`):
- [ ] `lightImpact` on number selection
- [ ] `mediumImpact` on lock-in
- [ ] `heavyImpact` on game over
- [ ] Selection click on rank change

Add global settings toggle in Profile → Sounds on/off + Haptics on/off.

### 3g. Memorable quote *(wrap-up)*
- [ ] Game over screen: "Add a memory" button
- [ ] Text field, 140 char max
- [ ] Multiple players can add
- [ ] Stored as `estimation_game_quotes(id, game_id, player_id, quote, created_at)`
- [ ] Displayed inline on the game summary + in game history

---

## Build order (realistic day-3 schedule)

| Block | Duration | Tasks | Track |
|---|---|---|---|
| Morning 1 | 2h | 1a + 1b + 1c (leaderboard schema + view + tab) | 1 |
| Morning 2 | 1h | 3b (fun awards logic) + 3c (session name) | 3 |
| Mid-morning | 30m | 2c (picker bounce) + 2g (error shake) | 2 |
| Before lunch | 1h | 2a (score count-up) | 2 |
| Afternoon 1 | 2h | 1d (live scoreboard bottom sheet) | 1 |
| Afternoon 2 | 1h | 2b (gold shimmer) + 2d (prediction reveal flip) | 2 |
| Afternoon 3 | 1h | 2e (rank change) + 2f (page transitions) | 2 |
| Evening | 1h | 3f (sound + haptics) | 3 |
| **Total Day 3** | **~9h** | Tracks 1 + 2 + partial 3 | |

**Day 4:**
| Block | Duration | Tasks |
|---|---|---|
| Morning | 3h | 3a (BeReal dual-camera + storage) |
| Afternoon | 2h | 3d (shareable card) + 3e (game history) |
| Evening | 1h | 3g (quotes) + 2h (confetti) + polish |
| **Total Day 4** | **~6h** | Remaining Track 3 + final polish |

---

## Decisions needed before starting

1. **Animation library:** stick with built-in AnimationController or add `flutter_animate` for cleaner syntax?
2. **Audio library:** `audioplayers` (web-safe) or `soundpool` (mobile-optimized)?
3. **Camera fallback for web:** single-cam photo, or skip entirely with "mobile only" message?
4. **Storage bucket RLS:** strict participant-only reads, or public for shareable cards?

## Not in scope (park for later)

- Kafeneio mode (location-based discovery) — Phase B / v1.2
- Weekly Cyprus leaderboard — Phase B
- Custom themes / card backs — Phase B
- Achievement badges — Phase B
- Multi-language (Greek + English toggle) — A3 polish, separate pass
- Push notifications — Phase B
