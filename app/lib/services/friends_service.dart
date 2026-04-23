import 'supabase_client.dart';

/// Thin wrapper around the `friendships` table. RLS guards every write
/// (requester-only insert, either-party update/delete) so the service just
/// shapes the calls.
class FriendsService {
  FriendsService();

  /// Send a friend request to the player with [targetUsername].
  ///
  /// Throws `FriendsException` with a human-readable Greek message on the
  /// expected failure modes:
  ///   * username not found
  ///   * requesting self
  ///   * friendship already exists in either direction
  Future<void> sendFriendRequest(String targetUsername) async {
    final client = SupabaseBootstrap.client;
    final me = client.auth.currentUser?.id;
    if (me == null) throw FriendsException('δεν είσαι συνδεδεμένος');

    final normalized = targetUsername.trim();
    if (normalized.isEmpty) {
      throw FriendsException('δώσε ένα όνομα');
    }

    // Look up target by username.
    final target = await client
        .from('players')
        .select('id, username')
        .eq('username', normalized)
        .maybeSingle();
    if (target == null) {
      throw FriendsException('δεν βρέθηκε');
    }
    final targetId = target['id'] as String;
    if (targetId == me) {
      throw FriendsException('δεν μπορείς να προσθέσεις τον εαυτό σου');
    }

    // Check for existing friendship in either direction.
    final existing = await client
        .from('friendships')
        .select('id, status, requester_id, addressee_id')
        .or(
          'and(requester_id.eq.$me,addressee_id.eq.$targetId),'
          'and(requester_id.eq.$targetId,addressee_id.eq.$me)',
        );
    if (existing.isNotEmpty) {
      final row = existing.first;
      final status = row['status'] as String;
      if (status == 'accepted') {
        throw FriendsException('είστε ήδη φίλοι');
      }
      if (status == 'pending') {
        throw FriendsException('υπάρχει ήδη αίτηση');
      }
      if (status == 'blocked') {
        throw FriendsException('ο χρήστης δεν είναι διαθέσιμος');
      }
    }

    await client.from('friendships').insert({
      'requester_id': me,
      'addressee_id': targetId,
      'status': 'pending',
    });
  }

  /// Addressee accepts an inbound pending request.
  Future<void> acceptRequest(String friendshipId) async {
    await SupabaseBootstrap.client
        .from('friendships')
        .update({'status': 'accepted'})
        .eq('id', friendshipId)
        .eq('status', 'pending');
  }

  /// Addressee declines an inbound pending request (deletes the row so a
  /// fresh request can be sent later).
  Future<void> declineRequest(String friendshipId) async {
    await SupabaseBootstrap.client
        .from('friendships')
        .delete()
        .eq('id', friendshipId);
  }

  /// Requester cancels an outbound pending request they sent.
  Future<void> cancelRequest(String friendshipId) async {
    await SupabaseBootstrap.client
        .from('friendships')
        .delete()
        .eq('id', friendshipId);
  }

  /// Either party unfriends an accepted friendship.
  Future<void> removeFriend(String friendshipId) async {
    await SupabaseBootstrap.client
        .from('friendships')
        .delete()
        .eq('id', friendshipId);
  }
}

/// Raised for the handful of expected friends-flow failures. Contains a
/// message safe to surface to the user (Greek, lower-cased, kafeneio voice).
class FriendsException implements Exception {
  FriendsException(this.message);
  final String message;
  @override
  String toString() => message;
}
