import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';

/// The active app `Locale`, derived from the signed-in user's stored
/// preference (`players.locale` — set via the SegmentedButton on Profile).
///
/// Falls back to `el` for signed-out users and brand-new sign-ups whose
/// profile hasn't been hydrated yet, matching the default in
/// `PlayerProfile.fromJson` and the `handle_new_user` Postgres trigger.
///
/// MaterialApp watches this provider directly; flipping the segmented
/// toggle on Profile invalidates `currentPlayerProfileProvider`, which
/// propagates here within the same frame.
final activeLocaleProvider = Provider<Locale>((ref) {
  final profile = ref.watch(currentPlayerProfileProvider).valueOrNull;
  final code = profile?.locale ?? 'el';
  // Whitelist: anything else falls back to Greek so we never hit a
  // missing-translations crash on a malformed profile row.
  return code == 'en' ? const Locale('en') : const Locale('el');
});
