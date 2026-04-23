/// Row from `public.estimation_tricks`. One row per sub-round (trick) within
/// a round. A trick goes through three states:
///
///   1. **empty** — no proposed_winner yet. Anyone at the table can tap a
///      seat to propose the winner.
///   2. **proposed** — proposed_winner_id is set; peer confirmations accumulate
///      in confirmed_by_ids. Any other player can dispute, clearing the
///      proposal back to empty.
///   3. **confirmed** — winner_player_id is set (consensus reached). The
///      game advances to the next trick (or to validation if this was the
///      last trick of the round).
class EstimationTrick {
  const EstimationTrick({
    required this.id,
    required this.gameId,
    required this.roundNumber,
    required this.trickNumber,
    required this.leaderSeat,
    required this.confirmedByIds,
    this.proposedWinnerId,
    this.proposedById,
    this.winnerPlayerId,
  });

  final String id;
  final String gameId;
  final int roundNumber;
  final int trickNumber;
  final int leaderSeat;
  final String? proposedWinnerId;
  final String? proposedById;
  final List<String> confirmedByIds;
  final String? winnerPlayerId;

  bool get isConfirmed => winnerPlayerId != null;
  bool get hasProposal => proposedWinnerId != null && !isConfirmed;

  factory EstimationTrick.fromJson(Map<String, dynamic> json) {
    final raw = json['confirmed_by_ids'] as List<dynamic>? ?? const [];
    return EstimationTrick(
      id: json['id'] as String,
      gameId: json['game_id'] as String,
      roundNumber: json['round_number'] as int,
      trickNumber: json['trick_number'] as int,
      leaderSeat: json['leader_seat'] as int,
      proposedWinnerId: json['proposed_winner_id'] as String?,
      proposedById: json['proposed_by_id'] as String?,
      confirmedByIds: raw.map((e) => e as String).toList(),
      winnerPlayerId: json['winner_player_id'] as String?,
    );
  }
}
