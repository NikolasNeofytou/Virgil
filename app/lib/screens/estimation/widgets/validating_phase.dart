import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/estimation_round.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/estimation_providers.dart';
import '../../../services/estimation_service.dart';
import '../../../theme/app_background.dart';
import '../../../theme/app_theme.dart';
import 'round_header.dart';

class ValidatingPhase extends ConsumerStatefulWidget {
  const ValidatingPhase({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<ValidatingPhase> createState() => _ValidatingPhaseState();
}

class _ValidatingPhaseState extends ConsumerState<ValidatingPhase> {
  bool _confirming = false;
  bool _disputing = false;
  bool _finalizing = false;
  final _service = EstimationService();

  Future<void> _confirm(int roundNumber) async {
    setState(() => _confirming = true);
    try {
      await _service.confirmRound(
        gameId: widget.gameId,
        roundNumber: roundNumber,
      );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Future<void> _tryFinalize() async {
    if (_finalizing) return;
    _finalizing = true;
    try {
      final game =
          ref.read(estimationGameStreamProvider(widget.gameId)).valueOrNull;
      if (game == null || game.phase != 'validating') return;
      await _finalize(game.currentRound);
    } catch (_) {
      // Ignore races.
    } finally {
      _finalizing = false;
    }
  }

  Future<void> _dispute(int roundNumber, String playerId) async {
    setState(() => _disputing = true);
    try {
      await _service.disputeResult(
        gameId: widget.gameId,
        roundNumber: roundNumber,
        disputedPlayerId: playerId,
      );
    } finally {
      if (mounted) setState(() => _disputing = false);
    }
  }

  Future<void> _finalize(int roundNumber) async {
    final game =
        ref.read(estimationGameStreamProvider(widget.gameId)).valueOrNull;
    final entries = ref.read(activeRoundEntriesProvider(widget.gameId));
    if (game == null || entries.isEmpty) return;

    final rawEntries = entries
        .map((e) => {
              'id': e.id,
              'player_id': e.playerId,
              'prediction': e.prediction,
              'actual_tricks': e.actualTricks,
            },)
        .toList();

    await _service.finalizeRound(
      gameId: widget.gameId,
      currentRound: game.currentRound,
      totalRounds: game.totalRounds,
      maxCards: game.maxCards,
      playerCount: game.playerCount,
      dealerSeat: game.dealerSeat,
      entries: rawEntries,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(
      validationCountProvider(widget.gameId),
      (prev, next) {
        final threshold =
            ref.read(validationThresholdProvider(widget.gameId));
        if (next >= threshold && (prev ?? 0) < threshold) {
          _tryFinalize();
        }
      },
    );

    final game =
        ref.watch(estimationGameStreamProvider(widget.gameId)).valueOrNull;
    final entries = ref.watch(activeRoundEntriesProvider(widget.gameId));
    final players = ref
            .watch(estimationPlayersStreamProvider(widget.gameId))
            .valueOrNull ??
        [];
    final usernames =
        ref.watch(playerUsernamesProvider(widget.gameId)).valueOrNull ?? {};
    final userId = ref.watch(currentUserIdProvider);
    final validationCount = ref.watch(validationCountProvider(widget.gameId));
    final threshold = ref.watch(validationThresholdProvider(widget.gameId));
    final myEntry = ref.watch(myRoundEntryProvider(widget.gameId));

    if (game == null) return const Center(child: CircularProgressIndicator());

    final iConfirmed = myEntry?.validated ?? false;

    final dealerPlayer = players.where((p) => p.seat == game.dealerSeat);
    final dealerName = dealerPlayer.isNotEmpty
        ? usernames[dealerPlayer.first.playerId]
        : null;

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
          const SizedBox(height: AppTheme.space4),

          // Validation counter
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space4,
              vertical: AppTheme.space3,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.how_to_vote_outlined,
                  color: AppTheme.gold,
                  size: 18,
                ),
                const SizedBox(width: AppTheme.space2),
                const Expanded(
                  child: Text(
                    'Επιβεβαίωση',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Text(
                  '$validationCount / $threshold',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space5),

          const AppSectionLabel('Αποτελέσματα'),
          const SizedBox(height: AppTheme.space2),

          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (_, i) {
                final player = players[i];
                final pid = player.playerId;
                final name = usernames[pid] ?? '…';
                final isMe = pid == userId;
                final entry = _findEntry(entries, pid);
                if (entry == null) return const SizedBox.shrink();

                final predicted = entry.prediction ?? 0;
                final actual = entry.actualTricks ?? 0;
                final score =
                    EstimationRound.calculateScore(predicted, actual);
                final isBonus = predicted == actual;

                return _ResultRow(
                  username: name,
                  isMe: isMe,
                  predicted: predicted,
                  actual: actual,
                  score: score,
                  isBonus: isBonus,
                  validated: entry.validated,
                  onDispute: !isMe && !_disputing
                      ? () => _dispute(game.currentRound, pid)
                      : null,
                );
              },
            ),
          ),

          const SizedBox(height: AppTheme.space3),

          if (iConfirmed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                  SizedBox(width: AppTheme.space2),
                  Text(
                    'Επιβεβαιώθηκε',
                    style: TextStyle(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            FilledButton(
              onPressed:
                  _confirming ? null : () => _confirm(game.currentRound),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.success,
              ),
              child: _confirming
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Επιβεβαίωση αποτελεσμάτων'),
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
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.username,
    required this.isMe,
    required this.predicted,
    required this.actual,
    required this.score,
    required this.isBonus,
    required this.validated,
    this.onDispute,
  });

  final String username;
  final bool isMe;
  final int predicted;
  final int actual;
  final int score;
  final bool isBonus;
  final bool validated;
  final VoidCallback? onDispute;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.goldMuted : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isMe
              ? AppTheme.gold.withValues(alpha: 0.35)
              : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '@$username',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isMe ? AppTheme.gold : AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'εσύ',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.gold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          _Stat(label: 'Πρ', value: '$predicted'),
          const SizedBox(width: AppTheme.space2),
          _Stat(label: 'Μπ', value: '$actual', highlight: isBonus),
          const SizedBox(width: AppTheme.space2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isBonus ? AppTheme.gold : AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              '+$score',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isBonus ? AppTheme.background : AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space2),
          SizedBox(
            width: 24,
            child: validated
                ? const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppTheme.success,
                  )
                : onDispute != null
                    ? IconButton(
                        onPressed: onDispute,
                        icon: const Icon(Icons.flag_outlined),
                        iconSize: 14,
                        color: AppTheme.textTertiary,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Αμφισβήτηση',
                      )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppTheme.textTertiary,
            letterSpacing: 0.4,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: highlight ? AppTheme.success : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
