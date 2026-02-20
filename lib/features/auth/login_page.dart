import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage/secure_store.dart';
import '../../core/services/password_hash_service.dart';
import '../../theme/app_colors.dart';
import '../../core/design_system/app_animations.dart';
import '../../core/error_handling/error_handler.dart';
import '../../core/widgets/biometric_auth_widget.dart';
import '../../core/security/session_manager.dart';
import '../../core/widgets/micro_interactions.dart';

/// 💎 Premium Glassmorphic Login Page
/// Designed to provide a "WOW" experience with high-end aesthetics
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  String? _errorMessage;

  // Animations
  late AnimationController _bgAnimationController;
  late AnimationController _contentAnimationController;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _contentAnimationController.forward();
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
    _bgAnimationController.dispose();
    _contentAnimationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
        final hashedPassword = PasswordHashService.hashPassword(_passwordController.text);

        if (_rememberMe) {
          await SecureStore.saveCredentials(_usernameController.text, hashedPassword);
        }

        if (mounted) {
          await SessionManager().initialize(onSessionExpired: () => context.go('/login'));
          await SessionManager().startNewSession();

          EnhancedSnackbar.showSuccess(context, message: 'مرحباً ${_usernameController.text}!');

          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) context.go('/dashboard');
        }
      } else {
        throw Exception('بيانات الدخول غير صحيحة');
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = _getErrorMessage(e.toString());
        GlobalErrorHandler.handleError(
            context, AppError(type: ErrorType.authentication, message: errorMsg, originalError: e));
        setState(() => _errorMessage = errorMsg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('network')) return 'لا يوجد اتصال بالإنترنت';
    if (error.contains('timeout')) return 'انتهت مهلة الاتصال';
    if (error.contains('credentials')) return 'اسم المستخدم أو كلمة المرور غير صحيحة';
    return 'حدث خطأ أثناء تسجيل الدخول';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Mesh Gradient Background
          _buildAnimatedBackground(),

          // 2. Glassmorphic Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    _buildLogo(),
                    SizedBox(height: 40.h),
                    _buildGlassCard(),
                    SizedBox(height: 30.h),
                    _buildFooter(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),

          // 3. Ultra Premium Loading Overlay
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgAnimationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.15),
                AppColors.secondary.withOpacity(0.12),
                AppColors.primaryDark.withOpacity(0.08),
                Colors.white,
              ],
              stops: [
                0.1,
                0.4 + (0.1 * _bgAnimationController.value),
                0.7 - (0.1 * _bgAnimationController.value),
                1.0,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -100.h + (50 * _bgAnimationController.value),
                right: -50.w + (30 * _bgAnimationController.value),
                child: _buildBlurCircle(300, AppColors.primary.withOpacity(0.2)),
              ),
              Positioned(
                bottom: -150.h + (80 * _bgAnimationController.value),
                left: -100.w + (40 * _bgAnimationController.value),
                child: _buildBlurCircle(400, AppColors.secondary.withOpacity(0.15)),
              ),
              Positioned(
                top: 200.h + (100 * (1 - _bgAnimationController.value)),
                left: 50.w,
                child: _buildBlurCircle(150, AppColors.accent.withOpacity(0.1)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildLogo() {
    return FadeSlideTransition(
      duration: AppDurations.slow,
      slideOffset: const Offset(0, 0.3),
      child: Hero(
        tag: 'app_logo',
        child: Column(
          children: [
            Container(
              height: 120.r,
              width: 120.r,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.house_rounded, size: 60.r, color: Colors.white),
                  // Shine effect
                  Positioned(
                    top: 10,
                    left: 20,
                    child: Container(
                      width: 40.r,
                      height: 10.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ).rotate(angle: -45),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'منظومة بناء',
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 4), blurRadius: 10),
                ],
              ),
            ),
            Text(
              'نظام إدارة المستفيدين الذكي',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard() {
    return FadeSlideTransition(
      duration: AppDurations.slow,
      delay: const Duration(milliseconds: 200),
      slideOffset: const Offset(0, 0.1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(32.r),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20.r),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: AppColors.error, fontSize: 13.sp, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 32.h),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'اسم المستخدم',
                    icon: Icons.alternate_email_rounded,
                    hint: 'أدخل اسم المستخدم أو الإيميل',
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    icon: Icons.lock_outline_rounded,
                    hint: 'أدخل كلمة المرور الخاصة بك',
                    isPassword: true,
                  ),
                  SizedBox(height: 16.h),
                  _buildOptionsRow(),
                  SizedBox(height: 32.h),
                  _buildLoginButton(),
                  SizedBox(height: 24.h),
                  _buildBiometricOption(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 4.w, bottom: 8.h),
          child: Text(
            label,
            style:
                TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary.withOpacity(0.8)),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    color: Colors.grey,
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          ),
          validator: (v) => v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
        ),
      ],
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24.r,
              width: 24.r,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (v) => setState(() => _rememberMe = v ?? true),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                activeColor: AppColors.primary,
              ),
            ),
            SizedBox(width: 8.w),
            Text('تذكرني', style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary)),
          ],
        ),
        TextButton(
          onPressed: () => context.push('/forgot-password'),
          child: Text(
            'نسيت كلمة المرور؟',
            style: TextStyle(fontSize: 14.sp, color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return MicroInteractions.bounceButton(
      onTap: _handleLogin,
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'تسجيل الدخول',
                style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricOption() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text('أو عبر البصمة', style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp)),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        SizedBox(height: 20.h),
        BiometricAuthButton(
          onSuccess: () async {
            await SessionManager().initialize(onSessionExpired: () => context.go('/login'));
            await SessionManager().startNewSession();
            if (mounted) context.go('/dashboard');
          },
          onFailure: () => EnhancedSnackbar.showError(context, message: 'فشلت المصادقة البيومترية'),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return FadeSlideTransition(
      duration: AppDurations.slow,
      delay: const Duration(milliseconds: 600),
      child: Column(
        children: [
          Text(
            'نظام بناء - الإصدار 1.5.0 Premium',
            style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.6), fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            '© 2026 جميع الحقوق محفوظة لمنظومة بناء',
            style: TextStyle(color: AppColors.textSecondary.withOpacity(0.4), fontSize: 10.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: EdgeInsets.all(40.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    SizedBox(height: 24.h),
                    const Text(
                      'جاري التحقق من الهوية...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension WidgetExt on Widget {
  Widget rotate({double angle = 0}) => Transform.rotate(angle: angle * 3.14159 / 180, child: this);
}
