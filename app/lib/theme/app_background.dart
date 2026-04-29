import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'meraki_fonts.dart';

/// Virgil page background — a sheet of kafeneio paper, hand-inked.
///
/// Base pageBg color, two soft radial ink stains, and repeating horizontal
/// rules every ~29px to suggest a notebook page. The existing `showGlow`
/// parameter is preserved; when true, the ink stains are rendered; when
/// false, the background is flat paper (useful behind dense screens like
/// the scoring grid).
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.showGlow = true});

  final Widget child;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.pageBg,
      child: CustomPaint(
        painter: _PaperPainter(showStains: showGlow),
        child: child,
      ),
    );
  }
}

class _PaperPainter extends CustomPainter {
  const _PaperPainter({required this.showStains});

  final bool showStains;

  // Tracks AppTheme.ink — Aegean-tinted under Meraki, sepia under the legacy
  // Virgil identity.
  static const _ink = AppTheme.ink;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    if (showStains) {
      // Soft ink stain — upper-left.
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.6, -0.4),
            radius: 0.9,
            colors: [
              _ink.withValues(alpha: 0.04),
              _ink.withValues(alpha: 0.0),
            ],
          ).createShader(rect),
      );
      // Soft ink stain — lower-right.
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0.6, 0.2),
            radius: 0.9,
            colors: [
              _ink.withValues(alpha: 0.03),
              _ink.withValues(alpha: 0.0),
            ],
          ).createShader(rect),
      );
    }

    // Repeating horizontal hairlines — notebook rules.
    final rulePaint = Paint()
      ..color = _ink.withValues(alpha: 0.025)
      ..strokeWidth = 1;
    const gap = 29.0;
    for (double y = gap; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rulePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PaperPainter oldDelegate) =>
      oldDelegate.showStains != showStains;
}

/// A sheet of paper. The foundation of the Virgil aesthetic — warm off-white
/// with a soft warm drop-shadow and near-square corners.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.space4),
    this.highlighted = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: padding,
      decoration: BoxDecoration(
        color: highlighted ? AppTheme.surfaceElevated : AppTheme.paper,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: highlighted ? AppTheme.borderAccent : AppTheme.border,
          width: 1,
        ),
        boxShadow: highlighted ? AppTheme.shadowMd : AppTheme.shadowSm,
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        splashColor: AppTheme.terraMuted,
        highlightColor: Colors.transparent,
        child: content,
      ),
    );
  }
}

/// Eyebrow label — terracotta JetBrains Mono with a leading section mark,
/// followed by a hairline rule. Matches the "§ 01 — Logo exploration"
/// pattern from the Virgil identity sheet.
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel(this.text, {super.key, this.showRule = false});

  final String text;
  final bool showRule;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: MerakiFonts.geistMonoFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.6,
        color: AppTheme.coral,
      ),
    );
    if (!showRule) return label;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        label,
        const SizedBox(width: AppTheme.space3),
        const Expanded(
          child: Divider(color: AppTheme.border, height: 1, thickness: 1),
        ),
      ],
    );
  }
}
