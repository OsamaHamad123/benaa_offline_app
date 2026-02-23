import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../config/sentry_config.dart';

/// Central error logging service
///
/// Usage:
/// ```dart
/// try {
///   // risky operation
/// } catch (e, st) {
///   await ErrorLogger.logError(e, st, context: {'function': 'myFunction'});
/// }
/// ```
class ErrorLogger {
  /// Log an exception/error
  static Future<void> logError(
    Object error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
    String? hint,
    SentryLevel level = SentryLevel.error,
  }) async {
    // Always log to console in debug mode
    if (kDebugMode) {
      debugPrint('❌ Error: $error');
      if (stackTrace != null) {
        debugPrint('📍 Stack: $stackTrace');
      }
      if (hint != null) {
        debugPrint('💡 Hint: $hint');
      }
      if (context != null) {
        debugPrint('📋 Context: $context');
      }

      // Don't send to Sentry in debug if configured not to
      if (!SentryConfig.sendInDebug) {
        return;
      }
    }

    // Send to Sentry in production or if configured to send in debug
    if (kReleaseMode || SentryConfig.sendInDebug) {
      try {
        await Sentry.captureException(
          error,
          stackTrace: stackTrace,
          withScope: (scope) {
            // Add custom context
            if (context != null) {
              context.forEach((key, value) {
                scope.setExtra(key, value);
              });
            }

            // Add hint as tag for filtering
            if (hint != null) {
              scope.setTag('hint', hint);
            }

            // Set level
            scope.level = level;
          },
        );
      } catch (e) {
        // Fallback if Sentry fails
        debugPrint('⚠️ Failed to send error to Sentry: $e');
      }
    }
  }

  /// Log a message (non-error)
  static Future<void> logMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? context,
  }) async {
    if (kDebugMode) {
      debugPrint('📝 Message: $message');
      if (context != null) {
        debugPrint('📋 Context: $context');
      }

      if (!SentryConfig.sendInDebug) {
        return;
      }
    }

    if (kReleaseMode || SentryConfig.sendInDebug) {
      try {
        await Sentry.captureMessage(
          message,
          level: level,
          withScope: (scope) {
            if (context != null) {
              context.forEach((key, value) {
                scope.setExtra(key, value);
              });
            }
          },
        );
      } catch (e) {
        debugPrint('⚠️ Failed to send message to Sentry: $e');
      }
    }
  }

  /// Log a warning
  static Future<void> logWarning(
    String message, {
    Map<String, dynamic>? context,
  }) async {
    await logMessage(message, level: SentryLevel.warning, context: context);
  }

  /// Log info
  static Future<void> logInfo(
    String message, {
    Map<String, dynamic>? context,
  }) async {
    await logMessage(message, context: context);
  }
}
