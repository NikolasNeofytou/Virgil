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

class SubmittingPhase extends ConsumerStatefulWidget {
  const SubmittingPhase({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<SubmittingPhase> createState() => _SubmittingPhaseState();
}

class _SubmittingPhaseState extends ConsumerState<SubmittingPhase> {
  int _selected = 0;
  bool _submitting = false;
  bool _advancing = false;
  final _service = EstimationService();

  Future<void> _submit(int roundNumber) async {
    setState(() => _submitting = true);
    try {
      await _service.submitActualTricks(
        gameId: widget.gameId,
        roundNumber: roundNumber,
        actualTricks: _selected,
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
      if (game == null || game.phase != 'submitting') return;
      await _service.advanceToValidating(
        gameId: widget.gameId,
        roundNumber: game.currentRound,
      );
    } catch (_) {
      // Ignore races.
    } finally {
      _advancing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(
      tricksSanityCheckProvider(widget.gameId),
      (prev, next) {
        if (next == true && prev != true) _tryAdvance();
      },
    );

    final game =
        ref.watch(estimationGameStreamProvider(widget.gameId)).valueOrNull;
    final entries = ref.watch(activeRoundEntriesProvider(widget.gameId));
    final myEntry = ref.watch(myRoundEntryProvider(widget.gameId));
    final players = ref
            .watch(estimationPlayersStreamProvider(widget.gameId))
            .valueOrNull ??
        [];
    final usernames =
        ref.watch(playerUsernamesProvider(widget.gameId)).valueOrNull ?? {};
    final userId = ref.watch(currentUserIdProvider);
    final tricksSum = ref.watch(tricksSubmittedSumProvider(widget.gameId));
    final allSubmitted = ref.watch(allTricksSubmittedProvider(widget.gameId));

    if (game == null) return const Center(child: CircularProgressIndicator());

    final maxVal = game.cardsThisRound;
    final hasSubmitted = myEntry?.hasSubmittedTricks ?? false;
    final sanityFailed = allSubmitted && tricksSum != maxVal;

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

          if (hasSubmitted)
            _SubmittedCard(value: myEntry!.actualTricks!)
          else ...[
            Text(
              'Πόσες μπάζες πήρες;',
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
              onPressed: _submitting ? null : () => _submit(game.currentRound),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Υποβολή'),
            ),
          ],

          if (sanityFailed) ...[
            const SizedBox(height: AppTheme.space3),
            _Banner(
              color: AppTheme.danger,
              icon: Icons.error_outline,
              text: 'Σύνολο: $tricksSum / $maxVal — Δεν ταιριάζει',
            ),
          ],

          const SizedBox(height: AppTheme.space5),
          Row(
            children: [
              const AppSectionLabel('Παίκτες'),
              const Spacer(),
              Text(
                '$tricksSum / $maxVal',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: sanityFailed
                      ? AppTheme.danger
                      : (allSubmitted ? AppTheme.success : AppTheme.gold),
                ),
              ),
            ],
          ),
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
                final submitted = entry?.hasSubmittedTricks ?? false;
                return PlayerScoreRow(
                  username: name,
                  isMe: isMe,
                  statusIcon: submitted
                      ? Icons.check_circle
                      : Icons.hourglass_empty,
                  statusText: submitted
                      ? '${entry!.actualTricks} μπάζες'
                      : 'Περιμένω…',
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
}

class _SubmittedCard extends StatelessWidget {
  const _SubmittedCard({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.space5,
        horizontal: AppTheme.space5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 14,
                color: AppTheme.success,
              ),
              SizedBox(width: 6),
              Text(
                'ΟΙ ΜΠΑΖΕΣ ΣΟΥ',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.success,
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
              color: AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.color,
    required this.icon,
    required this.text,
  });

  final Color color;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space3,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppTheme.space2),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
