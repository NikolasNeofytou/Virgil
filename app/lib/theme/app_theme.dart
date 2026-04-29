import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'meraki_fonts.dart';
import 'meraki_tokens.dart';

/// Virgil identity — Vol. II "Meraki, refined".
///
/// Source: design/rebrand_of_Virgil.pptx. Seven hues, three voices, strict
/// rhythm. Aegean carries structure, Coral signals action, Ochre and Myrtle
/// add warmth without volume. Type is Fraunces (display, italic verbs),
/// Inter (body, headings, labels), Geist Mono (eyebrow captions).
///
/// Legacy aliases (`paper`, `terra`, `olive`, `goldReserved`, etc.) are kept
/// pointing at the new tokens so existing call sites inherit the rebrand
/// without a per-file edit. PR 3 introduces a ThemeExtension for the tokens
/// Material's `ColorScheme` does not model.
class AppTheme {
  AppTheme._();

  // ── Meraki palette (the seven hues) ────────────────────────────────────────

  /// Structure, navigation, dark surfaces, ranked accents.
  static const Color aegean = Color(0xFF1F2A5C);

  /// Body type, deepest contrast.
  static const Color ink = Color(0xFF14193F);

  /// Softer ink — secondary text, captions.
  static const Color inkSoft = Color(0xFF4A4F6B);

  /// Tertiary ink — disabled state, faint marginalia.
  static const Color inkFaint = Color(0xFF8489A0);

  /// Action — CTAs, "your turn", emphasis.
  static const Color coral = Color(0xFFD9573F);
  static const Color coralHover = Color(0xFFE0654E);
  static const Color coralMuted = Color(0x33D9573F); // 20% alpha

  /// Reward — wins, scores, premium accents.
  static const Color ochre = Color(0xFFC39448);
  static const Color ochreMuted = Color(0x33C39448);

  /// Affirm — success, online, gentle confirms.
  static const Color myrtle = Color(0xFF4F6B5C);
  static const Color myrtleMuted = Color(0x334F6B5C);

  /// Cards, secondary surfaces.
  static const Color bone = Color(0xFFEBE2D3);

  /// Default canvas — calm space.
  static const Color linen = Color(0xFFF6EFE6);

  // ── Legacy aliases ─────────────────────────────────────────────────────────
  // Names from the pre-Meraki palette, repointed at the new hues so existing
  // screens absorb the rebrand without per-file edits. Treat new code as
  // referencing the Meraki tokens above (or, after PR 3, the ThemeExtension).

  static const Color pageBg = bone;
  static const Color paper = linen;
  static const Color paperEdge = bone;

  static const Color background = linen;
  static const Color surface = linen;
  static const Color surfaceElevated = linen; // a hair-lifted card sits flat now
  static const Color surfaceHigh = ink; // inverted (snackbars, toasts)

  /// Hairline ink — used for borders and dividers.
  static const Color border = Color(0x2414193F); // ink @ ~14%
  static const Color borderAccent = Color(0x4D14193F); // ink @ ~30%

  static const Color terra = coral;
  static const Color terraHover = coralHover;
  static const Color terraMuted = coralMuted;
  static const Color olive = myrtle;
  static const Color oliveMuted = myrtleMuted;
  static const Color goldReserved = ochre;
  static const Color goldReservedMuted = ochreMuted;

  /// Pre-Meraki "gold" is the action accent — Coral now.
  static const Color gold = coral;
  static const Color goldHover = coralHover;
  static const Color goldMuted = coralMuted;

  /// Pre-Meraki "amber" was a hover/glow tint — Ochre now.
  static const Color amber = ochre;

  static const Color textPrimary = ink;
  static const Color textSecondary = inkSoft;
  static const Color textTertiary = inkFaint;

  static const Color success = myrtle;
  static const Color warning = ochre;
  static const Color danger = Color(0xFF9E3B2B); // pompeiian rust — reads on linen
  static const Color info = aegean;

