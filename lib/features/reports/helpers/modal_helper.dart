import 'package:flutter/material.dart';

/// Helper functions for showing report modal sheets
class ModalHelper {
  /// Show a report modal bottom sheet
  static void showReportModal(
    BuildContext context, {
    required Widget child,
    double initialChildSize = 0.5,
    double minChildSize = 0.3,
    double maxChildSize = 0.7,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        expand: false,
        builder: (context, scrollController) => child,
      ),
    );
  }
}
