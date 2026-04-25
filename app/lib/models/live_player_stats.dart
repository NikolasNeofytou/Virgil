/// Aggregate per-player view of an in-progress estimation game. Computed
/// client-side from the streamed rounds + players state, so it's always live.
class LivePlayerStats {
  const LivePlayerStats({
    required this.playerId,
    required this.username,
    required this.totalScore,
    required this.accuracyHits,
    required this.accuracyAttempts,
    required this.cumulativeByRound,
  });

  final String playerId;
  final String username;

  /// Mirror of `estimation_players.total_score` for ordering.
  final int totalScore;

  /// Number of rounds where prediction == actual_tricks (both non-null).
  final int accuracyHits;

  /// Number of rounds with both prediction and actual_tricks recorded.
  final int accuracyAttempts;

  /// `null` when no rounds have been completed yet.
  double? get accuracy =>
      accuracyAttempts == 0 ? null : accuracyHits / accuracyAttempts;

  /// Map of `roundNumber → cumulativeScore` for this player up to and
  /// including that round. Used to draw the score-progression line chart.
  /// Only contains entries for rounds where the score has been calculated.
  final Map<int, int> cumulativeByRound;
}
