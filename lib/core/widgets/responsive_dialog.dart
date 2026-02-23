import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 💬 Responsive Dialog Widget
///
/// Widget موحد للـ Dialogs مع تصميم responsive
/// يُستخدم في:
/// - Confirmation dialogs
/// - Alert dialogs
/// - Form dialogs
/// - Info dialogs
///
/// Features:
/// - ✅ Responsive widths (mobile/tablet/desktop)
/// - ✅ Custom header with title + icon
/// - ✅ Smooth animations
/// - ✅ Consistent design with ResponsiveBottomSheet
/// - ✅ Auto-adjusts to content height
/// - ✅ Optional actions (buttons)
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => ResponsiveDialog(
///     title: 'تأكيد الحذف',
///     icon: Icons.delete_outline,
///     iconColor: Colors.red,
///     content: Text('هل أنت متأكد من حذف هذا العنصر؟'),
///     actions: [
///       TextButton(
///         onPressed: () => Navigator.pop(context),
///         child: Text('إلغاء'),
///       ),
///       ElevatedButton(
///         onPressed: () {
///           // Delete logic
///           Navigator.pop(context);
///         },
///         child: Text('حذف'),
///       ),
///     ],
///   ),
/// );
/// ```
class ResponsiveDialog extends StatelessWidget {
  /// Title text
  final String title;

  /// Leading icon (optional)
  final IconData? icon;

  /// Icon color (defaults to primary)
  final Color? iconColor;

  /// Icon size (defaults to 48.sp)
  final double? iconSize;

  /// Custom title widget (overrides title + icon)
  final Widget? titleWidget;

  /// Content widget
  final Widget content;

  /// Dialog actions (buttons)
  final List<Widget>? actions;

  /// Background color (defaults to theme)
  final Color? backgroundColor;

  /// Border radius
  final double borderRadius;

  /// Content padding
  final EdgeInsets? contentPadding;

  /// Actions padding
  final EdgeInsets? actionsPadding;

  /// Max width (desktop/tablet)
  final double maxWidth;

  /// Show close button in header
  final bool showCloseButton;

  /// Actions alignment
  final MainAxisAlignment actionsAlignment;

  const ResponsiveDialog({
    required this.title, required this.content, super.key,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.titleWidget,
    this.actions,
    this.backgroundColor,
    this.borderRadius = 20,
    this.contentPadding,
    this.actionsPadding,
    this.maxWidth = 500,
    this.showCloseButton = true,
    this.actionsAlignment = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;

    // Responsive width
    double dialogWidth;
    if (isDesktop) {
      dialogWidth = maxWidth;
    } else if (isTablet) {
      dialogWidth = screenWidth * 0.7;
    } else {
      dialogWidth = screenWidth * 0.9; // Mobile: 90% of screen
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.dialogBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with title, icon, close button
            _buildHeader(context, theme),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: contentPadding ??
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: content,
              ),
            ),

            // Actions
            if (actions != null && actions!.isNotEmpty) _buildActions(context),
          ],
        ),
      ),
    );
  }

  /// Build header with title and optional close button
  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 16.w, 16.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon (optional)
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize ?? 32.sp,
              color: iconColor ?? theme.colorScheme.primary,
            ),
            SizedBox(width: 12.w),
          ],

          // Title
          Expanded(
            child: titleWidget ??
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
          ),

          // Close button
          if (showCloseButton)
            IconButton(
              icon: Icon(Icons.close, size: 24.sp),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  /// Build actions (buttons)
  Widget _buildActions(BuildContext context) {
    return Container(
      padding: actionsPadding ??
          EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: actionsAlignment,
        children: [
          for (int i = 0; i < actions!.length; i++) ...[
            if (i > 0) SizedBox(width: 12.w),
            actions![i],
          ],
        ],
      ),
    );
  }
}

/// 🎯 Helper function to show ResponsiveDialog
///
/// Usage:
/// ```dart
/// showResponsiveDialog(
///   context: context,
///   title: 'تأكيد',
///   icon: Icons.warning_outlined,
///   content: Text('هل أنت متأكد؟'),
///   actions: [
///     TextButton(
///       onPressed: () => Navigator.pop(context),
///       child: Text('لا'),
///     ),
///     ElevatedButton(
///       onPressed: () {
///         // Action
///         Navigator.pop(context, true);
///       },
///       child: Text('نعم'),
///     ),
///   ],
/// );
/// ```
Future<T?> showResponsiveDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  IconData? icon,
  Color? iconColor,
  List<Widget>? actions,
  bool barrierDismissible = true,
  bool showCloseButton = true,
  MainAxisAlignment actionsAlignment = MainAxisAlignment.end,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => ResponsiveDialog(
      title: title,
      content: content,
      icon: icon,
      iconColor: iconColor,
      actions: actions,
      showCloseButton: showCloseButton,
      actionsAlignment: actionsAlignment,
    ),
  );
}

/// 🎯 Helper function for confirmation dialog
///
/// Usage:
/// ```dart
/// final confirmed = await showConfirmationDialog(
///   context: context,
///   title: 'تأكيد الحذف',
///   message: 'هل أنت متأكد من حذف هذا العنصر؟',
///   confirmText: 'حذف',
///   confirmColor: Colors.red,
/// );
///
/// if (confirmed == true) {
///   // Delete logic
/// }
/// ```
Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'تأكيد',
  String cancelText = 'إلغاء',
  IconData? icon,
  Color? iconColor,
  Color? confirmColor,
  bool isDangerous = false,
}) {
  final theme = Theme.of(context);

  return showResponsiveDialog<bool>(
    context: context,
    title: title,
    icon: icon ?? (isDangerous ? Icons.warning_outlined : Icons.help_outline),
    iconColor:
        iconColor ?? (isDangerous ? Colors.red : theme.colorScheme.primary),
    content: Text(
      message,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontSize: 15.sp,
        height: 1.5,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text(cancelText),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        style: ElevatedButton.styleFrom(
          backgroundColor: confirmColor ??
              (isDangerous ? Colors.red : theme.colorScheme.primary),
        ),
        child: Text(confirmText),
      ),
    ],
  );
}

/// 🎯 Helper function for info dialog
///
/// Usage:
/// ```dart
/// showInfoDialog(
///   context: context,
///   title: 'معلومة',
///   message: 'تم حفظ البيانات بنجاح',
///   icon: Icons.check_circle_outline,
///   iconColor: Colors.green,
/// );
/// ```
Future<void> showInfoDialog({
  required BuildContext context,
  required String title,
  required String message,
  IconData? icon,
  Color? iconColor,
  String closeText = 'حسناً',
}) {
  final theme = Theme.of(context);

  return showResponsiveDialog(
    context: context,
    title: title,
    icon: icon ?? Icons.info_outline,
    iconColor: iconColor ?? theme.colorScheme.primary,
    content: Text(
      message,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontSize: 15.sp,
        height: 1.5,
      ),
    ),
    actions: [
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: Text(closeText),
      ),
    ],
  );
}
