import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ⌨️ Keyboard Shortcuts Handler for Form
class FormKeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSave;
  final VoidCallback? onNextTab;
  final VoidCallback? onPreviousTab;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onNew;

  const FormKeyboardShortcuts({
    required this.child, super.key,
    this.onSave,
    this.onNextTab,
    this.onPreviousTab,
    this.onUndo,
    this.onRedo,
    this.onNew,
  });

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        // Ctrl+S = Save
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          if (onSave != null) {
            HapticFeedback.mediumImpact();
            onSave!();
          }
        },

        // Ctrl+Tab = Next Tab
        const SingleActivator(LogicalKeyboardKey.tab, control: true): () {
          if (onNextTab != null) {
            HapticFeedback.lightImpact();
            onNextTab!();
          }
        },

        // Ctrl+Shift+Tab = Previous Tab
        const SingleActivator(
          LogicalKeyboardKey.tab,
          control: true,
          shift: true,
        ): () {
          if (onPreviousTab != null) {
            HapticFeedback.lightImpact();
            onPreviousTab!();
          }
        },

        // Ctrl+Z = Undo
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
          if (onUndo != null) {
            HapticFeedback.lightImpact();
            onUndo!();
          }
        },

        // Ctrl+Y = Redo
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): () {
          if (onRedo != null) {
            HapticFeedback.lightImpact();
            onRedo!();
          }
        },

        // Ctrl+N = New
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          if (onNew != null) {
            HapticFeedback.mediumImpact();
            onNew!();
          }
        },
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}

/// 🎹 Keyboard Shortcuts Help Dialog
class KeyboardShortcutsHelp extends StatelessWidget {
  const KeyboardShortcutsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(24.r),
        constraints: BoxConstraints(maxWidth: 400.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.keyboard_rounded,
                  size: 28.sp,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 12.w),
                Text(
                  'اختصارات لوحة المفاتيح',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _buildShortcut('Ctrl + S', 'حفظ النموذج', Icons.save_rounded),
            _buildShortcut(
              'Ctrl + Tab',
              'التبويب التالي',
              Icons.arrow_forward_rounded,
            ),
            _buildShortcut(
              'Ctrl + Shift + Tab',
              'التبويب السابق',
              Icons.arrow_back_rounded,
            ),
            _buildShortcut('Ctrl + Z', 'تراجع', Icons.undo_rounded),
            _buildShortcut('Ctrl + Y', 'إعادة', Icons.redo_rounded),
            _buildShortcut('Ctrl + N', 'مستفيد جديد', Icons.add_rounded),
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcut(String shortcut, String description, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Colors.grey.shade600),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(description, style: TextStyle(fontSize: 14.sp)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              shortcut,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
