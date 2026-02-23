import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎬 Card Action Buttons - أزرار الإجراءات
class CardActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onViewDetails;

  const CardActionButtons({
    required this.onEdit, required this.onDelete, super.key,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.edit_outlined,
            label: 'تعديل',
            color: theme.colorScheme.primary,
            onPressed: onEdit,
          ),
          Container(
            width: 1,
            height: 24.h,
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          _ActionButton(
            icon: Icons.delete_outline,
            label: 'حذف',
            color: theme.colorScheme.error,
            onPressed: onDelete,
          ),
          if (onViewDetails != null) ...[
            Container(
              width: 1,
              height: 24.h,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            _ActionButton(
              icon: Icons.info_outline,
              label: 'تفاصيل',
              color: theme.colorScheme.secondary,
              onPressed: onViewDetails!,
            ),
          ],
        ],
      ),
    );
  }
}

/// 🔘 Action Button - زر إجراء واحد
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
