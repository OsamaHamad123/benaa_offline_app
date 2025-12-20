import 'package:flutter/material.dart';

/// 📐 نقاط التوقف (Breakpoints) للتصميم المتجاوب
///
/// يحدد أحجام الشاشات المختلفة:
/// - Mobile: < 600px
/// - Tablet: 600px - 900px
/// - Desktop: >= 900px
class AppBreakpoints {
  AppBreakpoints._();

  /// حجم الموبايل (أقل من 600px)
  static const double mobile = 600;

  /// حجم التابلت (600px - 900px)
  static const double tablet = 900;

  /// حجم الديسكتوب (أكبر من 900px)
  static const double desktop = 1200;

  /// التحقق من كون الجهاز موبايل
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  /// التحقق من كون الجهاز تابلت
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  /// التحقق من كون الجهاز ديسكتوب
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  /// الحصول على قيمة بناءً على حجم الشاشة
  ///
  /// مثال:
  /// ```dart
  /// final columns = AppBreakpoints.responsive<int>(
  ///   context: context,
  ///   mobile: 1,
  ///   tablet: 2,
  ///   desktop: 3,
  /// );
  /// ```
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// الحصول على عدد الأعمدة بناءً على حجم الشاشة
  static int getColumns(BuildContext context) {
    return responsive<int>(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );
  }

  /// الحصول على Padding بناءً على حجم الشاشة
  static double getPadding(BuildContext context) {
    return responsive<double>(
      context: context,
      mobile: 16,
      tablet: 24,
      desktop: 32,
    );
  }

  /// الحصول على عرض الـ Content بناءً على حجم الشاشة
  static double getContentWidth(BuildContext context) {
    return responsive<double>(
      context: context,
      mobile: double.infinity,
      tablet: 720,
      desktop: 1024,
    );
  }

  /// الحصول على نوع الجهاز كـ String (للتصحيح)
  static String getDeviceType(BuildContext context) {
    if (isDesktop(context)) return 'Desktop';
    if (isTablet(context)) return 'Tablet';
    return 'Mobile';
  }
}
