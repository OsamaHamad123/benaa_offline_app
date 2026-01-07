import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/auth/data/dto/auth_dto.dart';
import 'package:benaa_offline_app/features/auth/data/mappers/auth_mappers.dart';

void main() {
  group('🔐 Login Flow Integration Tests - اختبار تدفق تسجيل الدخول الكامل', () {
    test('✅ يجب معالجة استجابة تسجيل الدخول الكاملة بنجاح', () {
      // محاكاة استجابة حقيقية من API
      final apiResponse = {
        'success': true,
        'message': 'تم تسجيل الدخول بنجاح',
        'data': {
          'user': {
            'id': 123,
            'name': 'محمد أحمد علي',
            'email': 'mohammad@example.com',
            'phone': 970591234567, // ← رقم من نوع int
            'avatar': 999, // ← رقم من نوع int
            'role': 'admin',
            'roles': ['admin', 'user'],
            'permissions': [
              'view_beneficiaries',
              'create_beneficiaries',
              'view_associations',
              'download_database',
            ],
          },
          'token': {
            'access_token':
                'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoiLCJpYXQiOjE3MDQ1NTIwMDAsIm5iZiI6MTcwNDU1MjAwMCwiZXhwIjoxNzA1NDE2MDAwLCJzdWIiOiIxMjMiLCJzY29wZXMiOltdfQ.test',
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

      // يجب أن لا يرمي أي استثناء
      MobileLoginResponse? response;
      expect(
        () => response = MobileLoginResponse.fromJson(apiResponse),
        returnsNormally,
        reason: 'يجب معالجة الاستجابة بدون أخطاء',
      );

      // التحقق من البيانات
      expect(response, isNotNull);
      expect(response!.success, true);
      expect(response!.message, 'تم تسجيل الدخول بنجاح');
      expect(response!.data, isNotNull);

      // التحقق من بيانات المستخدم
      final user = response!.data!.user;
      expect(user.id, 123);
      expect(user.name, 'محمد أحمد علي');
      expect(user.email, 'mohammad@example.com');
      expect(user.phone, '970591234567', reason: 'يجب تحويل phone من int إلى String');
      expect(user.avatar, '999', reason: 'يجب تحويل avatar من int إلى String');
      expect(user.role, 'admin');
      expect(user.roles, contains('admin'));
      expect(user.permissions, contains('download_database'));

      print('✅ تحقق من بيانات المستخدم:');
      print('   ID: ${user.id}');
      print('   Name: ${user.name}');
      print('   Email: ${user.email}');
      print('   Phone: ${user.phone} (تم التحويل من int)');
      print('   Avatar: ${user.avatar} (تم التحويل من int)');
      print('   Role: ${user.role}');
      print('   Roles: ${user.roles}');
      print('   Permissions: ${user.permissions}');

      // التحقق من Token
      final token = response!.data!.token;
      expect(token.accessToken, isNotEmpty);
      expect(token.tokenType, 'Bearer');
      expect(token.expiresInDays, 10);

      print('✅ تحقق من Token:');
      print('   Type: ${token.tokenType}');
      print('   Expires in: ${token.expiresInDays} days');

      // التحقق من Offline Config
      final config = response!.data!.offlineConfig;
      expect(config.maxOfflineDays, 10);
      expect(config.requireOnlineReauth, true);

      print('✅ تحقق من Offline Config:');
      print('   Max offline days: ${config.maxOfflineDays}');
      print('   Require online reauth: ${config.requireOnlineReauth}');
    });

    test('✅ يجب تحويل LoginResponse إلى AuthSession', () {
      final apiResponse = {
        'success': true,
        'message': 'تم تسجيل الدخول بنجاح',
        'data': {
          'user': {
            'id': 1,
            'name': 'Test User',
            'email': 'test@example.com',
            'phone': 1234567890, // int
            'avatar': 999, // int
            'role': 'user',
            'roles': ['user'],
            'permissions': ['read'],
          },
          'token': {
            'access_token': 'test_token',
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

      final response = MobileLoginResponse.fromJson(apiResponse);
      final session = AuthMappers.sessionFromLoginResponse(response);

      expect(session, isNotNull, reason: 'يجب إنشاء session من response');
      expect(session!.user.phone, '1234567890');
      expect(session.user.avatar, '999');
      expect(session.token.accessToken, 'test_token');

      print('✅ تم تحويل Response إلى Session بنجاح');
      print('   User: ${session.user.name}');
      print('   Phone: ${session.user.phone}');
      print('   Token: ${session.token.bearerToken}');
    });

    test('❌ يجب معالجة استجابة فشل تسجيل الدخول', () {
      final errorResponse = {
        'success': false,
        'message': null,
        'data': null,
        'error': 'بيانات الاعتماد غير صحيحة',
        'errors': {
          'email': ['البريد الإلكتروني غير موجود'],
          'password': ['كلمة المرور غير صحيحة'],
        },
      };

      final response = MobileLoginResponse.fromJson(errorResponse);

      expect(response.success, false);
      expect(response.error, 'بيانات الاعتماد غير صحيحة');
      expect(response.data, isNull);
      expect(response.errors, isNotNull);

      print('✅ تم معالجة استجابة الفشل بنجاح');
      print('   Error: ${response.error}');
      print('   Errors: ${response.errors}');
    });

    test('🔢 يجب التعامل مع phone بصيغ مختلفة', () {
      // صيغ مختلفة للـ phone
      final testCases = [
        {'phone': 970591234567, 'expected': '970591234567'}, // int
        {'phone': '+970591234567', 'expected': '+970591234567'}, // String
        {'phone': 970591234567.0, 'expected': '970591234567.0'}, // double
        {'phone': null, 'expected': null}, // null
      ];

      for (final testCase in testCases) {
        final json = {
          'id': 1,
          'name': 'Test',
          'email': 'test@test.com',
          'phone': testCase['phone'],
          'avatar': null,
          'role': 'user',
          'roles': [],
          'permissions': [],
        };

        final user = MobileUserDto.fromJson(json);
        expect(user.phone, testCase['expected']);

        print(
          '✅ Phone: ${testCase['phone']} → ${user.phone} (${testCase['phone'].runtimeType})',
        );
      }
    });

    test('📸 يجب التعامل مع avatar بصيغ مختلفة', () {
      // صيغ مختلفة للـ avatar
      final testCases = [
        {'avatar': 12345, 'expected': '12345'}, // int (ID)
        {'avatar': 'https://example.com/avatar.jpg', 'expected': 'https://example.com/avatar.jpg'}, // String (URL)
        {'avatar': 999.5, 'expected': '999.5'}, // double
        {'avatar': null, 'expected': null}, // null
      ];

      for (final testCase in testCases) {
        final json = {
          'id': 1,
          'name': 'Test',
          'email': 'test@test.com',
          'phone': null,
          'avatar': testCase['avatar'],
          'role': 'user',
          'roles': [],
          'permissions': [],
        };

        final user = MobileUserDto.fromJson(json);
        expect(user.avatar, testCase['expected']);

        print(
          '✅ Avatar: ${testCase['avatar']} → ${user.avatar} (${testCase['avatar'].runtimeType})',
        );
      }
    });

    test('🔄 يجب حفظ واستعادة Session من/إلى Map', () {
      // إنشاء session
      final apiResponse = {
        'success': true,
        'data': {
          'user': {
            'id': 1,
            'name': 'Test User',
            'email': 'test@example.com',
            'phone': 1234567890,
            'avatar': 999,
            'role': 'user',
            'roles': ['user'],
            'permissions': ['read'],
          },
          'token': {
            'access_token': 'test_token',
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

      final response = MobileLoginResponse.fromJson(apiResponse);
      final session = AuthMappers.sessionFromLoginResponse(response)!;

      // تحويل إلى Map (للتخزين)
      final sessionMap = AuthMappers.sessionToMap(session);
      expect(sessionMap, isNotNull);
      expect(sessionMap['user'], isNotNull);
      expect(sessionMap['token'], isNotNull);

      // استعادة من Map
      final restoredSession = AuthMappers.sessionFromMap(sessionMap);
      expect(restoredSession.user.id, session.user.id);
      expect(restoredSession.user.phone, '1234567890');
      expect(restoredSession.user.avatar, '999');
      expect(restoredSession.token.accessToken, session.token.accessToken);

      print('✅ تم حفظ واستعادة Session بنجاح');
      print('   Original phone: ${session.user.phone}');
      print('   Restored phone: ${restoredSession.user.phone}');
      print('   Original avatar: ${session.user.avatar}');
      print('   Restored avatar: ${restoredSession.user.avatar}');
    });
  });

  group('🔍 Login Error Scenarios - سيناريوهات أخطاء تسجيل الدخول', () {
    test('❌ استجابة بدون بيانات', () {
      final emptyResponse = {
        'success': true,
        'message': 'نجاح',
        'data': null,
      };

      final response = MobileLoginResponse.fromJson(emptyResponse);
      final session = AuthMappers.sessionFromLoginResponse(response);

      expect(session, isNull, reason: 'يجب إرجاع null عندما data = null');
    });

    test('❌ استجابة غير ناجحة', () {
      final failedResponse = {
        'success': false,
        'error': 'فشل تسجيل الدخول',
      };

      final response = MobileLoginResponse.fromJson(failedResponse);
      final session = AuthMappers.sessionFromLoginResponse(response);

      expect(session, isNull, reason: 'يجب إرجاع null عندما success = false');
    });
  });
}
