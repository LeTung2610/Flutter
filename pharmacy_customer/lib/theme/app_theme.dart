import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Masterpiece 2026 Palette
  static const Color primaryTeal = Color(0xFF00D4C4);
  static const Color darkTeal = Color(0xFF004D40);
  static const Color deepTeal = Color(0xFF00796B);
  static const Color softBg = Color(0xFFFDFCFB); // Cream nhạt cao cấp
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color softLavender = Color(0xFFE1BEE7);
  static const Color softTeal = Color(0xFFE0F2F1);
  static const Color errorRed = Color(0xFFFF5252);

  static ThemeData get luxuryTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        onPrimary: pureWhite,
        secondary: deepTeal,
        surface: softBg,
        error: errorRed,
      ),
      scaffoldBackgroundColor: softBg,
      
      // Typography
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 72,
          fontWeight: FontWeight.w900,
          color: darkTeal,
          letterSpacing: -2,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: darkTeal,
          letterSpacing: -1,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: darkTeal,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkTeal,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.black87,
          height: 1.6,
        ),
      ),

      // Components
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkTeal),
      ),
      
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        color: pureWhite,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: pureWhite,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
    );
  }
}
