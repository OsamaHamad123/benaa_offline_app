# 🚨 Sentry Error Tracking Setup Guide

## ✅ Current Status

Sentry has been integrated into the application for production error tracking and monitoring.

## 📋 What's Been Implemented

### 1. **Package Installation**
- ✅ Added `sentry_flutter: ^8.11.0` to `pubspec.yaml`
- ✅ Installed dependencies with `flutter pub get`

### 2. **Main.dart Integration**
- ✅ Sentry initialization in `main()` function
- ✅ Wrapped app with `SentryFlutter.init()`
- ✅ Configured error tracking options:
  - Automatic performance tracing
  - Stack trace attachment
  - Screenshot capture on errors
  - Environment-based filtering (production only)

### 3. **Error Reporting in Critical Services**
- ✅ **Database Maintenance Service**: Captures maintenance failures
- ✅ **SearchProvider**: Reports search errors with full stack traces
- ✅ **BeneficiaryFormProvider**: Tracks form save failures

### 4. **DebugLogger Integration**
- All critical errors are logged locally via `DebugLogger`
- Errors are simultaneously reported to Sentry in production builds

## 🔧 Required Configuration Steps

### Step 1: Create Sentry Account
1. Go to [sentry.io](https://sentry.io)
2. Sign up for a free account
3. Create a new Flutter project

### Step 2: Get Your DSN
1. After creating the project, copy your **DSN** (Data Source Name)
2. It looks like: `https://[key]@[organization].ingest.sentry.io/[project-id]`

### Step 3: Configure DSN in Main.dart
Replace the placeholder in `lib/main.dart`:

```dart
options.dsn = 'YOUR_SENTRY_DSN_HERE'; // ← Replace this
```

With your actual DSN:

```dart
options.dsn = 'https://abc123@o123456.ingest.sentry.io/7890123';
```

### Step 4: Test Error Reporting (Development)

Add a test button in your app:

```dart
ElevatedButton(
  onPressed: () {
    throw Exception('Test Sentry error reporting');
  },
  child: Text('Test Sentry'),
)
```

### Step 5: Production Build Configuration

For production builds, errors will automatically be sent to Sentry.

```bash
flutter build apk --release
# or
flutter build ios --release
```

## 📊 What Gets Tracked

### Automatic Tracking
- ✅ Unhandled exceptions
- ✅ Flutter framework errors
- ✅ Native crashes (iOS/Android)
- ✅ Performance metrics
- ✅ App startup time
- ✅ Screen load times

### Manual Tracking (Already Implemented)
- ✅ Database maintenance errors
- ✅ Search query failures
- ✅ Beneficiary save errors
- ✅ All errors with full stack traces

## 🎯 Error Context Included

Each error report includes:
- **Stack Trace**: Full call stack when error occurred
- **Screenshot**: Visual context of the error (in production)
- **Device Info**: OS version, device model, screen size
- **User Context**: App version, build number
- **Environment**: Production/Development
- **Timestamp**: When the error occurred

## 🔒 Privacy & Performance

### Privacy Protections
- **Debug Mode**: Errors are NOT sent to Sentry (only logged locally)
- **Production Mode**: Errors are sent to Sentry for monitoring
- **No PII**: Ensure no personal data is included in error messages

### Performance Impact
- **Minimal**: ~50KB added to app size
- **Network**: Only sends data when errors occur
- **Async**: Error reporting doesn't block UI

## 📈 Monitoring Dashboard

Once configured, you can:
1. View all errors at `sentry.io/[organization]/[project]/issues`
2. See error frequency and trends
3. Identify most common crashes
4. Track error resolution
5. Get alerts for new errors

## 🛠️ Advanced Configuration (Optional)

### Custom Error Boundaries

Add custom error tracking:

```dart
try {
  await riskyOperation();
} catch (e, stackTrace) {
  await Sentry.captureException(
    e,
    stackTrace: stackTrace,
    withScope: (scope) {
      scope.setTag('feature', 'sync');
      scope.setExtra('userId', currentUserId);
    },
  );
}
```

### Performance Monitoring

Already enabled! Track custom operations:

```dart
final transaction = Sentry.startTransaction(
  'sync-operation',
  'task',
);

try {
  await syncData();
  transaction.status = SpanStatus.ok();
} catch (e) {
  transaction.status = SpanStatus.internalError();
  rethrow;
} finally {
  await transaction.finish();
}
```

### User Feedback

Allow users to submit feedback on errors:

```dart
await Sentry.captureUserFeedback(SentryUserFeedback(
  eventId: lastEventId,
  name: 'User Name',
  email: 'user@example.com',
  comments: 'The app crashed when I tried to sync',
));
```

## ✅ Verification Checklist

- [ ] Created Sentry account at sentry.io
- [ ] Created Flutter project in Sentry
- [ ] Copied DSN from Sentry dashboard
- [ ] Replaced `YOUR_SENTRY_DSN_HERE` in `lib/main.dart`
- [ ] Tested error reporting in development
- [ ] Verified errors appear in Sentry dashboard
- [ ] Built production release
- [ ] Confirmed production errors are tracked

## 📚 Resources

- **Sentry Docs**: https://docs.sentry.io/platforms/flutter/
- **Performance Monitoring**: https://docs.sentry.io/platforms/flutter/performance/
- **Best Practices**: https://docs.sentry.io/platforms/flutter/usage/

## 🎉 Benefits Achieved

✅ **Proactive Error Detection**: Know about crashes before users report them
✅ **Stack Traces**: Understand exactly where and why errors occur
✅ **Performance Insights**: Track app performance in production
✅ **User Context**: See device and environment details
✅ **Trend Analysis**: Identify patterns in crashes
✅ **Faster Debugging**: Complete context for every error

---

**Next Steps**: Configure DSN and start monitoring production errors! 🚀
