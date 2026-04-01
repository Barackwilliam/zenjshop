import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color secondary = Color(0xFFFF6B35);
  static const Color gold = Color(0xFFFFD700);

  // Dark Theme Colors
  static const Color bgDark = Color(0xFF0A0F1E);
  static const Color bgCard = Color(0xFF141929);
  static const Color bgSurface = Color(0xFF1E2640);

  // Light Theme Colors
  static const Color bgLight = Color(0xFFF5F7FF);
  static const Color bgCardLight = Color(0xFFFFFFFF);
  static const Color bgSurfaceLight = Color(0xFFEEF0FF);

  // Text Colors — Dark
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF8892B0);
  static const Color textLight = Color(0xFFCCD6F6);

  // Text Colors — Light
  static const Color textDark = Color(0xFF1A1F36);
  static const Color textDarkGrey = Color(0xFF6B7280);
  static const Color textDarkLight = Color(0xFF374151);

  // Status Colors
  static const Color success = Color(0xFF00D68F);
  static const Color warning = Color(0xFFFFAA00);
  static const Color error = Color(0xFFFF3D71);
  static const Color info = Color(0xFF0095FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4B44CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0A0F1E), Color(0xFF141929), Color(0xFF1A2040)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient bgGradientLight = LinearGradient(
    colors: [Color(0xFFF5F7FF), Color(0xFFEEF0FF), Color(0xFFF0F4FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E2640), Color(0xFF141929)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF9A3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  // ==================== DARK THEME ====================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgCard,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w800,
            fontSize: 40,
          ),
          displayMedium: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w700,
            fontSize: 32,
          ),
          headlineLarge: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
          headlineMedium: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
          titleLarge: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          titleMedium: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          bodyLarge: TextStyle(color: AppColors.textLight, fontSize: 16),
          bodyMedium: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2A3158), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 14),
        labelStyle: GoogleFonts.poppins(
          color: AppColors.textGrey,
          fontSize: 14,
        ),
        prefixIconColor: AppColors.textGrey,
        suffixIconColor: AppColors.textGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2A3158), width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgCard,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // ==================== LIGHT THEME ====================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgCardLight,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 40,
          ),
          displayMedium: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 32,
          ),
          headlineLarge: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
          headlineMedium: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
          titleLarge: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          titleMedium: TextStyle(
            color: AppColors.textDarkLight,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          bodyLarge: TextStyle(color: AppColors.textDarkLight, fontSize: 16),
          bodyMedium: TextStyle(color: AppColors.textDarkGrey, fontSize: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDDE0FF), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textDarkGrey,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.poppins(
          color: AppColors.textDarkGrey,
          fontSize: 14,
        ),
        prefixIconColor: AppColors.textDarkGrey,
        suffixIconColor: AppColors.textDarkGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFDDE0FF), width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgCardLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDarkGrey,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
