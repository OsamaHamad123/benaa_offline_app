import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../theme/app_colors.dart';

/// 🔑 صفحة نسيت كلمة المرور
///
/// تتيح للمستخدم طلب إعادة تعيين كلمة المرور عبر البريد الإلكتروني
/// ملاحظة: الـ Backend غير متوفر حالياً - UI فقط
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    // محاكاة طلب الـ API (البـ Backend غير متوفر)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSubmitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.primary,
          ),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _isSubmitted ? _buildSuccessView() : _buildFormView(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // أيقونة
          _buildIcon(),
          const SizedBox(height: 32),

          // العنوان
          Text(
            'نسيت كلمة المرور؟',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 12),

          // الوصف
          Text(
            'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 32),

          // حقل البريد الإلكتروني
          _buildEmailField(),
          const SizedBox(height: 24),

          // زر الإرسال
          _buildSubmitButton(),
          const SizedBox(height: 16),

          // رابط العودة لتسجيل الدخول
          _buildBackToLoginLink(),

          // ملاحظة أن الخدمة غير متوفرة حالياً
          const SizedBox(height: 32),
          _buildNotAvailableNote(),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // أيقونة النجاح
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 50,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 32),

        // العنوان
        Text(
          'تم إرسال الطلب!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
        ),
        const SizedBox(height: 12),

        // الوصف
        Text(
          'إذا كان البريد الإلكتروني مسجلاً لدينا،\nستتلقى رابطاً لإعادة تعيين كلمة المرور.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 32),

        // زر العودة
        ElevatedButton.icon(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.login_rounded),
          label: const Text('العودة لتسجيل الدخول'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // ملاحظة
        _buildNotAvailableNote(),
      ],
    );
  }

  Widget _buildIcon() {
    return FadeSlideTransition(
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.lock_reset_rounded,
          size: 40,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return ScaleTransitionWidget(
      duration: AppDurations.fast,
      child: TextFormField(
        controller: _emailController,
        enabled: !_isLoading,
        decoration: const InputDecoration(
          labelText: 'البريد الإلكتروني',
          prefixIcon: Icon(Icons.email_outlined),
          hintText: 'أدخل بريدك الإلكتروني المسجل',
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
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.emailAddress,
        onFieldSubmitted: (_) => _handleSubmit(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScaleTransitionWidget(
      duration: AppDurations.fast,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isLoading
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
                  Icon(Icons.send_rounded),
                  SizedBox(width: 8),
                  Text(
                    'إرسال رابط الاسترداد',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBackToLoginLink() {
    return TextButton.icon(
      onPressed: _isLoading ? null : () => context.go('/login'),
      icon: const Icon(Icons.arrow_back_rounded, size: 18),
      label: const Text('العودة لتسجيل الدخول'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildNotAvailableNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'ملاحظة: هذه الخدمة غير متوفرة حالياً.\nتواصل مع المسؤول لإعادة تعيين كلمة المرور.',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
