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
        .select('seat, player_id')
        .eq('game_id', gameId);

    // If user is already in this game, just return the gameId (re-join).
    final alreadyIn = existing.any((r) => r['player_id'] == userId);
    if (alreadyIn) return gameId;

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

  // ---------------------------------------------------------------------------
  // A2: Gameplay loop methods
  // ---------------------------------------------------------------------------

  /// Inserts one `estimation_rounds` row per player for the given round.
  /// Called when a new round begins (by the client that advances the round).
  Future<void> createRoundEntries({
    required String gameId,
    required int roundNumber,
    required int cardsThisRound,
    required List<String> playerIds,
  }) async {
    final rows = playerIds
        .map((pid) => {
              'game_id': gameId,
              'player_id': pid,
              'round_number': roundNumber,
              'cards_this_round': cardsThisRound,
            },)
        .toList();
    try {
      await SupabaseBootstrap.client.from('estimation_rounds').insert(rows);
    } on Object catch (e) {
      // Unique constraint violation means another client already created them.
      if (!e.toString().contains('estimation_rounds_game_id_player_id_round_number_key')) {
        rethrow;
      }
    }
  }

  /// Lock in the current user's prediction for a round.
  Future<void> submitPrediction({
    required String gameId,
    required int roundNumber,
    required int prediction,
  }) async {
    final userId = SupabaseBootstrap.client.auth.currentUser!.id;
    await SupabaseBootstrap.client
        .from('estimation_rounds')
        .update({'prediction': prediction})
        .eq('game_id', gameId)
        .eq('player_id', userId)
        .eq('round_number', roundNumber);
  }

  /// Transition predicting → playing. Conditional to prevent races.
  Future<void> advanceToPlaying({
    required String gameId,
    required int roundNumber,
  }) async {
    await SupabaseBootstrap.client
        .from('estimation_games')
        .update({'phase': 'playing'})
        .eq('id', gameId)
        .eq('phase', 'predicting')
        .eq('current_round', roundNumber);
  }

  /// Transition playing → submitting. Any player can trigger.
  Future<void> advanceToSubmitting({required String gameId}) async {
    await SupabaseBootstrap.client
        .from('estimation_games')
        .update({'phase': 'submitting'})
        .eq('id', gameId)
        .eq('phase', 'playing');
  }

  /// Submit how many tricks the current user actually won.
  Future<void> submitActualTricks({
    required String gameId,
    required int roundNumber,
    required int actualTricks,
  }) async {
    final userId = SupabaseBootstrap.client.auth.currentUser!.id;
    await SupabaseBootstrap.client
        .from('estimation_rounds')
        .update({'actual_tricks': actualTricks})
        .eq('game_id', gameId)
        .eq('player_id', userId)
        .eq('round_number', roundNumber);
  }

  /// Transition submitting → validating. Conditional to prevent races.
  Future<void> advanceToValidating({
    required String gameId,
    required int roundNumber,
  }) async {
    await SupabaseBootstrap.client
        .from('estimation_games')
        .update({'phase': 'validating'})
        .eq('id', gameId)
        .eq('phase', 'submitting')
        .eq('current_round', roundNumber);
  }

  /// Current user confirms the round results.
  Future<void> confirmRound({
    required String gameId,
    required int roundNumber,
  }) async {
    final userId = SupabaseBootstrap.client.auth.currentUser!.id;
    await SupabaseBootstrap.client
        .from('estimation_rounds')
        .update({'validated': true})
        .eq('game_id', gameId)
        .eq('player_id', userId)
        .eq('round_number', roundNumber);
  }

  /// Dispute a player's result. Nulls their tricks, resets all validated
  /// flags, reverts phase to submitting.
  Future<void> disputeResult({
    required String gameId,
    required int roundNumber,
    required String disputedPlayerId,
  }) async {
    final client = SupabaseBootstrap.client;
    // Null the disputed player's actual_tricks.
    await client
        .from('estimation_rounds')
        .update({'actual_tricks': null, 'validated': false})
        .eq('game_id', gameId)
        .eq('player_id', disputedPlayerId)
        .eq('round_number', roundNumber);
    // Reset everyone's validated flag.
    await client
        .from('estimation_rounds')
        .update({'validated': false})
        .eq('game_id', gameId)
        .eq('round_number', roundNumber);
    // Revert phase.
    await client
        .from('estimation_games')
        .update({'phase': 'submitting'})
        .eq('id', gameId);
  }

  /// Calculate scores, update totals, advance to next round or finish.
  Future<void> finalizeRound({
    required String gameId,
    required int currentRound,
    required int totalRounds,
    required int maxCards,
    required int playerCount,
    required int dealerSeat,
    required List<Map<String, dynamic>> entries,
  }) async {
    final client = SupabaseBootstrap.client;

    // 1. Calculate and persist scores for each player.
    for (final entry in entries) {
      final prediction = entry['prediction'] as int;
      final actual = entry['actual_tricks'] as int;
      final score = actual + (prediction == actual ? 10 : 0);
      final playerId = entry['player_id'] as String;
      final roundEntryId = entry['id'] as String;

      // Update the round entry score.
      await client
          .from('estimation_rounds')
          .update({'score': score})
          .eq('id', roundEntryId);

      // Add to running total.
      final playerRow = await client
          .from('estimation_players')
          .select('total_score')
          .eq('game_id', gameId)
          .eq('player_id', playerId)
          .single();
      final newTotal = (playerRow['total_score'] as int) + score;
      await client
          .from('estimation_players')
          .update({'total_score': newTotal})
          .eq('game_id', gameId)
          .eq('player_id', playerId);
    }

    // 2. Advance round or finish game.
    if (currentRound >= totalRounds) {
      await client
          .from('estimation_games')
          .update({'status': 'finished'})
          .eq('id', gameId);
    } else {
      final nextRound = currentRound + 1;
      final nextDealer = (dealerSeat + 1) % playerCount;
      await client.from('estimation_games').update({
        'current_round': nextRound,
        'dealer_seat': nextDealer,
        'phase': 'predicting',
      }).eq('id', gameId);

      // Create entries for the next round.
      final nextCards =
          nextRound <= maxCards ? nextRound : 2 * maxCards - nextRound;
      final playerIds = entries.map((e) => e['player_id'] as String).toList();
      await createRoundEntries(
        gameId: gameId,
        roundNumber: nextRound,
        cardsThisRound: nextCards,
        playerIds: playerIds,
      );
    }
  }
}
