import 'package:benaa_offline_app/core/design_system/app_animations.dart';
import 'package:benaa_offline_app/core/error_handling/error_handler.dart';
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

class _LoginPageV2State extends ConsumerState<LoginPageV2> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // التحقق من حالة المصادقة وتحميل البيانات المحفوظة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialAuthState();
      _loadSavedCredentials();
    });
  }

  Future<void> _checkInitialAuthState() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.checkAuthStatus();
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
          if (credentials.password != null) {
            _passwordController.text = credentials.password!;
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
    await ref.read(databaseDownloadProvider.notifier).checkDatabase();
    final dbState = ref.read(databaseDownloadProvider);

    if (dbState.canProceed) {
      // قاعدة البيانات موجودة أو تم تخطيها
      if (mounted && context.mounted) {
        context.go('/dashboard');
      }
    } else {
      // يجب تنزيل قاعدة البيانات
      if (mounted && context.mounted) {
        context.go('/database-download');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          password: password,
        );
      } else {
        await secureStorage.clearSavedCredentials();
      }

      // بدء الجلسة
      await SessionManager().initialize(
        onSessionExpired: () => context.go('/login'),
      );
      await SessionManager().startNewSession();

      // رسالة نجاح
      final user = ref.read(currentUserProvider);
      EnhancedSnackbar.showSuccess(
        context,
        message: 'مرحباً ${user?.name ?? 'بك'}!',
      );

      await Future.delayed(const Duration(milliseconds: 500));

      // التحقق من قاعدة البيانات
      if (mounted) {
        await ref.read(databaseDownloadProvider.notifier).checkDatabase();
        final dbState = ref.read(databaseDownloadProvider);

        // 🆕 استخدام canProceed بدلاً من isAvailable فقط
        if (!dbState.canProceed) {
          // قاعدة البيانات غير موجودة ولم يتم تخطيها - الذهاب لصفحة التنزيل
          if (mounted && context.mounted) {
            context.go('/database-download');
          }
        } else {
          // قاعدة البيانات موجودة أو تم تخطيها - الانتقال للوحة التحكم
          if (mounted && context.mounted) {
            context.go('/dashboard');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = ref.watch(isAuthLoadingProvider);

    // الاستماع لتغييرات حالة المصادقة
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        authenticated: (session, isOffline, tokenRefreshed) {
          // تم المصادقة - التحقق من حالة قاعدة البيانات أولاً
          if (mounted) {
            _navigateAfterAuth();
          }
        },
        error: (message, errorCode, canRetry) {
          // عرض رسالة الخطأ
          if (mounted) {
            GlobalErrorHandler.handleError(
              context,
              AppError(
                type: ErrorType.authentication,
                message: message,
              ),
            );
          }
        },
        sessionExpired: (lastUser, message) {
          // عرض رسالة انتهاء الجلسة
          if (mounted && lastUser != null) {
            EnhancedSnackbar.showWarning(
              context,
              message: message,
            );
          }
        },
        orElse: () {},
      );
    });

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary.withOpacity(0.05), Colors.white],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo
                            _buildLogo(),
                            const SizedBox(height: 32),

                            // App Title
                            _buildTitle(),
                            const SizedBox(height: 48),

                            // Error Message
                            _buildErrorMessage(authState),

                            // Session Expired Message
                            _buildSessionExpiredMessage(authState),

                            // Offline Indicator
                            _buildOfflineIndicator(authState),

                            // Email Field
                            _buildEmailField(isLoading),
                            const SizedBox(height: 16),

                            // Password Field
                            _buildPasswordField(isLoading),
                            const SizedBox(height: 16),

                            // Remember Me
                            _buildRememberMe(isLoading),
                            const SizedBox(height: 24),

                            // Login Button
                            _buildLoginButton(isLoading),
                            const SizedBox(height: 24),

                            // Token Status (for debugging - remove in production)
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
          // Loading Overlay
          if (isLoading) const LoadingOverlay(),
        ],
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
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.apartment_rounded,
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
            'نظام إدارة المستفيدين',
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

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).clearError();
            },
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionExpiredMessage(AuthState authState) {
    return authState.maybeWhen(
      sessionExpired: (lastUser, message) => Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer_off, color: AppColors.warning, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: AppColors.warning, fontSize: 13),
                  ),
                ),
              ],
            ),
            if (lastUser != null) ...[
              const SizedBox(height: 8),
              Text(
                'آخر مستخدم: ${lastUser.name}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildOfflineIndicator(AuthState authState) {
    if (!authState.isOffline) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.grey, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'لا يوجد اتصال بالإنترنت',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
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
    return Row(
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
        TextButton(
          onPressed: isLoading ? null : () => context.go('/forgot-password'),
          child: const Text(
            'نسيت كلمة المرور؟',
            style: TextStyle(color: AppColors.primary),
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
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
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
      color: Colors.black.withOpacity(0.3),
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
