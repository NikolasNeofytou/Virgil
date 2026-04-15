import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Horizontal grid of number buttons 0..max. Selected is filled gold,
/// others are subtle surface tiles. Wraps naturally for bigger ranges.
class NumberPicker extends StatelessWidget {
  const NumberPicker({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
    this.enabled = true,
  });

  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppTheme.space2,
      runSpacing: AppTheme.space2,
      children: List.generate(max + 1, (i) {
        return _NumberBox(
          number: i,
          selected: i == value,
          onTap: enabled ? () => onChanged(i) : null,
        );
      }),
    );
  }
}

class _NumberBox extends StatelessWidget {
  const _NumberBox({
    required this.number,
    required this.selected,
    this.onTap,
  });

  final int number;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.gold
                : disabled
                    ? AppTheme.surface.withValues(alpha: 0.5)
                    : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: selected
                  ? AppTheme.gold
                  : disabled
                      ? AppTheme.border.withValues(alpha: 0.5)
                      : AppTheme.border,
              width: 1,
            ),
          ),
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: selected
                  ? AppTheme.background
                  : disabled
                      ? AppTheme.textTertiary.withValues(alpha: 0.5)
                      : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
