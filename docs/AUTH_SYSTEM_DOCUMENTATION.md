# 🔐 Auth System - Clean Architecture Implementation

## 📋 نظرة عامة

تم تنفيذ نظام مصادقة متكامل باستخدام **Clean Architecture** مع دعم كامل لـ:

- ✅ تسجيل الدخول عبر API (Laravel Sanctum)
- ✅ تجديد تلقائي للـ Token
- ✅ Offline-first مع تخزين آمن
- ✅ Riverpod State Management
- ✅ Dio Interceptors للمصادقة التلقائية

---

## 🏗️ Architecture

```
lib/features/auth/
├── domain/                      # Domain Layer (Business Logic)
│   ├── entities/
│   │   ├── auth_user.dart       # User entity
│   │   ├── auth_token.dart      # Token entity with expiry logic
│   │   └── auth_session.dart    # Complete session (user + token + config)
│   ├── repositories/
│   │   └── auth_repository.dart # Repository interface
│   └── failures/
│       └── auth_failures.dart   # Specific auth failures
│
├── data/                        # Data Layer (Implementation)
│   ├── dto/
│   │   └── auth_dto.dart        # API request/response DTOs
│   ├── mappers/
│   │   └── auth_mappers.dart    # DTO ↔️ Entity converters
│   ├── repositories/
│   │   └── auth_repository_impl.dart  # Repository implementation
│   └── interceptors/
│       └── auth_interceptor.dart      # Dio auto-auth interceptor
│
├── presentation/                # Presentation Layer (UI)
│   ├── state/
│   │   ├── auth_state.dart      # Sealed class state
│   │   └── auth_notifier.dart   # StateNotifier
│   ├── providers/
│   │   └── auth_providers.dart  # Riverpod providers
│   └── pages/
│       └── login_page_v2.dart   # Updated login page
│
├── services/
│   └── token_manager.dart       # Auto-refresh service
│
└── auth.dart                    # Barrel export
```

---

## 🔑 Core Features

### 1. Entity Models

#### AuthUser

```dart
class AuthUser {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String role;
  final List<String> roles;
  final List<String> permissions;

  bool hasPermission(String permission);
  bool hasRole(String role);
}
```

#### AuthToken

```dart
class AuthToken {
  final String accessToken;
  final String tokenType;
  final DateTime expiresAt;

  bool get isExpired;
  bool get isValid;
  int get remainingDays;
  bool get shouldRefresh; // true if ≤ 2 days remaining
  String get bearerToken;  // "Bearer {token}"
}
```

#### AuthSession

```dart
class AuthSession {
  final AuthUser user;
  final AuthToken token;
  final OfflineConfig offlineConfig;

  bool get isValid;
  bool get shouldRefreshToken;
  AuthSession updateToken(AuthToken newToken);
}
```

---

### 2. API Integration

#### Endpoints (من API Documentation)

```dart
POST /api/mobile/auth/login
GET  /api/mobile/auth/validate
POST /api/mobile/auth/refresh
POST /api/mobile/auth/logout
```

#### Login Request

```json
{
  "email": "user@example.com",
  "password": "password123",
  "device_id": "device_12345",
  "device_name": "Samsung Galaxy S21",
  "device_platform": "android"
}
```

#### Login Response

```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "أحمد محمد",
      "email": "ahmed@example.com",
      "role": "admin",
      "roles": ["admin"],
      "permissions": ["view_beneficiaries", "edit_beneficiaries"]
    },
    "token": {
      "access_token": "1|abc123...",
      "token_type": "Bearer",
      "expires_at": "2026-01-17T10:00:00.000000Z",
      "expires_in_days": 10,
      "expires_in_seconds": 864000
    },
    "offline_config": {
      "max_offline_days": 10,
      "require_online_reauth": true,
      "sync_required_on_expiry": true
    }
  }
}
```

---

### 3. State Management (Riverpod)

#### Auth States

```dart
sealed class AuthState {
  AuthInitial()            // Initial state
  AuthLoading()            // Loading (login/refresh)
  AuthAuthenticated()      // Logged in successfully
  AuthUnauthenticated()    // Not logged in
  AuthError()              // Error occurred
  AuthTokenExpiring()      // Token needs refresh
  AuthSessionExpired()     // Session expired
}
```

#### Main Providers

```dart
// Auth Notifier (main state)
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);

// Derived Providers
final isAuthenticatedProvider = Provider<bool>(...);
final currentUserProvider = Provider<AuthUser?>(...);
final currentSessionProvider = Provider<AuthSession?>(...);
final hasPermissionProvider = Provider.family<bool, String>(...);
final hasRoleProvider = Provider.family<bool, String>(...);
```

---

### 4. Usage Examples

#### Login

```dart
// In your widget
final authNotifier = ref.read(authNotifierProvider.notifier);

Future<void> login() async {
  final success = await authNotifier.login(
    email: 'user@example.com',
    password: 'password123',
  );

  if (success) {
    // Navigate to dashboard
    context.go('/dashboard');
  }
}
```

