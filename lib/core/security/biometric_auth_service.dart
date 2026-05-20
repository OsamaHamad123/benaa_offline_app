import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../storage/secure_storage.dart';

/// 🔒 Biometric Authentication Service
///
/// خدمة المصادقة البيومترية (بصمة الإصبع / Face ID)

class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final SecureStorage _secureStorage = SecureStorage();

  /// التحقق من توفر المصادقة البيومترية
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  /// التحقق من توفر المصادقة على الجهاز
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// الحصول على أنواع المصادقة المتاحة
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  /// إجراء المصادقة البيومترية
  Future<bool> authenticate({
    String localizedReason = 'يرجى المصادقة للمتابعة',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final canAuthenticate = await canCheckBiometrics();
      if (!canAuthenticate) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print('Error during authentication: ${e.message}');
      return false;
    }
  }

  /// التحقق من تمكين المصادقة البيومترية
  Future<bool> isBiometricEnabled() async {
    return _secureStorage.getBiometricEnabledFlag();
  }

  /// تمكين/تعطيل المصادقة البيومترية
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.setBiometricEnabledFlag(enabled);
  }

  /// الحصول على نوع المصادقة المتاح
  Future<String> getBiometricTypeLabel() async {
    final types = await getAvailableBiometrics();

    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'بصمة الإصبع';
    } else if (types.contains(BiometricType.iris)) {
      return 'بصمة العين';
    } else if (types.contains(BiometricType.strong) || types.contains(BiometricType.weak)) {
      return 'المصادقة البيومترية';
    }

    return 'غير متوفر';
  }

  /// فحص شامل للإمكانيات
  Future<BiometricCapabilities> checkCapabilities() async {
    final supported = await isDeviceSupported();
    final canCheck = await canCheckBiometrics();
    final types = await getAvailableBiometrics();
    final enabled = await isBiometricEnabled();

    return BiometricCapabilities(
      isSupported: supported,
      canCheckBiometrics: canCheck,
      availableTypes: types,
      isEnabled: enabled,
    );
  }
}

/// قدرات المصادقة البيومترية
class BiometricCapabilities {
  final bool isSupported;
  final bool canCheckBiometrics;
  final List<BiometricType> availableTypes;
  final bool isEnabled;

  BiometricCapabilities({
    required this.isSupported,
    required this.canCheckBiometrics,
    required this.availableTypes,
    required this.isEnabled,
  });

  bool get hasFingerprint => availableTypes.contains(BiometricType.fingerprint);
  bool get hasFaceId => availableTypes.contains(BiometricType.face);
  bool get hasIris => availableTypes.contains(BiometricType.iris);
  bool get hasAnyBiometric => availableTypes.isNotEmpty;

  String get primaryType {
    if (hasFaceId) return 'Face ID';
    if (hasFingerprint) return 'بصمة الإصبع';
    if (hasIris) return 'بصمة العين';
    return 'غير متوفر';
  }
}
