import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/estimation_round.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/estimation_providers.dart';
import '../../../services/estimation_service.dart';
import '../../../theme/app_background.dart';
import '../../../theme/app_theme.dart';
import 'number_picker.dart';
import 'player_score_row.dart';
import 'round_header.dart';

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
  final _service = EstimationService();

  Future<void> _lockIn(int roundNumber) async {
    setState(() => _submitting = true);
    try {
      await _service.submitPrediction(
        gameId: widget.gameId,
        roundNumber: roundNumber,
        prediction: _selected,
      );
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
    // Auto-advance: when all predictions are locked, any client fires the
    // phase transition. Conditional WHERE on the UPDATE ensures only one wins.
    ref.listen<bool>(
      allPredictionsLockedProvider(widget.gameId),
      (prev, next) {
        if (next == true && prev != true) {
          _tryAdvance();
        }
      },
    );

    final game =
        ref.watch(estimationGameStreamProvider(widget.gameId)).valueOrNull;
    final entries = ref.watch(activeRoundEntriesProvider(widget.gameId));
    final myEntry = ref.watch(myRoundEntryProvider(widget.gameId));
    final usernames =
        ref.watch(playerUsernamesProvider(widget.gameId)).valueOrNull ?? {};
    final players = ref
            .watch(estimationPlayersStreamProvider(widget.gameId))
            .valueOrNull ??
        [];
    final userId = ref.watch(currentUserIdProvider);

    if (game == null) return const Center(child: CircularProgressIndicator());

    final maxVal = game.cardsThisRound;
    final hasLocked = myEntry?.hasLockedPrediction ?? false;
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
            cardsThisRound: maxVal,
            dealerName: dealerName,
          ),
          const SizedBox(height: AppTheme.space5),

          // Prompt / active picker OR locked display
          if (hasLocked)
            _LockedCard(
              label: 'Η πρόβλεψή σου',
              value: myEntry!.prediction!,
              waitingFor: _waitingCount(entries, game.playerCount),
            )
          else ...[
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
          ],

          const SizedBox(height: AppTheme.space5),

          const AppSectionLabel('Παίκτες'),
          const SizedBox(height: AppTheme.space2),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (_, i) {
                final player = players[i];
                final pid = player.playerId;
                final name = usernames[pid] ?? '...';
                final isMe = pid == userId;
                final entry = _findEntry(entries, pid);
                final locked = entry?.hasLockedPrediction ?? false;

                return PlayerScoreRow(
                  username: name,
                  isMe: isMe,
                  statusIcon:
                      locked ? Icons.check_circle : Icons.hourglass_empty,
                  statusText: locked ? 'Κλειδωμένο' : 'Περιμένω...',
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

  int _waitingCount(List<EstimationRound> entries, int playerCount) {
    final locked = entries.where((e) => e.hasLockedPrediction).length;
    return playerCount - locked;
  }
}

/// Displays the locked-in prediction prominently with a "waiting for…" caption.
class _LockedCard extends StatelessWidget {
  const _LockedCard({
    required this.label,
    required this.value,
    required this.waitingFor,
  });

  final String label;
  final int value;
  final int waitingFor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.space5,
        horizontal: AppTheme.space5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.goldMuted,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 14, color: AppTheme.gold),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space2),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: -2,
              color: AppTheme.gold,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          Text(
            waitingFor > 0
                ? 'Περιμένοντας ${waitingFor == 1 ? '1 παίκτη' : '$waitingFor παίκτες'}…'
                : 'Αποκάλυψη…',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
