import 'dart:async';

import 'package:benaa_offline_app/core/design_system/app_animations.dart';
import 'package:benaa_offline_app/core/error_handling/error_handler.dart';
import 'package:benaa_offline_app/core/monitoring/app_monitoring.dart';
import 'package:benaa_offline_app/core/security/session_manager.dart';
import 'package:benaa_offline_app/core/storage/secure_storage.dart';
import 'package:benaa_offline_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:benaa_offline_app/features/auth/presentation/state/auth_state.dart';
import 'package:benaa_offline_app/features/civil_db_download/presentation/providers/database_download_provider.dart';
import 'package:benaa_offline_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 🔐 صفحة تسجيل الدخول المحدثة
///
/// متكاملة مع:
/// - Auth Providers (Riverpod)
/// - API Authentication
/// - Offline-first support
/// - Token management
class LoginPageV2 extends ConsumerStatefulWidget {
  const LoginPageV2({super.key});

  @override
  ConsumerState<LoginPageV2> createState() => _LoginPageV2State();
}

class _LoginPageV2State extends ConsumerState<LoginPageV2> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isNavigatingAfterAuth = false;
  bool _pendingPostLoginKpi = false;
  bool _showRouteTransition = false;
  late AnimationController _animationController;
  late AnimationController _ambientController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _formSlideAnimation;
  ProviderSubscription<AuthState>? _authSubscription;

  void _logAuthEvent(String event, {Map<String, dynamic>? parameters}) {
    if (!mounted) return;
    ref.read(appMonitoringProvider).logEvent(event, parameters: parameters);
  }

  void _attachAuthListener() {
    _authSubscription?.close();
    _authSubscription = ref.listenManual<AuthState>(authNotifierProvider, (previous, next) {
      if (!mounted) return;

      next.maybeWhen(
        authenticated: (session, isOffline, tokenRefreshed) {
          _navigateAfterAuth();
        },
        error: (message, errorCode, canRetry) {
          GlobalErrorHandler.handleError(
            context,
            AppError(
              type: ErrorType.authentication,
              message: message,
            ),
          );
        },
        sessionExpired: (lastUser, message) {
          if (lastUser != null) {
            EnhancedSnackbar.showWarning(
              context,
              message: message,
            );
          }
        },
        orElse: () {},
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
    _attachAuthListener();

    // التحقق من حالة المصادقة وتحميل البيانات المحفوظة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(appMonitoringProvider).logScreenView('Login');
      unawaited(_loadSavedCredentials());
    });
  }

  /// 📥 تحميل بيانات تسجيل الدخول المحفوظة (Remember Me)
  Future<void> _loadSavedCredentials() async {
    try {
      final secureStorage = SecureStorage();
      final credentials = await secureStorage.getSavedCredentials();

      if (credentials.rememberMe && mounted) {
        setState(() {
          _rememberMe = true;
          if (credentials.email != null) {
            _emailController.text = credentials.email!;
          }
        });
      }
    } catch (e) {
      // تجاهل الأخطاء - البيانات المحفوظة اختيارية
      debugPrint('⚠️ Could not load saved credentials: $e');
    }
  }

  /// 🚀 الانتقال بعد المصادقة - التحقق من database أولاً
  Future<void> _navigateAfterAuth() async {
    if (!mounted || _isNavigatingAfterAuth) return;
    _isNavigatingAfterAuth = true;

    final dbNotifier = ref.read(databaseDownloadProvider.notifier);
    await dbNotifier.checkDatabase();
    if (!mounted) return;

    final dbState = ref.read(databaseDownloadProvider);
    if (!mounted || !context.mounted) return;

    setState(() {
      _showRouteTransition = true;
    });
    await Future.delayed(const Duration(milliseconds: 240));
    if (!mounted || !context.mounted) return;

    if (dbState.canProceed) {
      if (_pendingPostLoginKpi) {
        _logAuthEvent(
          'auth_post_login_destination',
          parameters: {'destination': 'dashboard'},
        );
        _pendingPostLoginKpi = false;
      }
      // قاعدة البيانات موجودة أو تم تخطيها
      context.go('/dashboard');
    } else {
      if (_pendingPostLoginKpi) {
        _logAuthEvent(
          'auth_post_login_destination',
          parameters: {'destination': 'database_download'},
        );
        _pendingPostLoginKpi = false;
      }
      // يجب تنزيل قاعدة البيانات
      context.go('/database-download');
    }
  }

  @override
  void dispose() {
    try {
      ref.read(appMonitoringProvider).logScreenExit('Login');
    } catch (_) {}
    _authSubscription?.close();
    _animationController.dispose();
    _ambientController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    final authNotifier = ref.read(authNotifierProvider.notifier);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final loginStopwatch = Stopwatch()..start();

    _logAuthEvent(
      'auth_login_attempt',
      parameters: {
        'remember_me': _rememberMe,
        'has_prefilled_email': _emailController.text.trim().isNotEmpty,
      },
    );

    final success = await authNotifier.login(
      email: email,
      password: password,
    );

    if (success && mounted) {
      // 💾 حفظ بيانات تسجيل الدخول إذا كان Remember Me مفعلاً
      final secureStorage = SecureStorage();
      if (_rememberMe) {
        await secureStorage.saveLoginCredentials(
          email: email,
        );
      } else {
        await secureStorage.clearSavedCredentials();
      }

      // بدء الجلسة
      await SessionManager().initialize(
        onSessionExpired: () {
          if (mounted && context.mounted) {
            context.go('/login');
          }
        },
      );
      await SessionManager().startNewSession();
      if (!mounted) return;

      // رسالة نجاح
      final user = ref.read(currentUserProvider);
      EnhancedSnackbar.showSuccess(
        context,
        message: 'مرحباً ${user?.name ?? 'بك'}!',
      );

      _logAuthEvent(
        'auth_login_success',
        parameters: {
          'duration_ms': loginStopwatch.elapsedMilliseconds,
          'remember_me': _rememberMe,
        },
      );
      _pendingPostLoginKpi = true;
    } else {
      _logAuthEvent(
        'auth_login_failed',
        parameters: {
          'duration_ms': loginStopwatch.elapsedMilliseconds,
        },
      );
    }

    loginStopwatch.stop();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = ref.watch(isAuthLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white.withValues(alpha: 0.90),
        foregroundColor: AppColors.primary,
        title: const Text('تسجيل الدخول'),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, child) {
                final t = _ambientController.value;
                final primary = Theme.of(context).colorScheme.primary;
                final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primary.withValues(alpha: 0.08),
                        primaryContainer.withValues(alpha: 0.18),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -95 + t * 36,
                        right: -70 + t * 28,
                        child: _buildAmbientBlob(
                          size: 220,
                          color: primary.withValues(alpha: 0.10),
                        ),
                      ),
                      Positioned(
                        bottom: -120 + (1 - t) * 44,
                        left: -60 + t * 18,
                        child: _buildAmbientBlob(
                          size: 260,
                          color: primaryContainer.withValues(alpha: 0.18),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _formSlideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLogo(),
                            const SizedBox(height: 24),
                            _buildTitle(),
                            const SizedBox(height: 28),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.10),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 18,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildPrimaryStatusBanner(authState),
                                  _buildEmailField(isLoading),
                                  const SizedBox(height: 14),
                                  _buildPasswordField(isLoading),
                                  const SizedBox(height: 14),
                                  _buildRememberMe(isLoading),
                                  const SizedBox(height: 20),
                                  _buildLoginButton(isLoading),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (authState is AuthTokenExpiring) _buildTokenExpiringWarning(authState),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_showRouteTransition)
            Container(
              color: AppColors.primary.withValues(alpha: 0.16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                      SizedBox(width: 10),
                      Text('جاري تجهيز الوجهة...'),
                    ],
                  ),
                ),
              ),
            ),
          // Loading Overlay
          if (isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAmbientBlob({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLogo() {
    return FadeSlideTransition(
      child: Hero(
        tag: 'app_logo',
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance,
            size: 50,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return FadeSlideTransition(
      child: Column(
        children: [
          Text(
            'منظومة بناء',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 32,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'نظام إدارة المستفيدين - دخول آمن',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(AuthState authState) {
    final errorMessage = authState.errorMessage;
    if (errorMessage == null) return const SizedBox.shrink();

    return _buildStatusCard(
      icon: Icons.error_outline,
      color: AppColors.error,
      message: errorMessage,
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18),
        onPressed: () {
          ref.read(authNotifierProvider.notifier).clearError();
        },
        color: AppColors.error,
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color color,
    required String message,
    Widget? trailing,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildPrimaryStatusBanner(AuthState authState) {
    return authState.maybeWhen(
      error: (message, _, __) => _buildErrorMessage(authState),
      sessionExpired: (_, __) => _buildSessionExpiredMessage(authState),
      orElse: () {
        if (authState.isOffline) {
          return _buildOfflineIndicator(authState);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSessionExpiredMessage(AuthState authState) {
    return authState.maybeWhen(
      sessionExpired: (lastUser, message) => _buildStatusCard(
        icon: Icons.timer_off,
        color: AppColors.warning,
        message: message,
        subtitle: lastUser != null ? 'آخر مستخدم: ${lastUser.name}' : null,
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildOfflineIndicator(AuthState authState) {
    if (!authState.isOffline) return const SizedBox.shrink();

    return _buildStatusCard(
      icon: Icons.wifi_off,
      color: Colors.grey,
      message: 'لا يوجد اتصال بالإنترنت',
    );
  }

  Widget _buildEmailField(bool isLoading) {
    return ScaleTransitionWidget(
      duration: AppDurations.fast,
      child: TextFormField(
        controller: _emailController,
        enabled: !isLoading,
        decoration: const InputDecoration(
          labelText: 'البريد الإلكتروني',
          prefixIcon: Icon(Icons.email_outlined),
          hintText: 'أدخل البريد الإلكتروني',
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال البريد الإلكتروني';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'الرجاء إدخال بريد إلكتروني صحيح';
          }
          return null;
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget _buildPasswordField(bool isLoading) {
    return ScaleTransitionWidget(
      duration: AppDurations.fast,
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        enabled: !isLoading,
        decoration: InputDecoration(
          labelText: 'كلمة المرور',
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          hintText: 'أدخل كلمة المرور',
          filled: true,
          fillColor: Colors.white,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال كلمة المرور';
          }
          if (value.length < 6) {
            return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
          }
          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _handleLogin(),
      ),
    );
  }

  Widget _buildRememberMe(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: isLoading ? null : (v) => setState(() => _rememberMe = v ?? true),
              activeColor: AppColors.primary,
            ),
            GestureDetector(
              onTap: isLoading ? null : () => setState(() => _rememberMe = !_rememberMe),
              child: const Text('تذكرني'),
            ),
            const Spacer(),
          ],
        ),
        if (_rememberMe)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            child: Text(
              'سيتم حفظ البريد الإلكتروني فقط على هذا الجهاز',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return ScaleTransitionWidget(
      duration: AppDurations.fast,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login_rounded),
                  SizedBox(width: 8),
                  Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTokenExpiringWarning(AuthTokenExpiring state) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'صلاحية الجلسة ستنتهي خلال ${state.remainingDays} يوم',
              style: const TextStyle(color: AppColors.info, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(authNotifierProvider.notifier).refreshToken();
            },
            child: const Text('تجديد'),
          ),
        ],
      ),
    );
  }
}

/// 🔄 Loading Overlay Widget
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري تسجيل الدخول...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
