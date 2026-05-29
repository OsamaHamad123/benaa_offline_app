import 'package:flutter/foundation.dart';

/// 🔒 LogSanitizer — يمنع تسرب البيانات الحساسة في السجلات
///
/// يوفر دوال لإخفاء المعرفات الوطنية وأرقام الهواتف والأسماء
/// قبل كتابتها في أي سجل (log).
///
/// مثال:
/// ```dart
/// final id = LogSanitizer.maskNationalId(beneficiary.nationalId);
/// UnifiedLogger.info('تم معالجة المستفيد id=$id');
/// // → "تم معالجة المستفيد id=***6789"
/// ```
class LogSanitizer {
  // Prevent instantiation
  LogSanitizer._();

  /// هل تمكين إخفاء البيانات مفعّل؟
  /// في debug mode: يمكن تعطيله للتطوير (لكن يُنصح بتركه مفعّلاً).
  /// في release mode: دائماً مفعّل.
  static bool get _maskingEnabled => !kDebugMode || _debugMaskingOverride;
  static bool _debugMaskingOverride = false;

  /// تفعيل الإخفاء حتى في debug mode (للاختبار)
  static void enableDebugMasking() {
    _debugMaskingOverride = true;
    debugPrint('[Security] sensitive log masking enabled (debug override)');
  }

  /// تعطيل الإخفاء في debug mode (للتطوير فقط — لا تستخدم في production)
  static void disableDebugMasking() {
    assert(() {
      _debugMaskingOverride = false;
      return true;
    }(), 'Cannot disable masking outside of debug mode');
  }

  // ────────────────────────────────────────────────────────────
  // الرقم الوطني / nationalId
  // ────────────────────────────────────────────────────────────

  /// إخفاء الرقم الوطني — يُظهر آخر 4 أرقام فقط.
  ///
  /// مثال: "1234567890" → "******7890"
  static String maskNationalId(String? id) {
    if (id == null || id.isEmpty) return '***';
    if (!_maskingEnabled) return id;
    if (id.length <= 4) return '****';
    final visible = id.substring(id.length - 4);
    return '${'*' * (id.length - 4)}$visible';
  }

  // ────────────────────────────────────────────────────────────
  // رقم الهاتف / phone
  // ────────────────────────────────────────────────────────────

