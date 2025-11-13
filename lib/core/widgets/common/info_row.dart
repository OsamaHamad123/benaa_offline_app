import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// صف معلومات قابل لإعادة الاستخدام
///
/// استخدامات:
/// - تفاصيل المستفيد
/// - تفاصيل السجل المدني
/// - أي معلومات Label: Value
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final bool isSelectable;
  final VoidCallback? onTap;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.isSelectable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: (isMobile ? 18 : 20).sp,
          color: iconColor ?? theme.colorScheme.primary,
        ),
        SizedBox(width: (isMobile ? 10 : 12).w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: (isMobile ? 11 : 12).sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: (isMobile ? 13 : 14).sp,
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.chevron_right,
            size: 20.sp,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          child: content,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: content,
    );
  }
}

/// نسخة أفقية مضغوطة
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: chipColor.withOpacity(0.3), width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: chipColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: chipColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
