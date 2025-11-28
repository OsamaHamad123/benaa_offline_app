import 'package:flutter/foundation.dart';

/// 📝 Unified Logger - نظام تسجيل موحد
///
/// Provides consistent logging across the app with emojis and colors
class UnifiedLogger {
  /// ℹ️ Info message
  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ $message');
    }
  }

  /// ✅ Success message
  static void success(String message) {
    if (kDebugMode) {
      print('✅ $message');
    }
  }

  /// ⚠️ Warning message
  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ $message');
    }
  }

  /// ❌ Error message
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('❌ $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  /// 🐛 Debug message (verbose)
  static void debug(String message) {
    if (kDebugMode) {
      print('🐛 $message');
    }
  }

  /// 🎯 Performance/timing message
  static void performance(String message) {
    if (kDebugMode) {
      print('🎯 $message');
    }
  }

  /// 🔍 Data inspection
  static void inspect(String label, dynamic data) {
    if (kDebugMode) {
      print('🔍 $label: $data');
    }
  }

  /// 📊 Performance/timing log
  static void logPerformance({
    String? message,
    String? operation,
    int? durationMs,
  }) {
    if (kDebugMode) {
      final msg = message ??
          (operation != null && durationMs != null ? '$operation (${durationMs}ms)' : operation ?? 'Performance log');
      print('📊 $msg');
    }
  }

  /// 🔍 Search log
  static void logSearch({
    String? message,
    String? query,
    int? resultsCount,
    int? durationMs,
  }) {
    if (kDebugMode) {
      final msg = message ??
          (query != null ? 'Search: $query → ${resultsCount ?? 0} results (${durationMs ?? 0}ms)' : 'Search executed');
      print('🔍 $msg');
    }
  }

  /// 💾 Cache log
  static void logCache({
    String? message,
    String? key,
    bool? hit,
    int? cacheSize,
  }) {
    if (kDebugMode) {
      final msg = message ??
          (key != null ? 'Cache ${hit == true ? "HIT" : "MISS"}: $key (size: ${cacheSize ?? 0})' : 'Cache operation');
      print('💾 $msg');
    }
  }

  /// 🗄️ Query log
  static void logQuery({
    String? message,
    String? query,
    int? durationMs,
    int? resultCount,
  }) {
    if (kDebugMode) {
      final msg = message ??
          (query != null ? 'Query: $query → ${resultCount ?? 0} results (${durationMs ?? 0}ms)' : 'Query executed');
      print('🗄️ $msg');
    }
  }

  /// 📝 Generic log (fallback)
  static void log(String message) {
    if (kDebugMode) {
      print('📝 $message');
    }
  }
}
