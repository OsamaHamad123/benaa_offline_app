import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/associations_reports_provider.dart';

/// 📤 قسم تصدير التقرير
class ExportReportSection extends StatelessWidget {
  final AssociationsStats stats;

  const ExportReportSection({required this.stats, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.file_download,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'تصدير التقرير',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _ExportButton(
                    icon: Icons.picture_as_pdf,
                    label: 'PDF',
                    color: Colors.red,
                    onTap: () => _exportPDF(context),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ExportButton(
                    icon: Icons.table_chart,
                    label: 'Excel',
                    color: Colors.green,
                    onTap: () => _exportExcel(context),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ExportButton(
                    icon: Icons.code,
                    label: 'CSV',
                    color: Colors.blue,
                    onTap: () => _exportCSV(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _exportPDF(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تصدير التقرير بصيغة PDF...'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Implement PDF export
  }

  void _exportExcel(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تصدير التقرير بصيغة Excel...'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Implement Excel export
  }

  void _exportCSV(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تصدير التقرير بصيغة CSV...'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Implement CSV export
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
