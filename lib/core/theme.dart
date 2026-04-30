// lib/core/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Vibrant Gym Palette ───────────────────────────────────────────────────
  static const Color primary = Color(0xFFFF2D55); // Brilliant electric red
  static const Color surface = Color(0xFF1C1C1E); // Apple-style dark surface
  static const Color background = Color(0xFF000000); // True black
  static const Color card = Color(0xFF2C2C2E); // Deep grey card
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color success = Color(0xFF32D74B); // Vibrant neon green
  static const Color warning = Color(0xFFFFD60A);

  static ThemeData get dark {
    final baseTheme = ThemeData(brightness: Brightness.dark);
    
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      
      // ── Typography ──────────────────────────────────────────────────────────
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 15,
        ),
      ),

      // ── Components ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: background.withOpacity(0.8),
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: textSecondary.withOpacity(0.1), width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.5)),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),

      useMaterial3: true,
    );
  }
}
