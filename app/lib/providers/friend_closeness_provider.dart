import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/supabase_client.dart';
import 'auth_providers.dart';
import 'friends_providers.dart';

/// `friend_id → shared_games_in_last_30d` map for the caller's accepted
/// friends. Drives the deck §05 SCREEN 03 sort-by-closeness on the
/// Parea tab.
///
/// One round-trip via the `friend_closeness()` RPC (0015), which bypasses
/// the participants-only RLS on `estimation_players` and re-enforces the
/// friendship boundary internally. Re-runs whenever the accepted-friends
/// list changes; closeness drifts slowly otherwise (only finished games
/// add to it), so no periodic refresh is needed.
final friendClosenessProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const {};

  // Re-fetch when the friend list changes — accepting a new friend
  // should immediately give them a (likely 0) entry in the map.
  ref.watch(acceptedFriendsProvider);

  final rows =
      await SupabaseBootstrap.client.rpc<dynamic>('friend_closeness');
  if (rows is! List) return const {};
  return {
    for (final r in rows.cast<Map<String, dynamic>>())
      r['friend_id'] as String: (r['shared_games'] as num).toInt(),
  };
});
