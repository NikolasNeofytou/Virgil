import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'meraki_fonts.dart';

/// Meraki design tokens that don't fit Material's ColorScheme / TextTheme /
/// shape system. Wired into ThemeData via `extensions:` and read with
/// `MerakiTokens.of(context)`.
///
/// What lives here vs. on AppTheme / Theme.of(context):
///   • ColorScheme.primary/secondary/tertiary/surface/onSurface — read from
///     `Theme.of(context).colorScheme`. Coral / Myrtle / Ochre / Linen / Ink
///     fill those slots in PR 2; don't duplicate here.
///   • Aegean, Bone, the *Muted variants, the hero radius (16px), and the
///     three Meraki text roles Material's TextTheme can't model (italic verb,
///     eyebrow caption, oldstyle score) — those live here.
@immutable
class MerakiTokens extends ThemeExtension<MerakiTokens> {
  const MerakiTokens({
    required this.aegean,
    required this.ochre,
    required this.ochreMuted,
    required this.myrtleMuted,
    required this.coralMuted,
    required this.bone,
    required this.radiusHero,
    required this.italicVerb,
    required this.eyebrow,
    required this.scoreOldstyle,
  });

  /// Structural color — dark surfaces, navigation grounds, ranked accents.
  /// Not modelled by Material's ColorScheme; reach for it directly when a
  /// surface should read as "the deep ground" (Tournament, ranked tier).
  final Color aegean;

  /// Reward accent — wins, premium scores. Lives on ColorScheme.tertiary,
  /// duplicated here for symmetry with the muted variant.
  final Color ochre;

  /// 20%-alpha ochre — pill backgrounds, soft glows.
  final Color ochreMuted;

  /// 20%-alpha myrtle — success-pill backgrounds.
  final Color myrtleMuted;

  /// 20%-alpha coral — accent-pill backgrounds, focus rings.
  final Color coralMuted;

  /// Secondary surface tone — cards sitting on linen, input fills.
  final Color bone;

  /// Hero-card corner radius (16px). Most surfaces use AppTheme.radiusMd (4);
  /// hero cards in the Lobby / Tournament screens sit at this softer corner.
  final double radiusHero;

  /// Persuasive verb register — Fraunces italic. The "Take your seat /
  /// Sit → / Continue →" voice from the deck.
  final TextStyle italicVerb;

  /// Section eyebrow — Geist Mono 11/16 letter-spaced. Small-caps caption
  /// and ornament label register ("§ 02 — SCORE", "ROOM · ΚΩΔΙΚΟΣ").
  final TextStyle eyebrow;

  /// Score oldstyle — Fraunces 500 with oldstyle figures (descenders on 3-9).
  /// Used for big score displays like "21⁄14".
  final TextStyle scoreOldstyle;

  /// Convenience reader. Throws if [MerakiTokens] is not registered on the
  /// active ThemeData — wire it via `extensions: [MerakiTokens.light]`.
  static MerakiTokens of(BuildContext context) =>
      Theme.of(context).extension<MerakiTokens>()!;

  /// The default Meraki tokens, aligned with the deck spec. Computed at call
  /// time because the GoogleFonts/MerakiFonts helpers can't be const.
  static MerakiTokens get light => MerakiTokens(
        aegean: AppTheme.aegean,
        ochre: AppTheme.ochre,
        ochreMuted: AppTheme.ochreMuted,
        myrtleMuted: AppTheme.myrtleMuted,
        coralMuted: AppTheme.coralMuted,
        bone: AppTheme.bone,
        radiusHero: AppTheme.radiusHero,
        italicVerb: GoogleFonts.fraunces(
          fontSize: 17,
          height: 1.2,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
          letterSpacing: -0.1,
          color: AppTheme.ink,
        ),
        eyebrow: const TextStyle(
          fontFamily: MerakiFonts.geistMonoFamily,
          fontSize: 11,
          height: 16 / 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.6,
          color: AppTheme.inkSoft,
        ),
        scoreOldstyle: GoogleFonts.fraunces(
          fontSize: 64,
          height: 56 / 64,
          fontWeight: FontWeight.w500,
          color: AppTheme.ink,
          fontFeatures: const [FontFeature.oldstyleFigures()],
        ),
      );

  @override
  MerakiTokens copyWith({
    Color? aegean,
    Color? ochre,
    Color? ochreMuted,
    Color? myrtleMuted,
    Color? coralMuted,
    Color? bone,
    double? radiusHero,
    TextStyle? italicVerb,
    TextStyle? eyebrow,
    TextStyle? scoreOldstyle,
  }) =>
      MerakiTokens(
        aegean: aegean ?? this.aegean,
        ochre: ochre ?? this.ochre,
        ochreMuted: ochreMuted ?? this.ochreMuted,
        myrtleMuted: myrtleMuted ?? this.myrtleMuted,
        coralMuted: coralMuted ?? this.coralMuted,
        bone: bone ?? this.bone,
        radiusHero: radiusHero ?? this.radiusHero,
        italicVerb: italicVerb ?? this.italicVerb,
        eyebrow: eyebrow ?? this.eyebrow,
        scoreOldstyle: scoreOldstyle ?? this.scoreOldstyle,
      );

  @override
  MerakiTokens lerp(ThemeExtension<MerakiTokens>? other, double t) {
    if (other is! MerakiTokens) return this;
    return MerakiTokens(
      aegean: Color.lerp(aegean, other.aegean, t)!,
      ochre: Color.lerp(ochre, other.ochre, t)!,
      ochreMuted: Color.lerp(ochreMuted, other.ochreMuted, t)!,
      myrtleMuted: Color.lerp(myrtleMuted, other.myrtleMuted, t)!,
      coralMuted: Color.lerp(coralMuted, other.coralMuted, t)!,
      bone: Color.lerp(bone, other.bone, t)!,
      radiusHero: lerpDouble(radiusHero, other.radiusHero, t)!,
      italicVerb: TextStyle.lerp(italicVerb, other.italicVerb, t)!,
      eyebrow: TextStyle.lerp(eyebrow, other.eyebrow, t)!,
      scoreOldstyle: TextStyle.lerp(scoreOldstyle, other.scoreOldstyle, t)!,
    );
  }
}
