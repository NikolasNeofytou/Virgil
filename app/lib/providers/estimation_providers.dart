import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/estimation_game.dart';
import '../models/estimation_player.dart';
import '../models/estimation_round.dart';
import '../providers/auth_providers.dart';
import '../services/supabase_client.dart';

/// Currently active game id — set when entering the game screen.
final selectedGameIdProvider = StateProvider<String?>((ref) => null);

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
