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
    this.roundStarterSeat,
    this.currentTrickNumber = 1,
    this.currentLeaderSeat,
  });

  final String id;
  final String roomCode;
  final int playerCount;
  final int maxCards;
  final int currentRound;
  final int totalRounds;
  final String status; // waiting | active | finished
  final String phase; // predicting | playing | validating (legacy: submitting)
  final int dealerSeat;
  final DateTime createdAt;

  /// Seat that bids first + leads trick 1 in the current round. Rotates
  /// clockwise by 1 each round (picked randomly at game start for round 1).
  final int? roundStarterSeat;

  /// 1-based counter of the active trick within the current round.
  final int currentTrickNumber;

  /// Seat leading the active trick. Starts at [roundStarterSeat], then
  /// follows trick winners.
  final int? currentLeaderSeat;

  /// Cards dealt this round. Climbs 1..N then descends N..1 with the peak
  /// doubled: round N and N+1 both get N cards. Total rounds = 2·N.
  int get cardsThisRound => currentRound <= maxCards
      ? currentRound
      : 2 * maxCards - currentRound + 1;

  bool get isFinished => status == 'finished';
  bool get isActive => status == 'active';

  /// Bid order starting from [roundStarterSeat], wrapping clockwise through
  /// every seat once. Returns [] if starter hasn't been picked yet.
  List<int> get bidOrder {
    final start = roundStarterSeat;
    if (start == null) return const [];
    return [for (var i = 0; i < playerCount; i++) (start + i) % playerCount];
  }

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
      roundStarterSeat: json['round_starter_seat'] as int?,
      currentTrickNumber: (json['current_trick_number'] as int?) ?? 1,
      currentLeaderSeat: json['current_leader_seat'] as int?,
    );
  }
}
