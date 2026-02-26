import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ⚡ أزرار الإجراءات في AppBar
///
/// تتضمن:
/// - حفظ سريع (Ctrl+S)
/// - التراجع/الإعادة (Ctrl+Z / Ctrl+Y)
/// - عرض السجل
/// - حذف (في وضع التعديل فقط)
/// - المساعدة
class FormActionButtons extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onToggleProgressCard;
  final bool isProgressCardVisible;
  final VoidCallback? onDelete;
  final VoidCallback onShowHistory;
  final VoidCallback onShowHelp;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool isEditMode;

  const FormActionButtons({
    required this.onSave,
    required this.onToggleProgressCard,
    required this.isProgressCardVisible,
    required this.onShowHistory,
    required this.onShowHelp,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    required this.isEditMode,
    super.key,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // زر الحفظ السريع
        IconButton(
          icon: Icon(Icons.save, size: 22.sp),
          tooltip: 'حفظ (Ctrl+S)',
          onPressed: onSave,
        ),

        if (!isMobile) ...[
          IconButton(
            icon: Icon(Icons.undo, size: 20.sp),
            tooltip: 'تراجع (Ctrl+Z)',
            onPressed: canUndo ? onUndo : null,
          ),
          IconButton(
            icon: Icon(Icons.redo, size: 20.sp),
            tooltip: 'إعادة (Ctrl+Y)',
            onPressed: canRedo ? onRedo : null,
          ),
        ],

        // قائمة خيارات إضافية
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: 22.sp),
          tooltip: 'خيارات',
          onSelected: (value) {
            switch (value) {
              case 'undo':
                onUndo();
                break;
              case 'redo':
                onRedo();
                break;
              case 'history':
                onShowHistory();
                break;
              case 'toggle_progress_card':
                onToggleProgressCard();
                break;
              case 'delete':
                onDelete?.call();
                break;
              case 'help':
                onShowHelp();
                break;
            }
          },
          itemBuilder: (context) => [
            if (isMobile) ...[
              PopupMenuItem<String>(
                value: 'undo',
                enabled: canUndo,
                child: Row(
                  children: [
                    Icon(Icons.undo, size: 20.sp),
                    SizedBox(width: 12.w),
                    const Text('تراجع'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'redo',
                enabled: canRedo,
                child: Row(
                  children: [
                    Icon(Icons.redo, size: 20.sp),
                    SizedBox(width: 12.w),
                    const Text('إعادة'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
            ],
            PopupMenuItem<String>(
              value: 'toggle_progress_card',
              child: Row(
                children: [
                  Icon(
                    isProgressCardVisible ? Icons.visibility_off_outlined : Icons.analytics_outlined,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(isProgressCardVisible ? 'إخفاء بطاقة التقدّم' : 'إظهار بطاقة التقدّم'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history, size: 20.sp),
                  SizedBox(width: 12.w),
                  const Text('عرض السجل'),
                ],
              ),
            ),
            if (isEditMode && onDelete != null) ...[
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      size: 20.sp,
                      color: colorScheme.error,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'حذف المستفيد',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help_outline, size: 20.sp),
                  SizedBox(width: 12.w),
                  const Text('المساعدة'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
