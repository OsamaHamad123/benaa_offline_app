import '../../../../core/error_handling/result.dart';
import '../entities/auth_device.dart';
import '../entities/auth_session.dart';
import '../entities/auth_user.dart';
import '../entities/auth_token.dart';

/// 📦 Auth Repository Interface - Domain Layer
///
/// واجهة Repository للمصادقة تتبع Clean Architecture.
/// تعرّف العمليات المطلوبة دون الاهتمام بتفاصيل التنفيذ.
abstract class AuthRepository {
  // ===========================
  // 🔐 AUTHENTICATION
  // ===========================

  /// 🔑 تسجيل الدخول
  ///
  /// [email] البريد الإلكتروني
  /// [password] كلمة المرور
  /// [deviceId] معرف الجهاز (مطلوب للـ API)
  /// [deviceName] اسم الجهاز (اختياري)
  /// [devicePlatform] نوع النظام (اختياري - android/ios)
  ///
  /// Returns [AuthSession] on success, [AppFailure] on error
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required String deviceId,
    String? deviceName,
    String? devicePlatform,
  });

  /// 🚪 تسجيل الخروج
  ///
  /// [deviceId] معرف الجهاز للخروج من جهاز محدد
  /// [logoutAllDevices] تسجيل الخروج من جميع الأجهزة
  Future<Result<void>> logout({
    String? deviceId,
    bool logoutAllDevices = false,
  });

  /// 👤 جلب الملف الشخصي من الخادم
  Future<Result<AuthUser>> getProfile();

  /// 📱 جلب الأجهزة النشطة للمستخدم
  Future<Result<List<AuthDevice>>> getActiveDevices();

  // ===========================
  // 🔄 TOKEN MANAGEMENT
  // ===========================

  /// ✅ التحقق من صلاحية الـ Token
  ///
  /// يتحقق من الـ Token مع السيرفر (يتطلب اتصال)
  /// Returns validation details including remaining days
  Future<Result<TokenValidationResult>> validateToken();

  /// 🔄 تجديد الـ Token
  ///
  /// [deviceId] معرف الجهاز (مطلوب)
  /// Returns new [AuthToken] on success
  Future<Result<AuthToken>> refreshToken({
    required String deviceId,
  });

  /// ⏰ فحص هل يجب تجديد الـ Token (أقل من يومين متبقيين)
  Future<bool> shouldRefreshToken();

  // ===========================
  // 💾 LOCAL SESSION
  // ===========================

  /// 📖 الحصول على الجلسة المخزنة محلياً
  Future<Result<AuthSession>> getStoredSession();

  /// 💾 حفظ الجلسة محلياً (Secure Storage)
  Future<Result<void>> saveSession(AuthSession session);

  /// 🗑️ حذف الجلسة المخزنة
  Future<Result<void>> clearSession();

  /// ✅ هل يوجد جلسة صالحة (محلياً)
  Future<bool> hasValidSession();

  // ===========================
  // 📱 DEVICE INFO
  // ===========================

  /// 📱 الحصول على معرف الجهاز
  Future<String> getDeviceId();

  /// 📱 الحصول على اسم الجهاز
  Future<String> getDeviceName();

  /// 📱 الحصول على منصة الجهاز (android/ios)
  String getDevicePlatform();
}

/// ✅ نتيجة التحقق من الـ Token
class TokenValidationResult {
  final bool valid;
  final int userId;
  final String userName;
  final DateTime tokenExpiresAt;
  final int remainingDays;
  final int remainingSeconds;
  final bool shouldRefresh;
  final String? actionRequired;

  const TokenValidationResult({
    required this.valid,
    required this.userId,
    required this.userName,
    required this.tokenExpiresAt,
    required this.remainingDays,
    required this.remainingSeconds,
    required this.shouldRefresh,
    this.actionRequired,
  });

  /// هل الـ Token صالح وغير منتهي
  bool get isFullyValid => valid && remainingDays > 0;

  /// هل يحتاج تجديد عاجل (يوم واحد أو أقل)
  bool get isUrgentRefresh => remainingDays <= 1;

  @override
  String toString() {
    return 'TokenValidationResult(valid: $valid, remainingDays: $remainingDays, shouldRefresh: $shouldRefresh)';
  }
}
