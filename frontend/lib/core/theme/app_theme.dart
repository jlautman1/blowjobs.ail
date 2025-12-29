import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette - EXTRA Bright & Vibrant (Maximum Dopamine!)
  static const Color primary = Color(0xFF00D4FF);        // Electric Cyan - Maximum Energy
  static const Color primaryLight = Color(0xFF00F5FF);   // Bright Cyan - Ultra Friendly
  static const Color primaryDark = Color(0xFF0099CC);   // Deep Cyan
  
  // Accent colors - Ultra Vibrant & Exciting
  static const Color accent = Color(0xFF00E5FF);         // Electric Teal
  static const Color superLike = Color(0xFFB24BF3);       // Electric Purple - Ultra Exciting
  static const Color success = Color(0xFF00FF88);       // Electric Green - Maximum Energy
  static const Color error = Color(0xFFFF6B6B);           // Vibrant Red
  static const Color warning = Color(0xFFFFB800);        // Electric Amber
  static const Color info = Color(0xFF00D4FF);          // Info Cyan
  
  // Additional vibrant colors for more color variety
  static const Color vibrantOrange = Color(0xFFFF6B35);
  static const Color vibrantPink = Color(0xFFFF3B9D);
  static const Color vibrantYellow = Color(0xFFFFD93D);
  
  // Background colors - Clean & Airy
  static const Color background = Color(0xFFFFFFFF);     // Pure white
  static const Color surface = Color(0xFFFFFFFF);       // Pure white
  static const Color surfaceLight = Color(0xFFF8FAFC);  // Very light gray - Airy
  static const Color surfaceBright = Color(0xFFE2E8F0);   // Light divider
  
  // Card background
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text colors - Dark text for light theme
  static const Color textPrimary = Color(0xFF0F172A);    // Primary text
  static const Color textSecondary = Color(0xFF475569);  // Secondary text
  static const Color textTertiary = Color(0xFF94A3B8);   // Muted text
  
  // Gradient colors - ULTRA Vibrant & Energetic (Maximum Dopamine!)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF00F5FF), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Card gradient - Vibrant with color
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Vibrant card gradient with cyan tint
  static const LinearGradient vibrantCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient matchGradient = LinearGradient(
    colors: [Color(0xFF00FF88), Color(0xFF00D4FF), Color(0xFFB24BF3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Background gradient - More alive with subtle color
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Swipe gradients - Ultra vibrant
  static const LinearGradient swipeRightGradient = LinearGradient(
    colors: [Color(0xFF00FF88), Color(0xFF00E676)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient swipeLeftGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient swipeUpGradient = LinearGradient(
    colors: [Color(0xFFB24BF3), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Swipe colors - ULTRA Bright & Vibrant (Maximum Dopamine!)
  static const Color swipeRight = Color(0xFF00FF88);    // Like - Electric Green
  static const Color swipeLeft = Color(0xFFFF6B6B);      // Skip - Vibrant Red
  static const Color swipeUp = Color(0xFFB24BF3);        // Super Like - Electric Purple
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      
      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),
      
      // Text theme - Using Inter for clean, modern look with generous spacing
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -2,
            height: 1.1,
          ),
          displayMedium: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -1.5,
            height: 1.1,
          ),
          displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -1,
            height: 1.2,
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          bodySmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: AppColors.textTertiary,
            height: 1.5,
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
            height: 1.4,
          ),
        ),
      ),
      
      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      
      // Card theme - Premium look with vibrant shadows
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: AppColors.primary.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Elevated button theme - Vibrant, prominent
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      
      // Outlined button theme - Vibrant borders
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      
      // Input decoration theme - Rounded, friendly
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.surfaceBright, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.surfaceBright, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2.5),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.primary.withOpacity(0.15),
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.surfaceBright),
        ),
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceBright,
        thickness: 1,
      ),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}

