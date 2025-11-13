import 'package:flutter/material.dart';

/// 🎨 Beneficiary App Bar Widget
///
/// Custom app bar with save button and progress indicator
class BeneficiaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool canSave;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback? onDelete;
  final Widget? progressWidget;

  const BeneficiaryAppBar({
    super.key,
    required this.title,
    required this.canSave,
    required this.isSaving,
    required this.onSave,
    this.onDelete,
    this.progressWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          if (progressWidget != null) ...[
            const SizedBox(height: 4),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
              child: progressWidget!,
            ),
          ],
        ],
      ),
      actions: [
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
            tooltip: 'حذف',
          ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: canSave && !isSaving ? onSave : null,
          icon: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(isSaving ? 'حفظ...' : 'حفظ'),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
