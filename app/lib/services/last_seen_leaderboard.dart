import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Per-device snapshot of the cross-game leaderboard ranks the current user
/// last viewed. Used by the leaderboard tab to render ↑/↓ delta chips next
/// to each row — "you went up two spots since last visit."
///
/// Stored as a JSON-encoded `Map<String, int>` (playerId → 1-indexed rank)
/// in `SharedPreferences`. Tiny, no schema, no migration cost. We read on
/// tab mount, compute deltas against current ranks, then persist the new
/// snapshot once the page paints so the next visit's deltas are fresh.
class LastSeenLeaderboardService {
  LastSeenLeaderboardService({SharedPreferences? prefs}) : _override = prefs;

  static const _key = 'last_seen_leaderboard_ranks_v1';

  /// Optional override for tests — when null we resolve via
  /// `SharedPreferences.getInstance()` lazily on first call.
  final SharedPreferences? _override;

  Future<SharedPreferences> _prefs() async =>
      _override ?? await SharedPreferences.getInstance();

  /// Returns the playerId → rank map persisted from the previous visit, or
  /// an empty map if this is the first visit (or storage was wiped).
  Future<Map<String, int>> load() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries)
          entry.key: (entry.value as num).toInt(),
      };
    } on Object {
      // Corrupt payload — wipe and start fresh.
      await prefs.remove(_key);
      return const {};
    }
  }

  /// Persists [ranks] as the latest snapshot. Caller passes a map of
  /// playerId → 1-indexed rank covering the rows currently on screen.
  Future<void> save(Map<String, int> ranks) async {
    final prefs = await _prefs();
    await prefs.setString(_key, jsonEncode(ranks));
  }
}
