import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🔔 مؤشر حالة البطاقة (جديد/محدث)
class CardStatusIndicator extends StatelessWidget {
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CardStatusIndicator({
    super.key,
    this.createdAt,
    this.updatedAt,
  });

  bool get _isNew {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final diff = now.difference(createdAt!);
    return diff.inDays <= 7; // جديد إذا أقل من 7 أيام
  }

  bool get _isRecentlyUpdated {
    if (updatedAt == null || createdAt == null) return false;
    final now = DateTime.now();
    final diff = now.difference(updatedAt!);
    // محدث إذا تم التحديث خلال 24 ساعة وليس جديد
    return diff.inHours <= 24 && !_isNew;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isNew && !_isRecentlyUpdated) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 3.h,
      ),
      decoration: BoxDecoration(
        color: _isNew ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: _isNew ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isNew ? Icons.fiber_new : Icons.update,
            size: 12.sp,
            color: _isNew ? Colors.green.shade700 : Colors.blue.shade700,
          ),
          SizedBox(width: 4.w),
          Text(
            _isNew ? 'جديد' : 'محدث',
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: _isNew ? Colors.green.shade700 : Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
