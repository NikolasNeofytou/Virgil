import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Meraki rebrand (Vol. II) — typography helpers.
///
/// Source: design/rebrand_of_Virgil.pptx §03 / §03.B.
///
/// Three voices:
///   • Fraunces — variable display serif, opsz-aware, generous italic.
///     Roles: Display, Title, Score (oldstyle figures).
///   • Inter — workhorse sans. Body, Heading, every label and micro-moment.
///   • Geist Mono — eyebrow labels and credits ("§ 02 — SCORE").
///
/// Wired in PR 1 of the rebrand. PR 2 swaps the AppTheme TextTheme to use
/// these. Until then, no production call site references this class — it
/// exists so the fonts are reachable and verifiable on a live sim.
class MerakiFonts {
  MerakiFonts._();

  // ── Family names ───────────────────────────────────────────────────────────

  /// Local family declared in pubspec.yaml under `flutter.fonts:`.
  /// Geist Mono is not in the Google Fonts catalog (Vercel font, OFL 1.1),
  /// so it is vendored under assets/fonts/.
  static const String geistMonoFamily = 'GeistMono';

  // ── Display · Fraunces ─────────────────────────────────────────────────────

  /// Display — the literary register. Mastheads, big numerals.
  /// Deck spec: 96/96, Fraunces 400, letterSpacing −2.5%.
  static TextStyle display({
    double fontSize = 96,
    double height = 1.0,
    double letterSpacing = -2.4, // ≈ −2.5% of 96
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) =>
      GoogleFonts.fraunces(
        fontSize: fontSize,
        height: height,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight,
        color: color,
      );

  /// Title — section heroes ("Pilotta night.").
  /// Deck spec: 56/60, Fraunces 400.
  static TextStyle title({
    double fontSize = 56,
    double height = 60 / 56,
    double letterSpacing = -0.4,
    FontWeight fontWeight = FontWeight.w400,
    FontStyle fontStyle = FontStyle.normal,
    Color? color,
  }) =>
      GoogleFonts.fraunces(
        fontSize: fontSize,
        height: height,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        color: color,
      );

  /// Score — oldstyle figures ("21⁄14"). Deck spec: 64/56, Fraunces 500.
  static TextStyle score({
    double fontSize = 64,
    double height = 56 / 64,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) =>
      GoogleFonts.fraunces(
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        color: color,
        fontFeatures: const [FontFeature.oldstyleFigures()],
      );

  // ── Body / Heading · Inter ─────────────────────────────────────────────────

  /// Heading — Inter 600. Deck spec: 28/32.
  static TextStyle heading({
    double fontSize = 28,
    double height = 32 / 28,
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = -0.2,
    Color? color,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color,
      );

  /// Body — Inter 400. Deck spec: 17/24.
  static TextStyle body({
    double fontSize = 17,
    double height = 24 / 17,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        color: color,
      );

  // ── Caption · Geist Mono (vendored) ────────────────────────────────────────

  /// Caption — section eyebrows, credits ("§ 02 — SCORE").
  /// Deck spec: 11/16, Geist Mono 500. Loaded from assets/fonts/.
  static TextStyle caption({
    double fontSize = 11,
    double height = 16 / 11,
    FontWeight fontWeight = FontWeight.w500,
    double letterSpacing = 1.6,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: geistMonoFamily,
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color,
      );
}
