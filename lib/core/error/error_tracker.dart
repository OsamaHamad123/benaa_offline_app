import 'package:flutter/foundation.dart';

/// 🐛 خدمة تتبع الأخطاء والتقارير
class ErrorTracker {
  static final List<AppError> _errors = [];
  static const int _maxErrors = 50;

  /// تسجيل خطأ
  static void logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? metadata,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    final appError = AppError(
      error: error,
      stackTrace: stackTrace,
      context: context,
      metadata: metadata,
      severity: severity,
      timestamp: DateTime.now(),
    );

    _errors.add(appError);

    // الاحتفاظ بآخر 50 خطأ فقط
    if (_errors.length > _maxErrors) {
      _errors.removeAt(0);
    }

    // طباعة في وضع التطوير
    if (kDebugMode) {
      _printError(appError);
    }

    // إرسال للخدمات الخارجية في Production
    if (kReleaseMode && severity == ErrorSeverity.critical) {
      _reportToExternalService(appError);
    }
  }

  /// تسجيل خطأ حرج
  static void logCritical(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    logError(
      error,
      stackTrace,
      context: context,
      metadata: metadata,
      severity: ErrorSeverity.critical,
    );
  }

  /// تسجيل تحذير
  static void logWarning(
    String message, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    logError(
      message,
      null,
      context: context,
      metadata: metadata,
      severity: ErrorSeverity.warning,
    );
  }

  /// تسجيل معلومة
  static void logInfo(
    String message, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    logError(
      message,
      null,
      context: context,
      metadata: metadata,
      severity: ErrorSeverity.info,
    );
  }

  /// الحصول على كل الأخطاء
  static List<AppError> getAllErrors() => List.unmodifiable(_errors);

  /// الحصول على أخطاء حسب الخطورة
  static List<AppError> getErrorsBySeverity(ErrorSeverity severity) {
    return _errors.where((e) => e.severity == severity).toList();
  }

  /// الحصول على الأخطاء الحرجة فقط
  static List<AppError> getCriticalErrors() {
    return getErrorsBySeverity(ErrorSeverity.critical);
  }

  /// مسح كل الأخطاء
  static void clear() {
    _errors.clear();
  }

  /// تصدير تقرير الأخطاء
  static String generateErrorReport() {
    final buffer = StringBuffer();
    buffer.writeln('🐛 Error Report');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total Errors: ${_errors.length}\n');

    // تجميع حسب الخطورة
    final bySeverity = <ErrorSeverity, int>{};
    for (final error in _errors) {
      bySeverity[error.severity] = (bySeverity[error.severity] ?? 0) + 1;
    }

    buffer.writeln('--- By Severity ---');
    bySeverity.forEach((severity, count) {
      buffer.writeln('${severity.name}: $count');
    });

    buffer.writeln('\n--- Recent Errors ---');
    final recentErrors = _errors.reversed.take(10);
    for (final error in recentErrors) {
      buffer.writeln('\n${error.severity.emoji} ${error.timestamp}');
      buffer.writeln('Context: ${error.context ?? 'N/A'}');
      buffer.writeln('Error: ${error.error}');
      if (error.metadata != null) {
        buffer.writeln('Metadata: ${error.metadata}');
      }
    }

    return buffer.toString();
  }

  static void _printError(AppError error) {
    print(
      '\n${error.severity.emoji} ${error.severity.name.toUpperCase()} '
      '${error.context != null ? '[${error.context}]' : ''}',
    );
    print('Error: ${error.error}');
    if (error.metadata != null) {
      print('Metadata: ${error.metadata}');
    }
    if (error.stackTrace != null) {
      print('Stack Trace:\n${error.stackTrace}');
    }
  }

  static void _reportToExternalService(AppError error) {
    // TODO: إرسال للـ Sentry أو Firebase Crashlytics
    if (kDebugMode) {
      print('📤 Would report to external service: ${error.error}');
    }
  }
}

/// نموذج الخطأ
class AppError {
  final dynamic error;
  final StackTrace? stackTrace;
  final String? context;
  final Map<String, dynamic>? metadata;
  final ErrorSeverity severity;
  final DateTime timestamp;

  const AppError({
    required this.error,
    this.stackTrace,
    this.context,
    this.metadata,
    required this.severity,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'AppError(${severity.name}, $context, $error)';
  }
}

/// مستوى خطورة الخطأ
enum ErrorSeverity {
  info('ℹ️'),
  warning('⚠️'),
  error('❌'),
  critical('🔴');

  final String emoji;
  const ErrorSeverity(this.emoji);
}
