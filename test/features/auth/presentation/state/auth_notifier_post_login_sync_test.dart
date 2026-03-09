import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/error_handling/result.dart';
import 'package:benaa_offline_app/features/auth/domain/entities/auth_device.dart';
import 'package:benaa_offline_app/features/auth/domain/entities/auth_session.dart';
import 'package:benaa_offline_app/features/auth/domain/entities/auth_token.dart';
import 'package:benaa_offline_app/features/auth/domain/entities/auth_user.dart';
import 'package:benaa_offline_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:benaa_offline_app/features/auth/presentation/state/auth_notifier.dart';
import 'package:benaa_offline_app/features/auth/presentation/state/auth_state.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._session);

  final AuthSession _session;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required String deviceId,
    String? deviceName,
    String? devicePlatform,
  }) async {
    return Success(_session);
  }

  @override
  Future<String> getDeviceId() async => 'device-test';

  @override
  Future<String> getDeviceName() async => 'device-name';

  @override
  String getDevicePlatform() => 'android';

  @override
  Future<Result<void>> clearSession() async => const Success(null);

  @override
  Future<Result<List<AuthDevice>>> getActiveDevices() async => const Success([]);

  @override
  Future<Result<AuthUser>> getProfile() async => Success(_session.user);

  @override
  Future<Result<AuthSession>> getStoredSession() async => Success(_session);

  @override
  Future<bool> hasValidSession() async => true;

  @override
  Future<Result<void>> logout({String? deviceId, bool logoutAllDevices = false}) async => const Success(null);

  @override
  Future<Result<AuthToken>> refreshToken({required String deviceId}) async => Success(_session.token);

  @override
  Future<Result<void>> saveSession(AuthSession session) async => const Success(null);

  @override
  Future<bool> shouldRefreshToken() async => false;

  @override
  Future<Result<TokenValidationResult>> validateToken() async {
    return Success(
      TokenValidationResult(
        valid: true,
        userId: _session.user.id,
        userName: _session.user.name,
        tokenExpiresAt: _session.token.expiresAt,
        remainingDays: _session.token.remainingDays,
        remainingSeconds: _session.token.remainingSeconds,
        shouldRefresh: false,
      ),
    );
  }
}

AuthSession _buildSession() {
  return AuthSession(
    user: const AuthUser(
      id: 1,
      name: 'Tester',
      email: 'tester@example.com',
      role: 'user',
    ),
    token: AuthToken(
      accessToken: 'token',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      expiresInDays: 7,
      expiresInSeconds: 7 * 24 * 60 * 60,
    ),
    offlineConfig: const OfflineConfig(),
    loginAt: DateTime.now(),
    deviceId: 'device-test',
  );
}

void main() {
  group('AuthNotifier post-login sync', () {
    test('runs post-login sync after successful login', () async {
      final repository = _FakeAuthRepository(_buildSession());
      var syncCalls = 0;

      final notifier = AuthNotifier(
        authRepository: repository,
        isOnline: () async => true,
        postLoginSync: () async {
          syncCalls++;
        },
      );

      final result = await notifier.login(
        email: 'tester@example.com',
        password: '123456',
      );

      expect(result, isTrue);
      expect(syncCalls, 1);
      expect(notifier.currentState, isA<AuthAuthenticated>());
    });

    test('keeps login successful even if post-login sync fails', () async {
      final repository = _FakeAuthRepository(_buildSession());

      final notifier = AuthNotifier(
        authRepository: repository,
        isOnline: () async => true,
        postLoginSync: () async {
          throw Exception('sync failed');
        },
      );

      final result = await notifier.login(
        email: 'tester@example.com',
        password: '123456',
      );

      expect(result, isTrue);
      expect(notifier.currentState, isA<AuthAuthenticated>());
    });
  });
}
