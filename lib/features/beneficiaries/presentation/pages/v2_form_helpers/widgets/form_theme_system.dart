import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎨 نظام موحد لتصميم عناصر النموذج (Form Theme System)
///
/// يوفر تصميمات متناسقة لجميع عناصر واجهة المستخدم:
/// - الحقول (Text Fields)
/// - الأزرار (Buttons)
/// - القوائم المنسدلة (Dropdowns)
/// - البطاقات (Cards)

class FormFieldTheme {
  /// تصميم موحد لحقول الإدخال - Material 3 Style
  static InputDecoration standardDecoration({
    required BuildContext context,
    required String label,
    bool isRequired = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? helperText,
    String? hintText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      labelText: isRequired ? '$label *' : label,
      hintText: hintText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,

      // Material 3 Filled style
      filled: true,
      fillColor: isDark
          ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
          : theme.colorScheme.surfaceVariant.withOpacity(0.3),

      // حدود منحنية
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide.none,
      ),

      // حالة enabled
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),

      // حالة focused
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),

      // حالة error
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(
          color: theme.colorScheme.error.withOpacity(0.5),
          width: 1,
        ),
      ),

      // حالة focused مع error
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
      ),

      // padding داخلي
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
    );
  }

  /// تصميم للحقول الكبيرة (Multi-line)
  static InputDecoration largeFieldDecoration({
    required BuildContext context,
    required String label,
    bool isRequired = false,
    String? helperText,
  }) {
    return standardDecoration(
      context: context,
      label: label,
      isRequired: isRequired,
      helperText: helperText,
    ).copyWith(contentPadding: EdgeInsets.all(20.w));
  }
}

/// 🔘 نظام موحد للأزرار
class FormButtons {
  /// Primary Button - للعمليات الأساسية (حفظ، إرسال)
  static Widget primary({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool isFullWidth = true,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        final button = icon != null
            ? FilledButton.icon(
                onPressed: isLoading ? null : onPressed,
                icon: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Icon(icon, size: 20.sp),
                label: Text(label),
                style: _primaryButtonStyle(context),
              )
            : FilledButton(
                onPressed: isLoading ? null : onPressed,
                style: _primaryButtonStyle(context),
                child: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Text(label),
              );

        return isFullWidth
            ? SizedBox(width: double.infinity, child: button)
            : button;
      },
    );
  }

  static ButtonStyle _primaryButtonStyle(BuildContext context) {
    return FilledButton.styleFrom(
      minimumSize: Size(120.w, 56.h),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
    );
  }

  /// Secondary Button - للعمليات الثانوية (إلغاء، رجوع)
  static Widget secondary({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isFullWidth = true,
  }) {
    return Builder(
      builder: (context) {
        final button = icon != null
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 20.sp),
                label: Text(label),
                style: _secondaryButtonStyle(context),
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: _secondaryButtonStyle(context),
                child: Text(label),
              );

        return isFullWidth
            ? SizedBox(width: double.infinity, child: button)
            : button;
      },
    );
  }

  static ButtonStyle _secondaryButtonStyle(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.styleFrom(
      minimumSize: Size(120.w, 56.h),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      side: BorderSide(color: theme.colorScheme.outline, width: 1.5),
      textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
    );
  }

  /// Danger Button - للعمليات الخطرة (حذف)
  static Widget danger({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isFullWidth = false,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        final button = icon != null
            ? FilledButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 20.sp),
                label: Text(label),
                style: FilledButton.styleFrom(
                  minimumSize: Size(120.w, 56.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  minimumSize: Size(120.w, 56.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(label),
              );

        return isFullWidth
            ? SizedBox(width: double.infinity, child: button)
            : button;
      },
    );
  }

  /// Text Button - للعمليات الخفيفة
  static Widget text({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    return Builder(
      builder: (context) {
        return icon != null
            ? TextButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 20.sp),
                label: Text(label),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  textStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : TextButton(
                onPressed: onPressed,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  textStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text(label),
              );
      },
    );
  }
}

/// 📋 نظام موحد للبطاقات
class FormCard {
  /// بطاقة قياسية
  static Widget standard({
    required Widget child,
    EdgeInsets? padding,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        return Card(
          elevation: 0,
          color: color ?? theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.all(20.w),
            child: child,
          ),
        );
      },
    );
  }

  /// بطاقة مرتفعة
  static Widget elevated({required Widget child, EdgeInsets? padding}) {
    return Builder(
      builder: (context) {
        return Card(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.all(20.w),
            child: child,
          ),
        );
      },
    );
  }
}

/// 🎨 نظام موحد للتبويبات
class FormTabTheme {
  /// تصميم التبويبات - Material 3
  static Widget buildTabBar({
    required TabController controller,
    required List<Tab> tabs,
    bool isScrollable = true,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        return TabBar(
          controller: controller,
          tabs: tabs,
          isScrollable: isScrollable,

          // Material 3 Indicator
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: theme.colorScheme.primaryContainer,
          ),

          // تباعد بين التبويبات
          labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),

          // ألوان النص
          labelColor: theme.colorScheme.onPrimaryContainer,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,

          // نمط النص
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }

  /// Tab مخصص بأيقونة
  static Tab buildTab({required String text, required IconData icon}) {
    return Tab(
      height: 60.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20.sp),
          SizedBox(width: 8.w),
          Text(text),
        ],
      ),
    );
  }
}
