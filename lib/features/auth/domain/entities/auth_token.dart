import 'package:equatable/equatable.dart';

/// 🔐 Auth Token Entity - كيان الـ Token
class AuthToken extends Equatable {
  final String accessToken;
  final String tokenType;
  final DateTime expiresAt;
  final int expiresInDays;
  final int expiresInSeconds;

  const AuthToken({
    required this.accessToken,
    required this.expiresAt, required this.expiresInDays, required this.expiresInSeconds, this.tokenType = 'Bearer',
  });

  /// ⏰ هل انتهت صلاحية الـ token؟
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// ✅ هل الـ token صالح؟
  bool get isValid => !isExpired && accessToken.isNotEmpty;

  /// 📅 الأيام المتبقية
  int get remainingDays {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inDays;
  }

  /// ⏳ الثواني المتبقية
  int get remainingSeconds {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inSeconds;
  }

  /// ⚠️ هل يحتاج الـ token لتجديد؟ (عندما يتبقى ≤ 2 يوم)
  bool get shouldRefresh => remainingDays <= 2 && !isExpired;

  /// 🔑 Bearer token header
  String get bearerToken => '$tokenType $accessToken';

  @override
  List<Object?> get props => [accessToken, expiresAt];
}

/// ⚙️ إعدادات العمل Offline
class OfflineConfig extends Equatable {
  final int maxOfflineDays;
  final bool requireOnlineReauth;
  final bool syncRequiredOnExpiry;

  const OfflineConfig({
    this.maxOfflineDays = 10,
    this.requireOnlineReauth = true,
    this.syncRequiredOnExpiry = true,
  });

  @override
  List<Object?> get props => [maxOfflineDays, requireOnlineReauth, syncRequiredOnExpiry];
}
