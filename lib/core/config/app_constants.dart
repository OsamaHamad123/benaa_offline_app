/// 🔧 App Constants - Centralized Configuration
///
/// جمع كل الـ Magic Numbers و Configuration في مكان واحد
class AppConstants {
  // ============================================================================
  // SYNC CONFIGURATION
  // ============================================================================

  /// حجم الدفعة للمزامنة (عدد السجلات)
  static const int syncBatchSize = 200;

  /// عدد محاولات إعادة المزامنة
  static const int maxSyncRetries = 3;

  /// مدة الانتظار قبل إعادة المحاولة (exponential backoff)
  static const Duration initialRetryDelay = Duration(seconds: 2);

  /// الحد الأقصى لمدة الانتظار بين المحاولات
  static const Duration maxRetryDelay = Duration(minutes: 5);

  // ============================================================================
  // SEARCH CONFIGURATION
  // ============================================================================

  /// Search debounce duration (ms) - للتحكم بتأخير البحث التلقائي
  static const Duration searchDebounceDuration = Duration(milliseconds: 300);

  /// Search page size - عدد النتائج لكل صفحة
  static const int searchPageSize = 20;

  /// Max cached searches - عدد عمليات البحث المخزنة
  static const int maxCachedSearches = 20;

  /// Search cache max memory (bytes) - الحد الأقصى لذاكرة البحث
  static const int searchCacheMaxMemoryBytes = 12 * 1024 * 1024; // 12MB

  /// Max autocomplete suggestions
  static const int maxSuggestions = 10;

  /// الحد الأدنى لطول استعلام البحث
  static const int minSearchQueryLength = 2;

  // ============================================================================
  // DATABASE CONFIGURATION
  // ============================================================================

  /// مدة صلاحية الـ cache للإحصائيات (دقائق)
  static const Duration statisticsCacheDuration = Duration(minutes: 10);

  /// مدة صلاحية الـ cache للـ Dashboard (دقائق)
  static const Duration dashboardCacheDuration = Duration(minutes: 5);

  /// مدة صلاحية الـ cache للتقارير (دقائق)
  static const Duration reportsCacheDuration = Duration(minutes: 15);

  /// حجم الـ batch للعمليات الجماعية
  static const int databaseBatchSize = 100;

  // ============================================================================
  // PERFORMANCE CONFIGURATION
  // ============================================================================

  /// الحد الأقصى للنتائج في الاستعلام الواحد
  static const int maxQueryResults = 1000;

  /// مدة timeout للاتصال بالـ API (ثانية)
  static const Duration apiConnectionTimeout = Duration(seconds: 30);

  /// مدة timeout لاستقبال البيانات (ثانية)
  static const Duration apiReceiveTimeout = Duration(seconds: 30);

  /// Buffer للـ token expiry (دقائق قبل انتهاء الصلاحية)
  static const Duration tokenExpiryBuffer = Duration(minutes: 5);

  // ============================================================================
  // UI CONFIGURATION
  // ============================================================================

  /// مدة الـ auto-save للنماذج (ثانية)
  static const Duration autoSaveInterval = Duration(seconds: 60);

  /// مدة الـ toast messages (ثانية)
  static const Duration toastDuration = Duration(seconds: 3);

  /// الحد الأقصى لحجم الملف المرفوع (MB)
  static const int maxAttachmentSizeMB = 50;

  /// الحد الأقصى لعدد المرفقات لكل زيارة
  static const int maxAttachmentsPerVisit = 10;

  // ============================================================================
  // LOGGING CONFIGURATION
  // ============================================================================

  /// تفعيل الـ verbose logging في Debug mode
  static const bool enableVerboseLogging = true;

  /// تفعيل الـ performance logging
  static const bool enablePerformanceLogging = true;

  // ============================================================================
  // CIVIL REGISTRY DATABASE
  // ============================================================================

  /// اسم ملف قاعدة السجل المدني
  static const String civilDbFileName = 'persons.db';

  /// حجم الـ FTS cache (MB)
  static const int ftsCacheSizeMB = 50;

  // ============================================================================
  // MAINTENANCE
  // ============================================================================

  /// مدة تنفيذ VACUUM على قاعدة البيانات (أيام)
  static const Duration vacuumInterval = Duration(days: 30);

  /// Run ANALYZE every 3 days to update query optimizer statistics
  static const Duration analyzeInterval = Duration(days: 3);

  /// Run FTS optimization weekly to maintain search performance
  static const Duration ftsOptimizeInterval = Duration(days: 7);

  /// الحد الأقصى لعمر ملفات الـ temp (ساعات)
  static const Duration tempFileMaxAge = Duration(hours: 24);

  // ============================================================================
  // NETWORK
  // ============================================================================

  /// الحد الأقصى لعدد محاولات إعادة الاتصال
  static const int maxNetworkRetries = 3;

  /// مدة الانتظار بين محاولات الاتصال (ثانية)
  static const Duration networkRetryDelay = Duration(seconds: 2);
}
