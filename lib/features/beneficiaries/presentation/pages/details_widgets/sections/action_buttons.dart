import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🔘 Action Buttons Widget
///
/// Edit and Add Visit buttons
class ActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onAddVisit;

  const ActionButtons({
    required this.onEdit,
    required this.onAddVisit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: 'تعديل بيانات المستفيد',
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, size: 20.sp),
              label: const Text('تعديل'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                minimumSize: Size.fromHeight(48.h),
                side: BorderSide(color: colorScheme.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Semantics(
            button: true,
            label: 'إضافة زيارة جديدة',
            child: ElevatedButton.icon(
              onPressed: onAddVisit,
              icon: Icon(Icons.add, size: 20.sp),
              label: const Text('إضافة زيارة'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                minimumSize: Size.fromHeight(48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
