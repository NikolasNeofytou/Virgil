/// Row from `public.estimation_rounds`.
class EstimationRound {
  const EstimationRound({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.roundNumber,
    required this.cardsThisRound,
    this.prediction,
    this.actualTricks,
    this.score,
    required this.validated,
  });

  final String id;
  final String gameId;
  final String playerId;
  final int roundNumber;
  final int cardsThisRound;
  final int? prediction;
  final int? actualTricks;
  final int? score;
  final bool validated;

  bool get hasLockedPrediction => prediction != null;
  bool get hasSubmittedTricks => actualTricks != null;

  /// +1 per trick won, +10 bonus if prediction === actual.
  static int calculateScore(int prediction, int actual) =>
      actual + (prediction == actual ? 10 : 0);

  factory EstimationRound.fromJson(Map<String, dynamic> json) {
    return EstimationRound(
      id: json['id'] as String,
      gameId: json['game_id'] as String,
      playerId: json['player_id'] as String,
      roundNumber: json['round_number'] as int,
      cardsThisRound: json['cards_this_round'] as int,
      prediction: json['prediction'] as int?,
      actualTricks: json['actual_tricks'] as int?,
      score: json['score'] as int?,
      validated: (json['validated'] as bool?) ?? false,
    );
  }
}
