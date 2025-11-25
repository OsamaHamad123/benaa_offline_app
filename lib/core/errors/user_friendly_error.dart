/// 🎯 User-Friendly Error Messages System
///
/// يوفر رسائل خطأ واضحة وصديقة للمستخدم بدلاً من الرسائل التقنية

abstract class AppError implements Exception {
  String get userMessage;
  String get technicalMessage;
  ErrorSeverity get severity;

  @override
  String toString() => technicalMessage;
}

enum ErrorSeverity {
  info, // معلومة
  warning, // تحذير
  error, // خطأ
  critical, // حرج
}

/// ❌ خطأ في التحقق من البيانات
class ValidationError extends AppError {
  final Map<String, String> fieldErrors;

  ValidationError(this.fieldErrors);

  @override
  String get userMessage {
    if (fieldErrors.length == 1) {
      return fieldErrors.values.first;
    }
    return 'يرجى تصحيح ${fieldErrors.length} أخطاء في النموذج';
  }

  @override
  String get technicalMessage => 'Validation failed: $fieldErrors';

  @override
  ErrorSeverity get severity => ErrorSeverity.warning;
}

/// 🌐 خطأ في الشبكة
class NetworkError extends AppError {
  final dynamic originalError;

  NetworkError([this.originalError]);

  @override
  String get userMessage => 'تحقق من اتصال الإنترنت وحاول مرة أخرى';

  @override
  String get technicalMessage => 'Network error: $originalError';

  @override
  ErrorSeverity get severity => ErrorSeverity.error;
}

/// 💾 خطأ في قاعدة البيانات
class DatabaseError extends AppError {
  final dynamic originalError;
  final String? operation;

  DatabaseError(this.originalError, {this.operation});

  @override
  String get userMessage {
    if (operation == 'save') {
      return 'حدث خطأ أثناء حفظ البيانات';
    } else if (operation == 'load') {
      return 'حدث خطأ أثناء تحميل البيانات';
    } else if (operation == 'delete') {
      return 'حدث خطأ أثناء حذف البيانات';
    }
    return 'حدث خطأ في قاعدة البيانات';
  }

  @override
  String get technicalMessage => 'Database error [$operation]: $originalError';

  @override
  ErrorSeverity get severity => ErrorSeverity.error;
}

/// ⛔ بيانات مفقودة
class DataNotFoundError extends AppError {
  final String resourceType;
  final String? resourceId;

  DataNotFoundError(this.resourceType, [this.resourceId]);

  @override
  String get userMessage {
    if (resourceType == 'beneficiary') {
      return 'المستفيد غير موجود';
    }
    return 'لم يتم العثور على البيانات المطلوبة';
  }

  @override
  String get technicalMessage =>
      '$resourceType not found${resourceId != null ? " (ID: $resourceId)" : ""}';

  @override
  ErrorSeverity get severity => ErrorSeverity.error;
}

/// 🔒 خطأ في الصلاحيات
class PermissionError extends AppError {
  final String action;

  PermissionError(this.action);

  @override
  String get userMessage => 'ليس لديك صلاحية للقيام بهذا الإجراء';

  @override
  String get technicalMessage => 'Permission denied for action: $action';

  @override
  ErrorSeverity get severity => ErrorSeverity.error;
}

/// ⏱️ خطأ انتهاء الوقت
class TimeoutError extends AppError {
  final Duration timeout;

  TimeoutError(this.timeout);

  @override
  String get userMessage =>
      'العملية استغرقت وقتاً طويلاً، يرجى المحاولة مرة أخرى';

  @override
  String get technicalMessage => 'Operation timed out after $timeout';

  @override
  ErrorSeverity get severity => ErrorSeverity.warning;
}

/// ❓ خطأ غير متوقع
class UnexpectedError extends AppError {
  final dynamic originalError;
  final StackTrace? stackTrace;

  UnexpectedError(this.originalError, [this.stackTrace]);

  @override
  String get userMessage => 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';

  @override
  String get technicalMessage =>
      'Unexpected error: $originalError${stackTrace != null ? "\n$stackTrace" : ""}';

  @override
  ErrorSeverity get severity => ErrorSeverity.critical;
}

/// 🎨 Helper class لتحويل الأخطاء العامة إلى رسائل صديقة
class UserFriendlyError {
  /// تحويل أي خطأ إلى رسالة صديقة للمستخدم
  static String getMessage(Object error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      return error.userMessage;
    }

    // تصنيف الأخطاء الشائعة
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return NetworkError(error).userMessage;
    }

    if (errorString.contains('timeout')) {
      return TimeoutError(const Duration(seconds: 30)).userMessage;
    }

    if (errorString.contains('database') ||
        errorString.contains('sql') ||
        errorString.contains('drift')) {
      return DatabaseError(error).userMessage;
    }

    if (errorString.contains('permission') || errorString.contains('denied')) {
      return PermissionError('unknown').userMessage;
    }

    if (errorString.contains('not found')) {
      return DataNotFoundError('resource').userMessage;
    }

    // خطأ غير معروف
    return UnexpectedError(error, stackTrace).userMessage;
  }

  /// الحصول على نوع الخطأ AppError من خطأ عام
  static AppError toAppError(Object error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      return error;
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return NetworkError(error);
    }

    if (errorString.contains('timeout')) {
      return TimeoutError(const Duration(seconds: 30));
    }

    if (errorString.contains('database') ||
        errorString.contains('sql') ||
        errorString.contains('drift')) {
      return DatabaseError(error);
    }

    if (errorString.contains('permission') || errorString.contains('denied')) {
      return PermissionError('unknown');
    }

    if (errorString.contains('not found')) {
      return DataNotFoundError('resource');
    }

    return UnexpectedError(error, stackTrace);
  }
}
