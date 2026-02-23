import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../security/biometric_auth_service.dart';

/// 🔒 Biometric Auth Button Widget
///
/// زر المصادقة البيومترية

class BiometricAuthButton extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback? onFailure;
  final String? customMessage;
  final bool showLabel;

  const BiometricAuthButton({
    required this.onSuccess, super.key,
    this.onFailure,
    this.customMessage,
    this.showLabel = true,
  });

  @override
  ConsumerState<BiometricAuthButton> createState() =>
      _BiometricAuthButtonState();
}

class _BiometricAuthButtonState extends ConsumerState<BiometricAuthButton> {
  final _biometricService = BiometricAuthService();
  bool _isAuthenticating = false;
  String _biometricType = 'المصادقة البيومترية';

  @override
  void initState() {
    super.initState();
    _loadBiometricType();
  }

  Future<void> _loadBiometricType() async {
    final type = await _biometricService.getBiometricTypeLabel();
    if (mounted) {
      setState(() => _biometricType = type);
    }
  }

  Future<void> _authenticate() async {
    setState(() => _isAuthenticating = true);

    final result = await _biometricService.authenticate(
      localizedReason: widget.customMessage ?? 'يرجى المصادقة للمتابعة',
    );

    setState(() => _isAuthenticating = false);

    if (result) {
      widget.onSuccess();
    } else {
      widget.onFailure?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشلت المصادقة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BiometricCapabilities>(
      future: _biometricService.checkCapabilities(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.hasAnyBiometric) {
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: _isAuthenticating ? null : _authenticate,
              icon: _isAuthenticating
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(_getBiometricIcon(snapshot.data!), size: 24.sp),
              label: Text(
                _isAuthenticating ? 'جارٍ المصادقة...' : 'تسجيل الدخول',
                style: TextStyle(fontSize: 16.sp),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            if (widget.showLabel) ...[
              SizedBox(height: 8.h),
              Text(
                'باستخدام $_biometricType',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  IconData _getBiometricIcon(BiometricCapabilities capabilities) {
    if (capabilities.hasFaceId) {
      return Icons.face;
    } else if (capabilities.hasFingerprint) {
      return Icons.fingerprint;
    }
    return Icons.security;
  }
}

/// 🔓 Biometric Settings Tile
class BiometricSettingsTile extends ConsumerStatefulWidget {
  const BiometricSettingsTile({super.key});

  @override
  ConsumerState<BiometricSettingsTile> createState() =>
      _BiometricSettingsTileState();
}

class _BiometricSettingsTileState extends ConsumerState<BiometricSettingsTile> {
  final _biometricService = BiometricAuthService();
  bool _isEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _biometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _isEnabled = enabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // تتطلب المصادقة قبل التمكين
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'يرجى المصادقة لتمكين المصادقة البيومترية',
      );

      if (!authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشلت المصادقة'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    await _biometricService.setBiometricEnabled(value);
    setState(() => _isEnabled = value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'تم تمكين المصادقة البيومترية'
                : 'تم تعطيل المصادقة البيومترية',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BiometricCapabilities>(
      future: _biometricService.checkCapabilities(),
      builder: (context, snapshot) {
        if (_isLoading || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final capabilities = snapshot.data!;

        if (!capabilities.hasAnyBiometric) {
          return const ListTile(
            leading: Icon(Icons.fingerprint, color: Colors.grey),
            title: Text('المصادقة البيومترية'),
            subtitle: Text('غير متوفرة على هذا الجهاز'),
            enabled: false,
          );
        }

        return SwitchListTile(
          secondary: Icon(
            capabilities.hasFaceId ? Icons.face : Icons.fingerprint,
            color: _isEnabled ? Theme.of(context).primaryColor : Colors.grey,
          ),
          title: Text('المصادقة البيومترية (${capabilities.primaryType})'),
          subtitle: Text(
            _isEnabled
                ? 'مفعّلة - سيُطلب منك المصادقة عند تسجيل الدخول'
                : 'معطّلة - استخدم كلمة المرور فقط',
          ),
          value: _isEnabled,
          onChanged: _toggleBiometric,
        );
      },
    );
  }
}
