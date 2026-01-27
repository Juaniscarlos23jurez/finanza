import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFF5F9F6); // Light mint/cream background
  static const Color primary = Color(0xFF2A8659); // Fresh green
  static const Color secondary = Color(0xFF7A8A7F); // Soft sage
  static const Color accent = Color(0xFFFF9B5E); // Warm orange accent
  static const Color cardBackground = Colors.white;

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
