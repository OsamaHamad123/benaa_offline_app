import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/password_hash_service.dart';
import '../../core/storage/secure_store.dart';
import '../../data/services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../core/design_system/app_animations.dart';
import '../../core/error_handling/error_handler.dart';
import '../../core/widgets/loading_state.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  String? _errorMessage;
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
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final username = await SecureStore.getUsername();
    if (username != null) {
      _usernameController.text = username;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Clear previous error
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      // 1) محاولة تسجيل الدخول عبر السيرفر
      final authService = AuthService();
      final result = await authService.login(
        email: username,
        password: password,
      );

      if (result.success) {
        // حفظ ملخص كلمة المرور للسماح بالدخول لاحقاً دون اتصال
        await SecureStore.saveOfflineLoginHash(
          username,
          PasswordHashService.hashPassword(password),
        );
      } else if (result.isNetworkError) {
        // 2) لا يوجد اتصال: تحقق محلي من ملخص كلمة المرور
        // المخزن بعد آخر دخول ناجح عبر السيرفر
        final storedHash = await SecureStore.getOfflineLoginHash(username);
        final offlineOk = storedHash != null &&
            PasswordHashService.verifyPassword(password, storedHash);

        if (!offlineOk) {
          throw Exception(
            storedHash == null
                ? 'لا يوجد اتصال بالإنترنت، ويتطلب أول تسجيل دخول اتصالاً بالسيرفر'
                : 'بيانات الدخول غير صحيحة (credentials)',
          );
        }
      } else {
        // السيرفر رفض البيانات
        throw Exception(result.error ?? 'بيانات الدخول غير صحيحة (credentials)');
      }

      // إنشاء الجلسة المحلية (يعتمد عليها الـ router للدخول إلى التطبيق)
      await SecureStore.saveCredentials(username, rememberUsername: _rememberMe);

      if (mounted) {
        // Success feedback
        EnhancedSnackbar.showSuccess(
          context,
          message: 'مرحباً ${_usernameController.text}!',
        );

        // Navigate to dashboard
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = _getErrorMessage(e.toString());
        GlobalErrorHandler.handleError(
          context,
          AppError(
            type: ErrorType.authentication,
            message: errorMsg,
            originalError: e,
          ),
        );
        setState(() => _errorMessage = errorMsg);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    final message = error.replaceFirst('Exception: ', '');
    if (message.contains('credentials')) {
      return 'اسم المستخدم أو كلمة المرور غير صحيحة';
    }
    if (message.contains('network')) {
      return 'لا يوجد اتصال بالإنترنت';
    }
    if (message.contains('timeout')) {
      return 'انتهت مهلة الاتصال';
    }
    // إن كانت الرسالة عربية مفهومة اعرضها كما هي
    if (RegExp(r'[؀-ۿ]').hasMatch(message)) {
      return message;
    }
    return 'حدث خطأ أثناء تسجيل الدخول';
  }

  @override
  Widget build(BuildContext context) {
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
                            // Logo with animation
                            FadeSlideTransition(
                              duration: AppDurations.normal,
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
                            ),
                            const SizedBox(height: 32),

                            // App Title
                            FadeSlideTransition(
                              duration: AppDurations.normal,
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
                            ),
                            const SizedBox(height: 48),

                            // Error Message Card
                            if (_errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.error.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Username Field
                            ScaleTransitionWidget(
                              duration: AppDurations.fast,
                              child: TextFormField(
                                controller: _usernameController,
                                enabled: !_isLoading,
                                decoration: InputDecoration(
                                  labelText: 'البريد الإلكتروني',
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                  ),
                                  hintText: 'أدخل البريد الإلكتروني',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال البريد الإلكتروني';
                                  }
                                  if (value.length < 3) {
                                    return 'البريد الإلكتروني يجب أن يكون 3 أحرف على الأقل';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            ScaleTransitionWidget(
                              duration: AppDurations.fast,
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                enabled: !_isLoading,
                                decoration: InputDecoration(
                                  labelText: 'كلمة المرور',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  hintText: 'أدخل كلمة المرور',
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال كلمة المرور';
                                  }
                                  if (value.length < 4) {
                                    return 'كلمة المرور يجب أن تكون 4 أحرف على الأقل';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleLogin(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Remember Me Checkbox
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: _isLoading
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _rememberMe = value ?? true;
                                            });
                                          },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'تذكرني',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          // TODO: Implement forgot password
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'سيتم إضافة هذه الميزة قريباً',
                                              ),
                                            ),
                                          );
                                        },
                                  child: const Text('نسيت كلمة المرور؟'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            ScaleTransitionWidget(
                              duration: AppDurations.fast,
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.login_rounded),
                                      const SizedBox(width: 8),
                                      Text(
                                        'تسجيل الدخول',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'أو',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Biometric Login Button (if available)
                            OutlinedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      // TODO: Implement biometric authentication
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'سيتم إضافة المصادقة البيومترية قريباً',
                                          ),
                                        ),
                                      );
                                    },
                              icon: const Icon(Icons.fingerprint),
                              label: const Text('تسجيل الدخول بالبصمة'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Version Info
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'الإصدار 1.0.0',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '© 2025 منظومة بناء',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const LoadingState(message: 'جاري تسجيل الدخول...'),
            ),
        ],
      ),
    );
  }
}
