/// 🔌 Export Providers - Riverpod providers for export services
///
/// Providers للحصول على خدمات التصدير في أي مكان بالتطبيق

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'unified_pdf_export_service.dart';
import 'unified_excel_export_service.dart';
import 'unified_csv_export_service.dart';

/// Provider لخدمة تصدير PDF
final pdfExportServiceProvider = Provider<UnifiedPdfExportService>((ref) {
  return UnifiedPdfExportService();
});

/// Provider لخدمة تصدير Excel
final excelExportServiceProvider = Provider<UnifiedExcelExportService>((ref) {
  return UnifiedExcelExportService();
});

/// Provider لخدمة تصدير CSV
final csvExportServiceProvider = Provider<UnifiedCsvExportService>((ref) {
  return UnifiedCsvExportService();
});

/// Provider لتهيئة خطوط PDF العربية
final pdfInitializationProvider = FutureProvider<void>((ref) async {
  await UnifiedPdfExportService.initialize();
});
