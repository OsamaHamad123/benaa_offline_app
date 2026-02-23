import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 👆 Swipe Actions Wrapper - سحب لتعديل أو حذف
///
/// - سحب لليمين (→) = تعديل (أزرق)
/// - سحب لليسار (←) = حذف (أحمر)
class SwipeActionsWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String itemName;

  const SwipeActionsWrapper({
    required this.child, required this.itemName, super.key,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('swipe_${itemName}_${DateTime.now().millisecondsSinceEpoch}'),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && onEdit != null) {
          // سحب لليمين = تعديل
          onEdit!();
          return false; // لا نحذف الـ item
        } else if (direction == DismissDirection.endToStart && onDelete != null) {
          // سحب لليسار = حذف
          return await _showDeleteConfirmDialog(context);
        }
        return false;
      },
      background: _buildEditBackground(),
      secondaryBackground: _buildDeleteBackground(),
      child: child,
    );
  }

  /// خلفية التعديل (يمين)
  Widget _buildEditBackground() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2196F3),
            Color(0xFF1976D2),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit,
            color: Colors.white,
            size: 28.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            'تعديل',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  /// خلفية الحذف (يسار)
  Widget _buildDeleteBackground() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF44336),
            Color(0xFFD32F2F),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.delete,
            color: Colors.white,
            size: 28.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            'حذف',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  /// حوار تأكيد الحذف
  Future<bool> _showDeleteConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                const Text('تأكيد الحذف'),
              ],
            ),
            content: Text(
              'هل أنت متأكد من حذف "$itemName"؟\nلا يمكن التراجع عن هذا الإجراء.',
              style: TextStyle(fontSize: 14.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'حذف',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
