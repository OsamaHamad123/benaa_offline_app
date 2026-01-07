import 'package:equatable/equatable.dart';
import 'auth_user.dart';
import 'auth_token.dart';

/// 🔐 Auth Session Entity - جلسة المستخدم الكاملة
class AuthSession extends Equatable {
  final AuthUser user;
  final AuthToken token;
  final OfflineConfig offlineConfig;
  final DateTime loginAt;
  final String? deviceId;

  const AuthSession({
    required this.user,
    required this.token,
    required this.offlineConfig,
    required this.loginAt,
    this.deviceId,
  });

  /// ✅ هل الجلسة صالحة؟
  bool get isValid => token.isValid;

  /// ⚠️ هل يحتاج الـ token لتجديد؟
  bool get shouldRefreshToken => token.shouldRefresh;

  /// ⏰ هل انتهت الجلسة؟
  bool get isExpired => token.isExpired;

  /// 📅 الأيام المتبقية
  int get remainingDays => token.remainingDays;

  /// 🔄 تحديث الـ token
  AuthSession updateToken(AuthToken newToken) {
    return AuthSession(
      user: user,
      token: newToken,
      offlineConfig: offlineConfig,
      loginAt: loginAt,
      deviceId: deviceId,
    );
  }

  @override
  List<Object?> get props => [user, token, loginAt, deviceId];
}
