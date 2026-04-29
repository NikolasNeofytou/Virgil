import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Section ornament — a Fraunces glyph (default `§`) flanked by ink hairlines.
/// The deck uses these between every numbered section.
///
/// Pass `glyph: '·'` for the lighter mid-section dividers, or any other
/// single character for one-off ornaments. The glyph is rendered in coral
/// to read as a quiet accent against the linen canvas.
class VirgilOrnament extends StatelessWidget {
  const VirgilOrnament({
    super.key,
    this.glyph = '§',
    this.padding = const EdgeInsets.symmetric(vertical: AppTheme.space5),
  });

  final String glyph;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          const Expanded(
            child: Divider(thickness: 1, color: AppTheme.border, height: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space3),
            child: Text(
              glyph,
              style: GoogleFonts.fraunces(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: scheme.primary,
              ),
            ),
          ),
          const Expanded(
            child: Divider(thickness: 1, color: AppTheme.border, height: 1),
          ),
        ],
      ),
    );
  }
}
