import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable Info Section Widget
class InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<InfoItem> items;
  final Color? accentColor;

  const InfoSection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

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
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
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
                    Divider(height: 1, indent: 60.w),
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
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 20.sp, color: Colors.grey[700]),
          ),
          SizedBox(width: 14.w),

          // Label
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Value
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
