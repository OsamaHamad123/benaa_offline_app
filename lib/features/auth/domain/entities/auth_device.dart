import 'package:equatable/equatable.dart';

/// 📱 Auth Device Entity - جهاز نشط مرتبط بالمستخدم
class AuthDevice extends Equatable {
  final String deviceId;
  final String? deviceName;
  final String? devicePlatform;
  final DateTime? lastLoginAt;
  final DateTime? expiresAt;
  final String? ipAddress;

  const AuthDevice({
    required this.deviceId,
    this.deviceName,
    this.devicePlatform,
    this.lastLoginAt,
    this.expiresAt,
    this.ipAddress,
  });

  @override
  List<Object?> get props => [
        deviceId,
        deviceName,
        devicePlatform,
        lastLoginAt,
        expiresAt,
        ipAddress,
      ];
}
