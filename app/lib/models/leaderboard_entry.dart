/// One row in the cross-game leaderboard, sourced from the
/// `public.estimation_stats` view. One row per player who has finished at
/// least one estimation game. Distinct from `EstimationStats` in
/// `providers/stats_providers.dart` (which is the simpler client-derived
/// summary used on the profile tab).
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.playerId,
    required this.username,
    required this.gamesPlayed,
    required this.wins,
    required this.lifetimePoints,
    required this.avgScorePerGame,
    required this.accuracy,
    this.avatarUrl,
  });

  final String playerId;
  final String username;
  final String? avatarUrl;
  final int gamesPlayed;
  final int wins;
  final int lifetimePoints;
  final double avgScorePerGame;

  /// Hit rate of `prediction == actual_tricks` across all rounds the player
  /// has completed in any estimation game (finished or in progress). 0..1.
  /// Null when the player has zero completed rounds.
  final double? accuracy;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      playerId: json['player_id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      gamesPlayed: (json['games_played'] as num).toInt(),
      wins: (json['wins'] as num).toInt(),
      lifetimePoints: (json['lifetime_points'] as num? ?? 0).toInt(),
      avgScorePerGame: (json['avg_score_per_game'] as num? ?? 0).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
    );
  }
}
