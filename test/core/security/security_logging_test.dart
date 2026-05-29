import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/utils/log_sanitizer.dart';

/// اختبارات أمان السجلات — تضمن أن البيانات الحساسة لا تُسجَّل خام
///
/// المتطلبات:
/// 1. nationalId مُخفى
/// 2. phone مُخفى
/// 3. fullName/name مُخفى
/// 4. email مُخفى جزئياً
/// 5. Firebase token مُحجوب
/// 6. API key مُحجوب
/// 7. IBAN/bank account مُخفى
/// 8. raw beneficiary map مُعقّم
/// 9. nested map sensitive fields مُعقّمة إن كان مدعوماً
/// 10. null/empty values لا تُعطل
void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('Security Logging Tests — بيانات حساسة', () {
    setUp(() => LogSanitizer.enableDebugMasking());

    // 1. nationalId
    test('1. nationalId مُخفى في السجلات', () {
      const nationalId = '9876543210';
      final masked = LogSanitizer.maskNationalId(nationalId);
      expect(masked.contains(nationalId), isFalse, reason: 'الرقم الوطني الكامل يجب ألا يظهر في أي سجل');
      expect(masked.endsWith('3210'), isTrue, reason: 'يُظهر آخر 4 أرقام فقط');
    });

    // 2. phone
    test('2. phone مُخفى في السجلات', () {
      const phone = '0599887766';
      final masked = LogSanitizer.maskPhone(phone);
      expect(masked.contains(phone), isFalse, reason: 'رقم الهاتف الكامل يجب ألا يظهر');
      expect(masked.endsWith('766'), isTrue, reason: 'يُظهر آخر 3 أرقام فقط');
    });

    // 3. fullName / name
    test('3. fullName/name مُخفى في السجلات', () {
      const name = 'أحمد محمد الغزي';
      final masked = LogSanitizer.maskName(name);
      expect(masked.contains('الغزي'), isFalse, reason: 'اللقب لا يجب أن يظهر');
      expect(masked.startsWith('أ'), isTrue, reason: 'يُظهر الحرف الأول فقط');
    });

    // 4. email مُخفى جزئياً
    test('4. email مُخفى جزئياً', () {
      const email = 'admin@benaa-cedar.org';
      final masked = LogSanitizer.maskEmail(email);
      expect(masked.contains('admin'), isFalse, reason: 'الجزء المحلي يجب إخفاؤه');
      expect(masked.contains('@benaa-cedar.org'), isTrue, reason: 'النطاق يُظهر');
      expect(masked.startsWith('a'), isTrue, reason: 'الحرف الأول يُظهر');
    });

    // 5. Firebase token مُحجوب
    test('5. Firebase token مُحجوب بـ [TOKEN_REDACTED]', () {
      const token = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.payload.signature';
      final masked = LogSanitizer.maskToken(token);
      expect(masked, '[TOKEN_REDACTED]', reason: 'Token Firebase يجب أن يكون محجوباً تماماً');
      expect(masked.contains('eyJ'), isFalse);
    });

    // 6. API key مُحجوب
    test('6. API key مُحجوب بـ maskSensitive', () {
      const apiKey = 'AIzaSyB-production-firebase-key-12345';
      final masked = LogSanitizer.maskSensitive(apiKey);
      expect(masked, '[REDACTED]', reason: 'API key يجب أن يكون محجوباً تماماً');
      expect(masked.contains('AIzaSy'), isFalse);
    });

    // 7. IBAN / bank account مُخفى
    test('7. IBAN مُخفى — آخر 4 أرقام فقط', () {
      const iban = 'PS92PALS000000000400123456789';
      final masked = LogSanitizer.maskIban(iban);
      expect(masked.contains('PS92PALS'), isFalse, reason: 'رقم IBAN الكامل يجب إخفاؤه');
      expect(masked.endsWith('6789'), isTrue, reason: 'يُظهر آخر 4 أرقام');
    });

    // 8. raw beneficiary map مُعقّم
    test('8. raw beneficiary map مُعقّم قبل التسجيل', () {
      final beneficiaryMap = {
        'nationalId': '123456789',
        'phone': '0791234567',
        'fullName': 'محمد أحمد',
        'email': 'm.ahmed@example.com',
        'category': 'widow', // غير حساس
        'age': 45, // غير حساس
      };
      final sanitized = LogSanitizer.sanitizeMap(
        beneficiaryMap.map((k, v) => MapEntry(k, v.toString())),
        LogSanitizer.defaultSensitiveKeys,
      );
      expect(sanitized['nationalId'], isNot('123456789'));
      expect(sanitized['phone'], isNot('0791234567'));
      expect(sanitized['fullName'], isNot('محمد أحمد'));
      expect(sanitized['email'], isNot('m.ahmed@example.com'));
      expect(sanitized['category'], 'widow', reason: 'الحقول غير الحساسة لا تُخفى');
    });

    // 9. nested fields — token في map
    test('9. token في map يُخفى بـ [TOKEN_REDACTED]', () {
      final data = {
        'token': 'firebase-id-token-value',
        'refreshToken': 'firebase-refresh-token',
        'userId': 'u_001',
      };
      final sanitized = LogSanitizer.sanitizeMap(data, ['token', 'refreshToken']);
      expect(sanitized['token'], '[TOKEN_REDACTED]');
      expect(sanitized['refreshToken'], '[TOKEN_REDACTED]');
      expect(sanitized['userId'], 'u_001', reason: 'userId لا يُخفى');
    });

    // 10. null/empty values لا تُعطل
    test('10. null/empty values لا تُعطل أي دالة', () {
      expect(() => LogSanitizer.maskNationalId(null), returnsNormally);
      expect(() => LogSanitizer.maskNationalId(''), returnsNormally);
      expect(() => LogSanitizer.maskPhone(null), returnsNormally);
      expect(() => LogSanitizer.maskPhone(''), returnsNormally);
      expect(() => LogSanitizer.maskName(null), returnsNormally);
      expect(() => LogSanitizer.maskName(''), returnsNormally);
      expect(() => LogSanitizer.maskEmail(null), returnsNormally);
      expect(() => LogSanitizer.maskEmail(''), returnsNormally);
      expect(() => LogSanitizer.maskToken(null), returnsNormally);
      expect(() => LogSanitizer.maskToken(''), returnsNormally);
      expect(() => LogSanitizer.maskIban(null), returnsNormally);
      expect(() => LogSanitizer.maskIban(''), returnsNormally);
      expect(() => LogSanitizer.maskSensitive(null), returnsNormally);
      expect(() => LogSanitizer.maskSensitive(''), returnsNormally);
    });

    // 11. masking enabled by default in tests
    test('11. إخفاء البيانات مفعّل في وضع الاختبار عبر enableDebugMasking', () {
      const id = '1234567890';
      final result = LogSanitizer.maskNationalId(id);
      // إذا كان المسking مفعّلاً، النتيجة لن تساوي الـ id الأصلي
      expect(result, isNot(id));
    });
  });
}
