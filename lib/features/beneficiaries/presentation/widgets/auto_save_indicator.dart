import 'package:flutter/material.dart';

/// 💾 Auto Save Indicator Widget
///
/// Shows "حفظ تلقائي..." when saving
class AutoSaveIndicator extends StatelessWidget {
  final bool isSaving;
  final DateTime? lastSaved;

  const AutoSaveIndicator({required this.isSaving, super.key, this.lastSaved});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!isSaving && lastSaved == null) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSaving
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSaving) ...[
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'جاري الحفظ...',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ] else if (lastSaved != null) ...[
            Icon(Icons.check_circle, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              'تم الحفظ ${_getTimeAgo(lastSaved!)}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inSeconds < 10) {
      return 'الآن';
    } else if (diff.inSeconds < 60) {
      return 'منذ ${diff.inSeconds} ثانية';
    } else if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else {
      return 'منذ ${diff.inHours} ساعة';
    }
  }
}
