import 'package:flutter/material.dart';

/// 🎯 List AppBar with selection mode support - Reusable component
///
/// يوفر:
/// - AppBar عادي مع actions
/// - Selection mode AppBar مع counter
/// - AnimatedSwitcher للتبديل السلس
/// - Actions مخصصة لكل mode
class ListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSelectionMode;
  final int selectedCount;
  final String normalTitle;
  final List<Widget>? normalActions;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;
  final List<Widget>? selectionActions;

  const ListAppBar({
    super.key,
    required this.isSelectionMode,
    this.selectedCount = 0,
    this.normalTitle = 'القائمة',
    this.normalActions,
    this.onSelectAll,
    this.onDeselectAll,
    this.selectionActions,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.2),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: isSelectionMode
          ? _buildSelectionAppBar(context)
          : _buildNormalAppBar(context),
    );
  }

  /// AppBar عادي
  AppBar _buildNormalAppBar(BuildContext context) {
    return AppBar(
      key: const ValueKey('normal_appbar'),
      title: Text(normalTitle),
      actions: normalActions,
    );
  }

  /// Selection mode AppBar
  AppBar _buildSelectionAppBar(BuildContext context) {
    return AppBar(
      key: const ValueKey('selection_appbar'),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      title: Text('$selectedCount محدد'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'إلغاء',
        onPressed: onDeselectAll,
      ),
      actions: [
        if (onSelectAll != null)
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: 'تحديد الكل',
            onPressed: onSelectAll,
          ),
        ...?selectionActions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
