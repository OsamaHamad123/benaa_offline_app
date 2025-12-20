import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📊 Review Data Row Widget
///
/// صف عرض البيانات في صفحة المراجعة (تسمية: قيمة)
class ReviewDataRow extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;

  const ReviewDataRow({
    super.key,
    required this.label,
    this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayValue = value?.isEmpty ?? true ? 'غير محدد' : value!;
    final isEmpty = value?.isEmpty ?? true;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20.sp,
              color: isEmpty ? colorScheme.onSurfaceVariant.withOpacity(0.5) : colorScheme.primary,
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 3,
            child: Text(
              displayValue,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isEmpty ? colorScheme.onSurfaceVariant.withOpacity(0.5) : colorScheme.onSurface,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
