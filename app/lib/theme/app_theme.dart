import 'package:flutter/material.dart';

/// Balatro-inspired dark theme with gold/amber accents.
class AppTheme {
  AppTheme._();

  // Core palette
  static const Color background = Color(0xFF0B0D12);
  static const Color surface = Color(0xFF14171F);
  static const Color surfaceElevated = Color(0xFF1C2029);
  static const Color gold = Color(0xFFE8B14A);
  static const Color amber = Color(0xFFFFB547);
  static const Color textPrimary = Color(0xFFF4F3EE);
  static const Color textSecondary = Color(0xFFB5B2A7);
  static const Color success = Color(0xFF5FB37A);
  static const Color danger = Color(0xFFE46A6A);

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      surface: surface,
      primary: gold,
      secondary: amber,
      onSurface: textPrimary,
      onPrimary: background,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Inter',
    );
  }
}
