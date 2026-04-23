import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

/// Masthead for every in-game phase. Gloock round numeral, JetBrains Mono
/// eyebrow, Caveat dealer byline.
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
        vertical: AppTheme.space4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ΓΥΡΟΣ · ROUND',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 3,
                        color: AppTheme.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$currentRound',
                          style: GoogleFonts.gloock(
                            fontSize: 36,
                            color: AppTheme.ink,
                            height: 1.0,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          ' / $totalRounds',
                          style: GoogleFonts.gloock(
                            fontSize: 20,
                            color: AppTheme.inkFaint,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$cardsThisRound ${cardsThisRound == 1 ? 'κάρτα' : 'κάρτες'}',
                      style: GoogleFonts.kalam(
                        fontSize: 13,
                        color: AppTheme.inkSoft,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (dealerName != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'DEALER',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 3,
                        color: AppTheme.terra,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dealerName!,
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
          const SizedBox(height: AppTheme.space3),
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
        final maxDots =
            ((constraints.maxWidth + gap) / (minDotWidth + gap)).floor();
        final dotCount = total <= maxDots ? total : maxDots;
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
                      ? AppTheme.terra
                      : isPast
                          ? AppTheme.terra.withValues(alpha: 0.5)
                          : AppTheme.paperEdge,
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
