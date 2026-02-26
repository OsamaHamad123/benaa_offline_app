import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/dashboard_statistics.dart'; // ✅ Use existing model
import '../../../taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import '../utils/dashboard_colors.dart';
import '../utils/dashboard_text_styles.dart';
import '../utils/dashboard_spacing.dart';
import '../utils/dashboard_pdf_exporter.dart';
import '../utils/dashboard_excel_exporter.dart';

/// Dashboard Export Dialog
class DashboardExportDialog extends ConsumerWidget {
  final DashboardStatistics dashboard;

  const DashboardExportDialog({
    required this.dashboard,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryRows = _buildCategoryRows(ref, dashboard.categoryCounts);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DashboardSpacing.radiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(DashboardSpacing.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.file_download,
                  color: DashboardColors.totalBeneficiaries,
                  size: 28.sp,
                ),
                SizedBox(width: DashboardSpacing.small),
                Text('تصدير التقرير', style: DashboardTextStyles.sectionTitle),
              ],
            ),

            SizedBox(height: DashboardSpacing.medium),

            Divider(height: 1.h),

            SizedBox(height: DashboardSpacing.medium),

            // Export Options
            _buildExportOption(
              context: context,
              icon: Icons.picture_as_pdf,
              title: 'تصدير PDF',
              subtitle: 'حفظ التقرير كملف PDF',
              color: Colors.red,
              onTap: () => _exportPdf(context, categoryRows),
            ),

            SizedBox(height: DashboardSpacing.small),

            _buildExportOption(
              context: context,
              icon: Icons.table_chart,
              title: 'تصدير Excel',
              subtitle: 'حفظ التقرير كملف Excel',
              color: Colors.green,
              onTap: () => _exportExcel(context, categoryRows),
            ),

            SizedBox(height: DashboardSpacing.small),

            _buildExportOption(
              context: context,
              icon: Icons.print,
              title: 'طباعة',
              subtitle: 'طباعة التقرير مباشرة',
              color: Colors.blue,
              onTap: () => _printDashboard(context, categoryRows),
            ),

            SizedBox(height: DashboardSpacing.small),

            _buildExportOption(
              context: context,
              icon: Icons.share,
              title: 'مشاركة',
              subtitle: 'مشاركة التقرير عبر التطبيقات',
              color: Colors.orange,
              onTap: () => _shareDashboard(context, categoryRows),
            ),

