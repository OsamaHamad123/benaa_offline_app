import 'package:logger/logger.dart';

/// 📝 Application Logger
///
/// Centralized logging utility for the entire app
/// Usage:
///   AppLogger.info('User searched for: $query');
///   AppLogger.error('Database error', error: e, stackTrace: st);
///
/// Log Levels:
///   - debug: Development only (cache hits, query details)
///   - info: Important events (search results, user actions)
///   - warning: Potential issues (cache full, slow queries)
///   - error: Actual errors (database failures, crashes)
class AppLogger {
  // ============================================================================
  // CONFIGURATION - Change for Production
  // ============================================================================

  /// Set to false in production to reduce logs
  static const bool _isDevelopment = true;

  /// Minimum log level (debug, info, warning, error)
  static const Level _logLevel = _isDevelopment ? Level.debug : Level.info;

  /// Enable/disable cache logging (verbose in development)
  static const bool _enableCacheLogging = false; // Set to false to reduce noise

  /// Enable/disable query logging
  static const bool _enableQueryLogging = false; // Set to false to reduce noise

  // ============================================================================

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Reduce stack trace lines (was 2)
      printTime: false, // Disable time in production (less noise)
    ),
    level: _logLevel,
  );

  // Prevent instantiation
  AppLogger._();

  /// Log debug message
  static void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info message
  static void info(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning message
  static void warning(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error message
  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal error (critical)
  static void fatal(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // ============================================================================
  // SEARCH-SPECIFIC LOGGING HELPERS
  // ============================================================================

  /// Log search query
  static void logSearch({
    required String query,
    String? filter,
    int? resultsCount,
    int? durationMs,
  }) {
    final details = StringBuffer('Search: "$query"');
    if (filter != null) details.write(' | Filter: $filter');
    if (resultsCount != null) details.write(' | Results: $resultsCount');
    if (durationMs != null) {
      details.write(' | Time: ${durationMs}ms');

      // ⚠️ Warn if search is slow
      if (durationMs > 100) {
        warning('Slow search detected: ${durationMs}ms for "$query"');
      }
    }

    info(details.toString());
  }

  /// Log cache hit/miss
  static void logCache({
    required String key,
    required bool hit,
    int? cacheSize,
  }) {
    if (!_enableCacheLogging) return; // Skip if disabled

    final status = hit ? '✅ HIT' : '❌ MISS';
    final message = 'Cache $status: $key';
    final details = cacheSize != null ? ' | Size: $cacheSize' : '';
    debug(message + details);

    // ⚠️ Warn if cache is approaching limit
    if (cacheSize != null && cacheSize >= 45) {
      // 90% of 50
      warning('Cache approaching limit: $cacheSize/50 entries');
    }
  }

  /// Log database query
  static void logQuery({
    required String query,
    int? resultCount,
    int? durationMs,
  }) {
    if (!_enableQueryLogging) return; // Skip if disabled

    final details = StringBuffer(
      'Query: ${query.substring(0, query.length > 100 ? 100 : query.length)}',
    );
    if (resultCount != null) details.write(' | Rows: $resultCount');
    if (durationMs != null) details.write(' | ${durationMs}ms');
    debug(details.toString());
  }

  /// Log performance metric
  static void logPerformance({
    required String operation,
    required int durationMs,
    Map<String, dynamic>? metadata,
  }) {
    final details = StringBuffer('⚡ $operation: ${durationMs}ms');
    if (metadata != null) {
      metadata.forEach((key, value) {
        details.write(' | $key: $value');
      });
    }
    info(details.toString());
  }
}
