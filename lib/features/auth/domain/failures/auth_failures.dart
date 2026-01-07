import '../../../../core/error_handling/result.dart';

/// 🔐 Auth Failures - أنواع الأخطاء الخاصة بالمصادقة
///
/// تمديد للـ AuthFailure الموجود في core مع أنواع أكثر تحديداً

/// ❌ فشل تسجيل الدخول - بيانات غير صحيحة
class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([
    super.message = 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
  ]);
}

/// 🔒 الحساب معطل
class AccountDisabledFailure extends AuthFailure {
  const AccountDisabledFailure([
    super.message = 'الحساب معطل. يرجى التواصل مع الإدارة',
  ]);
}

/// ⏰ Token منتهي الصلاحية
class TokenExpiredFailure extends AuthFailure {
  const TokenExpiredFailure([
    super.message = 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى',
  ]);
}

/// 🔑 Token غير صالح
class InvalidTokenFailure extends AuthFailure {
  const InvalidTokenFailure([
    super.message = 'رمز الجلسة غير صالح',
  ]);
}

/// 🔄 فشل تجديد الـ Token
class TokenRefreshFailure extends AuthFailure {
  const TokenRefreshFailure([
    super.message = 'فشل في تجديد الجلسة. يرجى تسجيل الدخول مرة أخرى',
  ]);
}

/// 📱 الجهاز غير مسجل
class DeviceNotRegisteredFailure extends AuthFailure {
  const DeviceNotRegisteredFailure([
    super.message = 'الجهاز غير مسجل. يرجى تسجيل الدخول',
  ]);
}

/// 🌐 فشل الاتصال بالخادم
class ServerConnectionFailure extends AuthFailure {
  final int? statusCode;

  const ServerConnectionFailure([
    super.message = 'فشل الاتصال بالخادم',
    this.statusCode,
  ]);
}

/// 💾 فشل التخزين المحلي
class StorageFailure extends AuthFailure {
  const StorageFailure([
    super.message = 'فشل في حفظ بيانات الجلسة',
  ]);
}

/// 🔗 Offline - لا يوجد جلسة محفوظة
class NoStoredSessionFailure extends AuthFailure {
  const NoStoredSessionFailure([
    super.message = 'لا توجد جلسة محفوظة. يرجى الاتصال بالإنترنت وتسجيل الدخول',
  ]);
}

/// 📴 Offline - الجلسة منتهية والجهاز offline
class OfflineSessionExpiredFailure extends AuthFailure {
  final int expiredDaysAgo;

  OfflineSessionExpiredFailure({
    this.expiredDaysAgo = 0,
    String? message,
  }) : super(message ?? 'انتهت صلاحية الجلسة منذ $expiredDaysAgo يوم. يرجى الاتصال بالإنترنت');
}

/// 🚫 تجاوز عدد المحاولات
class TooManyAttemptsFailure extends AuthFailure {
  final int? retryAfterSeconds;

  const TooManyAttemptsFailure([
    super.message = 'عدد محاولات كثيرة. يرجى المحاولة لاحقاً',
    this.retryAfterSeconds,
  ]);
}

/// ⚠️ خطأ غير متوقع
class UnexpectedAuthFailure extends AuthFailure {
  const UnexpectedAuthFailure([
    super.message = 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً',
  ]);
}
