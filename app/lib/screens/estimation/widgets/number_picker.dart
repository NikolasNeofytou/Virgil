import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

/// Horizontal grid of number tiles. Selected tile gets a terracotta stamp
/// ring — overshooting at 2.4× and settling to 1.0× in 250ms, per the
/// Virgil identity lock-in motion.
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
        return _NumberTile(
          number: i,
          selected: i == value,
          onTap: enabled ? () => onChanged(i) : null,
        );
      }),
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({
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
    final numeralColor = selected
        ? AppTheme.terra
        : disabled
            ? AppTheme.inkFaint
            : AppTheme.ink;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        splashColor: AppTheme.terraMuted,
        highlightColor: Colors.transparent,
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.paper,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: selected
                  ? AppTheme.terra.withValues(alpha: 0.6)
                  : disabled
                      ? AppTheme.border.withValues(alpha: 0.5)
                      : AppTheme.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (selected)
                TweenAnimationBuilder<double>(
                  key: ValueKey('stamp-$number'),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) {
                    // Scale: 2.4 → 1.0, opacity: ink → settled terra
                    final scale = 2.4 - 1.4 * t;
                    final opacity = (t * 2).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: 0.9 - t * 0.4,
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.terra.withValues(alpha: opacity),
                              width: 1.6,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              Text(
                '$number',
                style: GoogleFonts.fraunces(
                  fontSize: 22,
                  color: numeralColor,
                  height: 1.0,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
