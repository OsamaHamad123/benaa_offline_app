import 'package:flutter/material.dart';
import '../../../../../core/utils/haptic_patterns.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/responsive_utils_v2.dart';
import '../../providers/list/selection_provider.dart';
import '../../providers/list/beneficiaries_list_provider.dart';

/// ☑️ Bulk Actions Bar
class BulkActionsBar extends ConsumerWidget {
  const BulkActionsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(selectionProvider);
    final theme = Theme.of(context);
    final rv = ResponsiveUtils.getValues(context);

    if (!selection.isSelectionMode) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rv.isTablet ? 20 : 16,
        vertical: rv.isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.close, size: rv.isTablet ? 26 : 24),
              onPressed: () {
                HapticPatterns.selection();
                ref.read(selectionProvider.notifier).deselectAll();
              },
            ),
            SizedBox(width: rv.isTablet ? 10 : 8),
            Text(
              '${selection.selectedCount} محدد',
              style: TextStyle(
                fontSize: rv.isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.delete_outline, size: rv.isTablet ? 26 : 24),
              tooltip: 'حذف',
              onPressed: () {
                HapticPatterns.warning();
                _showDeleteConfirmation(context, ref);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.file_download_outlined,
                size: rv.isTablet ? 26 : 24,
              ),
              tooltip: 'تصدير',
              onPressed: () {
                HapticPatterns.selection();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً: تصدير المحددة')),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.sync, size: rv.isTablet ? 26 : 24),
              tooltip: 'مزامنة',
              onPressed: () {
                HapticPatterns.selection();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً: مزامنة المحددة')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final selection = ref.read(selectionProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ${selection.selectedCount} مستفيد؟'),
        actions: [
          TextButton(
            onPressed: () {
              HapticPatterns.selection();
              Navigator.pop(context, false);
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticPatterns.error();
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        HapticPatterns.warning();

        await ref
            .read(beneficiariesListProvider.notifier)
            .bulkDelete(selection.selectedIds);

        ref.read(selectionProvider.notifier).deselectAll();

        if (context.mounted) {
          HapticPatterns.selection();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف ${selection.selectedCount} مستفيد بنجاح'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          HapticPatterns.error();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل الحذف: ${e.toString()}'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'إعادة المحاولة',
                textColor: Colors.white,
                onPressed: () => _showDeleteConfirmation(context, ref),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }
}
