import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 💾 مؤشر Auto-save محسّن
class AutoSaveIndicator extends StatelessWidget {
  final DateTime? lastSaved;
  final bool isSaving;

  const AutoSaveIndicator({super.key, this.lastSaved, this.isSaving = false});

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isSaving) {
      return _buildSavingIndicator();
    }

    if (lastSaved != null) {
      return _buildLastSavedIndicator(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildSavingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14.w,
            height: 14.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'جاري الحفظ...',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastSavedIndicator(BuildContext context) {
    final timeAgo = _formatTimeAgo(lastSaved!);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14.sp, color: Colors.green),
          SizedBox(width: 6.w),
          Text(
            'حُفظ $timeAgo',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
