import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/storage/secure_storage.dart';

// سيتم توليد الـ Mock لاحقاً أو استخدامه مباشرة إذا كان متاحاً
// لغرض العرض، سنقوم بكتابة الاختبار بافتراض وجود إمكانية المحاكاة

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Device ID Tests', () {
    late SecureStorage secureStorage;

    setUp(() {
      secureStorage = SecureStorage();
    });

    test('getDeviceId should return a valid UUID', () async {
      final deviceId = await secureStorage.getDeviceId();

      // تحقق من أن المعرف ليس فارغاً
      expect(deviceId, isNotEmpty);

      // تحقق من تنسيق الـ UUID (8-4-4-4-12)
      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false,
      );
      expect(uuidRegex.hasMatch(deviceId), isTrue);
    });

    test('getDeviceId should be persistent', () async {
      final firstId = await secureStorage.getDeviceId();
      final secondId = await secureStorage.getDeviceId();

      expect(firstId, equals(secondId));
    });
  });
}
