import '../../../../../core/utils/haptic_patterns.dart';

/// Dashboard Haptics - ردود فعل لمسية موحدة للداشبورد
class DashboardHaptics {
  // Prevent instantiation
  DashboardHaptics._();

  /// عند تغيير الفلتر
  static void onFilterChange() => HapticPatterns.selection();

  /// عند الضغط على إجراء سريع
  static void onQuickAction() => HapticPatterns.submit();

  /// عند تحديث البيانات
  static void onRefresh() => HapticPatterns.refresh();

  /// عند فتح/إغلاق قسم
  static void onExpand() => HapticPatterns.light();

  /// عند النقر على بطاقة إحصائيات
  static void onStatTap() => HapticPatterns.selection();

  /// عند النجاح (مثل حفظ الفلاتر)
  static void onSuccess() => HapticPatterns.success();

  /// عند حدوث خطأ
  static void onError() => HapticPatterns.error();

  /// عند التنقل لصفحة أخرى
  static void onNavigation() => HapticPatterns.selection();
}
