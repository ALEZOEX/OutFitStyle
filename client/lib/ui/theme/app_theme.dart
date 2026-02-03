import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF0A84FF));
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF3F4F6),
    );

    return baseTheme.copyWith(
      cardTheme: baseTheme.cardTheme.copyWith(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    const bg = Color(0xFF0B0B14);
    const surface = Color(0xFF111126);
    const purple = Color(0xFF7C3AED);
    const purple2 = Color(0xFFA78BFA);

    const scheme = ColorScheme.dark(
      primary: purple,
      secondary: purple2,
      surface: surface,
      error: Color(0xFFEF4444),
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
    );

    return baseTheme.copyWith(
      cardTheme: baseTheme.cardTheme.copyWith(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}
