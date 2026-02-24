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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16.w,
          height: 16.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          'جاري الحفظ...',
          style: TextStyle(
            fontSize: 12.sp,
            color: colorScheme.onPrimary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(
    BuildContext context,
    DateTime? lastSaved,
    bool hasUnsavedChanges,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (lastSaved == null) {
      return const SizedBox.shrink();
    }

    final timeAgo = _formatTimeAgo(lastSaved);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // نقطة تحذير إذا كانت هناك تغييرات غير محفوظة
        if (hasUnsavedChanges)
          Container(
            width: 8.w,
            height: 8.h,
            margin: EdgeInsets.only(left: 4.w),
            decoration: BoxDecoration(
              color: colorScheme.tertiary,
              shape: BoxShape.circle,
            ),
          ),

        Icon(
          hasUnsavedChanges ? Icons.edit : Icons.check_circle,
          size: 16.sp,
          color: hasUnsavedChanges ? colorScheme.tertiary : colorScheme.secondary,
        ),

        SizedBox(width: 4.w),

        Text(
          hasUnsavedChanges ? 'تعديلات غير محفوظة' : 'حُفظ $timeAgo',
          style: TextStyle(
            fontSize: 11.sp,
            color: colorScheme.onPrimary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} د';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} س';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} ي';
    } else {
      return 'منذ ${(difference.inDays / 7).floor()} أ';
    }
  }
}
