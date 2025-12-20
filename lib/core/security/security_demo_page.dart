import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/biometric_auth_widget.dart';
import '../widgets/password_strength_widget.dart';
import 'session_manager.dart';
import 'password_validator.dart';

/// 🔒 Security Demo Page
///
/// صفحة توضيحية لميزات الأمان

class SecurityDemoPage extends ConsumerStatefulWidget {
  const SecurityDemoPage({super.key});

  @override
  ConsumerState<SecurityDemoPage> createState() => _SecurityDemoPageState();
}

class _SecurityDemoPageState extends ConsumerState<SecurityDemoPage> {
  final _passwordController = TextEditingController();
  final _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    await _sessionManager.initialize(
      onSessionExpired: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('انتهت الجلسة بسبب عدم النشاط'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _sessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ميزات الأمان'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showSecurityInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Password Strength Section
            _buildSection(
              title: '🔐 قوة كلمة المرور',
              child: Column(
                children: [
                  SecurePasswordField(
                    controller: _passwordController,
                    labelText: 'أدخل كلمة مرور',
                    hintText: 'اختبر قوة كلمة المرور',
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: _generatePassword,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('توليد كلمة مرور قوية'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Biometric Authentication Section
            _buildSection(
              title: '🔒 المصادقة البيومترية',
              child: Column(
                children: [
                  const BiometricSettingsTile(),
                  SizedBox(height: 16.h),
                  BiometricAuthButton(
                    onSuccess: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('نجحت المصادقة!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Session Management Section
            _buildSection(
              title: '⏱️ إدارة الجلسة',
              child: Column(
                children: [
                  _buildSessionInfo(),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _updateActivity,
                          icon: const Icon(Icons.touch_app),
                          label: const Text('تحديث النشاط'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _expireSession,
                          icon: const Icon(Icons.logout),
                          label: const Text('إنهاء الجلسة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildSessionTimeoutSetting(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo() {
    final stats = _sessionManager.getStats();

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: stats.isActive ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: stats.isActive ? Colors.green : Colors.orange,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                stats.isActive ? Icons.check_circle : Icons.warning,
                color: stats.isActive ? Colors.green : Colors.orange,
              ),
              SizedBox(width: 8.w),
              Text(
                stats.isActive ? 'الجلسة نشطة' : 'الجلسة غير نشطة',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (stats.isActive) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الوقت المتبقي:'),
                Text(
                  stats.remainingTimeFormatted,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('مهلة الجلسة:'),
              Text(
                '${stats.timeoutMinutes} دقيقة',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTimeoutSetting() {
    return DropdownButtonFormField<int>(
      value: _sessionManager.sessionTimeoutMinutes,
      decoration: InputDecoration(
        labelText: 'مهلة الجلسة',
        prefixIcon: const Icon(Icons.timer),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      items: [5, 10, 15, 30, 60].map((minutes) {
        return DropdownMenuItem(
          value: minutes,
          child: Text('$minutes دقيقة'),
        );
      }).toList(),
      onChanged: (value) async {
        if (value != null) {
          await _sessionManager.setSessionTimeout(value);
          setState(() {});
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم تعيين المهلة إلى $value دقيقة')),
            );
          }
        }
      },
    );
  }

  void _generatePassword() {
    final password = PasswordValidator.generateStrongPassword();
    _passwordController.text = password;
    setState(() {});
  }

  Future<void> _updateActivity() async {
    await _sessionManager.updateActivity();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث النشاط')),
    );
  }

  void _expireSession() {
    _sessionManager.expireSession();
    setState(() {});
  }

  void _showSecurityInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ميزات الأمان'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoItem(
                '🔐 كلمة مرور قوية',
                'تحقق من قوة كلمة المرور وتوليد كلمات مرور آمنة',
              ),
              _buildInfoItem(
                '🔒 المصادقة البيومترية',
                'استخدم بصمة الإصبع أو Face ID لتسجيل الدخول',
              ),
              _buildInfoItem(
                '⏱️ إدارة الجلسة',
                'انتهاء تلقائي للجلسة بعد فترة من عدم النشاط',
              ),
              _buildInfoItem(
                '🔐 تشفير قاعدة البيانات',
                'SQLCipher لتشفير البيانات الحساسة',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
