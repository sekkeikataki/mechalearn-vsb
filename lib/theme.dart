import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MechaTheme {
  static const seed = Color(0xFF1B6CA8);

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    final scheme = base.copyWith(
      primary: const Color(0xFF1565C0),
      secondary: const Color(0xFF00897B),
      tertiary: const Color(0xFFF9A825),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: GoogleFonts.nunitoTextTheme(),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
