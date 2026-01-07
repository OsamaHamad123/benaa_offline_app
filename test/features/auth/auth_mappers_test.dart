import 'package:benaa_offline_app/features/auth/data/mappers/auth_mappers.dart';
import 'package:flutter_test/flutter_test.dart';

/// 🧪 اختبارات Auth Mappers - للتحقق من التحويلات الصحيحة
///
/// هذا الاختبار يتحقق من إصلاح المشكلة:
/// "type 'int' is not a subtype of type 'String?' in type cast"
void main() {
  group('🔧 Auth Mappers Bug Fix Tests - اختبارات إصلاح الأخطاء', () {
    test('✅ يجب تحويل phone من int إلى String بنجاح', () {
      // Arrange - محاكاة البيانات القادمة من الـ API حيث phone هو int
      final map = {
        'id': 1,
        'name': 'محمد أحمد',
        'email': 'mohammed@test.com',
        'phone': 970591234567, // ❗ phone كـ int (هذا كان يسبب الخطأ)
        'avatar': null,
        'role': 'admin',
        'roles': ['admin', 'user'],
        'permissions': ['read', 'write', 'delete'],
      };

      // Act - محاولة تحويل Map إلى AuthUser
      final user = AuthMappers.userFromMap(map);

      // Assert - يجب أن يتم التحويل بنجاح
      expect(user.id, 1);
      expect(user.name, 'محمد أحمد');
      expect(user.email, 'mohammed@test.com');
      expect(user.phone, '970591234567'); // ✅ تم التحويل من int إلى String
      expect(user.role, 'admin');
    });

    test('✅ يجب تحويل avatar من int إلى String بنجاح', () {
      // Arrange - محاكاة avatar كـ int
      final map = {
        'id': 2,
        'name': 'فاطمة علي',
        'email': 'fatima@test.com',
        'phone': null,
        'avatar': 12345, // ❗ avatar كـ int
        'role': 'user',
        'roles': ['user'],
        'permissions': ['read'],
      };

      // Act
      final user = AuthMappers.userFromMap(map);

      // Assert
      expect(user.avatar, '12345'); // ✅ تم التحويل من int إلى String
    });

    test('✅ يجب قبول phone كـ String عادي', () {
      // Arrange - phone كـ String (الحالة العادية)
      final map = {
        'id': 3,
        'name': 'أحمد خالد',
        'email': 'ahmed@test.com',
        'phone': '+970591234567', // phone كـ String
        'avatar': 'https://example.com/avatar.jpg',
        'role': 'user',
        'roles': [],
        'permissions': [],
      };

      // Act
      final user = AuthMappers.userFromMap(map);

      // Assert
      expect(user.phone, '+970591234567'); // ✅ String يبقى كما هو
      expect(user.avatar, 'https://example.com/avatar.jpg');
    });

    test('✅ يجب التعامل مع phone و avatar كـ null', () {
      // Arrange - كلاهما null
      final map = {
        'id': 4,
        'name': 'سارة محمود',
        'email': 'sara@test.com',
        'phone': null,
        'avatar': null,
        'role': 'guest',
        'roles': [],
        'permissions': [],
      };

      // Act
      final user = AuthMappers.userFromMap(map);

      // Assert
      expect(user.phone, null);
      expect(user.avatar, null);
    });

    test('🔢 يجب التعامل مع أرقام phone مختلفة الأنواع', () {
      // Arrange - أنواع مختلفة من الأرقام
      final testCases = [
        {'phone': 123, 'expected': '123'},
        {'phone': 970591234567, 'expected': '970591234567'},
        {'phone': 0, 'expected': '0'},
        {'phone': -1, 'expected': '-1'},
        {'phone': 1.5, 'expected': '1.5'}, // double
      ];

      for (final testCase in testCases) {
        // Arrange
        final map = {
          'id': 5,
          'name': 'Test User',
          'email': 'test@test.com',
          'phone': testCase['phone'],
          'avatar': null,
          'role': 'user',
          'roles': [],
          'permissions': [],
        };

        // Act
        final user = AuthMappers.userFromMap(map);

        // Assert
        expect(user.phone, testCase['expected'], reason: 'Failed for phone: ${testCase['phone']}');
      }
    });

    test('📋 يجب التعامل مع roles و permissions بشكل صحيح', () {
      // Arrange
      final map = {
        'id': 6,
        'name': 'علي محمد',
        'email': 'ali@test.com',
        'phone': 970599999999,
        'avatar': null,
        'role': 'admin',
        'roles': ['admin', 'moderator', 'user'],
        'permissions': ['read', 'write', 'delete', 'manage_users'],
      };

      // Act
      final user = AuthMappers.userFromMap(map);

      // Assert
      expect(user.roles, ['admin', 'moderator', 'user']);
      expect(user.permissions, ['read', 'write', 'delete', 'manage_users']);
      expect(user.hasRole('admin'), true);
      expect(user.hasRole('guest'), false);
      expect(user.hasPermission('write'), true);
      expect(user.hasPermission('invalid'), false);
    });

    test('🔄 يجب عدم رمي استثناء مع بيانات API حقيقية', () {
      // Arrange - محاكاة البيانات الفعلية من الـ API
      final apiResponse = {
        'id': 1,
        'name': 'مستخدم النظام',
        'email': 'system@benaa.ps',
        'phone': 970591234567, // API قد ترسلها كـ int
        'avatar': null,
        'role': 'admin',
        'roles': ['admin'],
        'permissions': ['read', 'write', 'delete', 'manage_users'],
      };

      // Act & Assert - يجب ألا يرمي أي استثناء
      expect(
        () => AuthMappers.userFromMap(apiResponse),
        returnsNormally,
      );

      final user = AuthMappers.userFromMap(apiResponse);
      expect(user.phone, isNotNull);
      expect(user.phone, isA<String>());
    });

    test('⚠️ الاختبار القديم الذي كان يفشل - يجب أن ينجح الآن', () {
      // Arrange - البيانات التي كانت تسبب الخطأ:
      // "type 'int' is not a subtype of type 'String?' in type cast"
      final problematicMap = {
        'id': 100,
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': 1234567890, // هذا كان يسبب crash
        'avatar': 999, // هذا أيضاً كان يسبب crash
        'role': 'user',
        'roles': [],
        'permissions': [],
      };

      // Act - قبل الإصلاح: كان يرمي استثناء
      //       بعد الإصلاح: يجب أن يعمل بنجاح
      final user = AuthMappers.userFromMap(problematicMap);

      // Assert
      expect(user, isNotNull);
      expect(user.phone, '1234567890');
      expect(user.avatar, '999');
      print('✅ الإصلاح ناجح! phone=${user.phone}, avatar=${user.avatar}');
    });
  });

  group('🔐 Token Mappers Tests - اختبارات محول الـ Token', () {
    test('✅ يجب تحويل Token Map بشكل صحيح', () {
      // Arrange
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 10));

      final map = {
        'access_token': 'test_token_12345',
        'token_type': 'Bearer',
        'expires_at': expiresAt.toIso8601String(),
        'expires_in_days': 10,
        'expires_in_seconds': 864000,
      };

      // Act
      final token = AuthMappers.tokenFromMap(map);

      // Assert
      expect(token.accessToken, 'test_token_12345');
      expect(token.tokenType, 'Bearer');
      expect(token.expiresInDays, 10);
      expect(token.expiresInSeconds, 864000);
      expect(token.isValid, true);
      expect(token.isExpired, false);
    });

    test('✅ يجب حساب expires_in_days تلقائياً إذا لم يكن موجوداً', () {
      // Arrange - بدون expires_in_days
      final expiresAt = DateTime.now().add(const Duration(days: 5));

      final map = {
        'access_token': 'token_abc',
        'token_type': 'Bearer',
        'expires_at': expiresAt.toIso8601String(),
        // expires_in_days غير موجود
        // expires_in_seconds غير موجود
      };

      // Act
      final token = AuthMappers.tokenFromMap(map);

      // Assert
      expect(token.expiresInDays, greaterThanOrEqualTo(4)); // ~5 أيام
      expect(token.expiresInDays, lessThanOrEqualTo(5));
    });
  });

  group('📦 Session Mappers Tests - اختبارات محول الجلسة', () {
    test('✅ يجب تحويل Session Map مع جميع الحقول', () {
      // Arrange
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 10));

      final map = {
        'user': {
          'id': 1,
          'name': 'Test User',
          'email': 'test@test.com',
          'phone': 970591234567, // int
          'avatar': null,
          'role': 'admin',
          'roles': ['admin'],
          'permissions': ['read', 'write'],
        },
        'token': {
          'access_token': 'token_xyz',
          'token_type': 'Bearer',
          'expires_at': expiresAt.toIso8601String(),
          'expires_in_days': 10,
          'expires_in_seconds': 864000,
        },
        'offline_config': {
          'max_offline_days': 7,
          'require_online_reauth': false,
          'sync_required_on_expiry': true,
        },
        'created_at': now.toIso8601String(),
        'device_id': 'device_123',
      };

      // Act
      final session = AuthMappers.sessionFromMap(map);

      // Assert
      expect(session.user.name, 'Test User');
      expect(session.user.phone, '970591234567'); // ✅ تم التحويل
      expect(session.token.accessToken, 'token_xyz');
      expect(session.offlineConfig.maxOfflineDays, 7);
      expect(session.isValid, true);
    });
  });
}
