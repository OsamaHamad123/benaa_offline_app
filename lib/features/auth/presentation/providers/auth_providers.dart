import 'package:benaa_offline_app/core/config/api_config.dart';
import 'package:benaa_offline_app/core/storage/secure_storage.dart';
import 'package:benaa_offline_app/features/auth/data/interceptors/auth_interceptor.dart';
import 'package:benaa_offline_app/core/security/auth_session_events.dart';
import 'package:benaa_offline_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:benaa_offline_app/features/auth/domain/entities/auth_session.dart';
import 'package:benaa_offline_app/features/auth/domain/entities/auth_user.dart';
import 'package:benaa_offline_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:benaa_offline_app/features/auth/presentation/state/auth_notifier.dart';
import 'package:benaa_offline_app/features/auth/presentation/state/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ===========================
// 📦 INFRASTRUCTURE PROVIDERS
// ===========================

/// 💾 Secure Storage Provider
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// 🌐 Dio HTTP Client Provider (بدون Auth Interceptor)
/// يُستخدم للطلبات التي لا تحتاج مصادقة (مثل Login)
final baseDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.defaultBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Add interceptors for logging
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (object) => print('🌐 DIO: $object'),
  ));

  return dio;
});

/// 🔐 Authenticated Dio HTTP Client Provider (مع Auth Interceptor)
/// يُستخدم للطلبات التي تحتاج مصادقة
final authDioProvider = Provider<Dio>((ref) {
  final dio = AuthDioFactory.create(
    baseUrl: ApiConfig.defaultBaseUrl,
    secureStorage: ref.watch(secureStorageProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );

  return dio;
});

// ===========================
// 📚 REPOSITORY PROVIDERS
// ===========================

/// 🔐 Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    dio: ref.watch(baseDioProvider), // استخدام baseDio للـ login (لا يحتاج token)
    secureStorage: ref.watch(secureStorageProvider),
  );
});

// ===========================
// 🔐 AUTH STATE PROVIDERS
// ===========================

/// 🔐 Auth Notifier Provider - Main Auth State
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authRepository: ref.watch(authRepositoryProvider),
  );
});

/// 🚀 Auth Bootstrap Provider
/// يفحص الجلسة عند تشغيل التطبيق مرة واحدة لكل دورة حياة المزود.
final authBootstrapProvider = FutureProvider<void>((ref) async {
  await Future<void>.microtask(() {});
  await ref.read(authNotifierProvider.notifier).checkAuthStatus();
});

/// 📡 Global session events provider
final authSessionEventProvider = StreamProvider<AuthSessionEvent>((ref) {
  return AuthSessionEvents.instance.stream;
});

/// ✅ Is Authenticated Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

/// 👤 Current User Provider
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

/// 📦 Current Session Provider
final currentSessionProvider = Provider<AuthSession?>((ref) {
  return ref.watch(authNotifierProvider).session;
});

/// ⏳ Is Loading Provider
final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isLoading;
});

/// ❌ Auth Error Provider
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).errorMessage;
});

/// 📴 Is Offline Provider
final isOfflineAuthProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isOffline;
});

/// 🔄 Needs Token Refresh Provider
final needsTokenRefreshProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).needsTokenRefresh;
});

// ===========================
// 🔒 PERMISSION PROVIDERS
// ===========================

/// ✅ Has Permission Provider Factory
final hasPermissionProvider = Provider.family<bool, String>((ref, permission) {
  return ref.watch(currentUserProvider)?.hasPermission(permission) ?? false;
});

/// ✅ Has Role Provider Factory
final hasRoleProvider = Provider.family<bool, String>((ref, role) {
  return ref.watch(currentUserProvider)?.hasRole(role) ?? false;
});

// ===========================
// 🔑 TOKEN PROVIDERS
// ===========================

/// ⏰ Token Remaining Days Provider
final tokenRemainingDaysProvider = Provider<int>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session?.token.remainingDays ?? 0;
});

/// ⏰ Token Expires At Provider
final tokenExpiresAtProvider = Provider<DateTime?>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session?.token.expiresAt;
});

/// ✅ Is Token Valid Provider
final isTokenValidProvider = Provider<bool>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session?.token.isValid ?? false;
});
