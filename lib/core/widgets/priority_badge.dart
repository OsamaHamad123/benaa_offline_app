import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Priority Badge Widget - Shows priority level with color coding
class PriorityBadge extends StatelessWidget {
  final String level; // 'critical', 'high', 'medium', 'low'
  final String? label;

  const PriorityBadge({super.key, required this.level, this.label});

  @override
  Widget build(BuildContext context) {
    final config = _getPriorityConfig(level);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: config.color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, color: config.color, size: 14.sp),
          SizedBox(width: 4.w),
          Text(
            label ?? config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _PriorityConfig _getPriorityConfig(String level) {
    switch (level.toLowerCase()) {
      case 'critical':
        return _PriorityConfig(
          color: Colors.red,
          icon: Icons.error,
          label: 'عاجل',
        );
      case 'high':
        return _PriorityConfig(
          color: Colors.orange,
          icon: Icons.warning_amber,
          label: 'مهم',
        );
      case 'medium':
        return _PriorityConfig(
          color: Colors.yellow[700]!,
          icon: Icons.info,
          label: 'متوسط',
        );
      case 'low':
        return _PriorityConfig(
          color: Colors.blue,
          icon: Icons.info_outline,
          label: 'عادي',
        );
      default:
        return _PriorityConfig(
          color: Colors.grey,
          icon: Icons.circle,
          label: 'غير محدد',
        );
    }
  }
}

class _PriorityConfig {
  final Color color;
  final IconData icon;
  final String label;

  _PriorityConfig({
    required this.color,
    required this.icon,
    required this.label,
  });
}
