import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/estimation_providers.dart';
import '../../../theme/app_theme.dart';

/// Final standings after the last round.
class GameOverPanel extends ConsumerWidget {
  const GameOverPanel({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players =
        ref.watch(estimationPlayersStreamProvider(gameId)).valueOrNull ?? [];
    final usernames =
        ref.watch(playerUsernamesProvider(gameId)).valueOrNull ?? {};
    final game =
        ref.watch(estimationGameStreamProvider(gameId)).valueOrNull;

    if (players.isEmpty || game == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final sorted = [...players]
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    final winner = sorted.first;
    final winnerName = usernames[winner.playerId] ?? '???';

    return Padding(
      padding: const EdgeInsets.all(AppTheme.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),

          // Trophy
          Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.goldMuted,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              boxShadow: AppTheme.glow(AppTheme.gold, opacity: 0.25),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: AppTheme.gold,
              size: 44,
            ),
          ),
          const SizedBox(height: AppTheme.space5),
          const Text(
            'ΝΙΚΗΤΗΣ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          Text(
            '@$winnerName',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.gold,
                ),
          ),
          const SizedBox(height: AppTheme.space1),
          Text(
            '${winner.totalScore} πόντοι',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),

          const SizedBox(height: AppTheme.space6),

          // Standings
          ...List.generate(sorted.length, (i) {
            final p = sorted[i];
            final name = usernames[p.playerId] ?? '???';
            final isWinner = i == 0;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space4,
                vertical: AppTheme.space3,
              ),
              decoration: BoxDecoration(
                color: isWinner ? AppTheme.goldMuted : AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: isWinner
                      ? AppTheme.gold.withValues(alpha: 0.4)
                      : AppTheme.border,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isWinner
                            ? AppTheme.gold
                            : AppTheme.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.space2),
                  Expanded(
                    child: Text(
                      '@$name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isWinner
                            ? AppTheme.gold
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${p.totalScore}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: isWinner
                          ? AppTheme.gold
                          : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),

          const Spacer(),

          FilledButton(
            onPressed: () => Navigator.of(context).popUntil(
              (route) => route.isFirst,
            ),
            child: const Text('Πίσω στο μενού'),
          ),
        ],
      ),
    );
  }
}
