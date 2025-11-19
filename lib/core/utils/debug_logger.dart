import 'package:flutter/foundation.dart';

/// Debug Logger Utility
/// Wraps all print statements with kDebugMode to prevent logging in production
class DebugLogger {
  /// Log general messages
  static void log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  /// Log error messages
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }

  /// Log success messages
  static void success(String message) {
    if (kDebugMode) {
      print('✅ $message');
    }
  }

  /// Log warning messages
  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ $message');
    }
  }

  /// Log info messages
  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ $message');
    }
  }

  /// Log debug messages with emoji
  static void debug(String message) {
    if (kDebugMode) {
      print('🔧 $message');
    }
  }
}
