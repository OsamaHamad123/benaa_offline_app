import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/utils/log_sanitizer.dart';

/// اختبارات التحقق من أن البيانات الحساسة لا تظهر في السجلات
void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('LogSanitizer — Security Visibility', () {
    setUp(() => LogSanitizer.enableDebugMasking());

    test('[Security] الرقم الوطني لا يظهر كاملاً في السجلات', () {
      const nationalId = '9876543210';
      final masked = LogSanitizer.maskNationalId(nationalId);
      expect(masked.contains(nationalId), isFalse, reason: 'الرقم الوطني الكامل يجب ألا يظهر في أي سجل');
      expect(masked.endsWith('3210'), isTrue, reason: 'يجب إظهار آخر 4 أرقام فقط');
    });

    test('[Security] رقم الهاتف لا يظهر كاملاً في السجلات', () {
      const phone = '0599887766';
      final masked = LogSanitizer.maskPhone(phone);
      expect(masked.contains(phone), isFalse, reason: 'رقم الهاتف الكامل يجب ألا يظهر في أي سجل');
      expect(masked.endsWith('766'), isTrue, reason: 'يجب إظهار آخر 3 أرقام فقط');
    });

    test('[Security] الاسم لا يظهر كاملاً في السجلات', () {
      const name = 'أحمد محمد الغزي';
      final masked = LogSanitizer.maskName(name);
      expect(masked.contains('الغزي'), isFalse, reason: 'الاسم الكامل يجب ألا يظهر في السجلات');
      expect(masked.startsWith('أ'), isTrue, reason: 'يجب إظهار الحرف الأول فقط');
    });

    test('[Security] البريد الإلكتروني لا يظهر كاملاً', () {
      const email = 'admin@benaa.org';
      final masked = LogSanitizer.maskEmail(email);
      expect(masked.contains('admin'), isFalse, reason: 'الجزء المحلي من البريد يجب أن يُخفى');
      expect(masked.contains('@benaa.org'), isTrue, reason: 'النطاق يمكن إظهاره');
    });

    test('[Security] maskSensitive يُعيد [REDACTED]', () {
      expect(LogSanitizer.maskSensitive('firebase-token-xyz'), '[REDACTED]');
      expect(LogSanitizer.maskSensitive('session-key'), '[REDACTED]');
    });

    test('[Security] sanitizeMap يُخفي المفاتيح المحددة فقط', () {
      final data = {
        'nationalId': '123456789',
        'phone': '0791234567',
        'name': 'محمد',
        'category': 'orphan', // لا يُخفى
      };
      final safe = LogSanitizer.sanitizeMap(data, ['nationalId', 'phone', 'name']);
      expect(safe['nationalId'], isNot('123456789'));
      expect(safe['phone'], isNot('0791234567'));
      expect(safe['name'], isNot('محمد'));
      expect(safe['category'], 'orphan', reason: 'الحقول غير الحساسة لا تُخفى');
    });

    test('[Security] التعامل الآمن مع القيم null', () {
      expect(() => LogSanitizer.maskNationalId(null), returnsNormally);
      expect(() => LogSanitizer.maskPhone(null), returnsNormally);
      expect(() => LogSanitizer.maskName(null), returnsNormally);
      expect(() => LogSanitizer.maskEmail(null), returnsNormally);
    });
  });
}
