import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/unified_logger.dart';
import '../domain/repositories/auth_repository.dart';
import '../presentation/providers/auth_providers.dart';
import '../presentation/state/auth_notifier.dart';

/// 🔄 Token Manager - إدارة تجديد الـ Token تلقائياً
///
/// مسؤول عن:
/// - مراقبة صلاحية الـ Token
/// - التجديد التلقائي قبل الانتهاء
/// - التعامل مع تغييرات الاتصال
class TokenManager {
  final AuthRepository _authRepository;
  final AuthNotifier _authNotifier;
  final Connectivity _connectivity;

  Timer? _refreshTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isInitialized = false;

  // إعدادات التجديد
  static const int _refreshBeforeDays = 2; // تجديد قبل يومين من الانتهاء
  static const int _checkIntervalHours = 6; // فحص كل 6 ساعات
  static const int _retryDelayMinutes = 30; // إعادة المحاولة بعد 30 دقيقة

  TokenManager({
    required AuthRepository authRepository,
    required AuthNotifier authNotifier,
    Connectivity? connectivity,
  })  : _authRepository = authRepository,
        _authNotifier = authNotifier,
        _connectivity = connectivity ?? Connectivity();

  /// 🚀 بدء مراقبة الـ Token
  Future<void> initialize() async {
    if (_isInitialized) return;

    UnifiedLogger.info('🔄 TokenManager: Initializing...');

    // بدء مراقبة الاتصال
    _startConnectivityMonitoring();

    // بدء فحص الـ Token الدوري
    _startPeriodicCheck();

    // فحص أولي
    await _checkAndRefreshIfNeeded();

    _isInitialized = true;
    UnifiedLogger.success('✅ TokenManager: Initialized');
  }

  /// 🛑 إيقاف المراقبة
  void dispose() {
    _refreshTimer?.cancel();
    _connectivitySubscription?.cancel();
    _isInitialized = false;
    UnifiedLogger.info('🔄 TokenManager: Disposed');
  }

  // ===========================
  // 🔄 PERIODIC CHECK
  // ===========================

  /// بدء الفحص الدوري
  void _startPeriodicCheck() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(
      Duration(hours: _checkIntervalHours),
      (_) => _checkAndRefreshIfNeeded(),
    );
  }

  /// فحص وتجديد إذا لزم الأمر
  Future<void> _checkAndRefreshIfNeeded() async {
    try {
      final currentState = _authNotifier.currentState;
      final session = currentState.session;
      if (session == null) return;

      final remainingDays = session.token.remainingDays;

      UnifiedLogger.info('🔄 Token check: $remainingDays days remaining');

      if (remainingDays <= _refreshBeforeDays && remainingDays > 0) {
        UnifiedLogger.info('🔄 Token needs refresh - attempting...');

        final success = await _authNotifier.refreshToken();

        if (!success) {
          // جدولة إعادة المحاولة
          _scheduleRetry();
        }
      }
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Token check failed', error: e, stackTrace: stackTrace);
      _scheduleRetry();
    }
  }

  /// جدولة إعادة المحاولة
  void _scheduleRetry() {
    Future.delayed(Duration(minutes: _retryDelayMinutes), () {
      _checkAndRefreshIfNeeded();
    });
  }

  // ===========================
  // 🌐 CONNECTIVITY MONITORING
  // ===========================

  /// بدء مراقبة الاتصال
  void _startConnectivityMonitoring() {
    _connectivitySubscription?.cancel();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        final isOnline = results.any((r) => r != ConnectivityResult.none);

        if (isOnline) {
          UnifiedLogger.info('🌐 Connection restored - checking token...');
          _checkAndRefreshIfNeeded();
        }
      },
    );
  }

  // ===========================
  // 🛠️ UTILITIES
  // ===========================

  /// تجديد الـ Token يدوياً
  Future<bool> forceRefresh() async {
    UnifiedLogger.info('🔄 Force refresh requested');
    return await _authNotifier.refreshToken();
  }

  /// الحصول على معلومات الـ Token الحالي
  TokenInfo? getTokenInfo() {
    final currentState = _authNotifier.currentState;
    final session = currentState.session;
    if (session == null) return null;

    return TokenInfo(
      expiresAt: session.token.expiresAt,
      remainingDays: session.token.remainingDays,
      remainingSeconds: session.token.remainingSeconds,
      isValid: session.token.isValid,
      shouldRefresh: session.token.shouldRefresh,
    );
  }
}

/// 📊 معلومات الـ Token
class TokenInfo {
  final DateTime expiresAt;
  final int remainingDays;
  final int remainingSeconds;
  final bool isValid;
  final bool shouldRefresh;

  TokenInfo({
    required this.expiresAt,
    required this.remainingDays,
    required this.remainingSeconds,
    required this.isValid,
    required this.shouldRefresh,
  });

  @override
  String toString() {
    return 'TokenInfo(expiresAt: $expiresAt, remainingDays: $remainingDays, isValid: $isValid, shouldRefresh: $shouldRefresh)';
  }
}

// ===========================
// 📦 PROVIDER
// ===========================

/// 🔄 Token Manager Provider
final tokenManagerProvider = Provider<TokenManager>((ref) {
  final manager = TokenManager(
    authRepository: ref.watch(authRepositoryProvider),
    authNotifier: ref.watch(authNotifierProvider.notifier),
  );

  // تهيئة عند الإنشاء
  manager.initialize();

  // التنظيف عند الإلغاء
  ref.onDispose(() => manager.dispose());

  return manager;
});
