import 'dart:developer' as developer;
import 'dart:math';

import 'supabase_client.dart';

/// Thin client wrapper around the `estimation_*` tables. Writes go through
/// regular Supabase RLS — the authenticated user must be a participant.
class EstimationService {
  EstimationService();

  static const _codeAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'; // no I,L,O,0,1
  static final _rand = Random.secure();

  /// Peer-confirmation threshold for trick winners & round validation.
  /// 2 players → both (unanimous). 3 players → all three (unanimous).
  /// 4 players → 3/4 (one player may dissent).
  static int confirmationThreshold(int playerCount) =>
      playerCount <= 3 ? playerCount : 3;

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

  /// Join-or-create a rematch game for a just-finished session.
  ///
  /// Either client can call this. The first one creates a new
  /// `estimation_games` row with `rematch_of = previousGameId` and seats
  /// themselves at their old seat. Every subsequent caller finds that row
  /// (via the unique `rematch_of` index) and seats themselves in it.
  ///
  /// Returns the rematch game id. The caller navigates to its lobby; the
  /// host taps Ξεκίνα when all seats are filled, which runs [startGame]
  /// as usual — re-drawing the short-straw dealer + starter.
  Future<String> rematchOrJoin(String previousGameId) async {
    final client = SupabaseBootstrap.client;
    final userId = client.auth.currentUser!.id;

    // Previous seating info — need this both for new-game creation and to
    // figure out my seat.
    final previous = await client
        .from('estimation_games')
        .select('player_count, status')
        .eq('id', previousGameId)
        .single();
    if (previous['status'] != 'finished') {
      throw StateError('Το προηγούμενο παιχνίδι δεν έχει τελειώσει');
    }
    final playerCount = previous['player_count'] as int;

    final mySeatRow = await client
        .from('estimation_players')
        .select('seat')
        .eq('game_id', previousGameId)
        .eq('player_id', userId)
        .single();
    final mySeat = mySeatRow['seat'] as int;

    // Is there already a rematch game for this previous one?
    final existing = await client
        .from('estimation_games')
        .select('id')
        .eq('rematch_of', previousGameId)
        .maybeSingle();
    if (existing != null) {
      final gameId = existing['id'] as String;
      // Seat me if not already there.
      final alreadySeated = await client
          .from('estimation_players')
          .select('id')
          .eq('game_id', gameId)
          .eq('player_id', userId)
          .maybeSingle();
      if (alreadySeated == null) {
        await client.from('estimation_players').insert({
          'game_id': gameId,
          'player_id': userId,
          'seat': mySeat,
        });
      }
      return gameId;
    }

    // First in — create the rematch game + seat myself.
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
              'rematch_of': previousGameId,
            })
            .select('id')
            .single();
        final gameId = game['id'] as String;
        await client.from('estimation_players').insert({
          'game_id': gameId,
          'player_id': userId,
          'seat': mySeat,
        });
        return gameId;
      } on Object catch (e) {
        final msg = e.toString();
        if (msg.contains('rematch_of')) {
          // Race — someone else beat us. Retry the lookup.
          final winner = await client
              .from('estimation_games')
              .select('id')
              .eq('rematch_of', previousGameId)
              .single();
          final gameId = winner['id'] as String;
          await client.from('estimation_players').insert({
            'game_id': gameId,
            'player_id': userId,
            'seat': mySeat,
          });
          return gameId;
        }
        if (!msg.contains('room_code')) rethrow;
      }
    }
    throw StateError('Could not create rematch after 5 attempts');
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

  /// Update the optional human-readable name for a game. Trimmed; null/empty
  /// clears it. Capped at 48 chars to match the DB check constraint.
  Future<void> updateSessionName({
    required String gameId,
    required String? name,
  }) async {
    final trimmed = name?.trim();
    final value = (trimmed == null || trimmed.isEmpty)
        ? null
        : (trimmed.length > 48 ? trimmed.substring(0, 48) : trimmed);
    await SupabaseBootstrap.client
        .from('estimation_games')
        .update({'session_name': value}).eq('id', gameId);
  }

  // ---------------------------------------------------------------------------
  // Gameplay loop — sequential bidding + per-trick tracking
  // ---------------------------------------------------------------------------

  /// Host kicks off the game: picks random round_starter + random dealer
  /// (independent short-straw draws), seats everyone for round 1, flips
  /// status to 'active'.
  ///
  /// Guarded with `status='waiting'` so double-taps from races don't re-roll
  /// the seats.
  Future<void> startGame({
    required String gameId,
    required int playerCount,
    required List<int> seats,
    required List<String> playerIds,
  }) async {
    final client = SupabaseBootstrap.client;
    final starter = seats[_rand.nextInt(seats.length)];
    final dealer = seats[_rand.nextInt(seats.length)];

    // IMPORTANT: insert round entries BEFORE flipping status to 'active'.
    // The realtime broadcast of the status change drives both clients to
    // navigate from the lobby to the game screen, and if round entries
    // aren't persisted yet the prediction UI has nothing to write to.
    await createRoundEntries(
      gameId: gameId,
      roundNumber: 1,
      cardsThisRound: 1,
      playerIds: playerIds,
    );

    // Conditional on status='waiting' so two racing hosts can't re-roll the
    // seats after a genuine start.
    await client
        .from('estimation_games')
        .update({
          'status': 'active',
          'phase': 'predicting',
          'current_round': 1,
          'current_trick_number': 1,
          'round_starter_seat': starter,
          'current_leader_seat': starter,
          'dealer_seat': dealer,
        })
        .eq('id', gameId)
        .eq('status', 'waiting');
  }

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
    developer.log(
      '[virgil] createRoundEntries game=$gameId round=$roundNumber '
      'rows=${rows.length} uid=${SupabaseBootstrap.client.auth.currentUser?.id}',
      name: 'estimation',
    );
    try {
      final result = await SupabaseBootstrap.client
          .from('estimation_rounds')
          .insert(rows)
          .select('id');
      developer.log(
        '[virgil] createRoundEntries inserted=${result.length}',
        name: 'estimation',
      );
    } on Object catch (e) {
      // Unique constraint violation means another client already created them.
      final msg = e.toString();
      final isDuplicate = msg.contains(
            'estimation_rounds_game_id_player_id_round_number_key',
          ) ||
          msg.contains('duplicate key');
      developer.log(
        '[virgil] createRoundEntries threw: $msg  duplicate=$isDuplicate',
        name: 'estimation',
        error: e,
      );
      if (!isDuplicate) rethrow;
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

  // ── Per-trick methods ──────────────────────────────────────────────────────

  /// Tap-to-propose a trick winner. Proposer implicitly confirms, so
  /// `confirmed_by_ids` starts as `[proposerId]`. Safe to call even if a
  /// proposal already exists — the caller overwrites it (e.g. to change
  /// their mind before anyone confirmed).
  Future<void> proposeTrickWinner({
    required String gameId,
    required int roundNumber,
    required int trickNumber,
    required int leaderSeat,
    required String winnerPlayerId,
  }) async {
    final client = SupabaseBootstrap.client;
    final userId = client.auth.currentUser!.id;

    await client.from('estimation_tricks').upsert({
      'game_id': gameId,
      'round_number': roundNumber,
      'trick_number': trickNumber,
      'leader_seat': leaderSeat,
      'proposed_winner_id': winnerPlayerId,
      'proposed_by_id': userId,
      'confirmed_by_ids': [userId],
      'winner_player_id': null,
    }, onConflict: 'game_id,round_number,trick_number',);
  }

  /// Append the current user to `confirmed_by_ids` for the pending proposal
  /// on [trickId]. Uses a guard on the proposal id so we safely drop the
  /// write if the proposal changed underneath.
  ///
  /// Returns the new length of `confirmed_by_ids`, or `null` if the row
  /// moved (caller can retry from a fresh read).
  Future<int?> confirmTrickWinner({
    required String trickId,
    required String proposedWinnerId,
    required List<String> currentConfirmedByIds,
  }) async {
    final client = SupabaseBootstrap.client;
    final userId = client.auth.currentUser!.id;
    if (currentConfirmedByIds.contains(userId)) {
      return currentConfirmedByIds.length;
    }
    final next = [...currentConfirmedByIds, userId];
    final rows = await client
        .from('estimation_tricks')
        .update({'confirmed_by_ids': next})
        .eq('id', trickId)
        .eq('proposed_winner_id', proposedWinnerId)
        .filter('winner_player_id', 'is', null)
        .select('id');
    if (rows.isEmpty) return null;
    return next.length;
  }

  /// Clear the pending proposal on a trick. Winners already locked in
  /// (winner_player_id not null) are untouched.
  Future<void> disputeTrickProposal({required String trickId}) async {
    await SupabaseBootstrap.client
        .from('estimation_tricks')
        .update({
          'proposed_winner_id': null,
          'proposed_by_id': null,
          'confirmed_by_ids': <String>[],
        })
        .eq('id', trickId)
        .filter('winner_player_id', 'is', null);
  }

  /// Promote a pending proposal to the confirmed winner and advance the
  /// game state. Should be called once the confirmation threshold has been
  /// reached (caller checks).
  ///
  /// If this trick is the last of the round, counts all trick wins per
  /// player, writes `actual_tricks` to `estimation_rounds`, and flips the
  /// phase to `validating`. Otherwise bumps `current_trick_number` and
  /// sets `current_leader_seat = winner's seat`.
  ///
  /// All writes are idempotent: guarded so two racing clients converge on
  /// the same outcome.
  Future<void> advanceTrick({
    required String gameId,
    required String trickId,
    required int roundNumber,
    required int trickNumber,
    required int cardsThisRound,
    required String winnerPlayerId,
    required int winnerSeat,
  }) async {
    final client = SupabaseBootstrap.client;

    // 1. Lock the winner on the trick row. Guard on winner_player_id IS NULL
    //    so only one racing caller succeeds.
    final locked = await client
        .from('estimation_tricks')
        .update({'winner_player_id': winnerPlayerId})
        .eq('id', trickId)
        .filter('winner_player_id', 'is', null)
        .select('id');
    if (locked.isEmpty) return; // someone else already locked

    final isLastTrick = trickNumber >= cardsThisRound;

    if (!isLastTrick) {
      // 2a. Advance to the next trick. Guarded so late calls don't
      //     overwrite a further-along state.
      await client
          .from('estimation_games')
          .update({
            'current_trick_number': trickNumber + 1,
            'current_leader_seat': winnerSeat,
          })
          .eq('id', gameId)
          .eq('current_round', roundNumber)
          .eq('current_trick_number', trickNumber);
      return;
    }

    // 2b. Last trick — compute actual_tricks per player and flip phase.
    final allTricks = await client
        .from('estimation_tricks')
        .select('winner_player_id')
        .eq('game_id', gameId)
        .eq('round_number', roundNumber)
        .not('winner_player_id', 'is', null);

    final counts = <String, int>{};
    for (final t in allTricks) {
      final w = t['winner_player_id'] as String;
      counts[w] = (counts[w] ?? 0) + 1;
    }

    // Fetch all players so we can zero-fill those who won no tricks.
    final players = await client
        .from('estimation_players')
        .select('player_id')
        .eq('game_id', gameId);
    for (final p in players) {
      final pid = p['player_id'] as String;
      counts.putIfAbsent(pid, () => 0);
    }

    for (final entry in counts.entries) {
      await client
          .from('estimation_rounds')
          .update({'actual_tricks': entry.value})
          .eq('game_id', gameId)
          .eq('player_id', entry.key)
          .eq('round_number', roundNumber);
    }

    await client
        .from('estimation_games')
        .update({'phase': 'validating'})
        .eq('id', gameId)
        .eq('phase', 'playing')
        .eq('current_round', roundNumber);
  }

  // ── Legacy submission path (unused by new flow, kept for backward compat) ──

  /// Transition playing → submitting. Any player can trigger.
  @Deprecated('Replaced by per-trick tracking. See advanceTrick.')
  Future<void> advanceToSubmitting({required String gameId}) async {
    await SupabaseBootstrap.client
        .from('estimation_games')
        .update({'phase': 'submitting'})
        .eq('id', gameId)
        .eq('phase', 'playing');
  }

  /// Submit how many tricks the current user actually won.
  @Deprecated('Replaced by per-trick tracking. See advanceTrick.')
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
  @Deprecated('actual_tricks is now computed by advanceTrick on last trick.')
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

  // ── Validation & round finalization ────────────────────────────────────────

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
  /// flags, reverts phase to playing so the table can re-enter the tricks.
  Future<void> disputeResult({
    required String gameId,
    required int roundNumber,
    required String disputedPlayerId,
  }) async {
    final client = SupabaseBootstrap.client;
    await client
        .from('estimation_rounds')
        .update({'actual_tricks': null, 'validated': false})
        .eq('game_id', gameId)
        .eq('player_id', disputedPlayerId)
        .eq('round_number', roundNumber);
    await client
        .from('estimation_rounds')
        .update({'validated': false})
        .eq('game_id', gameId)
        .eq('round_number', roundNumber);
    // Wipe the tricks for this round so the table re-plays them.
    await client
        .from('estimation_tricks')
        .delete()
        .eq('game_id', gameId)
        .eq('round_number', roundNumber);
    await client
        .from('estimation_games')
        .update({'phase': 'playing', 'current_trick_number': 1})
        .eq('id', gameId);
  }

  /// Calculate scores, update totals, rotate starter + dealer by +1 seat,
  /// advance to the next round or finish.
  Future<void> finalizeRound({
    required String gameId,
    required int currentRound,
    required int totalRounds,
    required int maxCards,
    required int playerCount,
    required int dealerSeat,
    required int roundStarterSeat,
    required List<Map<String, dynamic>> entries,
  }) async {
    final client = SupabaseBootstrap.client;

    // 1. Calculate and persist scores.
    for (final entry in entries) {
      final prediction = entry['prediction'] as int;
      final actual = entry['actual_tricks'] as int;
      final score = actual + (prediction == actual ? 10 : 0);
      final playerId = entry['player_id'] as String;
      final roundEntryId = entry['id'] as String;

      await client
          .from('estimation_rounds')
          .update({'score': score})
          .eq('id', roundEntryId);

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

    // 2. Advance round or finish.
    if (currentRound >= totalRounds) {
      // Pick the winner = highest total_score post-this-round. Ties broken
      // by earliest joined_at (deterministic across clients).
      final standings = await client
          .from('estimation_players')
          .select('player_id, total_score, joined_at')
          .eq('game_id', gameId)
          .order('total_score', ascending: false)
          .order('joined_at', ascending: true)
          .limit(1);
      final winnerId = standings.isNotEmpty
          ? standings.first['player_id'] as String
          : null;

      await client.from('estimation_games').update({
        'status': 'finished',
        'ended_at': DateTime.now().toUtc().toIso8601String(),
        if (winnerId != null) 'winner_player_id': winnerId,
      }).eq('id', gameId);
      return;
    }

    final nextRound = currentRound + 1;
    final nextDealer = (dealerSeat + 1) % playerCount;
    final nextStarter = (roundStarterSeat + 1) % playerCount;
    final nextCards = nextRound <= maxCards
        ? nextRound
        : 2 * maxCards - nextRound + 1;

    // Same ordering rule as startGame: materialize the next round's entries
    // before publishing the round advance via the games row, so clients
    // arriving on the new phase always find data to bind to.
    final playerIds = entries.map((e) => e['player_id'] as String).toList();
    await createRoundEntries(
      gameId: gameId,
      roundNumber: nextRound,
      cardsThisRound: nextCards,
      playerIds: playerIds,
    );

    await client.from('estimation_games').update({
      'current_round': nextRound,
      'dealer_seat': nextDealer,
      'round_starter_seat': nextStarter,
      'current_leader_seat': nextStarter,
      'current_trick_number': 1,
      'phase': 'predicting',
    }).eq('id', gameId);
  }
}
