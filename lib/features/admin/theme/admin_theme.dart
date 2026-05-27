import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTheme {
  // Luxury Dark Palette
  static const Color luxuryBlack = Color(0xFF05070D);
  static const Color sidebarSurface = Color(0xFF0B0B0F);
  static const Color cardSurface = Color(0x08FFFFFF); // rgba(255,255,255,0.03)
  static const Color accentGold = Color(0xFFD4AF37);
  
  // Glowing Accents
  static const Color tealGlow = Color(0xFF00F5D4);
  static const Color purpleGlow = Color(0xFF8B5CF6);
  static const Color orangeGlow = Color(0xFFFF9F43);
  static const Color pinkGlow = Color(0xFFFF2E88);

  // Muted colors
  static const Color textDark = Colors.white;
  static const Color textGrey = Color(0xFF8E8E93);
  static const Color borderGold = Color(0x40D4AF37); // rgba(212,175,55,0.25)

  // Backward compatibility (keeping some old names but mapping to new style)
  static const Color primaryTeal = tealGlow;
  static const Color backgroundCream = luxuryBlack;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: accentGold,
        secondary: tealGlow,
        surface: cardSurface,
        background: luxuryBlack,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -1,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      scaffoldBackgroundColor: luxuryBlack,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderGold, width: 0.5),
        ),
        color: cardSurface,
      ),
    );
  }

  // Maintaining lightTheme getter for legacy calls but making it dark too
  static ThemeData get lightTheme => darkTheme;
}
