import 'package:flutter/material.dart';

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
                        letterSpacing: 0.3,
                        color: AppTheme.gold,
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
                    ? AppTheme.success
                    : AppTheme.textTertiary,
              ),
            if (statusText != null) ...[
              const SizedBox(width: 6),
              Text(
                statusText!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: highlight ? AppTheme.gold : AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: highlight
                  ? AppTheme.background
                  : AppTheme.textTertiary,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: highlight
                  ? AppTheme.background
                  : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
