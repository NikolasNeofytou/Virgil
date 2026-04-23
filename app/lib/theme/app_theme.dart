import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Virgil identity — paper & ink. A kafeneio receipt rendered as an app.
///
/// Fonts: Gloock (display serif), Caveat (UI voice / hand), Kalam (body),
/// JetBrains Mono (metadata, eyebrows). Palette: paper + ink with three
/// regional accents — terracotta (actions), olive (status / match),
/// gold (reserved for bonuses + wins).
class AppTheme {
  AppTheme._();

  // ── Virgil palette ─────────────────────────────────────────────────────────

  /// The page under the sheet — a hair darker than paper.
  static const Color pageBg = Color(0xFFECE1C2);

  /// Paper. Every sheet and surface sits on this.
  static const Color paper = Color(0xFFF4ECD8);

  /// Paper edge — corner folds, inset fills, input backgrounds.
  static const Color paperEdge = Color(0xFFE8D9B0);

  /// Primary ink — text, line art, strokes.
  static const Color ink = Color(0xFF3D2817);

  /// Secondary ink — subtitles, captions.
  static const Color inkSoft = Color(0xFF6B4F3A);

  /// Tertiary ink — faint marginalia, disabled state.
  static const Color inkFaint = Color(0xFF9A7E62);

  /// Terracotta — actions, stamps, focus, the primary accent.
  static const Color terra = Color(0xFFA0522D);
  static const Color terraHover = Color(0xFFB56134);
  static const Color terraMuted = Color(0x33A0522D); // 20% alpha

  /// Olive — status, laurels, match outcomes.
  static const Color olive = Color(0xFF5A6B3D);
  static const Color oliveMuted = Color(0x335A6B3D);

  /// Gold — reserved. Only for bonuses and wins.
  static const Color goldReserved = Color(0xFFB8862E);
  static const Color goldReservedMuted = Color(0x33B8862E);

  // ── Legacy aliases ─────────────────────────────────────────────────────────
  // Kept so existing screens inherit the new identity without per-file edits.
  // The names survive; the values are now the Virgil equivalents.

  static const Color background = paper;
  static const Color surface = paper;
  static const Color surfaceElevated = Color(0xFFEFE5C9); // paper, lifted
  static const Color surfaceHigh = ink; // inverted (snackbar, toasts)

  static const Color border = Color(0x243D2817); // ink @ ~14%
  static const Color borderAccent = Color(0x4D3D2817); // ink @ ~30%

  /// Primary accent — terracotta stands in for the old "gold".
  static const Color gold = terra;
  static const Color goldHover = terraHover;
  static const Color goldMuted = terraMuted;

  /// Amber used to be a hover/glow tint — map to the reserved gold.
  static const Color amber = goldReserved;

  static const Color textPrimary = ink;
  static const Color textSecondary = inkSoft;
  static const Color textTertiary = inkFaint;

  static const Color success = olive;
  static const Color warning = goldReserved;
  static const Color danger = Color(0xFF9E3B2B); // pompeiian rust — reads on paper
  static const Color info = Color(0xFF3E6B7C);

  // ── Radius ──
  // Paper prefers near-square corners. Softened, not rounded.
  static const double radiusSm = 2;
  static const double radiusMd = 4;
  static const double radiusLg = 6;
  static const double radiusXl = 10;

  // ── Spacing rhythm ──
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;
  static const double space7 = 48;
  static const double space8 = 64;

