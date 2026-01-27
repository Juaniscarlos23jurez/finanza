import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFF8F9FB); // Premium clean background
  static const Color primary = Color(0xFF1A1A1A); // Sleek charcoal
  static const Color secondary = Color(0xFF6E7191); // Modern muted slate
  static const Color accent = Color(0xFF00D084); // Electric teal (more premium than leaf green)
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFFF4D4D);

  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: background,
      onSurface: primary,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.manrope(
        fontSize: 120,
        fontWeight: FontWeight.w900,
        color: primary,
        letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.manrope(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        color: primary,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        color: secondary,
      ),
    ),
  );
}
