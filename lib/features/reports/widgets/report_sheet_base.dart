import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../services/pdf_export_service.dart';
import 'export_buttons.dart';

/// Base class للـ Report Sheets - يوفر الـ export functionality
abstract class ReportSheetBase<T> extends ConsumerStatefulWidget {
  const ReportSheetBase({super.key});
}

/// State للـ Report Sheet مع export methods
abstract class ReportSheetState<T, W extends ReportSheetBase<T>>
    extends ConsumerState<W> {
  bool _isExporting = false;

  bool get isExporting => _isExporting;

  /// Export to PDF
  Future<void> exportToPdf(
    List<T> data,
    Future<Uint8List> Function(List<T>) pdfGenerator,
    String filename,
  ) async {
    setState(() => _isExporting = true);
    try {
      final pdfBytes = await pdfGenerator(data);
      await PdfExportService.shareOrPrint(pdfBytes, filename);
      if (mounted) {
        _showSuccessSnackBar('تم تصدير PDF بنجاح');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('خطأ في تصدير PDF: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// Export to Excel
  Future<void> exportToExcel(
    List<T> data,
    Future<String> Function(List<T>) excelGenerator,
    String shareText,
  ) async {
    setState(() => _isExporting = true);
    try {
      final filePath = await excelGenerator(data);
      await Share.shareXFiles([XFile(filePath)], text: shareText);
      if (mounted) {
        _showSuccessSnackBar('تم تصدير Excel بنجاح');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('خطأ في تصدير Excel: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// Build Export Buttons Widget
  Widget buildExportButtons({
    required VoidCallback onPdfExport,
    required VoidCallback onExcelExport,
    required VoidCallback onPrint,
  }) {
    return ExportButtons(
      isLoading: _isExporting,
      onPdfExport: onPdfExport,
      onExcelExport: onExcelExport,
      onPrint: onPrint,
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
