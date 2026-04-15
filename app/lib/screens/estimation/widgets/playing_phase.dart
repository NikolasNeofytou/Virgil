import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/estimation_providers.dart';
import '../../../services/estimation_service.dart';
import '../../../theme/app_background.dart';
import '../../../theme/app_theme.dart';
import 'player_score_row.dart';
import 'round_header.dart';

/// Passive screen while the physical card round is being played.
class PlayingPhase extends ConsumerStatefulWidget {
  const PlayingPhase({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<PlayingPhase> createState() => _PlayingPhaseState();
}

class _PlayingPhaseState extends ConsumerState<PlayingPhase> {
  bool _advancing = false;

  Future<void> _donePlaying() async {
    setState(() => _advancing = true);
    try {
      await EstimationService().advanceToSubmitting(gameId: widget.gameId);
    } finally {
      if (mounted) setState(() => _advancing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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

    if (game == null) return const Center(child: CircularProgressIndicator());

    final dealerPlayer = players.where((p) => p.seat == game.dealerSeat);
    final dealerName = dealerPlayer.isNotEmpty
        ? usernames[dealerPlayer.first.playerId]
        : null;

    final predictionSum =
        entries.fold<int>(0, (s, e) => s + (e.prediction ?? 0));

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

          // ── Callout ──
          Container(
            padding: const EdgeInsets.all(AppTheme.space4),
            decoration: BoxDecoration(
              color: AppTheme.goldMuted,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.gold.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.style_outlined,
                  size: 20,
                  color: AppTheme.gold,
                ),
                const SizedBox(height: AppTheme.space2),
                Text(
                  'Παίξτε τον γύρο',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppTheme.space1),
                Text(
                  'Σύνολο προβλέψεων: $predictionSum / ${game.cardsThisRound}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space5),

          const AppSectionLabel('Προβλέψεις'),
          const SizedBox(height: AppTheme.space2),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (_, i) {
                final player = players[i];
                final pid = player.playerId;
                final name = usernames[pid] ?? '…';
                final isMe = pid == userId;
                final entry = entries.where((e) => e.playerId == pid).toList();
                final prediction =
                    entry.isNotEmpty ? entry.first.prediction : null;
                return PlayerScoreRow(
                  username: name,
                  isMe: isMe,
                  predicted: prediction,
                );
              },
            ),
          ),

          const SizedBox(height: AppTheme.space3),
          FilledButton(
            onPressed: _advancing ? null : _donePlaying,
            child: _advancing
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Τέλος γύρου — Καταχώρηση'),
          ),
        ],
      ),
    );
  }
}
