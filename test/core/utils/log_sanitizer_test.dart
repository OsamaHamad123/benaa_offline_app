import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/utils/log_sanitizer.dart';

void main() {
  group('LogSanitizer', () {
    setUp(() {
      // تأكد أن الإخفاء مفعّل في الاختبارات
      LogSanitizer.enableDebugMasking();
    });

    // ── nationalId ────────────────────────────────────────────────────────────
    group('maskNationalId', () {
      test('يُظهر آخر 4 أرقام فقط', () {
        expect(LogSanitizer.maskNationalId('1234567890'), '******7890');
      });

      test('يُعيد *** للقيمة الفارغة', () {
        expect(LogSanitizer.maskNationalId(''), '***');
      });

      test('يُعيد *** للقيمة null', () {
        expect(LogSanitizer.maskNationalId(null), '***');
      });

      test('يُعيد **** عند طول أقل من 4', () {
        expect(LogSanitizer.maskNationalId('123'), '****');
      });

      test('لا يُظهر الرقم الوطني الكامل', () {
        final result = LogSanitizer.maskNationalId('987654321');
        expect(result.contains('987654321'), isFalse);
      });
    });

    // ── phone ─────────────────────────────────────────────────────────────────
    group('maskPhone', () {
      test('يُظهر آخر 3 أرقام فقط', () {
        expect(LogSanitizer.maskPhone('0791234567'), '*******567');
      });

      test('يُعيد *** للقيمة الفارغة', () {
        expect(LogSanitizer.maskPhone(''), '***');
      });

      test('يُعيد *** للقيمة null', () {
        expect(LogSanitizer.maskPhone(null), '***');
      });

      test('يُعيد *** عند طول أقل من 3', () {
        expect(LogSanitizer.maskPhone('07'), '***');
      });

      test('لا يُظهر رقم الهاتف الكامل', () {
        final result = LogSanitizer.maskPhone('0599123456');
        expect(result.contains('0599123456'), isFalse);
      });
    });

    // ── name ──────────────────────────────────────────────────────────────────
    group('maskName', () {
      test('يُظهر الحرف الأول فقط', () {
        expect(LogSanitizer.maskName('محمد أحمد'), 'م***');
      });

      test('يُعيد *** للقيمة الفارغة', () {
        expect(LogSanitizer.maskName(''), '***');
      });

      test('يُعيد *** للقيمة null', () {
        expect(LogSanitizer.maskName(null), '***');
      });

      test('لا يُظهر الاسم الكامل في الإنتاج', () {
        final result = LogSanitizer.maskName('أحمد محمود الفلسطيني');
        expect(result.contains('الفلسطيني'), isFalse);
      });
    });

    // ── email ─────────────────────────────────────────────────────────────────
    group('maskEmail', () {
      test('يُظهر الحرف الأول والنطاق فقط', () {
        expect(LogSanitizer.maskEmail('user@example.com'), 'u***@example.com');
      });

      test('يُعيد *** للقيمة الفارغة', () {
        expect(LogSanitizer.maskEmail(''), '***');
      });

      test('يُعيد *** للقيمة null', () {
        expect(LogSanitizer.maskEmail(null), '***');
      });
    });

    // ── maskId ────────────────────────────────────────────────────────────────
    group('maskId', () {
      test('يُظهر آخر 6 أحرف', () {
        final result = LogSanitizer.maskId('abc-123-xyz-999');
        expect(result.endsWith('z-999'), isTrue);
      });
    });

    // ── maskSensitive ─────────────────────────────────────────────────────────
    group('maskSensitive', () {
      test('يُعيد [REDACTED]', () {
        expect(LogSanitizer.maskSensitive('any_value'), '[REDACTED]');
      });
    });

    // ── maskToken ─────────────────────────────────────────────────────────────
    group('maskToken', () {
      test('يُعيد [TOKEN_REDACTED] لأي token', () {
        expect(LogSanitizer.maskToken('eyJhbGciOiJSUzI1NiIsInR5cCI6Ik...'), '[TOKEN_REDACTED]');
      });

      test('يُعيد *** للقيمة الفارغة', () {
        expect(LogSanitizer.maskToken(''), '***');
      });

      test('يُعيد *** للقيمة null', () {
        expect(LogSanitizer.maskToken(null), '***');
      });

      test('لا يُظهر قيمة الـ token الفعلية', () {
        const token = 'firebase-secret-api-key-123';
        final result = LogSanitizer.maskToken(token);
        expect(result.contains(token), isFalse);
      });
    });

    // ── maskIban ──────────────────────────────────────────────────────────────
    group('maskIban', () {
      test('يُظهر آخر 4 أرقام فقط', () {
        expect(LogSanitizer.maskIban('PS92PALS000000000400123456789'), '****6789');
      });

      test('يُعيد *** للقيمة الفارغة', () {
        expect(LogSanitizer.maskIban(''), '***');
      });

      test('يُعيد *** للقيمة null', () {
        expect(LogSanitizer.maskIban(null), '***');
      });

      test('لا يُظهر رقم الحساب الكامل', () {
        const iban = 'PS92PALS000000000400123456789';
        final result = LogSanitizer.maskIban(iban);
        expect(result.contains('PS92PALS'), isFalse);
      });
    });

    // ── sanitizeMap ───────────────────────────────────────────────────────────
    group('sanitizeMap', () {
      test('يُخفي المفاتيح المحددة', () {
        final input = {'nationalId': '123456789', 'name': 'محمد', 'age': '30'};
        final result = LogSanitizer.sanitizeMap(input, ['nationalId', 'name']);
        expect(result['nationalId'], isNot('123456789'));
        expect(result['name'], isNot('محمد'));
        expect(result['age'], '30'); // لا يتم إخفاؤه
      });

      test('يُخفي token في map باستخدام [TOKEN_REDACTED]', () {
        final input = {'token': 'abc123secret', 'userId': 'u001'};
        final result = LogSanitizer.sanitizeMap(input, ['token']);
        expect(result['token'], '[TOKEN_REDACTED]');
      });

      test('يُخفي IBAN في map بآخر 4 أرقام', () {
        final input = {'iban': 'PS92PALS000000000400123456789', 'name': 'محمد'};
        final result = LogSanitizer.sanitizeMap(input, ['iban', 'name']);
        expect(result['iban'], '****6789');
      });

      test('لا يؤثر على الحقول غير الموجودة', () {
        final input = {'userId': 'u001'};
        final result = LogSanitizer.sanitizeMap(input, ['nationalId']);
        expect(result['userId'], 'u001');
      });
    });
  });
}
