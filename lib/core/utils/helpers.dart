import 'package:flutter/material.dart';

/// 🎨 Color Extensions - تحسينات على الألوان
/// بديل لـ withOpacity المهمل

extension ColorExtensions on Color {
  /// بديل لـ withOpacity - يستخدم withValues
  Color withAlpha(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withValues(alpha: opacity);
  }

  /// تفتيح اللون
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );

    return hslLight.toColor();
  }

  /// تغميق اللون
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }
}

/// 🔢 Number Formatting Extensions
extension NumberFormatting on num {
  /// تنسيق الأرقام بالفاصلة
  String formatWithCommas() {
    final parts = toString().split('.');
    final beforeDecimal = parts[0];
    final afterDecimal = parts.length > 1 ? '.${parts[1]}' : '';

    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = beforeDecimal.replaceAllMapped(
      regExp,
      (Match m) => '${m[1]},',
    );

    return formatted + afterDecimal;
  }

  /// تحويل bytes إلى حجم قابل للقراءة
  String formatBytes() {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = toDouble();
    var suffixIndex = 0;

    while (value >= 1024 && suffixIndex < suffixes.length - 1) {
      value /= 1024;
      suffixIndex++;
    }

    return '${value.toStringAsFixed(2)} ${suffixes[suffixIndex]}';
  }
}

/// 📅 DateTime Extensions
extension DateTimeFormatting on DateTime {
  /// تنسيق التاريخ بالعربي
  String formatArabic() {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'إبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return '$day ${months[month - 1]} $year';
  }

  /// تنسيق الوقت بالعربي
  String formatTimeArabic() {
    final period = hour >= 12 ? 'مساءً' : 'صباحاً';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');

    return '$hour12:$minuteStr $period';
  }

  /// منذ كم من الوقت
  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'منذ $years ${years == 1 ? "سنة" : "سنوات"}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months ${months == 1 ? "شهر" : "أشهر"}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? "يوم" : "أيام"}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? "ساعة" : "ساعات"}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? "دقيقة" : "دقائق"}';
    } else {
      return 'الآن';
    }
  }
}

/// 📝 String Extensions
extension StringExtensions on String {
  /// التحقق من أن النص باللغة العربية
  bool get isArabic {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(this);
  }

  /// تنظيف الأرقام العربية
  String normalizeArabicNumbers() {
    const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = this;

    for (var i = 0; i < arabicNums.length; i++) {
      result = result.replaceAll(arabicNums[i], i.toString());
    }

    return result;
  }

  /// تقصير النص مع ...
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

/// 📱 BuildContext Extensions
extension ContextExtensions on BuildContext {
  /// الحصول على MediaQuery
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// الحصول على Theme
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  /// التحقق من حجم الشاشة
  bool get isSmallScreen => screenWidth < 600;
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 900;
  bool get isLargeScreen => screenWidth >= 900;

  /// Navigation helpers
  void pop([dynamic result]) => Navigator.of(this).pop(result);
  Future<T?> push<T>(Widget page) =>
      Navigator.of(this).push<T>(MaterialPageRoute(builder: (_) => page));

  /// Snackbar helpers
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// 🎯 Validation Helpers
class Validators {
  /// التحقق من الرقم الوطني
  static String? nationalId(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال الرقم الوطني';
    }

    final normalized = value.normalizeArabicNumbers();
    if (!RegExp(r'^\d{11}$').hasMatch(normalized)) {
      return 'الرقم الوطني يجب أن يكون 11 رقماً';
    }

    return null;
  }

  /// التحقق من رقم الهاتف
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }

    final normalized = value.normalizeArabicNumbers();
    if (!RegExp(r'^\d{10}$').hasMatch(normalized)) {
      return 'رقم الهاتف يجب أن يكون 10 أرقام';
    }

    return null;
  }

  /// التحقق من الاسم
  static String? required(String? value, [String fieldName = 'هذا الحقل']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  /// التحقق من البريد الإلكتروني
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  /// التحقق من الرقم
  static String? number(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم';
    }

    final normalized = value.normalizeArabicNumbers();
    final number = int.tryParse(normalized);

    if (number == null) {
      return 'الرجاء إدخال رقم صحيح';
    }

    if (min != null && number < min) {
      return 'القيمة يجب أن تكون على الأقل $min';
    }

    if (max != null && number > max) {
      return 'القيمة يجب ألا تتجاوز $max';
    }

    return null;
  }
}

/// 🎨 UI Constants
class UIConstants {
  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Spacing
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;
  static const double spaceXLarge = 32.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Elevation
  static const double elevationSmall = 1.0;
  static const double elevationMedium = 2.0;
  static const double elevationLarge = 4.0;
  static const double elevationXLarge = 8.0;

  // Animation Duration
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}
