import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../core/utils/haptic_patterns.dart';

/// 🎯 Swipe Action Wrapper - غلاف إجراءات السحب
class SwipeActionWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onView;
  final bool enableEdit;
  final bool enableDelete;
  final bool enableView;

  const SwipeActionWrapper({
    super.key,
    required this.child,
    this.onEdit,
    this.onDelete,
    this.onView,
    this.enableEdit = true,
    this.enableDelete = true,
    this.enableView = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Slidable(
      key: ValueKey(child.hashCode),

      // Start Actions (سحب من اليمين → اليسار)
      startActionPane: enableEdit && onEdit != null
          ? ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (context) {
                    HapticPatterns.selection();
                    onEdit!();
                  },
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.edit_rounded,
                  label: 'تعديل',
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(16.r),
                  ),
                ),
              ],
            )
          : null,

      // End Actions (سحب من اليسار → اليمين)
      endActionPane: enableDelete && onDelete != null
          ? ActionPane(
              motion: const DrawerMotion(),
              extentRatio: enableView && onView != null ? 0.5 : 0.25,
              children: [
                if (enableView && onView != null)
                  SlidableAction(
                    onPressed: (context) {
                      HapticPatterns.selection();
                      onView!();
                    },
                    backgroundColor: theme.colorScheme.tertiary,
                    foregroundColor: Colors.white,
                    icon: Icons.visibility_rounded,
                    label: 'تفاصيل',
                  ),
                SlidableAction(
                  onPressed: (context) {
                    HapticPatterns.error();
                    _showDeleteConfirmation(context);
                  },
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_rounded,
                  label: 'حذف',
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(16.r),
                  ),
                ),
              ],
            )
          : null,

      child: child,
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف', textAlign: TextAlign.right),
        content: const Text(
          'هل أنت متأكد من حذف هذا العنصر؟ لا يمكن التراجع عن هذا الإجراء.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (onDelete != null) {
                HapticPatterns.success();
                onDelete!();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