            SizedBox(height: DashboardSpacing.medium),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: DashboardTextStyles.cardSubtitle.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DashboardSpacing.radiusMedium),
      child: Container(
        padding: EdgeInsets.all(DashboardSpacing.paddingMedium),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(DashboardSpacing.radiusMedium),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(DashboardSpacing.paddingSmall),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DashboardSpacing.radiusSmall),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: DashboardSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: DashboardTextStyles.cardTitle),
                  SizedBox(height: DashboardSpacing.tiny),
                  Text(subtitle, style: DashboardTextStyles.cardSubtitle),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    List<MapEntry<String, int>> categoryRows,
  ) async {
    Navigator.pop(context);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final file = await DashboardPdfExporter.exportToPdf(
        dashboard,
        categoryRows: categoryRows,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading

        if (file != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حفظ PDF في: ${file.path}'),
              backgroundColor: DashboardColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تصدير PDF: $e'),
            backgroundColor: DashboardColors.urgent,
          ),
        );
      }
    }
  }

  Future<void> _exportExcel(
    BuildContext context,
    List<MapEntry<String, int>> categoryRows,
  ) async {
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final file = await DashboardExcelExporter.exportToExcel(
        dashboard,
        categoryRows: categoryRows,
      );

      if (context.mounted) {
        Navigator.pop(context);

        if (file != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حفظ Excel في: ${file.path}'),
              backgroundColor: DashboardColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تصدير Excel: $e'),
            backgroundColor: DashboardColors.urgent,
          ),
        );
      }
    }
  }

  Future<void> _printDashboard(
    BuildContext context,
    List<MapEntry<String, int>> categoryRows,
  ) async {
    Navigator.pop(context);

    try {
      await DashboardPdfExporter.printDashboard(
        dashboard,
        categoryRows: categoryRows,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الطباعة: $e'),
            backgroundColor: DashboardColors.urgent,
          ),
        );
      }
    }
  }

  Future<void> _shareDashboard(
    BuildContext context,
    List<MapEntry<String, int>> categoryRows,
  ) async {
    Navigator.pop(context);

    // Show format selection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر صيغة المشاركة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('PDF'),
              onTap: () async {
                Navigator.pop(context);
                await DashboardPdfExporter.sharePdf(
                  dashboard,
                  categoryRows: categoryRows,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Excel'),
              onTap: () async {
                Navigator.pop(context);
                await DashboardExcelExporter.shareExcel(
                  dashboard,
                  categoryRows: categoryRows,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<String, int>> _buildCategoryRows(
    WidgetRef ref,
    Map<String, int> rawCounts,
  ) {
    final taxonomies = _mergeCategoryTaxonomies(ref);
    final normalizedCounts = _normalizeCategoryCounts(rawCounts);
    final labelByKey = _buildCategoryLabelMap(taxonomies);
    final orderedKeys = _orderedCategoryKeys(normalizedCounts.keys.toList());

    return orderedKeys.map((key) {
      final label = labelByKey[key] ?? _fallbackLabelForKey(key) ?? key;
      final count = normalizedCounts[key] ?? 0;
      return MapEntry(label, count);
    }).toList(growable: false);
  }

  List<taxonomy_domain.Taxonomy> _mergeCategoryTaxonomies(WidgetRef ref) {
    final sectionAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.section),
    );
    final categoryAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.category),
    );

    final sectionItems = sectionAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <taxonomy_domain.Taxonomy>[],
    );
    final categoryItems = categoryAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <taxonomy_domain.Taxonomy>[],
    );

    final merged = <String, taxonomy_domain.Taxonomy>{
      for (final item in sectionItems) item.id: item,
      for (final item in categoryItems) item.id: item,
    };

    return merged.values.toList(growable: false);
  }

  Map<String, int> _normalizeCategoryCounts(Map<String, int> rawCounts) {
    final normalized = <String, int>{};
    rawCounts.forEach((key, value) {
      final canonical = _canonicalizeCategoryKey(key);
      if (canonical == null) {
        normalized[key] = (normalized[key] ?? 0) + value;
        return;
      }
      normalized[canonical] = (normalized[canonical] ?? 0) + value;
    });
    return normalized;
  }

  List<String> _orderedCategoryKeys(List<String> keys) {
    final order = ['orphan', 'widow', 'poor', 'disabled'];
    final ordered = <String>[];
    for (final key in order) {
      if (keys.contains(key)) {
        ordered.add(key);
      }
    }
    for (final key in keys) {
      if (!ordered.contains(key)) {
        ordered.add(key);
      }
    }
    return ordered;
  }

  Map<String, String> _buildCategoryLabelMap(
    List<taxonomy_domain.Taxonomy> items,
  ) {
    final labelByKey = <String, String>{};
    for (final item in items) {
      final candidates = <String?>[
        _canonicalizeCategoryKey(item.code),
        _canonicalizeCategoryKey(item.label),
        _canonicalizeCategoryKey(_parseTaxonomyNumericKey(item)?.toString()),
      ];
      for (final candidate in candidates) {
        if (candidate == null || labelByKey.containsKey(candidate)) {
          continue;
        }
        final label = item.label.trim();
        if (label.isNotEmpty) {
          labelByKey[candidate] = label;
        }
      }
    }
    return labelByKey;
  }

  String? _canonicalizeCategoryKey(String? raw) {
    if (raw == null) {
      return null;
    }

    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    switch (normalized) {
      case '1':
        return 'orphan';
      case '2':
        return 'poor';
      case '3':
        return 'widow';
      case '4':
        return 'disabled';
      case 'orphan':
      case 'orphans':
      case 'يتيم':
      case 'أيتام':
        return 'orphan';
      case 'widow':
      case 'widows':
      case 'أرملة':
      case 'أرامل':
        return 'widow';
      case 'poor':
      case 'فقير':
      case 'فقراء':
        return 'poor';
      case 'disabled':
      case 'معاق':
      case 'ذوي الإعاقة':
      case 'ذوي إعاقة':
        return 'disabled';
    }

    return null;
  }

  String? _fallbackLabelForKey(String key) {
    switch (key) {
      case 'orphan':
        return 'أيتام';
      case 'widow':
        return 'أرامل';
      case 'poor':
        return 'فقراء';
      case 'disabled':
        return 'ذوي الإعاقة';
      default:
        return null;
    }
  }

  int? _parseTaxonomyNumericKey(taxonomy_domain.Taxonomy taxonomy) {
    final code = int.tryParse(taxonomy.code.trim());
    if (code != null) {
      return code;
    }

    final rawId = taxonomy.id.trim();
    if (rawId.isEmpty) {
      return null;
    }

    final separatorIndex = rawId.indexOf('::');
    final suffix = separatorIndex >= 0 ? rawId.substring(separatorIndex + 2) : rawId;
    return int.tryParse(suffix.trim());
  }
}
