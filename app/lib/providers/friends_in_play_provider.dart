import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/friend_in_play.dart';
import '../services/supabase_client.dart';
import 'auth_providers.dart';
import 'friends_providers.dart';

/// Streams the caller's accepted friends who are sitting at an estimation
/// table right now (status `waiting` or `active`).
///
/// Why this is a polled stream rather than postgres_changes: the
/// `estimation_players` SELECT policy is participants-only (0002), so
/// realtime inserts on a friend's seat row would never reach this client.
/// The `friends_in_play()` RPC (0014) bypasses RLS via SECURITY DEFINER,
/// but RPC results aren't subscribable. A 30s tick is the cheapest path
/// that keeps "quiet presence" approximately fresh; the user reopening
/// the Lobby tab also retriggers the initial fetch.
///
/// Re-runs whenever the accepted-friends list changes too, so accepting
/// a friend who's already at a table surfaces them immediately.
final friendsInPlayProvider =
    StreamProvider<List<FriendInPlay>>((ref) async* {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    yield const [];
    return;
  }

  // Re-subscribe whenever the friend list changes. The value is unused;
  // watching is enough to trigger StreamProvider rebuild.
  ref.watch(acceptedFriendsProvider);

  Future<List<FriendInPlay>> fetch() async {
    final rows =
        await SupabaseBootstrap.client.rpc<dynamic>('friends_in_play');
    if (rows is! List) return const [];
    return rows
        .cast<Map<String, dynamic>>()
        .map(FriendInPlay.fromJson)
        .toList();
  }

  yield await fetch();
  await for (final _
      in Stream<void>.periodic(const Duration(seconds: 30))) {
    yield await fetch();
  }
});
