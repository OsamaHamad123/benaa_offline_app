import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'save_status_indicator.dart';
import 'form_action_buttons.dart';

/// 🎨 AppBar مخصص لنموذج المستفيدين
///
/// يحتوي على:
/// - عنوان ديناميكي (إضافة/تعديل)
/// - مؤشر حالة الحفظ
/// - أزرار الإجراءات (حفظ، حذف، خيارات)
class BeneficiaryFormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isEditMode;
  final String? beneficiaryName;
  final ValueNotifier<bool> isSavingNotifier;
  final ValueNotifier<DateTime?> lastSavedNotifier;
  final ValueNotifier<bool> hasUnsavedChangesNotifier;
  final VoidCallback onSave;
  final VoidCallback? onDelete;
  final VoidCallback onShowHistory;
  final VoidCallback onShowHelp;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const BeneficiaryFormAppBar({
    required this.isEditMode,
    required this.isSavingNotifier,
    required this.lastSavedNotifier,
    required this.hasUnsavedChangesNotifier,
    required this.onSave,
    required this.onShowHistory,
    required this.onShowHelp,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    super.key,
    this.beneficiaryName,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEditMode ? 'تعديل مستفيد' : 'إضافة مستفيد',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (beneficiaryName != null && beneficiaryName!.isNotEmpty)
            Text(
              beneficiaryName!,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                color: colorScheme.onPrimary.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
      actions: [
        // مؤشر حالة الحفظ
        SaveStatusIndicator(
          isSavingNotifier: isSavingNotifier,
          lastSavedNotifier: lastSavedNotifier,
          hasUnsavedChangesNotifier: hasUnsavedChangesNotifier,
        ),

        SizedBox(width: 8.w),

        // أزرار الإجراءات
        FormActionButtons(
          onSave: onSave,
          onDelete: onDelete,
          onShowHistory: onShowHistory,
          onShowHelp: onShowHelp,
          canUndo: canUndo,
          canRedo: canRedo,
          onUndo: onUndo,
          onRedo: onRedo,
          isEditMode: isEditMode,
        ),

        SizedBox(width: 8.w),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
