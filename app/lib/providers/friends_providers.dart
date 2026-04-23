import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/friendship.dart';
import '../services/supabase_client.dart';
import 'auth_providers.dart';

/// Streams every `friendships` row I can see. RLS already limits this to
/// rows where I'm either requester or addressee, so no extra filter needed.
final friendshipsStreamProvider =
    StreamProvider<List<Friendship>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(const []);
  return SupabaseBootstrap.client
      .from('friendships')
      .stream(primaryKey: ['id'])
      .map((rows) => rows.map(Friendship.fromJson).toList());
});

/// Accepted friendships involving me.
final acceptedFriendsProvider = Provider<List<Friendship>>((ref) {
  final rows = ref.watch(friendshipsStreamProvider).valueOrNull ?? const [];
  return rows.where((f) => f.isAccepted).toList();
});

/// Pending requests addressed *to* me — my inbox.
final inboundPendingProvider = Provider<List<Friendship>>((ref) {
  final me = ref.watch(currentUserIdProvider);
  final rows = ref.watch(friendshipsStreamProvider).valueOrNull ?? const [];
  if (me == null) return const [];
  return rows.where((f) => f.isPending && f.addresseeId == me).toList();
});

/// Pending requests *I* sent — my outbox.
final outboundPendingProvider = Provider<List<Friendship>>((ref) {
  final me = ref.watch(currentUserIdProvider);
  final rows = ref.watch(friendshipsStreamProvider).valueOrNull ?? const [];
  if (me == null) return const [];
  return rows.where((f) => f.isPending && f.requesterId == me).toList();
});

/// All player ids involved in any of my friendships (the "other" side of
/// each row). We batch-fetch usernames for these into
/// [friendUsernamesProvider] so the UI can render names instead of UUIDs.
final _friendOtherPartyIdsProvider = Provider<List<String>>((ref) {
  final me = ref.watch(currentUserIdProvider);
  final rows = ref.watch(friendshipsStreamProvider).valueOrNull ?? const [];
  if (me == null) return const [];
  final ids = <String>{};
  for (final f in rows) {
    ids.add(f.otherParty(me));
  }
  return ids.toList();
});

/// player_id → username lookup for everyone I have any friendship with.
/// Refetched whenever the friendship list changes.
final friendUsernamesProvider =
    FutureProvider<Map<String, String>>((ref) async {
  final ids = ref.watch(_friendOtherPartyIdsProvider);
  if (ids.isEmpty) return const {};
  final rows = await SupabaseBootstrap.client
      .from('players')
      .select('id, username')
      .inFilter('id', ids);
  return {for (final r in rows) r['id'] as String: r['username'] as String};
});
