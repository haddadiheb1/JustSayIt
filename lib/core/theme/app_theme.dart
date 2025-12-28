import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🌊 PRIMARY PALETTE (Main Brand)
  static const Color primaryIndigo = Color(0xFF4F46E5); // Soft Indigo
  static const Color primaryContainer = Color(0xFFEEF2FF); // Light Indigo
  static const Color onPrimary = Color(0xFFFFFFFF); // White

  // 🌫️ NEUTRAL PALETTE (UI Foundation) - Light Mode
  static const Color backgroundLight = Color(0xFFF9FAFB); // Off White
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  static const Color cardLight = Color(0xFFF1F5F9); // Light Gray
  static const Color textPrimary = Color(0xFF0F172A); // Almost Black
  static const Color textSecondary = Color(0xFF64748B); // Cool Gray
  static const Color divider = Color(0xFFE5E7EB); // Subtle Gray

  // 🌙 DARK MODE PALETTE
  static const Color backgroundDark = Color(0xFF020617); // Deep Navy
  static const Color surfaceDark = Color(0xFF0F172A); // Dark Slate
  static const Color cardDark = Color(0xFF1E293B); // Charcoal
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Soft White
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Muted Gray
  static const Color dividerDark = Color(0xFF1E293B); // Dark Gray
  static const Color primaryIndigoDark =
      Color(0xFF6366F1); // Brighter Indigo for dark mode

  // ✅ ACCENT & STATUS COLORS
  static const Color success = Color(0xFF22C55E); // Soft Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Soft Red
  static const Color info = Color(0xFF38BDF8); // Sky Blue

  // Legacy color names for backward compatibility
  static const Color primaryBlue = primaryIndigo;
  static const Color secondaryGray = cardLight;
  static const Color errorRed = error;
  static const Color accentGreen = success;

  static TextTheme _buildTextTheme(TextTheme base, Color color) {
    return GoogleFonts.interTextTheme(base).copyWith(
      // Title: 22–24sp
      titleLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      // Task: 16–18sp
      bodyLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      // Meta: 12–14sp
      bodySmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.light(
        primary: primaryIndigo,
        primaryContainer: primaryContainer,
        onPrimary: onPrimary,
        secondary: success,
        surface: surfaceLight,
        onSurface: textPrimary,
        error: error,
        onError: onPrimary,
        outline: divider,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: _buildTextTheme(base.textTheme, textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryIndigo,
        foregroundColor: onPrimary,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      dividerColor: divider,
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: ColorScheme.dark(
        primary: primaryIndigoDark,
        primaryContainer: Color(0xFF312E81),
        onPrimary: onPrimary,
        secondary: success,
        surface: surfaceDark,
        onSurface: textPrimaryDark,
        error: error,
        onError: onPrimary,
        outline: dividerDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: _buildTextTheme(base.textTheme, textPrimaryDark),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimaryDark),
        titleTextStyle: GoogleFonts.inter(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryIndigoDark,
        foregroundColor: onPrimary,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      dividerColor: dividerDark,
      dividerTheme: const DividerThemeData(
        color: dividerDark,
        thickness: 1,
      ),
    );
  }
}
