import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modern AppBar with save/delete actions
class V2BeneficiaryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool canSave;
  final bool isSaving;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;
  final DateTime? lastSaved;

  const V2BeneficiaryAppBar({
    super.key,
    required this.title,
    this.canSave = false,
    this.isSaving = false,
    this.onSave,
    this.onDelete,
    this.lastSaved,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 2,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
          ),
          if (isSaving) ...[
            SizedBox(
              width: 16.w,
              height: 16.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'جاري الحفظ...',
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ] else if (lastSaved != null) ...[
            Icon(Icons.check_circle_rounded, size: 16.sp, color: Colors.green),
            SizedBox(width: 4.w),
            Text(
              _getTimeSinceLastSave(lastSaved!),
              style: TextStyle(
                fontSize: 11.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (onDelete != null)
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 22.sp),
            tooltip: 'حذف',
            onPressed: onDelete,
            color: Theme.of(context).colorScheme.error,
          ),
        if (onSave != null)
          Padding(
            padding: EdgeInsets.only(left: 8.w, right: 8.w),
            child: FilledButton.icon(
              onPressed: canSave && !isSaving ? onSave : null,
              icon: Icon(Icons.save_rounded, size: 18.sp),
              label: const Text('حفظ'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getTimeSinceLastSave(DateTime lastSaved) {
    final diff = DateTime.now().difference(lastSaved);
    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    return 'منذ ${diff.inDays} يوم';
  }
}
