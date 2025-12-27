import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryBlue = Color(0xFF5C6BC0); // Soft Indigo
  static const Color secondaryGray = Color(0xFFF5F5F5); // Neutral Gray Light
  static const Color secondaryGrayDark = Color(0xFF2C2C2C); // Neutral Gray Dark
  static const Color accentGreen = Color(0xFF81C784); // Subtle Green
  static const Color errorRed = Color(0xFFE57373);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static TextTheme _buildTextTheme(TextTheme base, Color color) {
    return GoogleFonts.interTextTheme(base).apply(
      bodyColor: color,
      displayColor: color,
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentGreen,
        surface: surfaceLight,
        // background deprecated for surface
        error: errorRed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: secondaryGray,
      // useMaterial3 default true in recent versions, explicitly setting in constructor or here is fine but copyWith might warn.
      // We will assume modern flutter and remove explicit useMaterial3 if copyWith warns,
      // but to be safe lets reconstruct ThemeData using .from or similar if needed.
      // However, the cleanest fix for "CardTheme" error is ensuring we pass CardTheme type.
      textTheme: _buildTextTheme(base.textTheme, Colors.black87),
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryGray,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentGreen,
        surface: surfaceDark,
        // background deprecated
        error: errorRed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: secondaryGrayDark,
      textTheme: _buildTextTheme(base.textTheme, Colors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryGrayDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }
}
