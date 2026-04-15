import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Compact header showing round progress, card count, and dealer name.
/// Displayed at the top of every phase body.
class RoundHeader extends StatelessWidget {
  const RoundHeader({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    required this.cardsThisRound,
    this.dealerName,
  });

  final int currentRound;
  final int totalRounds;
  final int cardsThisRound;
  final String? dealerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Round counter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'ΓΥΡΟΣ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(width: AppTheme.space2),
                        Text(
                          '$currentRound',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.gold,
                            letterSpacing: -0.5,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ $totalRounds',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textTertiary,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$cardsThisRound ${cardsThisRound == 1 ? 'κάρτα' : 'κάρτες'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Dealer pill
              if (dealerName != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space3,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.style_outlined,
                        size: 13,
                        color: AppTheme.textTertiary,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Dealer',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '@$dealerName',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.space3),
          // Dot progress — each round is a dot. Past = gold, current = filled
          // gold, future = border. Scales to fit any round count.
          _DotProgress(current: currentRound, total: totalRounds),
        ],
      ),
    );
  }
}

class _DotProgress extends StatelessWidget {
  const _DotProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minDotWidth = 4.0;
        const gap = 2.0;
        // Cap the dot count so we don't render hundreds at narrow widths.
        final maxDots =
            ((constraints.maxWidth + gap) / (minDotWidth + gap)).floor();
        final dotCount = total <= maxDots ? total : maxDots;
        // Map actual round to the compressed range if needed.
        final scaledCurrent =
            (current * dotCount / total).ceil().clamp(1, dotCount);
        final dotWidth =
            (constraints.maxWidth - gap * (dotCount - 1)) / dotCount;

        return Row(
          children: List.generate(dotCount, (i) {
            final idx = i + 1;
            final isPast = idx < scaledCurrent;
            final isCurrent = idx == scaledCurrent;
            return Padding(
              padding: EdgeInsets.only(right: i < dotCount - 1 ? gap : 0),
              child: Container(
                width: dotWidth,
                height: isCurrent ? 4 : 3,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppTheme.gold
                      : isPast
                          ? AppTheme.gold.withValues(alpha: 0.45)
                          : AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
