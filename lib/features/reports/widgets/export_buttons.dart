import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable widget for export buttons (PDF, Excel, CSV, Print)
class ExportButtons extends StatelessWidget {
  final VoidCallback? onPdfExport;
  final VoidCallback? onExcelExport;
  final VoidCallback? onCsvExport;
  final VoidCallback? onPrint;
  final bool isLoading;

  const ExportButtons({
    super.key,
    this.onPdfExport,
    this.onExcelExport,
    this.onCsvExport,
    this.onPrint,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          Row(
            children: [
              if (onPdfExport != null)
                Expanded(
                  child: _ExportButton(
                    icon: Icons.picture_as_pdf,
                    label: 'PDF',
                    color: Colors.red,
                    onTap: onPdfExport!,
                  ),
                ),
              if (onPdfExport != null && onExcelExport != null)
                SizedBox(width: 8.w),
              if (onExcelExport != null)
                Expanded(
                  child: _ExportButton(
                    icon: Icons.table_chart,
                    label: 'Excel',
                    color: Colors.green,
                    onTap: onExcelExport!,
                  ),
                ),
            ],
          ),
          if (onCsvExport != null || onPrint != null) SizedBox(height: 8.h),
          if (onCsvExport != null || onPrint != null)
            Row(
              children: [
                if (onCsvExport != null)
                  Expanded(
                    child: _ExportButton(
                      icon: Icons.description,
                      label: 'CSV',
                      color: Colors.orange,
                      onTap: onCsvExport!,
                    ),
                  ),
                if (onCsvExport != null && onPrint != null)
                  SizedBox(width: 8.w),
                if (onPrint != null)
                  Expanded(
                    child: _ExportButton(
                      icon: Icons.print,
                      label: 'طباعة',
                      color: Colors.blue,
                      onTap: onPrint!,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
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
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18.sp),
      label: Text(label, style: TextStyle(fontSize: 12.sp)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}
