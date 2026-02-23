import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// 🎨 Enhanced Toast Helper
///
/// استخدام Toast بدل SnackBar لتجربة أفضل
class ToastHelper {
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static void showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static void showWarning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

/// 💾 Auto-save Helper
///
/// حفظ تلقائي للبيانات كل فترة زمنية
class AutoSaveHelper {
  static const Duration _autoSaveDuration = Duration(seconds: 30);

  static void startAutoSave(VoidCallback onSave) {
    Stream.periodic(_autoSaveDuration).listen((_) {
      onSave();
    });
  }
}

/// ✅ Form Validation Visual Feedback
class ValidationIcon extends StatelessWidget {
  final bool isValid;
  final bool showIcon;

  const ValidationIcon({
    required this.isValid, super.key,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showIcon) return const SizedBox.shrink();

    return Icon(
      isValid ? Icons.check_circle : Icons.error,
      color: isValid ? Colors.green : Colors.red,
      size: 20,
    );
  }
}

/// 🎭 Enhanced SnackBar
class EnhancedSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final color = switch (type) {
      SnackBarType.success => Colors.green,
      SnackBarType.error => Colors.red,
      SnackBarType.warning => Colors.orange,
      SnackBarType.info => Colors.blue,
    };

    final icon = switch (type) {
      SnackBarType.success => Icons.check_circle,
      SnackBarType.error => Icons.error,
      SnackBarType.warning => Icons.warning,
      SnackBarType.info => Icons.info,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

enum SnackBarType { success, error, warning, info }