  /// إخفاء رقم الهاتف — يُظهر آخر 3 أرقام فقط.
  ///
  /// مثال: "0791234567" → "*******567"
  static String maskPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '***';
    if (!_maskingEnabled) return phone;
    if (phone.length <= 3) return '***';
    final visible = phone.substring(phone.length - 3);
    return '${'*' * (phone.length - 3)}$visible';
  }

  // ────────────────────────────────────────────────────────────
  // الاسم / name
  // ────────────────────────────────────────────────────────────

  /// إخفاء الاسم — يُظهر الحرف الأول فقط.
  ///
  /// مثال: "محمد أحمد" → "م***"
  static String maskName(String? name) {
    if (name == null || name.isEmpty) return '***';
    if (!_maskingEnabled) return name;
    return '${name[0]}***';
  }

  // ────────────────────────────────────────────────────────────
  // البريد الإلكتروني / email
  // ────────────────────────────────────────────────────────────

  /// إخفاء البريد الإلكتروني — يُظهر الحرف الأول والنطاق فقط.
  ///
  /// مثال: "user@example.com" → "u***@example.com"
  static String maskEmail(String? email) {
    if (email == null || email.isEmpty) return '***';
    if (!_maskingEnabled) return email;
    final atIndex = email.indexOf('@');
    if (atIndex <= 0) return '***';
    final local = email.substring(0, atIndex);
    final domain = email.substring(atIndex);
    if (local.isEmpty) return '***$domain';
    return '${local[0]}***$domain';
  }

  // ────────────────────────────────────────────────────────────
  // المعرّف / ID
  // ────────────────────────────────────────────────────────────

  /// إخفاء جزئي للمعرّف — يُظهر آخر 6 محارف فقط.
  ///
  /// مثال: "abc123def456" → "******f456" → "***f456"
  static String maskId(String? id) {
    if (id == null || id.isEmpty) return '***';
    if (!_maskingEnabled) return id;
    if (id.length <= 6) return '***${id.substring(id.length > 3 ? id.length - 3 : 0)}';
    return '***${id.substring(id.length - 6)}';
  }

  // ────────────────────────────────────────────────────────────
  // Firebase Token / API Key
  // ────────────────────────────────────────────────────────────

  /// إخفاء رموز Firebase / API keys / tokens — يُخفي كل المحتوى.
  ///
  /// مثال: "eyJhbGciOiJSUzI1NiIsInR5..." → "[TOKEN_REDACTED]"
  static String maskToken(String? token) {
    if (token == null || token.isEmpty) return '***';
    if (!_maskingEnabled) return token;
    return '[TOKEN_REDACTED]';
  }

  // ────────────────────────────────────────────────────────────
  // IBAN / حساب بنكي
  // ────────────────────────────────────────────────────────────

  /// إخفاء IBAN أو رقم الحساب البنكي — يُظهر آخر 4 أرقام فقط.
  ///
  /// مثال: "PS92PALS000000000400123456789" → "****6789"
  static String maskIban(String? iban) {
    if (iban == null || iban.isEmpty) return '***';
    if (!_maskingEnabled) return iban;
    // Remove spaces for length check
    final cleaned = iban.replaceAll(' ', '');
    if (cleaned.length <= 4) return '****';
    final visible = cleaned.substring(cleaned.length - 4);
    return '****$visible';
  }

  // ────────────────────────────────────────────────────────────
  // نص عام / generic
  // ────────────────────────────────────────────────────────────

  /// إخفاء نص عام — يُخفي كل المحتوى.
  static String maskSensitive(String? value) {
    if (value == null || value.isEmpty) return '***';
    if (!_maskingEnabled) return value;
    return '[REDACTED]';
  }

  // ────────────────────────────────────────────────────────────
  // Map — إخفاء مفاتيح محددة
  // ────────────────────────────────────────────────────────────

  /// إخفاء الحقول الحساسة في Map قبل تسجيلها.
  ///
  /// مثال:
  /// ```dart
  /// final safeMap = LogSanitizer.sanitizeMap(data, [
  ///   'national_id', 'nationalId', 'phone', 'fullName',
  /// ]);
  /// ```
  static Map<String, dynamic> sanitizeMap(
    Map<String, dynamic> data,
    List<String> sensitiveKeys,
  ) {
    if (!_maskingEnabled) return data;
    final sanitized = Map<String, dynamic>.from(data);
    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        final value = sanitized[key];
        if (value is String) {
          if (_isNationalIdKey(key)) {
            sanitized[key] = maskNationalId(value);
          } else if (_isPhoneKey(key)) {
            sanitized[key] = maskPhone(value);
          } else if (_isNameKey(key)) {
            sanitized[key] = maskName(value);
          } else if (_isTokenKey(key)) {
            sanitized[key] = maskToken(value);
          } else if (_isIbanKey(key)) {
            sanitized[key] = maskIban(value);
          } else {
            sanitized[key] = maskSensitive(value);
          }
        }
      }
    }
    return sanitized;
  }

  /// القائمة الافتراضية للمفاتيح الحساسة التي يجب إخفاؤها
  static const List<String> defaultSensitiveKeys = [
    'national_id',
    'nationalId',
    'phone',
    'phoneNumber',
    'phone_number',
    'fullName',
    'full_name',
    'name',
    'email',
    'password',
    'token',
    'refreshToken',
    'accessToken',
    'idToken',
    'secret',
    'key',
    'apiKey',
    'api_key',
    'iban',
    'bankAccount',
    'bank_account',
  ];

  // ────────────────────────────────────────────────────────────
  // Private helpers
  // ────────────────────────────────────────────────────────────

  static bool _isNationalIdKey(String key) {
    final lower = key.toLowerCase();
    return lower.contains('national') || lower == 'id';
  }

  static bool _isPhoneKey(String key) {
    final lower = key.toLowerCase();
    return lower.contains('phone') || lower.contains('mobile');
  }

  static bool _isNameKey(String key) {
    final lower = key.toLowerCase();
    return lower.contains('name');
  }

  static bool _isTokenKey(String key) {
    final lower = key.toLowerCase();
    return lower.contains('token') ||
        lower.contains('secret') ||
        lower == 'key' ||
        lower.contains('apikey') ||
        lower.contains('api_key') ||
        lower == 'password';
  }

  static bool _isIbanKey(String key) {
    final lower = key.toLowerCase();
    return lower.contains('iban') || lower.contains('bank_account') || lower.contains('bankaccount');
  }

  // ────────────────────────────────────────────────────────────
  // رسائل الأخطاء / error messages
  // ────────────────────────────────────────────────────────────

  /// تنظيف رسائل الأخطاء قبل تسجيلها.
  ///
  /// يحذف أي token أو مسار يحتوي على بيانات حساسة.
  /// يُستخدم عند تسجيل Firestore exceptions أو أخطاء الشبكة.
  ///
  /// مثال:
  /// ```dart
  /// final safe = LogSanitizer.sanitizeErrorMessage(e.toString());
  /// developer.log('error=$safe', name: 'SyncModule');
  /// ```
  static String sanitizeErrorMessage(String? message) {
    if (message == null || message.isEmpty) return '[error_redacted]';
    if (!_maskingEnabled) return message;

    var sanitized = message;

    // Redact Firebase/JWT tokens embedded in error messages
    sanitized = sanitized.replaceAll(
      RegExp(r'eyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]*'),
      '[TOKEN_REDACTED]',
    );

    // Redact national ID patterns (9-12 consecutive digits that look like IDs)
    sanitized = sanitized.replaceAll(
      RegExp(r'\b\d{9,12}\b'),
      '[ID_REDACTED]',
    );

    // Redact Palestinian/international phone numbers
    sanitized = sanitized.replaceAll(
      RegExp(r'\b(?:\+?970|0)(?:5[0-9])\d{7}\b'),
      '[PHONE_REDACTED]',
    );

    // Redact key=value pairs with sensitive key names in error strings
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'(?:national_id|nationalId|phone|fullName|name|password|token|secret)=([^\s,}]+)', caseSensitive: false),
      (m) => '${m.group(0)!.split('=').first}=[REDACTED]',
    );

    return sanitized;
  }
}
