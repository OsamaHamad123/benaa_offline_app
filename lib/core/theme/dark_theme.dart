import 'package:flutter/material.dart';

/// 🎨 Dark Theme Configuration
///
/// ألوان مخصصة للوضع الداكن - OLED friendly
class DarkThemeColors {
  // ألوان أساسية
  static const Color primary = Color(0xFF90CAF9); // أزرق فاتح
  static const Color primaryContainer = Color(0xFF1565C0);
  static const Color secondary = Color(0xFFCE93D8); // بنفسجي فاتح
  static const Color secondaryContainer = Color(0xFF6A1B9A);

  // خلفيات
  static const Color background = Color(0xFF121212); // أسود خالص OLED
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2C2C2C);

  // نصوص
  static const Color onBackground = Color(0xFFE0E0E0);
  static const Color onSurface = Color(0xFFE0E0E0);
  static const Color onSurfaceVariant = Color(0xFFB0B0B0);

  // ألوان وظيفية
  static const Color error = Color(0xFFEF5350);
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // تدرجات للبطاقات
  static const List<Color> cardGradient1 = [
    Color(0xFF1976D2),
    Color(0xFF1565C0),
  ];

  static const List<Color> cardGradient2 = [
    Color(0xFF7B1FA2),
    Color(0xFF6A1B9A),
  ];

  static const List<Color> cardGradient3 = [
    Color(0xFF388E3C),
    Color(0xFF2E7D32),
  ];

  static const List<Color> cardGradient4 = [
    Color(0xFFD32F2F),
    Color(0xFFC62828),
  ];
}

/// 🌞 Light Theme (الموجود)
class LightThemeColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryContainer = Color(0xFFBBDEFB);
  static const Color secondary = Color(0xFF9C27B0);
  static const Color secondaryContainer = Color(0xFFE1BEE7);

  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);
}

/// 🎨 Dark Theme Data
ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // نظام الألوان
    colorScheme: ColorScheme.dark(
      primary: DarkThemeColors.primary,
      primaryContainer: DarkThemeColors.primaryContainer,
      secondary: DarkThemeColors.secondary,
      secondaryContainer: DarkThemeColors.secondaryContainer,
      background: DarkThemeColors.background,
      surface: DarkThemeColors.surface,
      surfaceVariant: DarkThemeColors.surfaceVariant,
      error: DarkThemeColors.error,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onBackground: DarkThemeColors.onBackground,
      onSurface: DarkThemeColors.onSurface,
      onSurfaceVariant: DarkThemeColors.onSurfaceVariant,
      onError: Colors.black,
    ),

    // البطاقات
    cardTheme: CardTheme(
      color: DarkThemeColors.surface,
      elevation: 2,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: DarkThemeColors.surface,
      foregroundColor: DarkThemeColors.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: DarkThemeColors.onSurface,
        fontFamily: 'Cairo',
      ),
    ),

    // الأزرار
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkThemeColors.primary,
        foregroundColor: Colors.black,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: DarkThemeColors.primary,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // حقول النص
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DarkThemeColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DarkThemeColors.onSurfaceVariant.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DarkThemeColors.onSurfaceVariant.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DarkThemeColors.primary, width: 2),
      ),
      labelStyle: TextStyle(color: DarkThemeColors.onSurfaceVariant),
      hintStyle: TextStyle(color: DarkThemeColors.onSurfaceVariant.withOpacity(0.6)),
    ),

    // التبويبات
    tabBarTheme: TabBarTheme(
      labelColor: DarkThemeColors.primary,
      unselectedLabelColor: DarkThemeColors.onSurfaceVariant,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: DarkThemeColors.primary, width: 3),
      ),
    ),

    // الأيقونات
    iconTheme: IconThemeData(
      color: DarkThemeColors.onSurface,
    ),

    // النصوص
    textTheme: TextTheme(
      displayLarge: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
      displayMedium: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
      displaySmall: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
      headlineLarge: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
      headlineMedium: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
      headlineSmall: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
      titleLarge: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
      titleMedium: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
      titleSmall: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
      bodyLarge: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
      bodyMedium: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
      bodySmall: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
      labelLarge: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
      labelMedium: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
      labelSmall: TextStyle(color: DarkThemeColors.onSurface, fontFamily: 'Cairo'),
    ),

    // الخط الأساسي
    fontFamily: 'Cairo',
  );
}
