import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CivilRegistryAutofillFeedbackHelper {
  const CivilRegistryAutofillFeedbackHelper._();

  static void showSuccess({
    required BuildContext context,
    required String message,
    required VoidCallback onCompleted,
    Duration duration = const Duration(seconds: 3),
  }) {
    HapticFeedback.lightImpact();
    onCompleted();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }
}
