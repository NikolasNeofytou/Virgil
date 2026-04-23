import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/supabase_client.dart';
import 'auth_providers.dart';

/// A minimal view of an unfinished game the current user is in. Returned by
/// [activeEstimationGameProvider] when the user has force-quit mid-game and
/// should be offered a "Συνέχισε παιχνίδι" card on the Play tab.
class ActiveGameSummary {
  const ActiveGameSummary({
    required this.gameId,
    required this.roomCode,
    required this.status,
    required this.currentRound,
    required this.totalRounds,
  });

  final String gameId;
  final String roomCode;
  final String status; // waiting | active
  final int currentRound;
  final int totalRounds;

  bool get isInLobby => status == 'waiting';
  bool get isInGame => status == 'active';
}

/// The current user's most recent non-finished game. Resolves to null if
/// they have no game in progress. Cheap single-query call.
final activeEstimationGameProvider =
    FutureProvider<ActiveGameSummary?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  final client = SupabaseBootstrap.client;

  // My seat rows, newest first.
  final mine = await client
      .from('estimation_players')
      .select('game_id, joined_at')
      .eq('player_id', userId)
      .order('joined_at', ascending: false);
  if (mine.isEmpty) return null;

  final gameIds = mine.map((r) => r['game_id'] as String).toList();

  // Pick the most recent non-finished game.
  final games = await client
      .from('estimation_games')
      .select('id, room_code, status, current_round, total_rounds, created_at')
      .inFilter('id', gameIds)
      .neq('status', 'finished')
      .order('created_at', ascending: false)
      .limit(1);
  if (games.isEmpty) return null;

  final g = games.first;
  return ActiveGameSummary(
    gameId: g['id'] as String,
    roomCode: g['room_code'] as String,
    status: g['status'] as String,
    currentRound: (g['current_round'] as int?) ?? 1,
    totalRounds: (g['total_rounds'] as int?) ?? 14,
  );
});
