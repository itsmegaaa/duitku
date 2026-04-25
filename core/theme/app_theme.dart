import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Palet Warna (Material Design 3 — Dark Premium)
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color primary = Color(0xFFC9A84C);
  static const Color primaryLight = Color(0xFFF0C96B);
  static const Color primaryDark = Color(0xFF8B6914);
  static const Color accent = Color(0xFFFFD700);
  
  static const Color textMain = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9E9E9E);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color danger = Color(0xFFF44336);
  static const Color inputFill = Color(0xFF1A1A1A);
  static const Color inputBorder = Color(0xFF2A2A2A);
}

class AppTextStyles {
  static final TextStyle display = GoogleFonts.poppins(
    fontWeight: FontWeight.bold,
    fontSize: 36,
    color: AppColors.primary,
  );
  
  static final TextStyle heading = GoogleFonts.poppins(
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 20,
    color: AppColors.textMain,
  );
  
  static final TextStyle body = GoogleFonts.poppins(
    fontWeight: FontWeight.w400, // Regular
    fontSize: 14,
    color: AppColors.textMain,
  );
  
  static final TextStyle caption = GoogleFonts.poppins(
    fontWeight: FontWeight.w300, // Light
    fontSize: 12,
    color: AppColors.textSecondary,
  );
  
  static final TextStyle buttonLabel = GoogleFonts.poppins(
    fontWeight: FontWeight.w500, // Medium
    fontSize: 14,
    color: AppColors.background, // default for solid buttons
  );
  
  static final TextStyle error = GoogleFonts.poppins(
    fontWeight: FontWeight.w400, // Regular
    fontSize: 12,
    color: AppColors.danger,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: AppColors.background,
        onSecondary: AppColors.background,
        onSurface: AppColors.textMain,
        onError: AppColors.textMain,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display,
        titleLarge: AppTextStyles.heading,
        bodyMedium: AppTextStyles.body,
        labelSmall: AppTextStyles.caption,
      ).apply(
        fontFamily: GoogleFonts.poppins().fontFamily,
        bodyColor: AppColors.textMain,
        displayColor: AppColors.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        hintStyle: AppTextStyles.caption,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        errorStyle: AppTextStyles.error,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          textStyle: AppTextStyles.buttonLabel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
