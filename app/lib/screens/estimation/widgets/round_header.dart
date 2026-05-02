import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/meraki_fonts.dart';

/// Masthead for every in-game phase. Gloock round numeral, JetBrains Mono
/// eyebrow, Caveat dealer + starter bylines.
class RoundHeader extends StatelessWidget {
  const RoundHeader({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    required this.cardsThisRound,
    this.dealerName,
    this.starterName,
  });

  final int currentRound;
  final int totalRounds;
  final int cardsThisRound;
  final String? dealerName;
  final String? starterName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                      l10n.gameRoundEyebrow,
                      style: const TextStyle(fontFamily: MerakiFonts.geistMonoFamily,
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
                          style: GoogleFonts.fraunces(
                            fontSize: 36,
                            color: AppTheme.ink,
                            height: 1.0,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          ' / $totalRounds',
                          style: GoogleFonts.fraunces(
                            fontSize: 20,
                            color: AppTheme.inkFaint,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.gameCardsThisRound(cardsThisRound),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.inkSoft,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (dealerName != null || starterName != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (starterName != null) ...[
                      _HeaderLine(
                        label: l10n.roundHeaderLeadsLabel,
                        value: starterName!,
                        accent: AppTheme.terra,
                      ),
                    ],
                    if (dealerName != null && starterName != null)
                      const SizedBox(height: 6),
                    if (dealerName != null)
                      _HeaderLine(
                        label: l10n.roundHeaderDealerLabel,
                        value: dealerName!,
                        accent: AppTheme.inkSoft,
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

/// One labeled byline on the right of the round header — JetBrains Mono
/// eyebrow, Caveat name.
class _HeaderLine extends StatelessWidget {
  const _HeaderLine({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontFamily: MerakiFonts.geistMonoFamily, 
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 3,
            color: accent,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, 
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
            height: 1.0,
          ),
        ),
      ],
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
