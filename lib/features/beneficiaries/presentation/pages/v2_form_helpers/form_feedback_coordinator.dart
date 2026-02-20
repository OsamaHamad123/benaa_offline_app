import 'package:flutter/material.dart';
import '../../../../../core/error_handling/error_handler.dart';
import '../../../../../core/utils/haptic_patterns.dart';
import 'widgets/success_animation.dart';

/// 🔔 Unified feedback entry point for beneficiary form flows.
class FormFeedbackCoordinator {
  const FormFeedbackCoordinator();

  void showInfo(BuildContext context, String message) {
    EnhancedSnackbar.showInfo(context, message: message);
  }

  void showWarning(BuildContext context, String message) {
    EnhancedSnackbar.showWarning(context, message: message);
  }

  void showError(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    EnhancedSnackbar.showError(context, message: message, onRetry: onRetry);
  }

  void showSuccess(BuildContext context, String message) {
    EnhancedSnackbar.showSuccess(context, message: message);
  }

  void showSaveSuccessOverlay(BuildContext context, String message) {
    HapticPatterns.success();
    SuccessOverlay.show(context, message: message);
  }

  void showDeleteSuccess(BuildContext context, String message) {
    HapticPatterns.selection();
    EnhancedSnackbar.showSuccess(context, message: message);
  }
}
