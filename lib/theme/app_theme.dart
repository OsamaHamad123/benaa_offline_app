import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام الثيمات للتطبيق (Material 3 + Cupertino Adaptive)
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // COLOR SCHEME MAPPER
  // ═══════════════════════════════════════════════════════════════════════════

  static Color getColorFromScheme(String scheme) {
    switch (scheme) {
      case 'blue':
        return const Color(0xFF2196F3);
      case 'green':
        return const Color(0xFF4CAF50);
      case 'purple':
        return const Color(0xFF9C27B0);
      case 'orange':
        return const Color(0xFFFF9800);
      case 'red':
        return const Color(0xFFF44336);
      case 'teal':
        return const Color(0xFF009688);
      case 'indigo':
        return const Color(0xFF3F51B5);
      case 'pink':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF2196F3); // default blue
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DYNAMIC THEME BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData buildTheme({
    required Color primaryColor,
    required bool isDark,
    required bool useMaterial3,
    required double fontSize,
  }) {
    // Font size multiplier (base size 14)
    final fontSizeMultiplier = fontSize / 14.0;

    // Create adaptive text theme
    final textTheme = _buildTextTheme(isDark, fontSizeMultiplier);

    if (isDark) {
      return _buildDarkTheme(
        primaryColor: primaryColor,
        useMaterial3: useMaterial3,
        textTheme: textTheme,
      );
    } else {
      return _buildLightTheme(
        primaryColor: primaryColor,
        useMaterial3: useMaterial3,
        textTheme: textTheme,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT THEME BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  static TextTheme _buildTextTheme(bool isDark, double multiplier) {
    final baseColor = isDark ? const Color(0xFFE3E3E3) : const Color(0xFF1A1A1A);
    final secondaryColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF757575);

    return GoogleFonts.cairoTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 57 * multiplier,
          fontWeight: FontWeight.w400,
          color: baseColor,
        ),
        displayMedium: TextStyle(
          fontSize: 45 * multiplier,
          fontWeight: FontWeight.w400,
          color: baseColor,
        ),
        displaySmall: TextStyle(
          fontSize: 36 * multiplier,
          fontWeight: FontWeight.w400,
          color: baseColor,
        ),
        headlineLarge: TextStyle(
          fontSize: 32 * multiplier,
          fontWeight: FontWeight.w700,
          color: baseColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 28 * multiplier,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 24 * multiplier,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        titleLarge: TextStyle(
          fontSize: 22 * multiplier,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16 * multiplier,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        titleSmall: TextStyle(
          fontSize: 14 * multiplier,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16 * multiplier,
          fontWeight: FontWeight.w400,
          color: baseColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14 * multiplier,
          fontWeight: FontWeight.w400,
          color: baseColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12 * multiplier,
          fontWeight: FontWeight.w400,
          color: secondaryColor,
        ),
        labelLarge: TextStyle(
          fontSize: 14 * multiplier,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        labelMedium: TextStyle(
          fontSize: 12 * multiplier,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        labelSmall: TextStyle(
          fontSize: 11 * multiplier,
          fontWeight: FontWeight.w500,
          color: secondaryColor,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData _buildLightTheme({
    required Color primaryColor,
    required bool useMaterial3,
    required TextTheme textTheme,
  }) {
    final primaryLight = Color.alphaBlend(
      Colors.white.withOpacity(0.7),
      primaryColor,
    );
    final primaryDark = Color.alphaBlend(
      Colors.black.withOpacity(0.2),
      primaryColor,
    );

    return ThemeData(
      useMaterial3: useMaterial3,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.cairo().fontFamily,
      textTheme: textTheme,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryLight,
        onPrimaryContainer: primaryDark,
        secondary: primaryColor.withOpacity(0.8),
        onSecondary: Colors.white,
        secondaryContainer: primaryLight,
        onSecondaryContainer: primaryDark,
        tertiary: primaryColor.withOpacity(0.6),
        onTertiary: Colors.white,
        error: const Color(0xFFD32F2F),
        onError: Colors.white,
        errorContainer: const Color(0xFFFFCDD2),
        onErrorContainer: const Color(0xFFB71C1C),
        surface: Colors.white,
        onSurface: const Color(0xFF1A1A1A),
        surfaceContainerHighest: const Color(0xFFF5F5F5),
        outline: const Color(0xFFE0E0E0),
        outlineVariant: const Color(0xFFF0F0F0),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD32F2F)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: primaryColor, width: 2),
          foregroundColor: primaryColor,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F0F0),
        selectedColor: primaryLight,
        labelStyle: const TextStyle(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME - Professional Dark Mode 🌙
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData _buildDarkTheme({
    required Color primaryColor,
    required bool useMaterial3,
    required TextTheme textTheme,
  }) {
    // Enhanced dark colors for better contrast and readability
    final primaryLight = Color.alphaBlend(
      Colors.white.withOpacity(0.3),
      primaryColor,
    );

    // Professional dark palette
    const backgroundDark = Color(
      0xFF121212,
    ); // Pure AMOLED black with slight gray
    const surfaceDark = Color(0xFF1E1E1E); // Elevated surface
    const cardDark = Color(0xFF2C2C2C); // Card background
    const textPrimary = Color(0xFFE3E3E3); // High contrast text
    const textSecondary = Color(0xFFB0B0B0); // Secondary text
    const dividerDark = Color(0xFF3A3A3A); // Subtle dividers

    return ThemeData(
      useMaterial3: useMaterial3,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.cairo().fontFamily,
      textTheme: textTheme,

      colorScheme: ColorScheme.dark(
        primary: primaryLight,
        onPrimary: Colors.black87,
        primaryContainer: primaryColor,
        onPrimaryContainer: primaryLight,
        secondary: primaryLight.withOpacity(0.8),
        onSecondary: Colors.black87,
        secondaryContainer: primaryColor.withOpacity(0.6),
        onSecondaryContainer: primaryLight,
        tertiary: primaryLight.withOpacity(0.6),
        onTertiary: Colors.black87,
        error: const Color(0xFFEF5350),
        onError: Colors.black87,
        errorContainer: const Color(0xFFB71C1C),
        onErrorContainer: const Color(0xFFFFCDD2),
        surface: surfaceDark,
        onSurface: textPrimary,
        surfaceContainerHighest: backgroundDark,
        outline: dividerDark,
        outlineVariant: const Color(0xFF2A2A2A),
      ),

      scaffoldBackgroundColor: backgroundDark,

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 4,
        backgroundColor: surfaceDark,
        foregroundColor: textPrimary,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        shadowColor: Colors.black.withOpacity(0.5),
      ),

      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardDark,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF5350)),
        ),
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          backgroundColor: primaryLight,
          foregroundColor: Colors.black87,
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shadowColor: Colors.black.withOpacity(0.3),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: primaryLight, width: 2),
          foregroundColor: primaryLight,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: primaryLight,
        foregroundColor: Colors.black87,
        elevation: 6,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceDark,
        selectedColor: primaryColor.withOpacity(0.3),
        labelStyle: const TextStyle(fontSize: 14, color: textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: dividerDark),
      ),

      dividerTheme: const DividerThemeData(
        color: dividerDark,
        thickness: 1,
        space: 1,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryLight,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Additional dark theme enhancements
      dialogTheme: DialogThemeData(
        backgroundColor: cardDark,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        contentTextStyle: GoogleFonts.cairo(fontSize: 14, color: textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLight;
          }
          return textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return dividerDark;
        }),
      ),

      listTileTheme: const ListTileThemeData(
        textColor: textPrimary,
        iconColor: textSecondary,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LEGACY THEMES (for backward compatibility)
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData get adaptiveTheme => buildTheme(
        primaryColor: const Color(0xFF2196F3),
        isDark: false,
        useMaterial3: true,
        fontSize: 14.0,
      );

  static ThemeData get adaptiveDarkTheme => buildTheme(
        primaryColor: const Color(0xFF2196F3),
        isDark: true,
        useMaterial3: true,
        fontSize: 14.0,
      );
}
