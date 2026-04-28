import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/supabase_client.dart';
import 'auth_providers.dart';

/// One row in the Profile → "Τα παιχνίδια μου" history list. Aggregated
/// client-side from `estimation_games` + `estimation_players` so we have the
/// winner's name and the user's rank ready to render without a second
/// round-trip per row.
class PastGameSummary {
  const PastGameSummary({
    required this.gameId,
    required this.playerCount,
    required this.sessionName,
    required this.createdAt,
    required this.endedAt,
    required this.winnerPlayerId,
    required this.winnerUsername,
    required this.myScore,
    required this.myRank,
    required this.isWin,
  });

  final String gameId;
  final int playerCount;
  final String? sessionName;
  final DateTime createdAt;

  /// Null for legacy games finished before migration 0009 added the column.
  final DateTime? endedAt;

  final String winnerPlayerId;
  final String winnerUsername;
  final int myScore;

  /// 1-based rank for the signed-in user in this game.
  final int myRank;
  final bool isWin;

  /// Sortable timestamp — falls back to [createdAt] for legacy rows.
  DateTime get sortDate => endedAt ?? createdAt;
}

/// Every finished estimation game the signed-in user took part in, newest
/// first. Empty when the user is signed out or has no finished games.
final pastEstimationGamesProvider =
    FutureProvider<List<PastGameSummary>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];
  final client = SupabaseBootstrap.client;

  final mineRaw = await client
      .from('estimation_players')
      .select('game_id, total_score')
      .eq('player_id', userId);
  if (mineRaw.isEmpty) return const [];

  final myGameIds = mineRaw.map((r) => r['game_id'] as String).toList();
  final myScoreByGame = <String, int>{
    for (final r in mineRaw)
      r['game_id'] as String: (r['total_score'] as int? ?? 0),
  };

  final gamesRaw = await client
      .from('estimation_games')
      .select(
        'id, player_count, session_name, created_at, ended_at, winner_player_id',
      )
      .inFilter('id', myGameIds)
      .eq('status', 'finished');
  if (gamesRaw.isEmpty) return const [];

  final finishedIds = gamesRaw.map((r) => r['id'] as String).toList();

  final allPlayersRaw = await client
      .from('estimation_players')
      .select('game_id, player_id, total_score, joined_at')
      .inFilter('game_id', finishedIds);

  final playerIds = <String>{
    for (final r in allPlayersRaw) r['player_id'] as String,
  }.toList();
  final usersRaw = playerIds.isEmpty
      ? const <Map<String, dynamic>>[]
      : await client
          .from('players')
          .select('id, username')
          .inFilter('id', playerIds);
  final usernames = <String, String>{
    for (final u in usersRaw) u['id'] as String: u['username'] as String,
  };

  final byGame = <String, List<Map<String, dynamic>>>{};
  for (final r in allPlayersRaw) {
    byGame.putIfAbsent(r['game_id'] as String, () => []).add(r);
  }

  final summaries = <PastGameSummary>[];
  for (final g in gamesRaw) {
    final gameId = g['id'] as String;
    final rows = byGame[gameId];
    if (rows == null || rows.isEmpty) continue;

    final sorted = [...rows]..sort((a, b) {
        final byScore =
            (b['total_score'] as int).compareTo(a['total_score'] as int);
        if (byScore != 0) return byScore;
        final aj = DateTime.parse(a['joined_at'] as String);
        final bj = DateTime.parse(b['joined_at'] as String);
        return aj.compareTo(bj);
      });
    final myRank = sorted.indexWhere((r) => r['player_id'] == userId) + 1;
    final winnerId = (g['winner_player_id'] as String?) ??
        sorted.first['player_id'] as String;

    summaries.add(
      PastGameSummary(
        gameId: gameId,
        playerCount: g['player_count'] as int,
        sessionName: g['session_name'] as String?,
        createdAt: DateTime.parse(g['created_at'] as String),
        endedAt: g['ended_at'] == null
            ? null
            : DateTime.parse(g['ended_at'] as String),
        winnerPlayerId: winnerId,
        winnerUsername: usernames[winnerId] ?? '???',
        myScore: myScoreByGame[gameId] ?? 0,
        myRank: myRank == 0 ? sorted.length : myRank,
        isWin: winnerId == userId,
      ),
    );
  }

  summaries.sort((a, b) => b.sortDate.compareTo(a.sortDate));
  return summaries;
});
