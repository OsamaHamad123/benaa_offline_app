import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Form action buttons
class V2FormActions extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final bool isSaving;
  final bool canSave;

  const V2FormActions({
    super.key,
    this.onSave,
    this.onCancel,
    this.onDelete,
    this.isSaving = false,
    this.canSave = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (onDelete != null)
              OutlinedButton.icon(
                onPressed: isSaving ? null : onDelete,
                icon: Icon(Icons.delete_outline_rounded, size: 20.sp),
                label: const Text('حذف'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 14.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            const Spacer(),
            if (onCancel != null) ...[
              OutlinedButton(
                onPressed: isSaving ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 14.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('إلغاء'),
              ),
              SizedBox(width: 12.w),
            ],
            if (onSave != null)
              FilledButton.icon(
                onPressed: canSave && !isSaving ? onSave : null,
                icon: isSaving
                    ? SizedBox(
                        width: 18.w,
                        height: 18.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Icon(Icons.save_rounded, size: 20.sp),
                label: Text(isSaving ? 'جاري الحفظ...' : 'حفظ'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 14.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
