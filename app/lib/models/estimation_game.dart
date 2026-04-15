/// Row from `public.estimation_games`.
class EstimationGame {
  const EstimationGame({
    required this.id,
    required this.roomCode,
    required this.playerCount,
    required this.maxCards,
    required this.currentRound,
    required this.totalRounds,
    required this.status,
    required this.phase,
    required this.dealerSeat,
    required this.createdAt,
  });

  final String id;
  final String roomCode;
  final int playerCount;
  final int maxCards;
  final int currentRound;
  final int totalRounds;
  final String status; // waiting | active | finished
  final String phase; // predicting | playing | submitting | validating
  final int dealerSeat;
  final DateTime createdAt;

  /// Cards dealt this round. Goes up 1,2,...,N then back down N-1,...,2,1.
  int get cardsThisRound =>
      currentRound <= maxCards ? currentRound : 2 * maxCards - currentRound;

  bool get isFinished => status == 'finished';
  bool get isActive => status == 'active';

  factory EstimationGame.fromJson(Map<String, dynamic> json) {
    return EstimationGame(
      id: json['id'] as String,
      roomCode: json['room_code'] as String,
      playerCount: json['player_count'] as int,
      maxCards: json['max_cards'] as int,
      currentRound: json['current_round'] as int,
      totalRounds: json['total_rounds'] as int,
      status: json['status'] as String,
      phase: json['phase'] as String,
      dealerSeat: json['dealer_seat'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
