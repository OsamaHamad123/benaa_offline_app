/// 🔧 API Configuration
///
/// ملف إعدادات الـ API المركزي
/// يحتوي على جميع الـ endpoints والإعدادات المتعلقة بالاتصال بالسيرفر
class ApiConfig {
  // 🌐 Base URL - سيتم استبداله بالرابط الفعلي
  // يمكن تغييره من واجهة تسجيل الدخول
  static const String defaultBaseUrl = 'https://palestine.benaadev.org/api';

  // 🔗 API Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String logoutEndpoint = '/api/auth/logout';
  static const String refreshTokenEndpoint = '/api/auth/refresh';

  // 🔄 Sync Endpoints
  static const String syncEndpoint = '/api/sync';
  static const String initialDataEndpoint = '/api/sync/initial';
  static const String syncStatusEndpoint = '/api/sync/status';

  // 📊 Data Endpoints
  static const String materialsEndpoint = '/api/materials';
  static const String stockMovementsEndpoint = '/api/stock-movements';
  static const String beneficiariesEndpoint = '/api/beneficiaries';
  static const String projectsEndpoint = '/api/projects';

  // ⏱️ Timeout Settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  // 🔄 Sync Settings
  static const Duration syncInterval = Duration(minutes: 15);
  static const Duration manualSyncCooldown = Duration(seconds: 30);

  // 🔁 Retry Settings
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 5);
  static const Duration backoffMultiplier = Duration(seconds: 2);

  // 📱 Network Settings
  static const bool requireWifiForSync = false; // true = WiFi فقط
  static const bool requireWifiForDownload = true; // true = WiFi للتحميل الكبير
  static const int minBatteryLevel = 15; // % الحد الأدنى للبطارية

  // 📦 Data Settings
  static const int maxPendingChanges = 1000; // أقصى عدد للتغييرات المعلقة
  static const int batchSize = 50; // عدد السجلات في كل دفعة

  // 🔐 Security
  static const bool enableSslPinning = false; // تفعيل SSL Pinning
  static const bool validateCertificate = true;

  // 📝 Logging
  static const bool enableDebugLogging = true;
  static const bool logNetworkRequests = true;
  static const bool logNetworkResponses = true;

  // 🎯 Version
  static const String apiVersion = 'v1';
  static const String appVersion = '1.0.0';

  /// بناء URL كامل
  static String buildUrl(String endpoint, {String? baseUrl}) {
    final base = (baseUrl ?? defaultBaseUrl).replaceAll(RegExp(r'/$'), '');
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$base$path';
  }

  /// التحقق من صحة الـ URL
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
