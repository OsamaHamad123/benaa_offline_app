import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/dashboard_statistics.dart'; // ✅ Use existing model
import '../utils/dashboard_colors.dart';
import '../utils/dashboard_text_styles.dart';
import '../utils/dashboard_spacing.dart';
import '../utils/dashboard_pdf_exporter.dart';
import '../utils/dashboard_excel_exporter.dart';

/// Dashboard Export Dialog
class DashboardExportDialog extends StatelessWidget {
  final DashboardStatistics dashboard;

  const DashboardExportDialog({
    required this.dashboard, super.key,
  });

  @override
  Widget build(BuildContext context) {
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
              onTap: () => _exportPdf(context),
            ),

            SizedBox(height: DashboardSpacing.small),

            _buildExportOption(
              context: context,
              icon: Icons.table_chart,
              title: 'تصدير Excel',
              subtitle: 'حفظ التقرير كملف Excel',
              color: Colors.green,
              onTap: () => _exportExcel(context),
            ),

            SizedBox(height: DashboardSpacing.small),

            _buildExportOption(
              context: context,
              icon: Icons.print,
              title: 'طباعة',
              subtitle: 'طباعة التقرير مباشرة',
              color: Colors.blue,
              onTap: () => _printDashboard(context),
            ),

            SizedBox(height: DashboardSpacing.small),

            _buildExportOption(
              context: context,
              icon: Icons.share,
              title: 'مشاركة',
              subtitle: 'مشاركة التقرير عبر التطبيقات',
              color: Colors.orange,
              onTap: () => _shareDashboard(context),
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

  Future<void> _exportPdf(BuildContext context) async {
    Navigator.pop(context);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final file = await DashboardPdfExporter.exportToPdf(dashboard);

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

  Future<void> _exportExcel(BuildContext context) async {
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final file = await DashboardExcelExporter.exportToExcel(dashboard);

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

  Future<void> _printDashboard(BuildContext context) async {
    Navigator.pop(context);

    try {
      await DashboardPdfExporter.printDashboard(dashboard);
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

  Future<void> _shareDashboard(BuildContext context) async {
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
                await DashboardPdfExporter.sharePdf(dashboard);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Excel'),
              onTap: () async {
                Navigator.pop(context);
                await DashboardExcelExporter.shareExcel(dashboard);
              },
            ),
          ],
        ),
      ),
    );
  }
}
