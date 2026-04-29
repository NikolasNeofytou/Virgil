import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/leaderboard_entry.dart';
import '../services/last_seen_leaderboard.dart';
import '../services/supabase_client.dart';
import 'auth_providers.dart';

/// Top 50 stats rows (we render 10, but fetch 50 so we can also resolve "your
/// rank" in a single roundtrip). Sorted by wins desc, then lifetime points
/// desc as tiebreaker.
final leaderboardProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) async {
  // Reactively re-fetch when auth changes (so a freshly signed-in user sees
  // their highlight).
  ref.watch(currentUserIdProvider);
  final rows = await SupabaseBootstrap.client
      .from('estimation_stats')
      .select()
      .order('wins', ascending: false)
      .order('lifetime_points', ascending: false)
      .limit(50);
  return rows.map(LeaderboardEntry.fromJson).toList();
});

/// The current user's stats row, derived from [leaderboardProvider]. Null if
/// the user hasn't finished any games yet.
final myStatsProvider = Provider<LeaderboardEntry?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final list = ref.watch(leaderboardProvider).valueOrNull;
  if (userId == null || list == null) return null;
  try {
    return list.firstWhere((s) => s.playerId == userId);
  } catch (_) {
    return null;
  }
});

/// 1-indexed rank of the current user within the top 50, or null if not in
/// the top 50 (or if they have no stats row yet).
final myRankProvider = Provider<int?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final list = ref.watch(leaderboardProvider).valueOrNull;
  if (userId == null || list == null) return null;
  final idx = list.indexWhere((s) => s.playerId == userId);
  return idx == -1 ? null : idx + 1;
});

/// Service-instance provider — overrideable in tests to inject a fake
/// `SharedPreferences`. Default delegates to the platform.
final lastSeenLeaderboardServiceProvider =
    Provider<LastSeenLeaderboardService>((ref) {
  return LastSeenLeaderboardService();
});

/// playerId → 1-indexed rank of the previous leaderboard visit. Loaded
/// once on first read; subsequent reads return the cached snapshot. The
/// leaderboard tab calls `[lastSeenLeaderboardServiceProvider].save()`
/// directly to write — we deliberately don't expose a setter on this
/// provider so saves don't accidentally invalidate the cached value
/// mid-session (we want deltas computed against the snapshot at *mount*).
final lastSeenLeaderboardRanksProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(lastSeenLeaderboardServiceProvider);
  return service.load();
});
