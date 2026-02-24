import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable Info Section Widget
class InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<InfoItem> items;
  final Color? accentColor;

  const InfoSection({
    required this.title,
    required this.icon,
    required this.items,
    super.key,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = accentColor ?? colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Section Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  InfoRow(
                    icon: item.icon,
                    label: item.label,
                    value: item.value,
                    valueColor: item.valueColor,
                  ),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 60.w,
                      color: colorScheme.outlineVariant,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// Info Item Model
class InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}

/// Info Row Widget
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 20.sp, color: colorScheme.onSurfaceVariant),
          ),
          SizedBox(width: 14.w),

          // Label
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Value
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: valueColor ?? colorScheme.onSurface,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
