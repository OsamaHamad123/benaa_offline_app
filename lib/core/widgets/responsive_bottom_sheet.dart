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
class ResponsiveBottomSheet extends StatefulWidget {
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

  /// When false, uses a fixed-height sheet instead of DraggableScrollableSheet.
  /// This is recommended for heavy forms with many TextFields to avoid keyboard/focus jank.
  final bool useDraggableScrollableSheet;

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
    this.useDraggableScrollableSheet = true,
  }) : assert(child != null || builder != null,
            'Either child or builder must be provided');

  @override
  State<ResponsiveBottomSheet> createState() => _ResponsiveBottomSheetState();
}

class _ResponsiveBottomSheetState extends State<ResponsiveBottomSheet> {
  ScrollController? _fixedScrollController;

  @override
  void initState() {
    super.initState();
    if (!widget.useDraggableScrollableSheet && widget.builder != null) {
      _fixedScrollController = ScrollController();
    }
  }

  @override
  void didUpdateWidget(covariant ResponsiveBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    final needsController =
        !widget.useDraggableScrollableSheet && widget.builder != null;
    final hadController = _fixedScrollController != null;

    if (needsController && !hadController) {
      _fixedScrollController = ScrollController();
    } else if (!needsController && hadController) {
      _fixedScrollController?.dispose();
      _fixedScrollController = null;
    }
  }

  @override
  void dispose() {
    _fixedScrollController?.dispose();
    super.dispose();
  }

  Widget _buildSheetBody(
      BuildContext context, ScrollController? scrollController) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.scaffoldBackgroundColor;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag Handle
            if (widget.showDragHandle)
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withAlpha(51),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

            // Header
            if (widget.title != null || widget.titleWidget != null)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                child: Row(
                  children: [
                    // Icon
                    if (widget.icon != null && widget.titleWidget == null) ...[
                      Icon(
                        widget.icon,
                        color: theme.colorScheme.primary,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                    ],

                    // Title
                    Expanded(
                      child: widget.titleWidget ??
                          Text(
                            widget.title!,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),

                    // Actions
                    if (widget.actions != null) ...widget.actions!,

                    // Close Button
                    if (widget.showCloseButton)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'إغلاق',
                      ),
                  ],
                ),
              ),

            if (widget.title != null || widget.titleWidget != null)
              const Divider(height: 1),

            // Content
            Expanded(
              child: widget.builder != null
                  ? widget.builder!(
                      scrollController ?? PrimaryScrollController.of(context))
                  : widget.child!,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useDraggableScrollableSheet) {
      return DraggableScrollableSheet(
        initialChildSize: widget.initialChildSize,
        minChildSize: widget.minChildSize,
        maxChildSize: widget.maxChildSize,
        expand: false,
        builder: (context, scrollController) {
          return _buildSheetBody(context, scrollController);
        },
      );
    }

    final maxHeight = MediaQuery.of(context).size.height * widget.maxChildSize;
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
        ),
        child: _buildSheetBody(context, _fixedScrollController),
      ),
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
    required this.title, required this.items, super.key,
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
