import 'package:flutter/material.dart';
import '../../../core/widgets/responsive_bottom_sheet.dart';

/// Helper functions for showing report modal sheets
class ModalHelper {
  /// Show a report modal bottom sheet
  static void showReportModal(
    BuildContext context, {
    required Widget child,
    String? title,
    IconData? icon,
    double initialChildSize = 0.5,
    double minChildSize = 0.3,
    double maxChildSize = 0.7,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResponsiveBottomSheet(
        title: title,
        icon: icon,
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        child: child,
      ),
    );
  }
}
