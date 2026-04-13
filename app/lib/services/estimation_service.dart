import 'dart:math';

import 'supabase_client.dart';

/// Thin client wrapper around the `estimation_*` tables. Writes go through
/// regular Supabase RLS — the authenticated user must be a participant.
class EstimationService {
  EstimationService();

  static const _codeAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'; // no I,L,O,0,1
  static final _rand = Random.secure();

  /// Generates a 4-char room code. Matches the `room_code text check
  /// (char_length(room_code) = 4)` constraint in `0002_estimation.sql`.
  String generateRoomCode() {
    return List.generate(4, (_) => _codeAlphabet[_rand.nextInt(_codeAlphabet.length)])
        .join();
  }

  /// Creates a new estimation game and seats the caller at seat 0.
  /// Returns the created `estimation_games.id`.
  Future<String> createGame({required int playerCount}) async {
    final client = SupabaseBootstrap.client;
    final userId = client.auth.currentUser!.id;

    // Retry on the (unlikely) chance of a room_code collision.
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = generateRoomCode();
      try {
        final game = await client
            .from('estimation_games')
            .insert({
              'room_code': code,
              'player_count': playerCount,
              'status': 'waiting',
              'phase': 'predicting',
            })
            .select('id')
            .single();

        final gameId = game['id'] as String;
        await client.from('estimation_players').insert({
          'game_id': gameId,
          'player_id': userId,
          'seat': 0,
        });
        return gameId;
      } on Object catch (e) {
        if (!e.toString().contains('room_code')) rethrow;
      }
    }
    throw StateError('Could not generate unique room code after 5 attempts');
  }

  /// Joins the caller into the game identified by [roomCode]. Returns the
  /// `estimation_games.id`. Throws if the game is full or already finished.
  Future<String> joinGameByCode(String roomCode) async {
    final client = SupabaseBootstrap.client;
    final userId = client.auth.currentUser!.id;
    final normalized = roomCode.toUpperCase().trim();

    final game = await client
        .from('estimation_games')
        .select('id, player_count, status')
        .eq('room_code', normalized)
        .maybeSingle();

    if (game == null) {
      throw StateError('Δεν βρέθηκε δωμάτιο με κωδικό $normalized');
    }
    if (game['status'] != 'waiting') {
      throw StateError('Το δωμάτιο έχει ήδη ξεκινήσει');
    }

    final gameId = game['id'] as String;
    final playerCount = game['player_count'] as int;

    final existing = await client
        .from('estimation_players')
        .select('seat')
        .eq('game_id', gameId);

    final taken = existing.map((r) => r['seat'] as int).toSet();
    if (taken.length >= playerCount) {
      throw StateError('Το δωμάτιο είναι γεμάτο');
    }
    // First free seat.
    var nextSeat = 0;
    while (taken.contains(nextSeat)) {
      nextSeat++;
    }

    await client.from('estimation_players').insert({
      'game_id': gameId,
      'player_id': userId,
      'seat': nextSeat,
    });

    return gameId;
  }
}
