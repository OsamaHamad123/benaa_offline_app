import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Advanced Typography System with Arabic Font Support
class AppTypography {
  // Font Families (يمكن تخصيصها لاحقاً)
  static const String primaryFontFamily = 'Cairo';
  static const String secondaryFontFamily = 'Tajawal';

  // Display styles (for headers)
  static TextStyle displayLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle displayMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle displaySmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // Headline styles
  static TextStyle headlineLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 22.sp,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle headlineMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle headlineSmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Title styles
  static TextStyle titleLarge = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static TextStyle titleMedium = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static TextStyle titleSmall = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // Body styles (for content)
  static TextStyle bodyLarge = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    height: 1.6,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    height: 1.6,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    height: 1.6,
  );

  // Label styles (for buttons, chips, etc.)
  static TextStyle labelLarge = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle labelMedium = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle labelSmall = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // Special styles
  static TextStyle caption = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 11.sp,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: Colors.grey[600],
  );

  static TextStyle overline = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // Numbers style (for statistics)
  static TextStyle numberLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    height: 1.0,
    letterSpacing: -1.0,
  );

  static TextStyle numberMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    height: 1.0,
    letterSpacing: -0.5,
  );

  static TextStyle numberSmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    height: 1.0,
  );

  // Get TextTheme for ThemeData
  static TextTheme getTextTheme() {
    return TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }

  // Get dark TextTheme
  static TextTheme getDarkTextTheme() {
    return getTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );
  }
}

/// Gradient Text Widget
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText({
    super.key,
    required this.text,
    required this.style,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