  // ── Radius ──
  // Most surfaces sit at near-square 4-px corners; hero cards get 16-px.
  static const double radiusSm = 2;
  static const double radiusMd = 4;
  static const double radiusLg = 6;
  static const double radiusXl = 10;
  static const double radiusHero = 16;

  // ── Spacing rhythm ──
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;
  static const double space7 = 48;
  static const double space8 = 64;

  // ── Shadows (Aegean-ink tinted) ──
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0D14193F), blurRadius: 0, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F14193F), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x1414193F), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x1A14193F), blurRadius: 40, offset: Offset(0, 20)),
  ];

  /// Soft stain around an element — used for focus rings and splash highlights.
  static List<BoxShadow> glow(Color color, {double opacity = 0.18}) => [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          blurRadius: 24,
          spreadRadius: 1,
        ),
      ];

  // ── Font helpers ───────────────────────────────────────────────────────────
  // Pre-Meraki names are preserved so existing call sites inherit the new
  // typography. Bodies route through `MerakiFonts` so the deck spec stays
  // canonical in one place.

  /// Display serif — Fraunces. Mastheads, big numerals, hero headings.
  static TextStyle display({
    double fontSize = 48,
    double? height,
    double letterSpacing = -0.5,
    FontWeight fontWeight = FontWeight.w400,
    Color color = ink,
  }) =>
      MerakiFonts.title(
        fontSize: fontSize,
        height: height ?? 1.05,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight,
        color: color,
      );

  /// Persuasive verb voice — Fraunces italic. The "Take your seat / Sit / Continue"
  /// register from the deck. Replaces the old hand-written Caveat.
  static TextStyle hand({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w500,
    Color color = ink,
    double? height,
  }) =>
      MerakiFonts.title(
        fontSize: fontSize,
        height: height ?? 1.2,
        fontWeight: fontWeight,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.1,
        color: color,
      );

  /// Body — Inter. Paragraphs, descriptions, everything in product flow.
  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = ink,
    double height = 1.55,
  }) =>
      MerakiFonts.body(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );

  /// Eyebrow caption — Geist Mono. Section marks, metadata, room codes.
  static TextStyle mono({
    double fontSize = 10,
    FontWeight fontWeight = FontWeight.w500,
    double letterSpacing = 1.6,
    Color color = inkSoft,
  }) =>
      MerakiFonts.caption(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color,
      );

  // ── Theme data ─────────────────────────────────────────────────────────────

  /// Returns the Meraki light theme. The `dark()` alias is preserved for
  /// backward compatibility with existing call sites; the theme is a calm
  /// linen-on-ink light theme.
  static ThemeData dark() => light();

  static ThemeData light() {
    const scheme = ColorScheme.light(
      surface: linen,
      primary: coral,
      secondary: myrtle,
      tertiary: ochre,
      error: danger,
      onSurface: ink,
      onPrimary: linen,
      onSecondary: linen,
      onTertiary: ink,
      onError: linen,
      outline: border,
    );

    final textTheme = TextTheme(
      // Display — Fraunces (deck Display 96/96, scaled down for Material slots)
      displayLarge: GoogleFonts.fraunces(
        fontSize: 96, height: 1.0, letterSpacing: -2.4, color: ink,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 72, height: 1.0, letterSpacing: -1.6, color: ink,
      ),
      displaySmall: GoogleFonts.fraunces(
        fontSize: 56, height: 60 / 56, letterSpacing: -0.4, color: ink,
      ),
      // Headline — Inter 600 (deck Heading 28/32)
      headlineLarge: GoogleFonts.inter(
        fontSize: 28, height: 32 / 28, fontWeight: FontWeight.w600,
        letterSpacing: -0.2, color: ink,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22, height: 1.25, fontWeight: FontWeight.w600,
        letterSpacing: -0.1, color: ink,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18, height: 1.3, fontWeight: FontWeight.w600, color: ink,
      ),
      // Title — Fraunces, smaller hero register
      titleLarge: GoogleFonts.fraunces(
        fontSize: 28, height: 1.15, fontWeight: FontWeight.w400,
        letterSpacing: -0.2, color: ink,
      ),
      titleMedium: GoogleFonts.fraunces(
        fontSize: 22, height: 1.2, fontWeight: FontWeight.w400, color: ink,
      ),
      titleSmall: GoogleFonts.fraunces(
        fontSize: 18, height: 1.25, fontWeight: FontWeight.w500, color: ink,
      ),
      // Body — Inter 400 (deck Body 17/24)
      bodyLarge: GoogleFonts.inter(
        fontSize: 17, height: 24 / 17, color: ink,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15, height: 1.5, color: ink,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13, height: 1.5, color: inkSoft,
      ),
      // Labels — Inter 600 for buttons; Geist Mono for caption eyebrows
      labelLarge: GoogleFonts.inter(
        fontSize: 17, height: 1.0, fontWeight: FontWeight.w600, color: ink,
      ),
      labelMedium: const TextStyle(
        fontFamily: MerakiFonts.geistMonoFamily,
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.6,
        color: inkSoft,
      ),
      labelSmall: const TextStyle(
        fontFamily: MerakiFonts.geistMonoFamily,
        fontSize: 10,
        height: 1.4,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.4,
        color: inkFaint,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: linen,
      canvasColor: linen,
      textTheme: textTheme,

      // App bar — linen, ink hairline underline, Fraunces title.
      appBarTheme: AppBarTheme(
        backgroundColor: linen,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: ink,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: ink, size: 22),
        shape: const Border(
          bottom: BorderSide(color: border, width: 1),
        ),
      ),

      // Text fields — bone fill, ink hairline, coral focus.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bone.withValues(alpha: 0.55),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space4,
          vertical: space4,
        ),
        labelStyle: GoogleFonts.inter(
          color: inkSoft,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.inter(
          color: inkFaint,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: MerakiFonts.geistMonoFamily,
          color: coral,
          fontSize: 11,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: coral, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
      ),

      // Filled (primary) button — coral on linen, italic Fraunces verb.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: coral,
          foregroundColor: linen,
          disabledBackgroundColor: bone,
          disabledForegroundColor: inkFaint,
          padding: const EdgeInsets.symmetric(
            horizontal: space5,
            vertical: space4,
          ),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.fraunces(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.1,
          ),
          elevation: 0,
        ),
      ),

      // Outlined (secondary) button — ink hairline, Inter 600.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: borderAccent, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: space5,
            vertical: space4,
          ),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text button — coral, italic Fraunces verb (matches "Sit →" / "Continue →").
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: coral,
          padding: const EdgeInsets.symmetric(
            horizontal: space3,
            vertical: space2,
          ),
          textStyle: GoogleFonts.fraunces(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.1,
          ),
        ),
      ),

      // Icon button.
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: inkSoft),
      ),

      // Bottom navigation — linen, ink top hairline, coral selected, mono labels.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: linen,
        indicatorColor: coralMuted,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: MerakiFonts.geistMonoFamily,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.4,
            color: selected ? coral : inkFaint,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? coral : inkFaint,
          );
        }),
      ),

      // Snackbar — inverted: ink ground, linen text.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: GoogleFonts.inter(
          color: linen,
          fontSize: 15,
          height: 1.45,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        elevation: 0,
      ),

      // Dialog — a sheet of linen.
      dialogTheme: DialogThemeData(
        backgroundColor: linen,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: borderAccent),
        ),
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: ink,
          letterSpacing: -0.2,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 15,
          color: inkSoft,
          height: 1.5,
        ),
      ),

      // Dividers — ink hairline.
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // Segmented button.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: linen,
          foregroundColor: inkSoft,
          selectedBackgroundColor: coralMuted,
          selectedForegroundColor: coral,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Progress — coral on linen.
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: coral,
        linearTrackColor: bone,
        circularTrackColor: bone,
      ),

      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,

      // Meraki tokens that don't fit Material's slot system — Aegean, Bone,
      // muted accents, hero radius, italic-verb / eyebrow / score text roles.
      // Read with `MerakiTokens.of(context)`.
      extensions: [MerakiTokens.light],
    );
  }
}
