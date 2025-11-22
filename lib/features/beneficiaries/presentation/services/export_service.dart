import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/feedback_utils.dart';
import '../providers/list/beneficiaries_list_provider.dart';

/// 📤 Export Service for Beneficiaries List
class BeneficiariesExportService {
  /// تصدير القائمة الحالية إلى Excel
  static Future<void> exportToExcel(
    BuildContext context,
    WidgetRef ref, {
    String? fileName,
  }) async {
    try {
      final state = ref.read(beneficiariesListProvider);
      final beneficiaries = state.items;

      if (beneficiaries.isEmpty) {
        VisualFeedback.showWarning(context, 'لا توجد بيانات للتصدير');
        return;
      }

      // سيتم إضافة منطق التصدير قريباً
      // يحتاج إلى تحويل Drift entities إلى Domain entities
      HapticPatterns.success();
      VisualFeedback.showInfo(
        context,
        'سيتم إضافة التصدير قريباً (${beneficiaries.length} مستفيد)',
      );
    } catch (e) {
      if (context.mounted) {
        VisualFeedback.showError(context, 'فشل التصدير: ${e.toString()}');
      }
    }
  }

  /// تصدير المستفيدين المحددين فقط
  static Future<void> exportSelected(
    BuildContext context,
    WidgetRef ref,
    List<int> selectedIds,
  ) async {
    try {
      if (selectedIds.isEmpty) {
        VisualFeedback.showWarning(context, 'لم يتم تحديد أي مستفيد');
        return;
      }

      VisualFeedback.showInfo(
        context,
        'جاري تصدير ${selectedIds.length} مستفيد...',
      );

      // استخدام exportToExcel - سيقوم بتصدير كل البيانات
      // في المستقبل يمكن تحسينه لتصدير المحدد فقط
      await exportToExcel(context, ref);
    } catch (e) {
      if (context.mounted) {
        VisualFeedback.showError(context, 'فشل التصدير: ${e.toString()}');
      }
    }
  }
}

/// 📊 Export Options Dialog
class ExportOptionsDialog extends ConsumerWidget {
  final List<int>? selectedIds;

  const ExportOptionsDialog({super.key, this.selectedIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSelection = selectedIds != null && selectedIds!.isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.file_download, size: 28, color: Colors.orange),
                const SizedBox(width: 12),
                const Text(
                  'تصدير البيانات',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 32),

            // Export All
            _ExportOptionTile(
              icon: Icons.list_alt,
              title: 'تصدير كل القائمة',
              subtitle: 'تصدير جميع المستفيدين الحاليين',
              color: Colors.blue,
              onTap: () async {
                Navigator.of(context).pop();
                await BeneficiariesExportService.exportToExcel(context, ref);
              },
            ),

            const SizedBox(height: 16),

            // Export Selected
            _ExportOptionTile(
              icon: Icons.checklist,
              title: 'تصدير المحدد',
              subtitle: hasSelection
                  ? 'تصدير ${selectedIds!.length} مستفيد محدد'
                  : 'لم يتم تحديد أي مستفيد',
              color: hasSelection ? Colors.green : Colors.grey,
              enabled: hasSelection,
              onTap: hasSelection
                  ? () async {
                      Navigator.of(context).pop();
                      await BeneficiariesExportService.exportSelected(
                        context,
                        ref,
                        selectedIds!,
                      );
                    }
                  : null,
            ),

            const SizedBox(height: 16),

            // Export with Filters
            _ExportOptionTile(
              icon: Icons.filter_alt,
              title: 'تصدير حسب الفلاتر',
              subtitle: 'تصدير المستفيدين حسب الفلاتر المطبقة',
              color: Colors.purple,
              onTap: () {
                Navigator.of(context).pop();
                VisualFeedback.showInfo(
                  context,
                  'سيتم إضافة هذه الميزة قريباً',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;

  const _ExportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? color.withOpacity(0.1) : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: enabled ? color : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: enabled ? null : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: enabled ? Colors.grey[600] : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled)
                Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
