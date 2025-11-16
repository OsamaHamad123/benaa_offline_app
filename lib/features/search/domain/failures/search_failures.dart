/// 🔍 Search Domain Failures
///
/// Type-safe error handling for search operations
/// Following Clean Architecture principles
abstract class SearchFailure {
  final String message;
  final String? details;

  const SearchFailure(this.message, {this.details});

  @override
  String toString() => details != null ? '$message: $details' : message;
}

/// Database is not initialized or file not found
class DatabaseNotFoundFailure extends SearchFailure {
  const DatabaseNotFoundFailure()
    : super(
        'قاعدة بيانات السجل المدني غير موجودة',
        details: 'الرجاء تنزيل قاعدة البيانات من القائمة الرئيسية',
      );
}

/// Database query execution failed
class DatabaseQueryFailure extends SearchFailure {
  const DatabaseQueryFailure(String details)
    : super('فشل في تنفيذ البحث', details: details);
}

/// Search query is invalid or empty
class InvalidQueryFailure extends SearchFailure {
  const InvalidQueryFailure()
    : super('النص المدخل غير صالح', details: 'الرجاء إدخال نص صحيح للبحث');
}

/// Network error (for future remote search)
class NetworkFailure extends SearchFailure {
  const NetworkFailure(String details)
    : super('خطأ في الاتصال', details: details);
}

/// Cache-related failures
class CacheFailure extends SearchFailure {
  const CacheFailure(String details)
    : super('خطأ في ذاكرة التخزين المؤقت', details: details);
}

/// Permission denied to access database
class PermissionFailure extends SearchFailure {
  const PermissionFailure()
    : super(
        'لا توجد صلاحية للوصول',
        details: 'الرجاء التحقق من صلاحيات التطبيق',
      );
}

/// Unexpected error
class UnexpectedFailure extends SearchFailure {
  const UnexpectedFailure(String details)
    : super('خطأ غير متوقع', details: details);
}
