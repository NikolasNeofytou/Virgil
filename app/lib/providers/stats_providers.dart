import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/supabase_client.dart';
import 'auth_providers.dart';

/// Lifetime Estimation stats for the current user. Derived from their
/// `estimation_players` rows joined with `estimation_games` so we can count
/// wins (highest total_score in that game).
class EstimationStats {
  const EstimationStats({
    required this.gamesPlayed,
    required this.wins,
    required this.totalScore,
  });

  final int gamesPlayed;
  final int wins;
  final int totalScore;

  static const empty = EstimationStats(gamesPlayed: 0, wins: 0, totalScore: 0);
}

/// Queries `estimation_players` for the signed-in user and computes a few
/// aggregate stats client-side. Cheap enough to re-run on profile view.
final estimationStatsProvider =
    FutureProvider<EstimationStats>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return EstimationStats.empty;
  final client = SupabaseBootstrap.client;

  // My rows.
  final mine = await client
      .from('estimation_players')
      .select('game_id, total_score')
      .eq('player_id', userId);

  if (mine.isEmpty) return EstimationStats.empty;

  final myGameIds = mine.map((r) => r['game_id'] as String).toList();
  final totalScore =
      mine.fold<int>(0, (sum, r) => sum + (r['total_score'] as int? ?? 0));

  // Count games where the game is finished and I was the top scorer.
  final games = await client
      .from('estimation_games')
      .select('id, status')
      .inFilter('id', myGameIds);
  final finishedIds = games
      .where((g) => g['status'] == 'finished')
      .map((g) => g['id'] as String)
      .toList();

  var wins = 0;
  if (finishedIds.isNotEmpty) {
    final finishedPlayers = await client
        .from('estimation_players')
        .select('game_id, player_id, total_score')
        .inFilter('game_id', finishedIds);

    // Group by game_id, find winner per game.
    final byGame = <String, List<Map<String, dynamic>>>{};
    for (final row in finishedPlayers) {
      final gid = row['game_id'] as String;
      byGame.putIfAbsent(gid, () => []).add(row);
    }
    for (final rows in byGame.values) {
      rows.sort((a, b) =>
          (b['total_score'] as int).compareTo(a['total_score'] as int),);
      if (rows.first['player_id'] == userId) wins++;
    }
  }

  return EstimationStats(
    gamesPlayed: mine.length,
    wins: wins,
    totalScore: totalScore,
  );
});
