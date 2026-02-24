import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎯 أزرار الإجراءات في أسفل النموذج
///
/// يعرض أزرار:
/// - حفظ كمسودة
/// - حفظ ومتابعة
/// - حفظ وإغلاق
/// - إلغاء
class BeneficiaryFormActions extends StatelessWidget {
  final VoidCallback onSaveDraft;
  final VoidCallback onSaveAndContinue;
  final VoidCallback onSaveAndClose;
  final VoidCallback onCancel;
  final bool isSaving;
  final bool hasUnsavedChanges;

  const BeneficiaryFormActions({
    required this.onSaveDraft,
    required this.onSaveAndContinue,
    required this.onSaveAndClose,
    required this.onCancel,
    required this.isSaving,
    required this.hasUnsavedChanges,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر الإلغاء
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isSaving ? null : onCancel,
              icon: const Icon(Icons.close),
              label: const Text('إلغاء'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // زر حفظ كمسودة
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isSaving ? null : onSaveDraft,
              icon: const Icon(Icons.save_outlined),
              label: const Text('مسودة'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // زر حفظ ومتابعة أو حفظ وإغلاق
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: isSaving ? null : onSaveAndClose,
              icon: isSaving
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(isSaving ? 'جاري الحفظ...' : 'حفظ'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
