import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/meraki_tokens.dart';

/// Surface card with two registers from the deck:
///
/// * `standard` — bone ground, near-square 4-px corners, ink hairline border.
///   The everyday surface — list rows, secondary cards, sub-sections.
/// * `hero` — linen ground, generous 16-px corners, soft Aegean-ink shadow.
///   The featured surface — Lobby daily-moment, Tournament hero, room code.
///
/// Optional `onTap` adds an InkWell with a coral splash, no highlight.
enum VirgilCardVariant { standard, hero }

class VirgilCard extends StatelessWidget {
  const VirgilCard({
    super.key,
    required this.child,
    this.variant = VirgilCardVariant.standard,
    this.padding = const EdgeInsets.all(AppTheme.space4),
    this.onTap,
  });

  final Widget child;
  final VirgilCardVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = MerakiTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isHero = variant == VirgilCardVariant.hero;
    final radius = isHero ? tokens.radiusHero : AppTheme.radiusMd;
    final ground = isHero ? scheme.surface : tokens.bone;
    final border =
        isHero ? null : Border.all(color: AppTheme.border, width: 1);
    final shadow = isHero ? AppTheme.shadowSm : null;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: ground,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: shadow,
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: tokens.coralMuted,
        highlightColor: Colors.transparent,
        child: content,
      ),
    );
  }
}
