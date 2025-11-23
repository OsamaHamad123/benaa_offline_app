import 'package:benaa_offline_app/core/error/error_tracker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 🛡️ Error Handler - معالج أخطاء مركزي
///
/// استخدام:
/// ```dart
/// try {
///   await operation();
/// } catch (e) {
///   ErrorHandler.handle(context, e);
/// }
/// ```
class ErrorHandler {
  ErrorHandler._();

  /// معالجة الخطأ وعرضه للمستخدم
  static void handle(
    BuildContext context,
    dynamic error, {
    String? message,
    VoidCallback? onRetry,
    bool logError = true,
  }) {
    // لوج الخطأ
    if (logError) {
      _logError(error);
    }

    // عرض رسالة للمستخدم
    final errorMessage = message ?? _getErrorMessage(error);
    _showErrorSnackbar(context, errorMessage, onRetry);
  }

  /// عرض dialog للأخطاء الحرجة
  static Future<void> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) async {
    final errorMessage = message ?? _getErrorMessage(error);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title ?? 'حدث خطأ',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          errorMessage,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('إعادة المحاولة'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  /// تحويل الخطأ إلى رسالة مفهومة للمستخدم
  static String _getErrorMessage(dynamic error) {
    if (error == null) return 'حدث خطأ غير متوقع';

    // Network Errors
    if (error is NetworkException) {
      return 'خطأ في الاتصال بالإنترنت\nالرجاء التحقق من اتصالك';
    }

    // Database Errors
    if (error is DatabaseException) {
      return 'خطأ في قاعدة البيانات\nالرجاء المحاولة مرة أخرى';
    }

    // Validation Errors
    if (error is ValidationException) {
      return error.message;
    }

    // Permission Errors
    if (error is PermissionException) {
      return 'لا تملك الصلاحية للقيام بهذا الإجراء';
    }

    // File Errors
    if (error is FileException) {
      return 'خطأ في التعامل مع الملفات\n${error.message}';
    }

    // Timeout Errors
    if (error.toString().contains('timeout') ||
        error.toString().contains('TimeoutException')) {
      return 'انتهت مهلة الاتصال\nالرجاء المحاولة مرة أخرى';
    }

    // Generic error with toString()
    if (kDebugMode) {
      return 'خطأ: ${error.toString()}';
    }

    return 'حدث خطأ غير متوقع\nالرجاء المحاولة مرة أخرى';
  }

  /// عرض Snackbar للخطأ
  static void _showErrorSnackbar(
    BuildContext context,
    String message,
    VoidCallback? onRetry,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'إعادة',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : SnackBarAction(
                label: 'حسناً',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
      ),
    );
  }

  /// لوج الخطأ
  static void _logError(dynamic error) {
    if (kDebugMode) {
      debugPrint('❌ Error occurred: $error');
      if (error is Error) {
        debugPrint('Stack trace: ${error.stackTrace}');
      }
    }

    // إرسال للـ error tracking service
    ErrorTracker.logError(
      error,
      error is Error ? error.stackTrace : StackTrace.current,
    );
  }

  /// عرض رسالة نجاح
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// عرض رسالة تحذير
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
        ),
        backgroundColor: Colors.orange[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// عرض رسالة معلومات
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ========== Custom Exceptions ==========

/// خطأ في الشبكة
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network error']);

  @override
  String toString() => message;
}

/// خطأ في قاعدة البيانات
class DatabaseException implements Exception {
  final String message;
  DatabaseException([this.message = 'Database error']);

  @override
  String toString() => message;
}

/// خطأ في التحقق من البيانات
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}

/// خطأ في الصلاحيات
class PermissionException implements Exception {
  final String message;
  PermissionException([this.message = 'Permission denied']);

  @override
  String toString() => message;
}

/// خطأ في الملفات
class FileException implements Exception {
  final String message;
  FileException(this.message);

  @override
  String toString() => message;
}

/// خطأ في المصادقة
class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Authentication failed']);

  @override
  String toString() => message;
}

/// خطأ في الخادم
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerException: $message (${statusCode ?? "unknown"})';
}
