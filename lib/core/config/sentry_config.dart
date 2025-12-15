/// Sentry Configuration
///
/// HOW TO GET DSN:
/// 1. Go to https://sentry.io
/// 2. Project Settings → Client Keys (DSN)
/// 3. Copy the DSN and paste below
class SentryConfig {
  // ✅ DSN from Sentry project: palistine/flutter
  // Project: https://palistine.sentry.io/issues/?project=4510539427807232
  static const String dsn =
      'https://9f435522e83b9934c04f145696070cd6@o4510539424923648.ingest.us.sentry.io/4510539427807232';

  // Environment names
  static const String prodEnvironment = 'production';
  static const String devEnvironment = 'development';

  // Sample rate for performance monitoring (0.0 to 1.0)
  // 0.2 = 20% of transactions
  static const double tracesSampleRate = 0.2;

  // Should we send errors in debug mode?
  // Set to true for testing, false for normal development
  static const bool sendInDebug = true;
}
