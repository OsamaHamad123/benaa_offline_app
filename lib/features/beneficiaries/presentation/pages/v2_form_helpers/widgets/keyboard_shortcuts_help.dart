import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';

/// ⌨️ Keyboard Shortcuts Help Sheet
///
/// Shows available keyboard shortcuts in bottom sheet
class KeyboardShortcutsSheet extends StatelessWidget {
  const KeyboardShortcutsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTabletOrDesktop =
        ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.largeSpace),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.keyboard_outlined,
                size: isTabletOrDesktop ? 28.0 : 24.0,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: ResponsiveUtils.smallSpace),
              Text(
                'اختصارات لوحة المفاتيح',
                style: TextStyle(
                  fontSize: isTabletOrDesktop ? 20.sp : 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.mediumSpace),

          // Shortcuts List
          const _ShortcutItem(
            shortcut: 'Ctrl + S',
            description: 'حفظ النموذج',
            icon: Icons.save_outlined,
            color: Colors.green,
          ),
          const _ShortcutItem(
            shortcut: 'Ctrl + Tab',
            description: 'الانتقال للتبويب التالي',
            icon: Icons.arrow_forward,
            color: Colors.blue,
          ),
          const _ShortcutItem(
            shortcut: 'Ctrl + Shift + Tab',
            description: 'الانتقال للتبويب السابق',
            icon: Icons.arrow_back,
            color: Colors.blue,
          ),
          const _ShortcutItem(
            shortcut: 'Ctrl + Z',
            description: 'التراجع',
            icon: Icons.undo,
            color: Colors.orange,
          ),
          const _ShortcutItem(
            shortcut: 'Ctrl + Y',
            description: 'إعادة',
            icon: Icons.redo,
            color: Colors.orange,
          ),
          const _ShortcutItem(
            shortcut: 'F5',
            description: 'تحديث البيانات',
            icon: Icons.refresh,
            color: Colors.purple,
          ),
          const _ShortcutItem(
            shortcut: 'Esc',
            description: 'إلغاء / إغلاق',
            icon: Icons.close,
            color: Colors.red,
          ),

          SizedBox(height: ResponsiveUtils.smallSpace),

          // Footer Note
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.smallSpace),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: ResponsiveUtils.smallSpace),
                Expanded(
                  child: Text(
                    'استخدم هذه الاختصارات للعمل بشكل أسرع وأكثر كفاءة',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  final String shortcut;
  final String description;
  final IconData icon;
  final Color color;

  const _ShortcutItem({
    required this.shortcut,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.xSmallSpace),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 20, color: color),
          ),

          SizedBox(width: ResponsiveUtils.smallSpace),

          // Description
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ),

          // Shortcut Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Text(
              shortcut,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Show Keyboard Shortcuts Help Sheet
void showKeyboardShortcutsHelp(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const KeyboardShortcutsSheet(),
  );
}
