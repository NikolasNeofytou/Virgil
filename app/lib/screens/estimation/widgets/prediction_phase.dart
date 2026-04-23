import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/estimation_player.dart';
import '../../../models/estimation_round.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/estimation_providers.dart';
import '../../../services/estimation_service.dart';
import '../../../theme/app_background.dart';
import '../../../theme/app_theme.dart';
import 'number_picker.dart';
import 'round_header.dart';
import 'score_tally.dart';

/// Sequential prediction phase.
///
///  * Only the seat at `currentBidderSeatProvider` sees the [NumberPicker]
///    + Κλείδωμα button. Everyone else sees a waiting card with a running
///    list of bids already locked.
///  * When every seat has bid, any client triggers advance-to-playing.
class PredictionPhase extends ConsumerStatefulWidget {
  const PredictionPhase({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<PredictionPhase> createState() => _PredictionPhaseState();
}

class _PredictionPhaseState extends ConsumerState<PredictionPhase> {
  int _selected = 0;
  bool _submitting = false;
  bool _advancing = false;
  bool _seeding = false;
  final _service = EstimationService();

  /// Self-heal: if we arrive on the predicting phase with no round entries
  /// (e.g. the host's createRoundEntries call silently failed), any client
  /// can seed them. The insert is idempotent so duplicate callers are safe.
  Future<void> _seedIfMissing() async {
    if (_seeding) return;
    final game =
        ref.read(estimationGameStreamProvider(widget.gameId)).valueOrNull;
    final entries = ref.read(activeRoundEntriesProvider(widget.gameId));
    final players = ref
            .read(estimationPlayersStreamProvider(widget.gameId))
            .valueOrNull ??
        [];
    if (game == null ||
        game.phase != 'predicting' ||
        entries.isNotEmpty ||
        players.length < game.playerCount) {
      return;
    }
    _seeding = true;
    try {
      await _service.createRoundEntries(
        gameId: widget.gameId,
        roundNumber: game.currentRound,
        cardsThisRound: game.cardsThisRound,
        playerIds: players.map((p) => p.playerId).toList(),
      );
    } catch (_) {
      // Logged inside the service; nothing to surface to the user.
    } finally {
      _seeding = false;
    }
  }

  Future<void> _lockIn(int roundNumber) async {
    setState(() => _submitting = true);
    try {
      await _service.submitPrediction(
        gameId: widget.gameId,
        roundNumber: roundNumber,
        prediction: _selected,
      );
      if (mounted) setState(() => _selected = 0);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _tryAdvance() async {
    if (_advancing) return;
    _advancing = true;
    try {
      final game =
          ref.read(estimationGameStreamProvider(widget.gameId)).valueOrNull;
      if (game == null || game.phase != 'predicting') return;
      await _service.advanceToPlaying(
        gameId: widget.gameId,
        roundNumber: game.currentRound,
      );
    } catch (_) {
      // Ignore — another client may have advanced first.
    } finally {
      _advancing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auto-advance when every seat has bid.
    ref.listen<bool>(
      allPredictionsLockedProvider(widget.gameId),
      (prev, next) {
        if (next == true && prev != true) _tryAdvance();
      },
    );

    // Self-heal missing round entries on change.
    ref.listen<List<EstimationRound>>(
      activeRoundEntriesProvider(widget.gameId),
      (prev, next) {
        if (next.isEmpty) _seedIfMissing();
      },
    );

    final game =
        ref.watch(estimationGameStreamProvider(widget.gameId)).valueOrNull;
    final entries = ref.watch(activeRoundEntriesProvider(widget.gameId));
    // And on first build when entries are still empty.
    if (entries.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _seedIfMissing());
    }
    final usernames =
        ref.watch(playerUsernamesProvider(widget.gameId)).valueOrNull ?? {};
    final players = ref
            .watch(estimationPlayersStreamProvider(widget.gameId))
            .valueOrNull ??
        [];
    final bidOrder = ref.watch(bidOrderProvider(widget.gameId));
    final currentBidderSeat =
        ref.watch(currentBidderSeatProvider(widget.gameId));
    final mySeat = ref.watch(mySeatProvider(widget.gameId));
    final isMyTurn = ref.watch(isMyTurnToBidProvider(widget.gameId));
    final userId = ref.watch(currentUserIdProvider);

    if (game == null) return const Center(child: CircularProgressIndicator());

    final maxVal = game.cardsThisRound;
    final myEntry = _findMyEntry(entries, userId);
    final hasLocked = myEntry?.hasLockedPrediction ?? false;

    final dealerName = _seatName(players, usernames, game.dealerSeat);
    final currentBidderName =
        _seatName(players, usernames, currentBidderSeat);

    return Padding(
      padding: const EdgeInsets.all(AppTheme.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoundHeader(
            currentRound: game.currentRound,
            totalRounds: game.totalRounds,
            cardsThisRound: maxVal,
            dealerName: dealerName,
          ),
          const SizedBox(height: AppTheme.space3),
          ScoreTally(gameId: widget.gameId),
          const SizedBox(height: AppTheme.space5),

          if (isMyTurn && !hasLocked) ...[
            Text(
              'Πόσες μπάζες θα πάρεις;',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.space5),
            NumberPicker(
              value: _selected,
              max: maxVal,
              onChanged: (v) => setState(() => _selected = v),
            ),
            const SizedBox(height: AppTheme.space5),
            FilledButton(
              onPressed: _submitting ? null : () => _lockIn(game.currentRound),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Κλείδωμα'),
            ),
          ] else
            _WaitingCard(
              title: currentBidderSeat == mySeat
                  ? 'Η πρόβλεψή σου κλειδώθηκε'
                  : currentBidderName == null
                      ? 'αναμονή…'
                      : 'σειρά του $currentBidderName',
            ),

          const SizedBox(height: AppTheme.space5),
          const AppSectionLabel('ΣΕΙΡΑ · BID ORDER', showRule: true),
          const SizedBox(height: AppTheme.space3),
          Expanded(
            child: ListView.builder(
              itemCount: bidOrder.length,
              itemBuilder: (_, i) {
                final seat = bidOrder[i];
                final match = players.where((p) => p.seat == seat);
                final player = match.isEmpty ? null : match.first;
                final pid = player?.playerId;
                final entry =
                    pid == null ? null : _findEntry(entries, pid);
                final isMe = pid == userId;
                final name = pid == null ? '…' : (usernames[pid] ?? '…');
                final locked = entry?.hasLockedPrediction ?? false;
                final isCurrent = seat == currentBidderSeat;
                return _BidRow(
                  order: i + 1,
                  seat: seat,
                  name: name,
                  isMe: isMe,
                  isCurrent: isCurrent,
                  locked: locked,
                  prediction: entry?.prediction,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  EstimationRound? _findEntry(List<EstimationRound> entries, String playerId) {
    try {
      return entries.firstWhere((e) => e.playerId == playerId);
    } catch (_) {
      return null;
    }
  }

  EstimationRound? _findMyEntry(List<EstimationRound> entries, String? userId) {
    if (userId == null) return null;
    return _findEntry(entries, userId);
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

/// Non-active bidder waiting card.
class _WaitingCard extends StatelessWidget {
  const _WaitingCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.space5,
        horizontal: AppTheme.space5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Text(
            'ΓΥΡΟΣ ΠΡΟΒΛΕΨΕΩΝ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
              color: AppTheme.terra,
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.caveat(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

/// One row in the bid order list.
class _BidRow extends StatelessWidget {
  const _BidRow({
    required this.order,
    required this.seat,
    required this.name,
    required this.isMe,
    required this.isCurrent,
    required this.locked,
    required this.prediction,
  });

  final int order;
  final int seat;
  final String name;
  final bool isMe;
  final bool isCurrent;
  final bool locked;
  final int? prediction;

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
        border: Border.all(
          color: isCurrent && !locked
              ? AppTheme.terra.withValues(alpha: 0.6)
              : isMe
                  ? AppTheme.terra.withValues(alpha: 0.4)
                  : AppTheme.border,
          width: isCurrent && !locked ? 1.4 : 1,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$order',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                letterSpacing: 2,
                color: AppTheme.inkFaint,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    name,
                    style: GoogleFonts.caveat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isMe ? AppTheme.terra : AppTheme.ink,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.terraMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'ΕΣΥ',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                        color: AppTheme.terra,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (locked)
            Text(
              '${prediction ?? 0}',
              style: GoogleFonts.gloock(
                fontSize: 22,
                color: AppTheme.ink,
                height: 1.0,
                letterSpacing: -0.3,
              ),
            )
          else if (isCurrent)
            Text(
              '…',
              style: GoogleFonts.caveat(
                fontSize: 20,
                color: AppTheme.terra,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Text(
              '—',
              style: GoogleFonts.gloock(
                fontSize: 18,
                color: AppTheme.inkFaint,
              ),
            ),
        ],
      ),
    );
  }
}
