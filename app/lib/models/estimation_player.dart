/// Row from `public.estimation_players`.
class EstimationPlayer {
  const EstimationPlayer({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.seat,
    required this.totalScore,
    required this.joinedAt,
  });

  final String id;
  final String gameId;
  final String playerId;
  final int seat;
  final int totalScore;
  final DateTime joinedAt;

  factory EstimationPlayer.fromJson(Map<String, dynamic> json) {
    return EstimationPlayer(
      id: json['id'] as String,
      gameId: json['game_id'] as String,
      playerId: json['player_id'] as String,
      seat: json['seat'] as int,
      totalScore: (json['total_score'] as int?) ?? 0,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }
}
