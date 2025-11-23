import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 🚀 Context Extensions - اختصارات سياق Flutter
///
/// استخدام:
/// ```dart
/// // Navigation
/// context.push(DetailPage());
/// context.pop();
/// context.pushNamed('/dashboard');
///
/// // Theme
/// final primaryColor = context.primaryColor;
/// final textTheme = context.textTheme;
///
/// // Messages
/// context.showSuccess('تم الحفظ بنجاح');
/// context.showError('حدث خطأ');
/// ```
extension ContextExtensions on BuildContext {
  // ========== Navigation Shortcuts ==========
  // NOTE: push/pop removed due to conflict with GoRouter
  // Use context.push() and context.pop() from GoRouter directly

  /// العودة للصفحة الرئيسية (Dashboard)
  void goToDashboard() {
    GoRouter.of(this).go('/dashboard');
  }

  /// هل يمكن العودة؟
  bool get canPop => Navigator.canPop(this);

  // ========== Theme Shortcuts ==========

  /// الثيم الحالي
  ThemeData get theme => Theme.of(this);

  /// نمط النصوص
  TextTheme get textTheme => theme.textTheme;

  /// الألوان
  ColorScheme get colors => theme.colorScheme;

  /// اللون الأساسي
  Color get primaryColor => colors.primary;

  /// لون الخلفية
  Color get backgroundColor => colors.surface;

  /// لون النص
  Color get textColor => colors.onSurface;

  /// هل الوضع الداكن مفعّل؟
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ========== Media Query Shortcuts ==========

  /// حجم الشاشة
  Size get screenSize => MediaQuery.of(this).size;

  /// عرض الشاشة
  double get screenWidth => screenSize.width;

  /// ارتفاع الشاشة
  double get screenHeight => screenSize.height;

  /// نسبة العرض إلى الارتفاع
  double get aspectRatio => screenSize.aspectRatio;

  /// هل الشاشة صغيرة؟ (أقل من 600)
  bool get isSmallScreen => screenWidth < 600;

  /// هل الشاشة متوسطة؟ (600-900)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 900;

  /// هل الشاشة كبيرة؟ (أكبر من 900)
  bool get isLargeScreen => screenWidth >= 900;

  /// Padding أعلى الشاشة (للـ status bar)
  double get topPadding => MediaQuery.of(this).padding.top;

  /// Padding أسفل الشاشة (للـ navigation bar)
  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  /// هل لوحة المفاتيح ظاهرة؟
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  // ========== Snackbar Shortcuts ==========

  /// عرض رسالة نجاح
  void showSuccess(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'حسناً',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// عرض رسالة خطأ
  void showError(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'حسناً',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// عرض رسالة تحذير
  void showWarning(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
        ),
        backgroundColor: Colors.orange[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// عرض رسالة معلومات
  void showInfo(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// إخفاء الـ Snackbar الحالي
  void hideSnackbar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }

  // ========== Dialog Shortcuts ==========

  /// عرض dialog تأكيد
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
  }) {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// عرض dialog معلومات
  Future<void> showInfoDialog({
    required String title,
    required String message,
    String buttonText = 'حسناً',
  }) {
    return showDialog(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // ========== Focus Shortcuts ==========

  /// إخفاء لوحة المفاتيح
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }

  /// نقل الفوكس للحقل التالي
  void nextFocus() {
    FocusScope.of(this).nextFocus();
  }

  /// نقل الفوكس للحقل السابق
  void previousFocus() {
    FocusScope.of(this).previousFocus();
  }

  // ========== Locale Shortcuts ==========

  /// اللغة الحالية
  Locale get locale => Localizations.localeOf(this);

  /// هل اللغة عربية؟
  bool get isArabic => locale.languageCode == 'ar';

  /// اتجاه النص
  TextDirection get textDirection => Directionality.of(this);

  /// هل الاتجاه من اليمين لليسار؟
  bool get isRTL => textDirection == TextDirection.rtl;
}

/// 📅 DateTime Extensions - اختصارات التاريخ
extension DateTimeExtensions on DateTime {
  /// تنسيق التاريخ: DD/MM/YYYY
  String get formatted {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  /// تنسيق التاريخ والوقت: DD/MM/YYYY HH:MM
  String get formattedWithTime {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// هل هو اليوم؟
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// هل هو الأمس؟
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// هل هو هذا الأسبوع؟
  bool get isThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return isAfter(weekAgo) && isBefore(now.add(const Duration(days: 1)));
  }

  /// الفرق بالأيام من الآن
  int get daysFromNow {
    final now = DateTime.now();
    return difference(now).inDays;
  }

  /// الفرق بالساعات من الآن
  int get hoursFromNow {
    final now = DateTime.now();
    return difference(now).inHours;
  }

  /// نص نسبي (منذ ساعة، منذ يومين، إلخ)
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays > 365) {
      final years = (diff.inDays / 365).floor();
      return 'منذ $years ${years == 1 ? "سنة" : "سنوات"}';
    } else if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return 'منذ $months ${months == 1 ? "شهر" : "أشهر"}';
    } else if (diff.inDays > 0) {
      return 'منذ ${diff.inDays} ${diff.inDays == 1 ? "يوم" : "أيام"}';
    } else if (diff.inHours > 0) {
      return 'منذ ${diff.inHours} ${diff.inHours == 1 ? "ساعة" : "ساعات"}';
    } else if (diff.inMinutes > 0) {
      return 'منذ ${diff.inMinutes} ${diff.inMinutes == 1 ? "دقيقة" : "دقائق"}';
    } else {
      return 'الآن';
    }
  }
}

/// 🔢 String Extensions - اختصارات النصوص
extension StringExtensions on String {
  /// هل النص فارغ أو null؟
  bool get isNullOrEmpty => trim().isEmpty;

  /// هل النص ليس فارغاً؟
  bool get isNotNullOrEmpty => trim().isNotEmpty;

  /// تحويل أول حرف لـ capital
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// تحويل إلى رقم (أو null)
  int? get toIntOrNull => int.tryParse(this);

  /// تحويل إلى double (أو null)
  double? get toDoubleOrNull => double.tryParse(this);

  /// هل يحتوي على أرقام فقط؟
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);

  /// هل يحتوي على حروف عربية؟
  bool get hasArabic => RegExp(r'[\u0600-\u06FF]').hasMatch(this);

  /// إزالة المسافات الزائدة
  String get removeExtraSpaces => trim().replaceAll(RegExp(r'\s+'), ' ');
}
