import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📱 Responsive Bottom Sheet Widget
///
/// Widget موحد للـ Bottom Sheets مع DraggableScrollableSheet
/// يُستخدم في:
/// - Drafts List
/// - Filters
/// - Selections
/// - Form Dialogs
///
/// Features:
/// - ✅ Responsive heights (mobile/tablet/desktop)
/// - ✅ Drag handle indicator
/// - ✅ Custom header with title + close button
/// - ✅ Smooth animations
/// - ✅ Consistent design
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (context) => ResponsiveBottomSheet(
///     title: 'المسودات المحفوظة',
///     child: ListView(...),
///   ),
/// );
/// ```
class ResponsiveBottomSheet extends StatelessWidget {
  /// Title text (optional)
  final String? title;

  /// Leading icon (optional)
  final IconData? icon;

  /// Custom title widget (overrides title + icon)
  final Widget? titleWidget;

  /// Show close button
  final bool showCloseButton;

  /// Initial child size (0.0 - 1.0)
  final double initialChildSize;

  /// Minimum child size (0.0 - 1.0)
  final double minChildSize;

  /// Maximum child size (0.0 - 1.0)
  final double maxChildSize;

  /// Content widget (use either this or builder, not both)
  final Widget? child;

  /// Background color (defaults to theme)
  final Color? backgroundColor;

  /// Show drag handle
  final bool showDragHandle;

  /// Custom actions (e.g., filter buttons, search)
  final List<Widget>? actions;

  /// Optional builder that receives scrollController for custom scroll handling
  final Widget Function(ScrollController)? builder;

  const ResponsiveBottomSheet({
    super.key,
    this.title,
    this.icon,
    this.titleWidget,
    this.showCloseButton = true,
    this.initialChildSize = 0.7,
    this.minChildSize = 0.5,
    this.maxChildSize = 0.95,
    this.child,
    this.backgroundColor,
    this.showDragHandle = true,
    this.actions,
    this.builder,
  }) : assert(child != null || builder != null, 'Either child or builder must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.scaffoldBackgroundColor;

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag Handle
                if (showDragHandle)
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 12.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                // Header
                if (title != null || titleWidget != null)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      children: [
                        // Icon
                        if (icon != null && titleWidget == null) ...[
                          Icon(
                            icon,
                            color: theme.colorScheme.primary,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                        ],

                        // Title
                        Expanded(
                          child: titleWidget ??
                              Text(
                                title!,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),

                        // Actions
                        if (actions != null) ...actions!,

                        // Close Button
                        if (showCloseButton)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                            tooltip: 'إغلاق',
                          ),
                      ],
                    ),
                  ),

                if (title != null || titleWidget != null) const Divider(height: 1),

                // Content
                Expanded(
                  child: builder != null ? builder!(scrollController) : child!,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 📋 Quick Builder for Drafts/Lists
class ResponsiveDraftsList extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final Widget? emptyState;
  final IconData icon;

  const ResponsiveDraftsList({
    super.key,
    required this.title,
    required this.items,
    this.emptyState,
    this.icon = Icons.drafts,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBottomSheet(
      title: '$title (${items.length})',
      icon: icon,
      child: items.isEmpty && emptyState != null
          ? emptyState!
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) => items[index],
            ),
    );
  }
}
