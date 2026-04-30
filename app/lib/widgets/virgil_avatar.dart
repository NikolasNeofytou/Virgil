import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../theme/meraki_tokens.dart';

/// Initial avatar — circular Bone ground, ink hairline border, single
/// uppercase letter in Fraunces. Tonal by design: no status colour, the
/// avatar is "quiet presence" (deck §05 SCREEN 01 cue B).
///
/// Optional [onTap] adds an InkWell with a coral splash, matching the
/// VirgilCard interaction register.
class VirgilAvatar extends StatelessWidget {
  const VirgilAvatar({
    super.key,
    required this.label,
    this.size = 44,
    this.dim = false,
    this.onTap,
  });

  /// Source string for the initial. The first non-whitespace character
  /// is uppercased; an empty string falls back to "·".
  final String label;

  /// Diameter in logical pixels.
  final double size;

  /// Render at 60% opacity — used to mark unavailable/inert states
  /// (e.g. a friend whose room is mid-game and not joinable).
  final bool dim;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = MerakiTokens.of(context);
    final initial = _initialOf(label);

    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.bone,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Text(
        initial,
        style: GoogleFonts.fraunces(
          fontSize: size * 0.46,
          height: 1.0,
          fontWeight: FontWeight.w500,
          color: AppTheme.ink,
          letterSpacing: -0.2,
        ),
      ),
    );

    final body = dim ? Opacity(opacity: 0.6, child: circle) : circle;

    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: tokens.coralMuted,
        highlightColor: Colors.transparent,
        child: body,
      ),
    );
  }

  static String _initialOf(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return '·';
    return trimmed.characters.first.toUpperCase();
  }
}
