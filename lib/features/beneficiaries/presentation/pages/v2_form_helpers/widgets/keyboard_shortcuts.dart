import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ⌨️ Form Keyboard Shortcuts
///
/// Keyboard shortcuts for faster form navigation
class FormKeyboardShortcuts extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onSave;
  final VoidCallback? onDelete;
  final Widget child;

  const FormKeyboardShortcuts({
    super.key,
    required this.tabController,
    required this.onSave,
    this.onDelete,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: false,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          // Ctrl + S = Save
          if (event.logicalKey == LogicalKeyboardKey.keyS &&
              (event.physicalKey == PhysicalKeyboardKey.controlLeft ||
                  event.physicalKey == PhysicalKeyboardKey.controlRight)) {
            onSave();
            return KeyEventResult.handled;
          }

          // Ctrl + Delete = Delete
          if (onDelete != null &&
              event.logicalKey == LogicalKeyboardKey.delete &&
              (event.physicalKey == PhysicalKeyboardKey.controlLeft ||
                  event.physicalKey == PhysicalKeyboardKey.controlRight)) {
            onDelete!();
            return KeyEventResult.handled;
          }

          // Ctrl + Right Arrow = Next Tab
          if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
              (event.physicalKey == PhysicalKeyboardKey.controlLeft ||
                  event.physicalKey == PhysicalKeyboardKey.controlRight)) {
            if (tabController.index < tabController.length - 1) {
              tabController.animateTo(tabController.index + 1);
            }
            return KeyEventResult.handled;
          }

          // Ctrl + Left Arrow = Previous Tab
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
              (event.physicalKey == PhysicalKeyboardKey.controlLeft ||
                  event.physicalKey == PhysicalKeyboardKey.controlRight)) {
            if (tabController.index > 0) {
              tabController.animateTo(tabController.index - 1);
            }
            return KeyEventResult.handled;
          }

          // Ctrl + 1-6 = Jump to Tab
          final numberKeys = [
            LogicalKeyboardKey.digit1,
            LogicalKeyboardKey.digit2,
            LogicalKeyboardKey.digit3,
            LogicalKeyboardKey.digit4,
            LogicalKeyboardKey.digit5,
            LogicalKeyboardKey.digit6,
          ];

          for (var i = 0; i < numberKeys.length; i++) {
            if (event.logicalKey == numberKeys[i] &&
                (event.physicalKey == PhysicalKeyboardKey.controlLeft ||
                    event.physicalKey == PhysicalKeyboardKey.controlRight)) {
              tabController.animateTo(i);
              return KeyEventResult.handled;
            }
          }
        }

        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}

/// 💡 Keyboard Shortcuts Help Dialog
class KeyboardShortcutsDialog extends StatelessWidget {
  const KeyboardShortcutsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.keyboard_rounded, color: theme.colorScheme.primary),
          SizedBox(width: 8.w),
          const Text('اختصارات لوحة المفاتيح'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShortcut('Ctrl + S', 'حفظ النموذج'),
            _buildShortcut('Ctrl + Delete', 'حذف المستفيد'),
            _buildShortcut('Ctrl + →', 'التبويب التالي'),
            _buildShortcut('Ctrl + ←', 'التبويب السابق'),
            _buildShortcut('Ctrl + 1-6', 'الانتقال لتبويب محدد'),
            _buildShortcut('Tab', 'الانتقال للحقل التالي'),
            _buildShortcut('Shift + Tab', 'الانتقال للحقل السابق'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }

  Widget _buildShortcut(String keys, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Text(
              keys,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(description, style: TextStyle(fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }
}
