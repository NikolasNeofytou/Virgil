/// One celebratory accolade computed from a finished estimation game.
/// Pure data — rendered as a card on the game-over / summary screen.
class GameAward {
  const GameAward({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.playerId,
    required this.username,
  });

  /// Stable id (e.g. `best_predictor`) — useful for animations / keys.
  final String id;
  final String emoji;
  final String title;
  final String description;
  final String playerId;
  final String username;
}
