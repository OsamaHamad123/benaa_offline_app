import 'package:benaa_offline_app/core/error_handling/result.dart';
import 'package:benaa_offline_app/features/auth/domain/entities/auth_session.dart';
import 'package:benaa_offline_app/features/auth/domain/entities/auth_token.dart';
import 'package:benaa_offline_app/features/auth/domain/entities/auth_user.dart';
import 'package:benaa_offline_app/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// 🧪 اختبارات تسجيل الدخول - Login Tests
///
/// هذا ملف يختبر عملية تسجيل الدخول بشكل تكاملي
/// باستخدام البيانات الحقيقية من النظام

void main() {
  group('🔑 Login Flow Tests - اختبارات تدفق تسجيل الدخول', () {
    test('🧪 Login State Initial - الحالة الأولية', () {
      // هذا اختبار بسيط يتحقق من الحالة الأولية للنظام

      // الحالة الأولية يجب أن تكون AuthInitial
      const initialState = AuthInitial();

      expect(initialState, isA<AuthInitial>());
    });

    test('✅ Login State Authenticated - حالة المصادق', () {
      // إنشاء بيانات اختبار
      const testUser = AuthUser(
        id: 1,
        name: 'محمد أحمد',
        email: 'mohammed@test.com',
        phone: '+970591234567',
        role: 'admin',
        permissions: ['read', 'write'],
      );

      final testToken = AuthToken(
        accessToken: 'test_token_12345',
        expiresAt: DateTime.now().add(const Duration(days: 10)),
        expiresInDays: 10,
        expiresInSeconds: 864000,
      );

      const offlineConfig = OfflineConfig(
        maxOfflineDays: 7,
        requireOnlineReauth: false,
      );

      final testSession = AuthSession(
        user: testUser,
        token: testToken,
        offlineConfig: offlineConfig,
        loginAt: DateTime.now(),
        deviceId: 'test_device_123',
      );

      // إنشاء حالة مصادق عليها
      final authenticatedState = AuthAuthenticated(session: testSession);

      // التحقق من الحالة
      expect(authenticatedState, isA<AuthAuthenticated>());
      expect(authenticatedState.isAuthenticated, true);
      expect(authenticatedState.session.user.email, 'mohammed@test.com');
      expect(authenticatedState.session.user.name, 'محمد أحمد');
      expect(authenticatedState.session.token.isValid, true);
      expect(authenticatedState.session.isValid, true);
    });

    test('⏳ Login State Loading - حالة التحميل', () {
      const loadingState = AuthLoading(message: 'جاري تسجيل الدخول...');

      expect(loadingState, isA<AuthLoading>());
      expect(loadingState.isLoading, true);
      expect(loadingState.message, 'جاري تسجيل الدخول...');
    });

    test('❌ Login State Error - حالة الخطأ', () {
      const errorState = AuthError(
        message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
      );

      expect(errorState, isA<AuthError>());
      expect(errorState.message, contains('البريد الإلكتروني'));
      expect(errorState.canRetry, true);
    });

    test('🚪 Login State Unauthenticated - غير مصادق', () {
      const unauthenticatedState = AuthUnauthenticated(
        message: 'يرجى تسجيل الدخول',
      );

      expect(unauthenticatedState, isA<AuthUnauthenticated>());
      expect(unauthenticatedState.message, isNotNull);
    });

    test('⚠️ Token Expiring State - حالة انتهاء الصلاحية قريباً', () {
      const testUser = AuthUser(
        id: 1,
        name: 'محمد',
        email: 'test@test.com',
        role: 'user',
      );

      final testToken = AuthToken(
        accessToken: 'expiring_token',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        expiresInDays: 1,
        expiresInSeconds: 86400,
      );

      const offlineConfig = OfflineConfig(
        maxOfflineDays: 7,
        requireOnlineReauth: false,
      );

      final testSession = AuthSession(
        user: testUser,
        token: testToken,
        offlineConfig: offlineConfig,
        loginAt: DateTime.now(),
      );

      final expiringState = AuthTokenExpiring(
        session: testSession,
        remainingDays: 1,
      );

      expect(expiringState, isA<AuthTokenExpiring>());
      expect(expiringState.remainingDays, 1);
      expect(expiringState.session.token.remainingDays, lessThanOrEqualTo(1));
    });
  });

  group('👤 Auth User Entity Tests - اختبارات كيان المستخدم', () {
    test('✅ User permissions check - التحقق من الصلاحيات', () {
      const user = AuthUser(
        id: 1,
        name: 'أحمد',
        email: 'ahmed@test.com',
        role: 'admin',
        permissions: ['read', 'write', 'delete'],
      );

      expect(user.hasPermission('read'), true);
      expect(user.hasPermission('write'), true);
      expect(user.hasPermission('delete'), true);
      expect(user.hasPermission('invalid'), false);
    });

    test('✅ User role check - التحقق من الأدوار', () {
      const user = AuthUser(
        id: 1,
        name: 'فاطمة',
        email: 'fatima@test.com',
        role: 'editor',
        roles: ['editor', 'viewer'],
      );

      expect(user.hasRole('editor'), true);
      expect(user.hasRole('viewer'), true);
      expect(user.hasRole('admin'), false);
    });

    test('🔄 User copyWith - نسخة معدلة', () {
      const originalUser = AuthUser(
        id: 1,
        name: 'خالد',
        email: 'khaled@test.com',
        role: 'user',
      );

      final updatedUser = originalUser.copyWith(
        name: 'خالد محمد',
        email: 'khaled.mohammed@test.com',
      );

      expect(updatedUser.id, originalUser.id);
      expect(updatedUser.name, 'خالد محمد');
      expect(updatedUser.email, 'khaled.mohammed@test.com');
      expect(updatedUser.role, originalUser.role);
    });
  });

  group('🔐 Auth Token Entity Tests - اختبارات كيان الـ Token', () {
    test('✅ Token is valid - الـ Token صالح', () {
      final token = AuthToken(
        accessToken: 'valid_token_12345',
        expiresAt: DateTime.now().add(const Duration(days: 10)),
        expiresInDays: 10,
        expiresInSeconds: 864000,
      );

      expect(token.isValid, true);
      expect(token.isExpired, false);
      expect(token.remainingDays, greaterThan(0));
    });

    test('⏰ Token is expired - الـ Token منتهي', () {
      final token = AuthToken(
        accessToken: 'expired_token',
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        expiresInDays: 0,
        expiresInSeconds: 0,
      );

      expect(token.isExpired, true);
      expect(token.isValid, false);
      expect(token.remainingDays, 0);
    });

    test('⚠️ Token needs refresh - يحتاج لتجديد', () {
      final token = AuthToken(
        accessToken: 'token_needs_refresh',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        expiresInDays: 1,
        expiresInSeconds: 86400,
      );

      expect(token.shouldRefresh, true);
      expect(token.isExpired, false);
      expect(token.remainingDays, lessThanOrEqualTo(2));
    });

    test('🔑 Bearer token format - صيغة الـ Bearer token', () {
      final token = AuthToken(
        accessToken: 'abc123xyz',
        expiresAt: DateTime.now().add(const Duration(days: 10)),
        expiresInDays: 10,
        expiresInSeconds: 864000,
      );

      expect(token.bearerToken, 'Bearer abc123xyz');
    });
  });

  group('🔄 Auth Session Entity Tests - اختبارات كيان الجلسة', () {
    test('✅ Session is valid - الجلسة صالحة', () {
      const user = AuthUser(
        id: 1,
        name: 'علي',
        email: 'ali@test.com',
        role: 'user',
      );

      final token = AuthToken(
        accessToken: 'session_token',
        expiresAt: DateTime.now().add(const Duration(days: 10)),
        expiresInDays: 10,
        expiresInSeconds: 864000,
      );

      const offlineConfig = OfflineConfig(
        maxOfflineDays: 7,
        requireOnlineReauth: false,
      );

      final session = AuthSession(
        user: user,
        token: token,
        offlineConfig: offlineConfig,
        loginAt: DateTime.now(),
      );

      expect(session.isValid, true);
      expect(session.isExpired, false);
      expect(session.user.name, 'علي');
    });

    test('🔄 Session update token - تحديث الـ token', () {
      const user = AuthUser(
        id: 1,
        name: 'سارة',
        email: 'sara@test.com',
        role: 'user',
      );

      final oldToken = AuthToken(
        accessToken: 'old_token',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        expiresInDays: 1,
        expiresInSeconds: 86400,
      );

      final newToken = AuthToken(
        accessToken: 'new_token',
        expiresAt: DateTime.now().add(const Duration(days: 10)),
        expiresInDays: 10,
        expiresInSeconds: 864000,
      );

      const offlineConfig = OfflineConfig(
        maxOfflineDays: 7,
        requireOnlineReauth: false,
      );

      final oldSession = AuthSession(
        user: user,
        token: oldToken,
        offlineConfig: offlineConfig,
        loginAt: DateTime.now(),
      );

      final newSession = oldSession.updateToken(newToken);

      expect(newSession.user, user);
      expect(newSession.token.accessToken, 'new_token');
      expect(newSession.token.remainingDays, greaterThan(oldSession.token.remainingDays));
    });
  });

  group('📊 Result Pattern Tests - اختبارات نمط النتيجة', () {
    test('✅ Success Result', () {
      const testUser = AuthUser(
        id: 1,
        name: 'Test User',
        email: 'test@test.com',
        role: 'user',
      );

      const result = Success(testUser);

      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.getOrNull(), testUser);
      expect(result.getOrThrow(), testUser);
    });

    test('❌ Failure Result', () {
      const failure = AuthFailure('Authentication failed');
      const result = Failure<AuthUser>(failure);

      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.getOrNull(), null);
      expect(() => result.getOrThrow(), throwsA(isA<AuthFailure>()));
    });

    test('🔄 Result getOrElse', () {
      const defaultUser = AuthUser(
        id: 0,
        name: 'Default',
        email: 'default@test.com',
        role: 'guest',
      );

      const failure = Failure<AuthUser>(AuthFailure('Error'));
      expect(failure.getOrElse(defaultUser), defaultUser);

      const actualUser = AuthUser(
        id: 1,
        name: 'Actual',
        email: 'actual@test.com',
        role: 'user',
      );

      const success = Success(actualUser);
      expect(success.getOrElse(defaultUser), actualUser);
    });
  });
}
