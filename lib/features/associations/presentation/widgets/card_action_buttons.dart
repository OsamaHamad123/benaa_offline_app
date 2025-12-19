import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🔘 أزرار الإجراءات (تعديل/حذف)
class CardActionButtons extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CardActionButtons({
    super.key,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // زر التعديل
        _ActionButton(
          icon: Icons.edit_outlined,
          color: colorScheme.primary,
          onPressed: onEdit,
        ),

        SizedBox(width: 6.w),

        // زر الحذف
        _ActionButton(
          icon: Icons.delete_outline,
          color: Colors.red.shade400,
          onPressed: onDelete,
        ),
      ],
    );
  }
}

/// زر إجراء واحد
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 16.sp,
            color: color,
          ),
        ),
      ),
    );
  }
}
