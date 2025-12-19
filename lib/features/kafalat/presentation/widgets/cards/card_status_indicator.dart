import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎯 Card Status Indicator - مؤشر حالة البطاقة
class CardStatusIndicator extends StatelessWidget {
  final DateTime createdAt;
  final DateTime? endDate;

  const CardStatusIndicator({
    super.key,
    required this.createdAt,
    this.endDate,
  });

  bool _isNew() {
    final diff = DateTime.now().difference(createdAt);
    return diff.inDays <= 7; // جديد خلال 7 أيام
  }

  bool _isExpiringSoon() {
    if (endDate == null) return false;
    final diff = endDate!.difference(DateTime.now());
    return diff.inDays > 0 && diff.inDays <= 30; // ينتهي خلال 30 يوم
  }

  @override
  Widget build(BuildContext context) {
    if (_isNew()) {
      return _buildBadge(
        context,
        'جديد',
        Colors.blue,
        Icons.fiber_new,
      );
    }

    if (_isExpiringSoon()) {
      final daysLeft = endDate!.difference(DateTime.now()).inDays;
      return _buildBadge(
        context,
        'ينتهي بعد $daysLeft يوم',
        Colors.orange,
        Icons.warning_amber,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBadge(
    BuildContext context,
    String label,
    Color color,
    IconData icon,
  ) {
    return Positioned(
      top: 8.h,
      left: 8.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
