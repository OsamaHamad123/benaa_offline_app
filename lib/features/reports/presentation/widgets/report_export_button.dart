import 'package:flutter/material.dart';

/// 📤 Report Export Button with dropdown menu
class ReportExportButton extends StatelessWidget {
  final VoidCallback onExportPdf;
  final VoidCallback onExportExcel;

  const ReportExportButton({
    required this.onExportPdf, required this.onExportExcel, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.file_download),
      tooltip: 'تصدير التقرير',
      onSelected: (value) {
        if (value == 'pdf') {
          onExportPdf();
        } else if (value == 'excel') {
          onExportExcel();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red),
              SizedBox(width: 12),
              Text('تصدير PDF'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'excel',
          child: Row(
            children: [
              Icon(Icons.table_chart, color: Colors.green),
              SizedBox(width: 12),
              Text('تصدير Excel'),
            ],
          ),
        ),
      ],
    );
  }
}
