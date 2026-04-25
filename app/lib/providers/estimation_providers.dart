import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_awards_calculator.dart';
import '../models/estimation_game.dart';
import '../models/estimation_player.dart';
import '../models/estimation_round.dart';
import '../models/estimation_trick.dart';
import '../models/game_award.dart';
import '../models/live_player_stats.dart';
import '../providers/auth_providers.dart';
import '../services/supabase_client.dart';

/// Currently active game id — set when entering the game screen.
final selectedGameIdProvider = StateProvider<String?>((ref) => null);

/// Has this device already watched the round-1 dealer reveal for the given
/// game? Session-scoped (resets on app relaunch, which is fine — if the
/// dealer is still unknown when the user re-enters, they'd want to see it).
final dealerRevealDismissedProvider =
    StateProvider.family<bool, String>((ref, gameId) => false);

/// Streams the estimation_games row for the selected game.
final estimationGameStreamProvider =
    StreamProvider.family<EstimationGame?, String>((ref, gameId) {
  return SupabaseBootstrap.client
      .from('estimation_games')
      .stream(primaryKey: ['id'])
      .eq('id', gameId)
      .map((rows) =>
          rows.isEmpty ? null : EstimationGame.fromJson(rows.first),);
});

/// Streams all players in a game, ordered by seat.
final estimationPlayersStreamProvider =
    StreamProvider.family<List<EstimationPlayer>, String>((ref, gameId) {
  return SupabaseBootstrap.client
      .from('estimation_players')
      .stream(primaryKey: ['id'])
      .eq('game_id', gameId)
      .order('seat')
      .map((rows) => rows.map(EstimationPlayer.fromJson).toList());
});

/// Streams ALL estimation_rounds for a game. Filtered client-side per round.
final allRoundsStreamProvider =
    StreamProvider.family<List<EstimationRound>, String>((ref, gameId) {
  return SupabaseBootstrap.client
      .from('estimation_rounds')
      .stream(primaryKey: ['id'])
      .eq('game_id', gameId)
      .map((rows) => rows.map(EstimationRound.fromJson).toList());
});

/// Entries for the current round only.
final activeRoundEntriesProvider =
    Provider.family<List<EstimationRound>, String>((ref, gameId) {
  final game = ref.watch(estimationGameStreamProvider(gameId)).valueOrNull;
  final allRounds = ref.watch(allRoundsStreamProvider(gameId)).valueOrNull;
  if (game == null || allRounds == null) return [];
  return allRounds
      .where((r) => r.roundNumber == game.currentRound)
      .toList();
});

/// Current user's round entry for this round. Null if not yet created.
final myRoundEntryProvider =
    Provider.family<EstimationRound?, String>((ref, gameId) {
  final userId = ref.watch(currentUserIdProvider);
  final entries = ref.watch(activeRoundEntriesProvider(gameId));
  if (userId == null || entries.isEmpty) return null;
  try {
    return entries.firstWhere((e) => e.playerId == userId);
  } catch (_) {
    return null;
  }
});

/// True when all players have locked their predictions for this round.
final allPredictionsLockedProvider =
    Provider.family<bool, String>((ref, gameId) {
  final game = ref.watch(estimationGameStreamProvider(gameId)).valueOrNull;
  final entries = ref.watch(activeRoundEntriesProvider(gameId));
  if (game == null || entries.isEmpty) return false;
  return entries.length == game.playerCount &&
      entries.every((e) => e.hasLockedPrediction);
});

/// True when all players have submitted their actual tricks.
final allTricksSubmittedProvider =
    Provider.family<bool, String>((ref, gameId) {
  final game = ref.watch(estimationGameStreamProvider(gameId)).valueOrNull;
  final entries = ref.watch(activeRoundEntriesProvider(gameId));
  if (game == null || entries.isEmpty) return false;
  return entries.length == game.playerCount &&
      entries.every((e) => e.hasSubmittedTricks);
});

/// True when all tricks submitted AND sum equals cards this round.
final tricksSanityCheckProvider =
    Provider.family<bool, String>((ref, gameId) {
  final game = ref.watch(estimationGameStreamProvider(gameId)).valueOrNull;
  final allSubmitted = ref.watch(allTricksSubmittedProvider(gameId));
  if (game == null || !allSubmitted) return false;
  final entries = ref.watch(activeRoundEntriesProvider(gameId));
  final sum = entries.fold<int>(0, (s, e) => s + (e.actualTricks ?? 0));
  return sum == game.cardsThisRound;
});

