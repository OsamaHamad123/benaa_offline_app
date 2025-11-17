import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 💾 Auto-save Indicator
class AutoSaveIndicator extends StatefulWidget {
  final bool isSaving;
  final DateTime? lastSaved;
  final bool hasUnsavedChanges;

  const AutoSaveIndicator({
    super.key,
    required this.isSaving,
    this.lastSaved,
    this.hasUnsavedChanges = false,
  });

  @override
  State<AutoSaveIndicator> createState() => _AutoSaveIndicatorState();
}

class _AutoSaveIndicatorState extends State<AutoSaveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isSaving) {
      return _buildSavingState(theme);
    } else if (widget.lastSaved != null) {
      return _buildSavedState(theme);
    } else if (widget.hasUnsavedChanges) {
      return _buildUnsavedState(theme);
    }

    return const SizedBox.shrink();
  }

  Widget _buildSavingState(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14.w,
            height: 14.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'جاري الحفظ التلقائي...',
            style: TextStyle(fontSize: 11.sp, color: Colors.blue.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedState(ThemeData theme) {
    final timeAgo = _getTimeAgo(widget.lastSaved!);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14.sp, color: Colors.green.shade700),
          SizedBox(width: 8.w),
          Text(
            'تم الحفظ $timeAgo',
            style: TextStyle(fontSize: 11.sp, color: Colors.green.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsavedState(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 14.sp,
            color: Colors.orange.shade700,
          ),
          SizedBox(width: 8.w),
          Text(
            'تغييرات غير محفوظة',
            style: TextStyle(fontSize: 11.sp, color: Colors.orange.shade700),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 10) {
      return 'الآن';
    } else if (difference.inSeconds < 60) {
      return 'منذ ${difference.inSeconds} ثانية';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'منذ ${difference.inHours} ساعة';
    }
  }
}
