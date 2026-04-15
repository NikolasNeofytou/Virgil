import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Subtle radial gradient wrapper used as the root of most screens. Gives the
/// app a soft depth without being distracting — a dim gold glow anchored near
/// the top-center, fading into pure black at the edges.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.showGlow = true});

  final Widget child;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        gradient: showGlow
            ? const RadialGradient(
                center: Alignment(0, -0.6),
                radius: 1.4,
                colors: [
                  Color(0x1AD4A94D), // 10% gold
                  Color(0x08D4A94D), // 3% gold
                  Color(0x00000000), // transparent
                ],
                stops: [0.0, 0.3, 0.8],
              )
            : null,
      ),
      child: child,
    );
  }
}

/// A reusable card container — the foundation of the Linear/Notion style.
/// Dark surface, hairline border, optional subtle hover glow.
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
        color: highlighted ? AppTheme.surfaceElevated : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: highlighted ? AppTheme.borderAccent : AppTheme.border,
          width: 1,
        ),
        boxShadow: highlighted ? AppTheme.shadowSm : null,
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        splashColor: AppTheme.goldMuted,
        highlightColor: Colors.transparent,
        child: content,
      ),
    );
  }
}

/// Small uppercase label used to title sections. Think Notion headings.
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AppTheme.textTertiary,
      ),
    );
  }
}