/// Sum of actual tricks submitted so far (even if incomplete).
final tricksSubmittedSumProvider =
    Provider.family<int, String>((ref, gameId) {
  final entries = ref.watch(activeRoundEntriesProvider(gameId));
  return entries.fold<int>(0, (s, e) => s + (e.actualTricks ?? 0));
});

/// Count of players who have confirmed (validated == true) this round.
final validationCountProvider =
    Provider.family<int, String>((ref, gameId) {
  final entries = ref.watch(activeRoundEntriesProvider(gameId));
  return entries.where((e) => e.validated).length;
});

/// Required confirmations: 3/4 for 4 players, unanimous for 2-3.
final validationThresholdProvider =
    Provider.family<int, String>((ref, gameId) {
  final game = ref.watch(estimationGameStreamProvider(gameId)).valueOrNull;
  if (game == null) return 0;
  return game.playerCount == 4 ? 3 : game.playerCount;
});

// ── Sequential bidding providers ─────────────────────────────────────────────

/// Seats in bid order for the current round — starter first, then clockwise
/// through every seat once. Empty until [EstimationGame.roundStarterSeat] is
/// set (happens at game start).
final bidOrderProvider = Provider.family<List<int>, String>((ref, gameId) {
  final game = ref.watch(estimationGameStreamProvider(gameId)).valueOrNull;
  return game?.bidOrder ?? const [];
});

/// The seat whose turn it is to bid right now. `-1` if every seat has
/// already locked a prediction (or the game isn't ready yet).
final currentBidderSeatProvider =
    Provider.family<int, String>((ref, gameId) {
  final order = ref.watch(bidOrderProvider(gameId));
  final entries = ref.watch(activeRoundEntriesProvider(gameId));
  final players =
      ref.watch(estimationPlayersStreamProvider(gameId)).valueOrNull ?? [];
  if (order.isEmpty || players.isEmpty) return -1;
  final seatToEntry = {
    for (final p in players)
      p.seat: entries.firstWhere(
        (e) => e.playerId == p.playerId,
        orElse: () => const EstimationRound(
          id: '',
          gameId: '',
          playerId: '',
          roundNumber: 0,
          cardsThisRound: 0,
          validated: false,
        ),
      ),
  };
  for (final seat in order) {
    final entry = seatToEntry[seat];
    if (entry == null || entry.prediction == null) return seat;
  }
  return -1;
});

/// My seat in this game, or -1 if I'm not a participant (shouldn't happen).
final mySeatProvider = Provider.family<int, String>((ref, gameId) {
  final userId = ref.watch(currentUserIdProvider);
  final players =
      ref.watch(estimationPlayersStreamProvider(gameId)).valueOrNull ?? [];
  if (userId == null) return -1;
  final me = players.where((p) => p.playerId == userId);
  return me.isEmpty ? -1 : me.first.seat;
});

/// Convenience: is it my turn to bid?
final isMyTurnToBidProvider = Provider.family<bool, String>((ref, gameId) {
  final mySeat = ref.watch(mySeatProvider(gameId));
  final current = ref.watch(currentBidderSeatProvider(gameId));
  return mySeat >= 0 && mySeat == current;
});

// ── Per-trick providers ──────────────────────────────────────────────────────

/// Stream of every [EstimationTrick] for a game. Filtered client-side per
/// round to match how `estimation_rounds` is used.
final allTricksStreamProvider =
    StreamProvider.family<List<EstimationTrick>, String>((ref, gameId) {
  return SupabaseBootstrap.client
      .from('estimation_tricks')
      .stream(primaryKey: ['id'])
      .eq('game_id', gameId)
      .map((rows) => rows.map(EstimationTrick.fromJson).toList());
});

/// Tricks for the active round, sorted by trick_number.
final activeRoundTricksProvider =
    Provider.family<List<EstimationTrick>, String>((ref, gameId) {
  final game = ref.watch(estimationGameStreamProvider(gameId)).valueOrNull;
  final all = ref.watch(allTricksStreamProvider(gameId)).valueOrNull;
  if (game == null || all == null) return const [];
  final filtered = all
      .where((t) => t.roundNumber == game.currentRound)
      .toList()
    ..sort((a, b) => a.trickNumber.compareTo(b.trickNumber));
  return filtered;
});

