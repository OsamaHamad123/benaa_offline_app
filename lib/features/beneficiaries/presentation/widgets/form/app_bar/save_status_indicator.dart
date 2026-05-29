import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 💾 مؤشر حالة الحفظ
///
/// يعرض:
/// - أيقونة دوارة أثناء الحفظ
/// - وقت آخر حفظ (باستخدام timeago)
/// - نقطة تحذير إذا كانت هناك تغييرات غير محفوظة
class SaveStatusIndicator extends StatelessWidget {
  final ValueNotifier<bool> isSavingNotifier;
  final ValueNotifier<DateTime?> lastSavedNotifier;
  final ValueNotifier<bool> hasUnsavedChangesNotifier;

  const SaveStatusIndicator({
    required this.isSavingNotifier,
    required this.lastSavedNotifier,
    required this.hasUnsavedChangesNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isSavingNotifier,
      builder: (context, isSaving, _) {
        if (isSaving) {
          return _buildSavingIndicator(context);
        }

        return ValueListenableBuilder<DateTime?>(
          valueListenable: lastSavedNotifier,
          builder: (context, lastSaved, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: hasUnsavedChangesNotifier,
              builder: (context, hasUnsavedChanges, _) {
                return _buildStatusIndicator(
                  context,
                  lastSaved,
                  hasUnsavedChanges,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSavingIndicator(BuildContext context) {
    return SizedBox(
      width: 16.w,
      height: 16.h,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.85),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(
    BuildContext context,
    DateTime? lastSaved,
    bool hasUnsavedChanges,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // تغييرات غير محفوظة → نقطة برتقالية صغيرة فقط
    if (hasUnsavedChanges) {
      return Container(
        width: 9.w,
        height: 9.h,
        decoration: BoxDecoration(
          color: colorScheme.tertiary,
          shape: BoxShape.circle,
        ),
      );
    }

    // محفوظ → أيقونة اختيار صغيرة فقط
    if (lastSaved != null) {
      return Icon(
        Icons.check_circle_rounded,
        size: 16.sp,
        color: colorScheme.onPrimary.withValues(alpha: 0.7),
      );
    }

    return const SizedBox.shrink();
  }
}
