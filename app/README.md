# Tichu Cyprus — Flutter App

Mobile client for Tichu Cyprus. iOS + Android, built with Flutter + Flame + Riverpod.

## Directory Layout

```
lib/
├── main.dart            App entry point
├── app.dart             Root widget, theme, routing
├── game/                Flame game engine code (Phase B)
├── screens/             Top-level screens (Play, Friends, Leaderboard, Profile)
├── providers/           Riverpod providers (state management)
├── services/            Supabase, WebSocket, FCM clients
├── models/              Data models (freezed)
├── theme/               Dark theme, colors, typography (Balatro-inspired)
└── l10n/                Localization (Greek default, English)
```

## Prerequisites

- Flutter SDK 3.x (Dart 3.x)
- Xcode (for iOS) / Android Studio (for Android)
- A Supabase project (URL + anon key) — see `../supabase/README.md`

## First-Time Setup

```bash
flutter pub get
cp .env.example .env   # fill in SUPABASE_URL and SUPABASE_ANON_KEY
flutter run
```

## State Management

Riverpod — compile-time safe, provider scoping. See `lib/providers/`.

## Theme

Dark rich backgrounds, glass-morphic UI panels, gold/amber accents. See `lib/theme/`.