/// The row representing the currently active trick. `null` if none has been
/// proposed yet (anyone can tap a winner to create one).
final currentTrickProvider =
    Provider.family<EstimationTrick?, String>((ref, gameId) {
  final game = ref.watch(estimationGameStreamProvider(gameId)).valueOrNull;
  final tricks = ref.watch(activeRoundTricksProvider(gameId));
  if (game == null) return null;
  try {
    return tricks.firstWhere(
      (t) => t.trickNumber == game.currentTrickNumber,
    );
  } catch (_) {
    return null;
  }
});

/// Tricks already confirmed this round — for the "past tricks" strip.
final pastTricksProvider =
    Provider.family<List<EstimationTrick>, String>((ref, gameId) {
  final tricks = ref.watch(activeRoundTricksProvider(gameId));
  return tricks.where((t) => t.isConfirmed).toList();
});

/// Fetches player_id → username map for all players in the game.
final playerUsernamesProvider =
    FutureProvider.family<Map<String, String>, String>((ref, gameId) async {
  final players =
      ref.watch(estimationPlayersStreamProvider(gameId)).valueOrNull;
  if (players == null || players.isEmpty) return {};
  final ids = players.map((p) => p.playerId).toList();
  final rows = await SupabaseBootstrap.client
      .from('players')
      .select('id, username')
      .inFilter('id', ids);
  return {for (final r in rows) r['id'] as String: r['username'] as String};
});

// ── Day 3 additions: awards + live scoreboard ────────────────────────────────

/// Awards earned in a finished estimation game. Empty list while data is
/// loading or the game isn't finished yet.
final gameAwardsProvider =
    Provider.family<List<GameAward>, String>((ref, gameId) {
  final game = ref.watch(estimationGameStreamProvider(gameId)).valueOrNull;
  final players =
      ref.watch(estimationPlayersStreamProvider(gameId)).valueOrNull;
  final rounds = ref.watch(allRoundsStreamProvider(gameId)).valueOrNull;
  final usernames = ref.watch(playerUsernamesProvider(gameId)).valueOrNull;

  if (game == null ||
      players == null ||
      rounds == null ||
      usernames == null ||
      players.isEmpty ||
      rounds.isEmpty) {
    return const [];
  }
  // Final standings — pick the highest scorer as winner (matches what
  // finalizeRound() persists). Tiebreaker: earliest joined_at.
  final sorted = [...players]
    ..sort((a, b) {
      final byScore = b.totalScore.compareTo(a.totalScore);
      if (byScore != 0) return byScore;
      return a.joinedAt.compareTo(b.joinedAt);
    });
  final winnerId = sorted.first.playerId;
  final finalScores = {
    for (final p in players) p.playerId: p.totalScore,
  };
  return GameAwardsCalculator.compute(
    rounds: rounds,
    usernames: usernames,
    winnerId: winnerId,
    finalScores: finalScores,
  );
});

/// Live aggregate per-player stats for the in-game scoreboard sheet. Sorted
/// by `total_score` desc; ties broken by earliest `joined_at`.
final liveScoreboardProvider =
    Provider.family<List<LivePlayerStats>, String>((ref, gameId) {
  final players =
      ref.watch(estimationPlayersStreamProvider(gameId)).valueOrNull;
  final rounds = ref.watch(allRoundsStreamProvider(gameId)).valueOrNull;
  final usernames = ref.watch(playerUsernamesProvider(gameId)).valueOrNull;

  if (players == null || rounds == null || usernames == null) return const [];

  final sortedPlayers = [...players]
    ..sort((a, b) {
      final byScore = b.totalScore.compareTo(a.totalScore);
      if (byScore != 0) return byScore;
      return a.joinedAt.compareTo(b.joinedAt);
    });

  return sortedPlayers.map((p) {
    final mine = rounds.where((r) => r.playerId == p.playerId).toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    var hits = 0;
    var attempts = 0;
    var cumulative = 0;
    final cumByRound = <int, int>{};
    for (final r in mine) {
      if (r.prediction != null && r.actualTricks != null) {
        attempts++;
        if (r.prediction == r.actualTricks) hits++;
      }
      if (r.score != null) {
        cumulative += r.score!;
        cumByRound[r.roundNumber] = cumulative;
      }
    }
    return LivePlayerStats(
      playerId: p.playerId,
      username: usernames[p.playerId] ?? '???',
      totalScore: p.totalScore,
      accuracyHits: hits,
      accuracyAttempts: attempts,
      cumulativeByRound: cumByRound,
    );
  }).toList();
});
