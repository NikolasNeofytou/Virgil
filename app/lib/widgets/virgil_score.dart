import 'package:flutter/material.dart';

import '../theme/meraki_tokens.dart';

/// Oldstyle Fraunces score display from the deck's §03.B (SCORE 64/56,
/// Fraunces 500, oldstyle figures).
///
/// Two shapes:
///
/// * Single value — `VirgilScore(value: 247)` → `247`.
/// * Fraction — `VirgilScore(value: 21, outOf: 14)` → `21⁄14`.
///
/// Inherits the score role from MerakiTokens; pass `color` to tint (Coral for
/// "your turn", Myrtle for matched predictions, Ochre for premium tiers).
/// `fontSize` overrides the default 64pt for inline / smaller surfaces.
class VirgilScore extends StatelessWidget {
  const VirgilScore({
    super.key,
    required this.value,
    this.outOf,
    this.color,
    this.fontSize,
  });

  final int value;
  final int? outOf;
  final Color? color;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final tokens = MerakiTokens.of(context);
    final text = outOf == null ? '$value' : '$value⁄$outOf';
    final base = tokens.scoreOldstyle;
    return Text(
      text,
      style: base.copyWith(
        color: color ?? base.color,
        fontSize: fontSize ?? base.fontSize,
      ),
    );
  }
}
