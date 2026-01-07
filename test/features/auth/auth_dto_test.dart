import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/auth/data/dto/auth_dto.dart';

void main() {
  group('🔧 Auth DTO Type Conversion Tests - اختبارات تحويل الأنواع في DTO', () {
    test('✅ يجب تحويل MobileUserDto بنجاح عندما phone و avatar من نوع int', () {
      // هذا يحاكي الاستجابة الفعلية من API
      final json = {
        'id': 1,
        'name': 'محمد أحمد',
        'email': 'mohammad@example.com',
        'phone': 970591234567, // ← int من API
        'avatar': 12345, // ← int من API
        'role': 'user',
        'roles': ['user', 'admin'],
        'permissions': ['read', 'write'],
      };

      // يجب أن لا يرمي استثناء
      expect(
        () => MobileUserDto.fromJson(json),
        returnsNormally,
        reason: 'يجب أن يتعامل StringConverter مع int بدون استثناء',
      );

      final user = MobileUserDto.fromJson(json);

      // تحقق من التحويل الصحيح
      expect(user.phone, '970591234567');
      expect(user.avatar, '12345');
      expect(user.name, 'محمد أحمد');
      expect(user.email, 'mohammad@example.com');

      print('✅ نجح التحويل: phone=${user.phone}, avatar=${user.avatar}');
    });

    test('✅ يجب قبول phone و avatar كـ String', () {
      final json = {
        'id': 2,
        'name': 'أحمد علي',
        'email': 'ahmed@example.com',
        'phone': '+970591234567', // ← String
        'avatar': 'https://example.com/avatar.jpg', // ← String
        'role': 'admin',
        'roles': ['admin'],
        'permissions': ['all'],
      };

      final user = MobileUserDto.fromJson(json);

      expect(user.phone, '+970591234567');
      expect(user.avatar, 'https://example.com/avatar.jpg');
    });

    test('✅ يجب التعامل مع phone و avatar كـ null', () {
      final json = {
        'id': 3,
        'name': 'علي محمد',
        'email': 'ali@example.com',
        'phone': null,
        'avatar': null,
        'role': 'guest',
        'roles': [],
        'permissions': [],
      };

      final user = MobileUserDto.fromJson(json);

      expect(user.phone, isNull);
      expect(user.avatar, isNull);
    });

    test('✅ يجب التعامل مع phone كـ double', () {
      final json = {
        'id': 4,
        'name': 'خالد يوسف',
        'email': 'khaled@example.com',
        'phone': 970591234567.0, // ← double
        'avatar': 999.5, // ← double
        'role': 'user',
        'roles': ['user'],
        'permissions': ['read'],
      };

      final user = MobileUserDto.fromJson(json);

      expect(user.phone, '970591234567.0');
      expect(user.avatar, '999.5');
    });

    test('🔄 يجب التعامل مع استجابة كاملة من API', () {
      // استجابة كاملة تحاكي ما يرجع من السيرفر
      final apiResponse = {
        'success': true,
        'message': 'تم تسجيل الدخول بنجاح',
        'data': {
          'user': {
            'id': 1,
            'name': 'محمد أحمد',
            'email': 'mohammad@example.com',
            'phone': 970591234567, // ← int من API
            'avatar': 12345, // ← int من API
            'role': 'user',
            'roles': ['user', 'admin'],
            'permissions': ['read', 'write', 'delete'],
          },
          'token': {
            'access_token': 'test_token_123',
            'token_type': 'Bearer',
            'expires_at': DateTime.now().add(Duration(days: 10)).toIso8601String(),
            'expires_in_days': 10,
            'expires_in_seconds': 864000,
          },
          'offline_config': {
            'max_offline_days': 10,
            'require_online_reauth': true,
            'sync_required_on_expiry': true,
          },
        },
      };

      // يجب أن لا يرمي استثناء
      expect(
        () => MobileLoginResponse.fromJson(apiResponse),
        returnsNormally,
        reason: 'يجب معالجة الاستجابة الكاملة بدون أخطاء',
      );

      final response = MobileLoginResponse.fromJson(apiResponse);

      expect(response.success, true);
      expect(response.data, isNotNull);
      expect(response.data!.user.phone, '970591234567');
      expect(response.data!.user.avatar, '12345');

      print('✅ نجحت معالجة الاستجابة الكاملة من API');
      print('   User: ${response.data!.user.name}');
      print('   Phone: ${response.data!.user.phone}');
      print('   Avatar: ${response.data!.user.avatar}');
      print('   Token: ${response.data!.token.accessToken}');
    });

    test('⚠️ اختبار السيناريو الذي كان يفشل قبل الإصلاح', () {
      // هذا بالضبط ما كان يسبب الخطأ:
      // "type 'int' is not a subtype of type 'String?' in type cast"
      final problematicJson = {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': 1234567890, // ← كان يرمي استثناء هنا
        'avatar': 999, // ← وهنا
        'role': 'user',
        'roles': ['user'],
        'permissions': [],
      };

      // قبل الإصلاح: كان يرمي استثناء
      // بعد الإصلاح: يجب أن يعمل بدون مشاكل
      final user = MobileUserDto.fromJson(problematicJson);

      expect(user.phone, '1234567890');
      expect(user.avatar, '999');

      print('✅ الإصلاح ناجح! السيناريو الذي كان يفشل الآن يعمل بنجاح');
      print('   phone=${user.phone}, avatar=${user.avatar}');
    });
  });
}
