/// ⚡ نظام معالجة الأخطاء المتقدم
/// Advanced Error Handling System
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

/// 🎯 **Error Types**
enum ErrorType { network, database, validation, authentication, sync, unknown }

/// 📊 **App Error Model**
class AppError {
  final ErrorType type;
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final bool isFatal;

  AppError({
    required this.type,
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
    DateTime? timestamp,
    this.isFatal = false,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'AppError(${type.name}): $message ${code != null ? '[$code]' : ''}';
}

/// 🔧 **Global Error Handler**
class GlobalErrorHandler {
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();
  factory GlobalErrorHandler() => _instance;
  GlobalErrorHandler._internal();

  final List<AppError> _errorLog = [];
  final _maxLogSize = 100;

  /// Log error
  void logError(AppError error) {
    _errorLog.add(error);
    if (_errorLog.length > _maxLogSize) {
      _errorLog.removeAt(0);
    }

    // Log to console/analytics
    developer.log(
      error.message,
      name: 'AppError',
      error: error.originalError,
      stackTrace: error.stackTrace,
      level: error.isFatal ? 1000 : 900,
    );
  }

  /// Get error history
  List<AppError> get errorLog => List.unmodifiable(_errorLog);

  /// Clear error log
  void clearLog() => _errorLog.clear();

  /// Handle error with user feedback
  static void handleError(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) {
    _instance.logError(error);

    // Show user-friendly message
    _showErrorSnackBar(context, error, onRetry: onRetry);
  }

  static void _showErrorSnackBar(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getErrorIcon(error.type), color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getErrorTitle(error.type),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error.message,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(error.type),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'إعادة المحاولة',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.database:
        return Icons.storage_rounded;
      case ErrorType.validation:
        return Icons.error_outline_rounded;
      case ErrorType.authentication:
        return Icons.lock_outline_rounded;
      case ErrorType.sync:
        return Icons.sync_problem_rounded;
      case ErrorType.unknown:
        return Icons.warning_rounded;
    }
  }

  static String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'خطأ في الاتصال';
      case ErrorType.database:
        return 'خطأ في قاعدة البيانات';
      case ErrorType.validation:
        return 'خطأ في البيانات';
      case ErrorType.authentication:
        return 'خطأ في المصادقة';
      case ErrorType.sync:
        return 'خطأ في المزامنة';
      case ErrorType.unknown:
        return 'حدث خطأ';
    }
  }

  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange.shade700;
      case ErrorType.database:
        return Colors.red.shade700;
      case ErrorType.validation:
        return Colors.amber.shade700;
      case ErrorType.authentication:
        return Colors.deepOrange.shade700;
      case ErrorType.sync:
        return Colors.blue.shade700;
      case ErrorType.unknown:
        return Colors.grey.shade700;
    }
  }
}

/// 🎨 **Enhanced Snackbar Widgets**
class EnhancedSnackbar {
  EnhancedSnackbar._();

  /// Success message
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Error message
  static void showError(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: onRetry != null
            ? SnackBarAction(
                label: 'إعادة',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Warning message
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Info message
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// 🛡️ **Error Boundary Widget**
class ErrorBoundary extends ConsumerStatefulWidget {
  final Widget child;
  final Widget Function(Object error)? errorBuilder;
  final Function(Object error, StackTrace stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  @override
  void initState() {
    super.initState();

    // Set up global error handler
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Log the error
      if (widget.onError != null) {
        widget.onError!(details.exception, details.stack ?? StackTrace.current);
      }

      GlobalErrorHandler().logError(
        AppError(
          type: ErrorType.unknown,
          message: details.exceptionAsString(),
          originalError: details.exception,
          stackTrace: details.stack,
          isFatal: true,
        ),
      );

      // Show error widget
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(details.exception);
      }

      return Container(
        color: Colors.red.shade50,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade700),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ غير متوقع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              details.exceptionAsString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 🔄 **Retry Mechanism Widget**
class RetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  const RetryWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.refresh_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
