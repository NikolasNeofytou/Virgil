import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/estimation_player.dart';
import '../../../models/estimation_trick.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/estimation_providers.dart';
import '../../../services/estimation_service.dart';
import '../../../theme/app_background.dart';
import '../../../theme/app_theme.dart';
import 'round_header.dart';
import 'score_tally.dart';

/// Per-trick tracking with peer confirmation.
///
///  1. Anyone taps a seat → that seat is proposed as winner. Proposer
///     implicitly confirms.
///  2. Other players tap ✓ to confirm or ✗ to clear the proposal.
///  3. When `confirmed_by_ids.length >= threshold`, the proposal is
///     committed (winner_player_id set) and the game advances — to the
///     next trick, or to the validating phase if this was the last.
class PlayingPhase extends ConsumerStatefulWidget {
  const PlayingPhase({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<PlayingPhase> createState() => _PlayingPhaseState();
}

class _PlayingPhaseState extends ConsumerState<PlayingPhase> {
  final _service = EstimationService();
  bool _busy = false;
  bool _advancing = false;

  Future<void> _propose(int leaderSeat, String winnerPlayerId) async {
    final game =
        ref.read(estimationGameStreamProvider(widget.gameId)).valueOrNull;
    if (game == null || _busy) return;
    setState(() => _busy = true);
    try {
      await _service.proposeTrickWinner(
        gameId: widget.gameId,
        roundNumber: game.currentRound,
        trickNumber: game.currentTrickNumber,
        leaderSeat: leaderSeat,
        winnerPlayerId: winnerPlayerId,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm(EstimationTrick trick) async {
    if (_busy || trick.proposedWinnerId == null) return;
    setState(() => _busy = true);
    try {
      await _service.confirmTrickWinner(
        trickId: trick.id,
        proposedWinnerId: trick.proposedWinnerId!,
        currentConfirmedByIds: trick.confirmedByIds,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _dispute(EstimationTrick trick) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _service.disputeTrickProposal(trickId: trick.id);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Called when confirmed_by_ids crosses the threshold — any client can
  /// commit, the guarded write in [advanceTrick] keeps it idempotent.
  Future<void> _maybeCommit(EstimationTrick trick) async {
    if (_advancing || trick.winnerPlayerId != null) return;
    if (trick.proposedWinnerId == null) return;
    final game =
        ref.read(estimationGameStreamProvider(widget.gameId)).valueOrNull;
    final players = ref
            .read(estimationPlayersStreamProvider(widget.gameId))
            .valueOrNull ??
        [];
    if (game == null || players.isEmpty) return;
    final threshold = EstimationService.confirmationThreshold(game.playerCount);
    if (trick.confirmedByIds.length < threshold) return;

    final match = players.where((p) => p.playerId == trick.proposedWinnerId);
    if (match.isEmpty) return;
    final winnerPlayer = match.first;

    _advancing = true;
    try {
      await _service.advanceTrick(
        gameId: widget.gameId,
        trickId: trick.id,
        roundNumber: trick.roundNumber,
        trickNumber: trick.trickNumber,
        cardsThisRound: game.cardsThisRound,
        winnerPlayerId: winnerPlayer.playerId,
        winnerSeat: winnerPlayer.seat,
      );
    } catch (_) {
      // Ignore; another client likely already advanced.
    } finally {
      _advancing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final game =
        ref.watch(estimationGameStreamProvider(widget.gameId)).valueOrNull;
    final players = ref
            .watch(estimationPlayersStreamProvider(widget.gameId))
            .valueOrNull ??
        [];
    final usernames =
        ref.watch(playerUsernamesProvider(widget.gameId)).valueOrNull ?? {};
    final currentTrick = ref.watch(currentTrickProvider(widget.gameId));
    final pastTricks = ref.watch(pastTricksProvider(widget.gameId));
    final userId = ref.watch(currentUserIdProvider);

    if (game == null) return const Center(child: CircularProgressIndicator());

    // Drive the commit off confirmation count changes.
    ref.listen<EstimationTrick?>(
      currentTrickProvider(widget.gameId),
      (prev, next) {
        if (next == null) return;
        if (next.winnerPlayerId != null) return;
        final threshold = EstimationService.confirmationThreshold(
          game.playerCount,
        );
        if (next.confirmedByIds.length >= threshold) {
          _maybeCommit(next);
        }
      },
    );

    final leaderSeat = game.currentLeaderSeat ?? game.roundStarterSeat ?? 0;
    final leaderName = _seatName(players, usernames, leaderSeat);
    final dealerName = _seatName(players, usernames, game.dealerSeat);

    return Padding(
      padding: const EdgeInsets.all(AppTheme.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoundHeader(
            currentRound: game.currentRound,
            totalRounds: game.totalRounds,
            cardsThisRound: game.cardsThisRound,
            dealerName: dealerName,
          ),
          const SizedBox(height: AppTheme.space3),
          ScoreTally(gameId: widget.gameId),
          const SizedBox(height: AppTheme.space3),
          _TrickHeader(
            trickNumber: game.currentTrickNumber,
            totalTricks: game.cardsThisRound,
            leaderName: leaderName,
          ),
          const SizedBox(height: AppTheme.space4),

          if (currentTrick == null || !currentTrick.hasProposal)
            _SeatGrid(
              players: players,
              usernames: usernames,
              myUserId: userId,
              busy: _busy,
              onTap: (p) => _propose(leaderSeat, p.playerId),
            )
          else
            _ProposalCard(
              trick: currentTrick,
              players: players,
              usernames: usernames,
              myUserId: userId,
              playerCount: game.playerCount,
              busy: _busy,
              onConfirm: () => _confirm(currentTrick),
              onDispute: () => _dispute(currentTrick),
            ),

          const SizedBox(height: AppTheme.space5),
          const AppSectionLabel('ΠΡΟΗΓΟΥΜΕΝΕΣ · PAST', showRule: true),
          const SizedBox(height: AppTheme.space3),
          Expanded(
            child: pastTricks.isEmpty
                ? Center(
                    child: Text(
                      'καμιά μπάζα ακόμα',
                      style: GoogleFonts.caveat(
                        fontSize: 18,
                        color: AppTheme.inkFaint,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: pastTricks.length,
                    itemBuilder: (_, i) {
                      final t = pastTricks[i];
                      final match = players.where(
                        (p) => p.playerId == t.winnerPlayerId,
                      );
                      if (match.isEmpty) return const SizedBox.shrink();
                      final winner = match.first;
                      final name = usernames[winner.playerId] ?? '…';
                      return _PastTrickRow(
                        trickNumber: t.trickNumber,
                        winnerName: name,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String? _seatName(
    List<EstimationPlayer> players,
    Map<String, String> usernames,
    int? seat,
  ) {
    if (seat == null || seat < 0) return null;
    final match = players.where((p) => p.seat == seat);
    if (match.isEmpty) return null;
    return usernames[match.first.playerId];
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _TrickHeader extends StatelessWidget {
  const _TrickHeader({
    required this.trickNumber,
    required this.totalTricks,
    required this.leaderName,
  });

  final int trickNumber;
  final int totalTricks;
  final String? leaderName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ΜΠΑΖΑ · TRICK',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  letterSpacing: 3,
                  color: AppTheme.inkSoft,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$trickNumber',
                    style: GoogleFonts.gloock(
                      fontSize: 30,
                      color: AppTheme.ink,
                      height: 1.0,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    ' / $totalTricks',
                    style: GoogleFonts.gloock(
                      fontSize: 18,
                      color: AppTheme.inkFaint,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'LEADS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  letterSpacing: 3,
                  color: AppTheme.terra,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                leaderName ?? '…',
                style: GoogleFonts.caveat(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Paper tiles — tap to nominate that seat as the trick winner.
class _SeatGrid extends StatelessWidget {
  const _SeatGrid({
    required this.players,
    required this.usernames,
    required this.myUserId,
    required this.busy,
    required this.onTap,
  });

  final List<EstimationPlayer> players;
  final Map<String, String> usernames;
  final String? myUserId;
  final bool busy;
  final ValueChanged<EstimationPlayer> onTap;

  @override
  Widget build(BuildContext context) {
    final sorted = [...players]..sort((a, b) => a.seat.compareTo(b.seat));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ποιος πήρε τη μπάζα;',
          textAlign: TextAlign.center,
          style: GoogleFonts.caveat(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: AppTheme.space3),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppTheme.space2,
          runSpacing: AppTheme.space2,
          children: [
            for (final p in sorted)
              _SeatTile(
                seat: p.seat,
                name: usernames[p.playerId] ?? '…',
                isMe: p.playerId == myUserId,
                onTap: busy ? null : () => onTap(p),
              ),
          ],
        ),
      ],
    );
  }
}

class _SeatTile extends StatelessWidget {
  const _SeatTile({
    required this.seat,
    required this.name,
    required this.isMe,
    required this.onTap,
  });

  final int seat;
  final String name;
  final bool isMe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        splashColor: AppTheme.terraMuted,
        highlightColor: Colors.transparent,
        child: Container(
          width: 124,
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.space3,
            horizontal: AppTheme.space3,
          ),
          decoration: BoxDecoration(
            color: AppTheme.paper,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: isMe
                  ? AppTheme.terra.withValues(alpha: 0.5)
                  : AppTheme.border,
              width: isMe ? 1.2 : 1,
            ),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            children: [
              Text(
                '${seat + 1}',
                style: GoogleFonts.gloock(
                  fontSize: 20,
                  color: AppTheme.terra,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: GoogleFonts.caveat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                  height: 1.1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A pending proposal — shows the proposed winner, who proposed, and
/// confirmation / dispute controls.
class _ProposalCard extends StatelessWidget {
  const _ProposalCard({
    required this.trick,
    required this.players,
    required this.usernames,
    required this.myUserId,
    required this.playerCount,
    required this.busy,
    required this.onConfirm,
    required this.onDispute,
  });

  final EstimationTrick trick;
  final List<EstimationPlayer> players;
  final Map<String, String> usernames;
  final String? myUserId;
  final int playerCount;
  final bool busy;
  final VoidCallback onConfirm;
  final VoidCallback onDispute;

  @override
  Widget build(BuildContext context) {
    final proposedName = _nameFor(trick.proposedWinnerId);
    final proposedByName = _nameFor(trick.proposedById);
    final iConfirmed =
        myUserId != null && trick.confirmedByIds.contains(myUserId);
    final iProposed = myUserId != null && trick.proposedById == myUserId;
    final threshold = EstimationService.confirmationThreshold(playerCount);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.space5,
        horizontal: AppTheme.space5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.terra.withValues(alpha: 0.45)),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        children: [
          Text(
            'ΠΡΟΤΑΣΗ · PROPOSED WINNER',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
              color: AppTheme.terra,
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            proposedName ?? '…',
            style: GoogleFonts.gloock(
              fontSize: 40,
              color: AppTheme.ink,
              height: 1.0,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          Container(
            height: 1,
            width: 60,
            color: AppTheme.terra.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppTheme.space2),
          Text(
            'από ${proposedByName ?? '…'}',
            style: GoogleFonts.caveat(
              fontSize: 18,
              color: AppTheme.inkSoft,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            'συμφωνίες ${trick.confirmedByIds.length} / $threshold',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              letterSpacing: 2,
              color: AppTheme.inkSoft,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          if (iProposed)
            Text(
              'αναμονή για τους υπόλοιπους…',
              style: GoogleFonts.caveat(
                fontSize: 18,
                color: AppTheme.inkSoft,
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : onDispute,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      side: BorderSide(
                        color: AppTheme.danger.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Text('Λάθος'),
                  ),
                ),
                const SizedBox(width: AppTheme.space3),
                Expanded(
                  child: FilledButton(
                    onPressed: busy || iConfirmed ? null : onConfirm,
                    child: Text(iConfirmed ? 'OK ✓' : 'Επιβεβαίωση'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String? _nameFor(String? playerId) {
    if (playerId == null) return null;
    return usernames[playerId];
  }
}

class _PastTrickRow extends StatelessWidget {
  const _PastTrickRow({
    required this.trickNumber,
    required this.winnerName,
  });

  final int trickNumber;
  final String winnerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#$trickNumber',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                letterSpacing: 2,
                color: AppTheme.inkFaint,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward, size: 14, color: AppTheme.inkFaint),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Text(
              winnerName,
              style: GoogleFonts.caveat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
                height: 1.1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.check_circle, size: 16, color: AppTheme.olive),
        ],
      ),
    );
  }
}
