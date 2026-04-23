import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

/// Reusable row showing a player's status in the current phase.
class PlayerScoreRow extends StatelessWidget {
  const PlayerScoreRow({
    super.key,
    required this.username,
    required this.isMe,
    this.statusIcon,
    this.statusText,
    this.predicted,
    this.actual,
    this.score,
    this.highlightBonus = false,
  });

  final String username;
  final bool isMe;
  final IconData? statusIcon;
  final String? statusText;
  final int? predicted;
  final int? actual;
  final int? score;
  final bool highlightBonus;

  @override
  Widget build(BuildContext context) {
    final hasValues = predicted != null || actual != null || score != null;
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
          color: isMe
              ? AppTheme.terra.withValues(alpha: 0.55)
              : AppTheme.border,
          width: isMe ? 1.2 : 1,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    username,
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
          if (hasValues) ...[
            if (predicted != null) _ValueChip(label: 'Πρ', value: '$predicted'),
            if (actual != null) ...[
              const SizedBox(width: 6),
              _ValueChip(label: 'Μπ', value: '$actual'),
            ],
            if (score != null) ...[
              const SizedBox(width: 6),
              _ValueChip(
                label: 'Σκ',
                value: '+$score',
                highlight: highlightBonus,
              ),
            ],
          ] else if (statusIcon != null || statusText != null) ...[
            if (statusIcon != null)
              Icon(
                statusIcon,
                size: 16,
                color: statusIcon == Icons.check_circle
                    ? AppTheme.olive
                    : AppTheme.inkFaint,
              ),
            if (statusText != null) ...[
              const SizedBox(width: 6),
              Text(
                statusText!,
                style: GoogleFonts.kalam(
                  fontSize: 13,
                  color: AppTheme.inkSoft,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final fg = highlight ? AppTheme.olive : AppTheme.ink;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
            color: AppTheme.inkFaint,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: GoogleFonts.gloock(
            fontSize: 18,
            color: fg,
            height: 1.0,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
