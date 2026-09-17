import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.mustard,
      colorScheme: const ColorScheme.light(
        primary: AppColors.mustard,
        onPrimary: AppColors.charcoalDark,
        secondary: AppColors.charcoalDark,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.charcoalDark,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: AppColors.charcoalDark,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.charcoalDark,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.charcoalDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.charcoal,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.charcoal,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.charcoalMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.charcoalDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.charcoalDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.poppins(
          color: AppColors.charcoalMuted,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.secondary,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