  // ── Shadows (warm, ink-tinted) ──
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0D3D2817), blurRadius: 0, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F3D2817), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x143D2817), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x1A3D2817), blurRadius: 40, offset: Offset(0, 20)),
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

  /// Display serif — the literary weight. Masthead, big numerals, headings.
  static TextStyle display(
          {double fontSize = 48,
          double? height,
          double letterSpacing = -0.5,
          Color color = ink,}) =>
      GoogleFonts.gloock(
        fontSize: fontSize,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );

  /// UI voice — Caveat. Hand-written, warm. Buttons, labels, titles.
  static TextStyle hand(
          {double fontSize = 18,
          FontWeight fontWeight = FontWeight.w700,
          Color color = ink,
          double? height,}) =>
      GoogleFonts.caveat(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );

  /// Body — Kalam, casual hand. Paragraphs, descriptions.
  static TextStyle body(
          {double fontSize = 14,
          FontWeight fontWeight = FontWeight.w400,
          Color color = ink,
          double height = 1.55,}) =>
      GoogleFonts.kalam(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );

  /// Typewriter — JetBrains Mono. Metadata, eyebrows, room codes.
  static TextStyle mono(
          {double fontSize = 10,
          FontWeight fontWeight = FontWeight.w400,
          double letterSpacing = 3,
          Color color = inkSoft,}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color,
      );

  // ── Theme data ─────────────────────────────────────────────────────────────

  /// Returns the Virgil light theme. The name `dark()` is preserved for
  /// backward compatibility with existing call sites; the theme is in fact
  /// a warm light paper theme now.
  static ThemeData dark() => light();

  static ThemeData light() {
    const scheme = ColorScheme.light(
      surface: paper,
      primary: terra,
      secondary: olive,
      tertiary: goldReserved,
      error: danger,
      onSurface: ink,
      onPrimary: paper,
      onSecondary: paper,
      onTertiary: paper,
      onError: paper,
      outline: border,
    );

    final textTheme = TextTheme(
      // Display — Gloock, literary
      displayLarge: GoogleFonts.gloock(
        fontSize: 56, height: 1.0, letterSpacing: -1.2, color: ink,
      ),
      displayMedium: GoogleFonts.gloock(
        fontSize: 44, height: 1.05, letterSpacing: -0.8, color: ink,
      ),
      displaySmall: GoogleFonts.gloock(
        fontSize: 34, height: 1.1, letterSpacing: -0.4, color: ink,
      ),
      headlineLarge: GoogleFonts.gloock(
        fontSize: 28, height: 1.15, letterSpacing: -0.3, color: ink,
      ),
      headlineMedium: GoogleFonts.gloock(
        fontSize: 22, height: 1.2, letterSpacing: -0.2, color: ink,
      ),
      headlineSmall: GoogleFonts.gloock(
        fontSize: 18, height: 1.25, color: ink,
      ),
      // Title — Caveat, hand UI voice
      titleLarge: GoogleFonts.caveat(
        fontSize: 24, fontWeight: FontWeight.w700, color: ink, height: 1.15,
      ),
      titleMedium: GoogleFonts.caveat(
        fontSize: 20, fontWeight: FontWeight.w700, color: ink, height: 1.15,
      ),
      titleSmall: GoogleFonts.caveat(
        fontSize: 18, fontWeight: FontWeight.w700, color: ink, height: 1.15,
      ),
      // Body — Kalam, casual hand
      bodyLarge: GoogleFonts.kalam(
        fontSize: 16, height: 1.55, color: ink,
      ),
      bodyMedium: GoogleFonts.kalam(
        fontSize: 14, height: 1.55, color: ink,
      ),
      bodySmall: GoogleFonts.kalam(
        fontSize: 12, height: 1.5, color: inkSoft,
      ),
      // Labels — Caveat for buttons; JetBrains Mono for metadata eyebrows
      labelLarge: GoogleFonts.caveat(
        fontSize: 20, fontWeight: FontWeight.w700, color: ink,
      ),
      labelMedium: GoogleFonts.jetBrainsMono(
        fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 3,
        color: inkSoft,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 3,
        color: inkFaint,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: pageBg,
      canvasColor: paper,
      textTheme: textTheme,

      // App bar — paper, ink hairline underline.
      appBarTheme: AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.gloock(
          fontSize: 22,
          color: ink,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: ink, size: 22),
        shape: const Border(
          bottom: BorderSide(color: border, width: 1),
        ),
      ),

      // Text fields — paper-edge fill, ink hairline, terracotta focus.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paperEdge.withValues(alpha: 0.45),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space4,
          vertical: space4,
        ),
        labelStyle: GoogleFonts.kalam(
          color: inkSoft,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.kalam(
          color: inkFaint,
          fontSize: 14,
        ),
        floatingLabelStyle: GoogleFonts.jetBrainsMono(
          color: terra,
          fontSize: 11,
          letterSpacing: 2,
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
          borderSide: const BorderSide(color: terra, width: 1.5),
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

      // Filled (primary) button — terracotta stamp on paper.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: terra,
          foregroundColor: paper,
          disabledBackgroundColor: paperEdge,
          disabledForegroundColor: inkFaint,
          padding: const EdgeInsets.symmetric(
            horizontal: space5,
            vertical: space4,
          ),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.caveat(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          elevation: 0,
        ),
      ),

      // Outlined (secondary) button — ink hairline.
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
          textStyle: GoogleFonts.caveat(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Text button.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: terra,
          padding: const EdgeInsets.symmetric(
            horizontal: space3,
            vertical: space2,
          ),
          textStyle: GoogleFonts.caveat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Icon button.
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: inkSoft),
      ),

      // Bottom navigation — paper, ink top hairline, terracotta selected.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: paper,
        indicatorColor: terraMuted,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
            color: selected ? terra : inkFaint,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? terra : inkFaint,
          );
        }),
      ),

      // Snackbar — inverted: ink ground, paper text.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: GoogleFonts.kalam(
          color: paper,
          fontSize: 14,
          height: 1.45,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        elevation: 0,
      ),

      // Dialog — a sheet of paper.
      dialogTheme: DialogThemeData(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: borderAccent),
        ),
        titleTextStyle: GoogleFonts.gloock(
          fontSize: 22,
          color: ink,
          letterSpacing: -0.2,
        ),
        contentTextStyle: GoogleFonts.kalam(
          fontSize: 14,
          color: inkSoft,
          height: 1.55,
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
          backgroundColor: paper,
          foregroundColor: inkSoft,
          selectedBackgroundColor: terraMuted,
          selectedForegroundColor: terra,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.caveat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Progress — terracotta on paper.
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: terra,
        linearTrackColor: paperEdge,
        circularTrackColor: paperEdge,
      ),

      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
