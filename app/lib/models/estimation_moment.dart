/// "Στιγμή" — a 140-char hand-written note attached to an estimation game.
/// Optionally pinned to a specific round. Authored by any participant;
/// surfaced on the game-over summary panel and re-openable from the
/// Profile → "Τα παιχνίδια μου" history.
class EstimationMoment {
  const EstimationMoment({
    required this.id,
    required this.gameId,
    required this.authorId,
    required this.body,
    required this.createdAt,
    this.roundNumber,
  });

  final String id;
  final String gameId;
  final String authorId;
  final String body;
  final DateTime createdAt;

  /// Null when the moment is about the whole game rather than a single
  /// round.
  final int? roundNumber;

  factory EstimationMoment.fromJson(Map<String, dynamic> json) {
    return EstimationMoment(
      id: json['id'] as String,
      gameId: json['game_id'] as String,
      authorId: json['author_id'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      roundNumber: json['round_number'] as int?,
    );
  }
}