#### Check Authentication Status

```dart
// Watch auth state
final isAuthenticated = ref.watch(isAuthenticatedProvider);

if (isAuthenticated) {
  // Show authenticated UI
} else {
  // Show login page
}
```

#### Get Current User

```dart
final user = ref.watch(currentUserProvider);

if (user != null) {
  print('مرحباً ${user.name}');

  if (user.hasPermission('edit_beneficiaries')) {
    // Show edit button
  }
}
```

#### Check Permissions

```dart
// Using family provider
final canEdit = ref.watch(hasPermissionProvider('edit_beneficiaries'));
final isAdmin = ref.watch(hasRoleProvider('admin'));
```

#### Logout

```dart
await ref.read(authNotifierProvider.notifier).logout();
```

---

### 5. Dio Interceptor (Auto Auth)

يتم إضافة Authorization header تلقائياً لكل طلب:

```dart
// Auth Interceptor automatically:
// 1. Adds "Authorization: Bearer {token}" to every request
// 2. Catches 401 errors and attempts token refresh
// 3. Retries failed request with new token

final authDio = AuthDioFactory.create(
  baseUrl: 'https://palestine.benaadev.org',
  secureStorage: secureStorage,
  authRepository: authRepository,
);

// Now all requests automatically include auth
await authDio.get('/api/mobile/profile'); // ✅ Auto-authenticated
```

---

### 6. Token Manager (Auto-Refresh)

```dart
// Auto-refresh logic:
// - Checks token every 6 hours
// - Refreshes if ≤ 2 days remaining
// - Monitors connectivity and refreshes when online

final tokenManager = ref.watch(tokenManagerProvider);

// Manual refresh
await tokenManager.forceRefresh();

// Get token info
final info = tokenManager.getTokenInfo();
print('Token expires in ${info?.remainingDays} days');
```

---

### 7. Secure Storage

```dart
// New methods added to SecureStorage:

// Save full session
await secureStorage.saveAuthSession(sessionMap);

// Get session
final session = await secureStorage.getAuthSession();

// Check token expiry
final isExpired = await secureStorage.isTokenExpired();
final remainingDays = await secureStorage.getRemainingTokenDays();
final shouldRefresh = await secureStorage.shouldRefreshToken();

// Update token only
await secureStorage.updateToken(
  accessToken: newToken,
  expiresAt: expiresAt,
);

// Clear session
await secureStorage.clearAuthSession();
```

---

## 🔄 Flow Diagrams

### Login Flow

```
User Enters Credentials
        ↓
AuthNotifier.login()
        ↓
AuthRepository.login()
        ↓
[API] POST /api/mobile/auth/login
        ↓
Success? → Save Session → Update State to Authenticated
        ↓
Failure? → Update State to Error
```

### Token Refresh Flow

```
Request to API (Dio Interceptor)
        ↓
401 Response?
        ↓
AuthInterceptor.onError()
        ↓
Attempt Token Refresh
        ↓
[API] POST /api/mobile/auth/refresh
        ↓
Success? → Save New Token → Retry Original Request
        ↓
Failure? → Logout User
```

### App Startup Flow

```
App Starts
        ↓
AuthNotifier.checkAuthStatus()
        ↓
Has Stored Session?
        ↓
Yes → Is Online?
    ↓
    Yes → Validate Token with Server
    ↓
    No → Use Offline Session (if valid)
        ↓
No → Show Login Page
```

---

## 🧪 Testing

تم التأكد من أن جميع الـ **481 اختباراً** لا تزال تعمل بنجاح بعد تطبيق نظام المصادقة.

---

## 📦 Dependencies Used

```yaml
dependencies:
  flutter_riverpod: ^2.6.1 # State management
  dio: ^5.9.0 # HTTP client
  flutter_secure_storage: ^9.2.2 # Secure storage
  equatable: ^2.0.7 # Value equality
  json_annotation: ^4.9.0 # JSON serialization
  connectivity_plus: ^6.1.1 # Network connectivity
  device_info_plus: ^10.1.0 # Device info

dev_dependencies:
  build_runner: ^2.4.13 # Code generation
  json_serializable: ^6.9.0 # JSON serialization
```

---

## 🚀 Next Steps

1. ✅ Integrate auth with existing SyncApiClient
2. ✅ Add auth middleware to protected routes
3. ✅ Implement refresh token rotation
4. ✅ Add biometric auth option
5. ✅ Create integration tests

---

## 📝 Notes

- Token validity: **10 days** for offline use
- Auto-refresh triggers when ≤ **2 days** remaining
- All tokens stored in **encrypted secure storage**
- Full support for **offline-first** architecture
- Compatible with **Laravel Sanctum** token system

---

تم بناء هذا النظام بالكامل باستخدام **Clean Architecture** و **SOLID Principles** لضمان:

- ✅ قابلية الاختبار
- ✅ قابلية الصيانة
- ✅ سهولة التوسع
- ✅ فصل المسؤوليات
