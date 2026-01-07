import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';

/// 🔐 حالات المصادقة
///
/// تمثل جميع الحالات الممكنة للمصادقة في التطبيق
sealed class AuthState {
  const AuthState();

  /// الحصول على الجلسة إذا كانت موجودة
  AuthSession? get session => null;

  /// الحصول على المستخدم إذا كان موجوداً
  AuthUser? get user => session?.user;

  /// هل المستخدم مصادق حالياً
  bool get isAuthenticated => this is AuthAuthenticated;

  /// هل جاري التحميل
  bool get isLoading => this is AuthLoading;

  /// هل يوجد خطأ
  bool get hasError => this is AuthError;

  /// هل يعمل offline
  bool get isOffline {
    final state = this;
    if (state is AuthAuthenticated) {
      return state._isOffline;
    }
    return false;
  }

  /// هل يحتاج تجديد Token
  bool get needsTokenRefresh => this is AuthTokenExpiring;

  /// الحصول على رسالة الخطأ إذا كانت موجودة
  String? get errorMessage {
    final state = this;
    if (state is AuthError) return state.message;
    if (state is AuthUnauthenticated) return state.message;
    if (state is AuthSessionExpired) return state.message;
    return null;
  }

  /// Pattern matching helper
  T maybeWhen<T>({
    T Function()? initial,
    T Function(String message)? loading,
    T Function(AuthSession session, bool isOffline, bool tokenRefreshed)? authenticated,
    T Function(String? message)? unauthenticated,
    T Function(String message, String? errorCode, bool canRetry)? error,
    T Function(AuthSession session, int remainingDays)? tokenExpiring,
    T Function(AuthUser? lastUser, String message)? sessionExpired,
    required T Function() orElse,
  }) {
    final state = this;
    if (state is AuthInitial && initial != null) return initial();
    if (state is AuthLoading && loading != null) return loading(state.message);
    if (state is AuthAuthenticated && authenticated != null) {
      return authenticated(state.session, state._isOffline, state.tokenRefreshed);
    }
    if (state is AuthUnauthenticated && unauthenticated != null) {
      return unauthenticated(state.message);
    }
    if (state is AuthError && error != null) {
      return error(state.message, state.errorCode, state.canRetry);
    }
    if (state is AuthTokenExpiring && tokenExpiring != null) {
      return tokenExpiring(state.session, state.remainingDays);
    }
    if (state is AuthSessionExpired && sessionExpired != null) {
      return sessionExpired(state.lastUser, state.message);
    }
    return orElse();
  }
}

/// ⏳ الحالة الأولية - جاري التحقق
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// ⏳ جاري تحميل (تسجيل دخول، تجديد، إلخ)
class AuthLoading extends AuthState {
  final String message;

  const AuthLoading({this.message = 'جاري التحميل...'});
}

/// ✅ تم المصادقة بنجاح
class AuthAuthenticated extends AuthState {
  @override
  final AuthSession session;
  final bool _isOffline;
  final bool tokenRefreshed;

  const AuthAuthenticated({
    required this.session,
    bool isOffline = false,
    this.tokenRefreshed = false,
  }) : _isOffline = isOffline;

  @override
  bool get isOffline => _isOffline;
}

/// ❌ غير مصادق (لم يسجل دخول)
class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});
}

/// ⚠️ خطأ
class AuthError extends AuthState {
  final String message;
  final String? errorCode;
  final bool canRetry;

  const AuthError({
    required this.message,
    this.errorCode,
    this.canRetry = true,
  });
}

/// 🔄 يحتاج تجديد Token
class AuthTokenExpiring extends AuthState {
  @override
  final AuthSession session;
  final int remainingDays;

  const AuthTokenExpiring({
    required this.session,
    required this.remainingDays,
  });
}

/// ⏰ Token منتهي - يحتاج إعادة تسجيل دخول
class AuthSessionExpired extends AuthState {
  final AuthUser? lastUser;
  final String message;

  const AuthSessionExpired({
    this.lastUser,
    this.message = 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى',
  });
}
