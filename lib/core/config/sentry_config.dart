/// Sentry Configuration
///
/// HOW TO GET DSN:
/// 1. Go to https://sentry.io
/// 2. Project Settings → Client Keys (DSN)
/// 3. Copy the DSN and paste below
class SentryConfig {
  // DISABLED FOR PUBLIC GITHUB VERSION:
  // Real Sentry DSN has been removed to protect company monitoring infrastructure.
  // TODO: Replace with a new Sentry project DSN or Firebase Crashlytics.
  static const String dsn = '';

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
