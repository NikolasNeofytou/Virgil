# Day 4 — Sound + Haptics · BeReal Photo · TestFlight

**Path C** picked from the Day-3 wrap-up. The two highest-ROI items from Track 3 (Memorable Moments) plus a real-device build so we stop testing only in the simulator.

Total estimated effort: **~5 hours**.

## Why this set

- After today's Day 3 push, every screen is polished but **silent**. Sound + haptics are an across-the-board feel upgrade for ~1 hour of work.
- The **BeReal winner photo** is the roadmap's flagship "memorable moment" — every other Track 3 feature (shareable card, game history thumbnails, quote stamps) anchors on it. Build the foundation now, the rest slots in cheap.
- A **TestFlight build** gets the app on a real iPhone (and ideally a friend's). Real-device testing surfaces bugs the simulator hides — touch dispatch, network races, photo-permission UX, app-state-on-relaunch.

Skipping until Day 5+: shareable summary card (3d), game history (3e), memorable quotes (3g), confetti (2h), rank-change animation (2e). All cheap once 3a is in place.

---

## Block 1 — Sound + haptics (~1h)

Light, atmospheric, off-by-default-toggleable. Not a substitute for visual feedback — a layer on top.

### 1a. Asset prep

- [ ] Source/record 7 short clips (~50KB each, MP3 or M4A):
  - `click.mp3` — NumberPicker tap (very short, dry)
  - `lock.mp3` — prediction lock-in (single-thump confirmation)
  - `tick.mp3` — score count-up tick (already covered by Virgil's score_tally; consider whether we re-use or replace)
  - `chime.mp3` — bonus hit (prediction == actual)
  - `swoosh.mp3` — round advance / phase transition
  - `fanfare.mp3` — game over (3-second clip max)
  - `shutter.mp3` — camera capture (Block 2)
- [ ] Drop into `app/assets/sounds/` and register in `pubspec.yaml`

### 1b. Audio service

- [ ] Add `audioplayers: ^6.x` to pubspec
- [ ] `lib/services/audio_service.dart` — singleton with cached `AudioPlayer` per clip, `play(SoundEffect.click)` API
- [ ] Pre-cache clips on app start (in `app.dart` initState equivalent)

### 1c. Wire trigger points

- [ ] NumberPicker `onTap` → `click` + `lightImpact` haptic (tap haptic already exists from Day 3 — confirm not double-firing)
- [ ] Prediction "Κλείδωμα" button → `lock` + `mediumImpact`
- [ ] Trick winner confirmed (per-trick peer confirmation reaches threshold) → `swoosh` + `selectionClick`
- [ ] Score reveal in validating phase → no new sound (Virgil's score_tally already tweens; rely on its visual)
- [ ] Bonus hit on validating phase → `chime` + `lightImpact` synced to the score tick
- [ ] Game-over panel mount → `fanfare` + `heavyImpact` (single fire, gated with `_played` flag)

### 1d. Settings toggle

- [ ] Profile tab → new section "Ήχος · ΑΦΗ" with two `Switch`es:
  - Sounds on/off (default: on)
  - Haptics on/off (default: on)
- [ ] Persist via `shared_preferences` (add dep)
- [ ] AudioService and HapticService both gate on the prefs

---

## Block 2 — BeReal-style winner photo (~3h)

Dual-camera capture at the moment of game-over, composited into a single JPEG, uploaded to Supabase Storage. Gallery grid surfaces on the game-over screen.

### 2a. Schema (migration `0010_game_photos.sql`)

```sql
create table public.estimation_game_photos (
  id           uuid primary key default uuid_generate_v4(),
  game_id      uuid not null references public.estimation_games(id) on delete cascade,
  player_id    uuid not null references public.players(id) on delete cascade,
  photo_url    text not null,
  is_winner    bool not null default false,
  captured_at  timestamptz not null default now(),
  unique (game_id, player_id)
);

create index estimation_game_photos_game_id_idx on public.estimation_game_photos (game_id);

alter table public.estimation_game_photos enable row level security;

-- Anyone in the game can see photos.
create policy "estimation_game_photos_select_participants"
  on public.estimation_game_photos for select
  using (public.is_estimation_participant(game_id, auth.uid()));

-- Only the photo's player can insert their own.
create policy "estimation_game_photos_insert_self"
  on public.estimation_game_photos for insert
  with check (player_id = auth.uid());

-- Realtime so the gallery grid updates as photos land.
alter publication supabase_realtime add table public.estimation_game_photos;
```

### 2b. Supabase Storage bucket

- [ ] Create `game-photos` bucket via dashboard (or SQL):
  - Public read
  - Authenticated write
  - Path convention: `{game_id}/{player_id}.jpg`
- [ ] Storage RLS policies:
  - Read: anyone (since the bucket is public-read)
  - Write: only authenticated user, only their own `{game_id}/{user.id}.jpg` path
  - Delete: nobody (immutability)

### 2c. Camera capture flow

Tech choice: `camera: ^0.11.x` package. iOS-only first (the wireless iPhone is connected); Android polish later.

- [ ] Add `camera` to pubspec; iOS camera permission strings in `Info.plist`
- [ ] `lib/services/dual_camera_service.dart`:
  - Initialize back + front controllers in parallel
  - `captureBoth()`: trigger back-cam capture; trigger front-cam capture within 600ms
  - Returns two `XFile` paths
- [ ] `lib/services/photo_compositor.dart`:
  - Take the two captures, composite to single JPEG via `dart:ui` `Canvas.drawImage`
  - Front cam as a corner inset (top-right, ~28% width, rounded corners, terra ring border to match Virgil identity)
  - Back cam fills the frame
  - Compress to ~400KB target, return `Uint8List`
- [ ] `lib/services/photo_upload_service.dart`:
  - Upload to `game-photos/{gameId}/{userId}.jpg` (bytes from compositor)
  - Insert row into `estimation_game_photos`
  - Idempotent on the unique constraint — re-tap captures a new image (overwrite)

### 2d. UX on the game-over screen

- [ ] On `GameOverPanel` mount, after the WinnerCertificate settles (~4.4s, same delay used by today's awards), show a "Capture the moment" prompt:
  - Paper card with `📸` icon, Caveat title, terra "πάτα για φωτογραφία" hint
  - Tap → fires `captureBoth()` flow
  - During capture: show shutter sound + heavy haptic (Block 1)
  - After upload: card replaced by a thumbnail of *your* photo
- [ ] Below the awards section: gallery grid (`GridView.count(crossAxisCount: 2)`) of all photos uploaded so far for this game; live-updates via Realtime
- [ ] Tap any thumbnail → fullscreen viewer with `Hero` transition + pinch-to-zoom (`InteractiveViewer`)
- [ ] Web fallback: skip the capture card entirely, show "διαθέσιμο μόνο σε κινητό" message (the camera package doesn't run on web)

### 2e. Player-side considerations

- [ ] Permission flow: first capture asks for camera; deny → graceful inline message, no app crash
- [ ] If multiple players capture, the gallery grows in real-time
- [ ] Winner's photo gets a subtle terra ring around its thumbnail (`is_winner` flag — set server-side or client-set when `winner_player_id == player_id`)
- [ ] No retake button v1; users can just navigate away and tap again to overwrite (idempotent unique constraint)

---

## Block 3 — TestFlight build (~1h)

Get the app on a real device. Sets up the rails for ongoing dev-loop testing.

### 3a. Pre-flight

- [ ] Apple Developer account active (assuming yes — confirm)
- [ ] Bundle id chosen (likely `app.virgil.cards` or similar — confirm with user before configuring)
- [ ] Versioning: bump `pubspec.yaml` to `0.2.0+1`

### 3b. Manual upload (fastest path for v1)

- [ ] `flutter build ipa --release --dart-define-from-file=.env`
- [ ] Open `build/ios/archive/Runner.xcarchive` in Xcode → Window → Organizer
- [ ] Distribute App → App Store Connect → Upload
- [ ] Wait for processing on App Store Connect (~10-30min)
- [ ] In TestFlight tab: add internal testers (just you initially, then 1-2 friends)
- [ ] Install via TestFlight on real iPhones

### 3c. Fastlane (deferred — Day 5+)

If manual upload feels slow we can wire Fastlane for one-command builds. Skip for v1; the manual path is fine for a 5-tester rollout.

### 3d. What to test on device

- [ ] Sign-in flow with the magic link — does deep linking still fail? (it will; that's expected, password mode is the workaround)
- [ ] Game with 2 real iPhones in the same room (one yours, one borrowed)
- [ ] **The BeReal photo capture** — this is the killer feature; it'll make/break the experience
- [ ] Sound + haptics — feel right? Annoying? Loud?
- [ ] Network: try with poor connectivity (turn off Wi-Fi mid-game, see what happens to phase transitions)

---

## Build order (realistic Day 4 schedule)

| Block | Duration | Task | Why this slot |
|---|---|---|---|
| Morning 1 | 1h | Block 1 — Sound + haptics | Quick wins, exercises every screen |
| Morning 2 | 30m | Block 2a — migration 0010 + storage bucket | Done before lunch so DB work is unblocked |
| Mid-morning | 1.5h | Block 2c + 2d — camera + compositor + upload + UX | Bulk of Day 4 effort |
| Lunch | — | Test the photo flow on simulator | Surfaces UX nits cheaply |
| Afternoon 1 | 1h | Block 2 polish — gallery grid, fullscreen viewer, web fallback | |
| Afternoon 2 | 1h | Block 3 — TestFlight upload + first-device install | |
| **Total** | **~5h** | | |

---

## Open questions to resolve before starting

1. **Bundle id** — `app.virgil.cards` or something else?
2. **Apple Developer account** — confirm it's active and accessible
3. **Sound asset source** — record originals, license from a stock library, or generate via Bfxr/jsfxr? (last is fastest)
4. **Photo retention** — keep forever, or expire after 90 days? RLS implications either way.
5. **Storage bucket pricing** — Supabase free tier gives 1GB; at ~400KB/photo that's ~2,500 photos. Probably fine for v1.

## Not in scope for Day 4

- Shareable summary card (3d) — Day 5
- Game history screen (3e) — Day 5
- Memorable quotes (3g) — Day 5
- Confetti on win (2h) — Day 5
- Rank-change animation on leaderboard tab (2e) — gated on the cross-game leaderboard getting realtime updates; defer
- Deep linking (A3) — Day 5+ once we hit the friction again
- Google/Apple OAuth (A3) — Day 5+
- i18n EN/EL toggle (A3) — Day 5+
- Sentry error tracking (A3) — only after TestFlight users surface bugs we can't repro locally
