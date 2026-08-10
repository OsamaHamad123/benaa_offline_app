# 🎯 دليل تركيب Sentry - خطوة بخطوة

## 📋 الخطوات

### الخطوة 1️⃣: إنشاء حساب Sentry (5 دقائق)

#### 1. افتح المتصفح واذهب إلى:
```
https://sentry.io/signup/
```

#### 2. سجل حساب جديد:
- **الخيار 1**: استخدم GitHub account (أسرع)
- **الخيار 2**: استخدم Email

#### 3. بعد التسجيل:
- اختر "Create your first project"
- Platform: **Flutter**
- اسم المشروع: `benaa-offline-app`
- Alert frequency: **On every new issue** (للبداية)

#### 4. احفظ الـ DSN:
ستشوف شاشة فيها كود مثل:
```dart
dsn: 'https://examplePublicKey@o0.ingest.sentry.io/0'
```

**📋 انسخ الـ DSN كله** واحفظه في ملف نصي مؤقت!

---

### الخطوة 2️⃣: إضافة Sentry Config File (2 دقيقة)

سنضع الـ DSN في ملف منفصل (أمان أفضل):

#### ملف: `lib/core/config/sentry_config.dart`

```dart
/// Sentry Configuration
/// 
/// HOW TO GET DSN:
/// 1. Go to https://sentry.io
/// 2. Project Settings → Client Keys (DSN)
/// 3. Copy the DSN and paste below
class SentryConfig {
  // 🔴 IMPORTANT: Replace with your actual DSN from sentry.io
  static const String dsn = 'YOUR_DSN_HERE';
  
  // Environment names
  static const String prodEnvironment = 'production';
  static const String devEnvironment = 'development';
  
  // Sample rate for performance monitoring (0.0 to 1.0)
  // 0.2 = 20% of transactions
  static const double tracesSampleRate = 0.2;
  
  // Should we send errors in debug mode?
  static const bool sendInDebug = false;
}
```

**✏️ عدّل**: استبدل `'YOUR_DSN_HERE'` بالـ DSN اللي نسخته!

---

### الخطوة 3️⃣: إنشاء ErrorLogger Service (5 دقائق)

هذا السيرفس سيكون المسؤول عن تسجيل كل الأخطاء.

#### ملف: `lib/core/error_handling/error_logger.dart`

```dart
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
    await logMessage(message, level: SentryLevel.info, context: context);
  }
}
```

---

### الخطوة 4️⃣: تعديل main.dart (5 دقائق)

نحتاج نلف التطبيق بـ Sentry initialization.

#### ملف: `lib/main.dart`

**🔍 ابحث عن**:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... existing code
  runApp(const MyApp());
}
```

**✏️ استبدل بـ**:
```dart
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/config/sentry_config.dart';
import 'core/error_handling/error_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Sentry
  await SentryFlutter.init(
    (options) {
      options.dsn = SentryConfig.dsn;
      
      // Environment
      options.environment = kReleaseMode 
          ? SentryConfig.prodEnvironment 
          : SentryConfig.devEnvironment;
      
      // Performance monitoring (20% sample rate)
      options.tracesSampleRate = SentryConfig.tracesSampleRate;
      
      // Don't send in debug mode if configured
      options.beforeSend = (event, hint) {
        if (kDebugMode && !SentryConfig.sendInDebug) {
          return null; // Don't send
        }
        return event;
      };
      
      // Capture errors from Flutter framework
      options.enableAutoSessionTracking = true;
      
      // Print debug info
      options.debug = kDebugMode;
    },
    appRunner: () async {
      // ... الكود الموجود (Hive, etc.)
      
      runApp(const MyApp());
    },
  );
}
```

---

### الخطوة 5️⃣: إضافة Error Boundary Widget (اختياري - 5 دقائق)

هذا يمسك أي خطأ يحدث في الـ UI.

#### ملف: `lib/core/widgets/error_boundary.dart`

```dart
import 'package:flutter/material.dart';
import '../error_handling/error_logger.dart';

/// Wraps the app to catch any uncaught widget errors
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  
  const ErrorBoundary({
    required this.child,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    // Set custom error builder
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Log the error
      ErrorLogger.logError(
        details.exception,
        details.stack,
        context: {
          'library': details.library ?? 'unknown',
          'context': details.context?.toString() ?? 'unknown',
        },
        hint: 'Widget rendering error',
      );
      
      // Show user-friendly error screen
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'حدث خطأ غير متوقع',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'تم إرسال تقرير عن المشكلة\nحاول إعادة تشغيل التطبيق',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // في التطبيق الحقيقي، أضف restart logic
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };
    
    return child;
  }
}
```

**استخدام في main.dart**:
```dart
runApp(
  ErrorBoundary(
    child: const MyApp(),
  ),
);
```

---

### الخطوة 6️⃣: اختبار Crash Reporting (5 دقائق)

خليني نضيف زر تجريبي يسبب crash:

#### في أي صفحة (مثلاً Dashboard):

```dart
// في build method
if (kDebugMode) {
  FloatingActionButton(
    onPressed: () async {
      // Test 1: Manual error
      await ErrorLogger.logError(
        Exception('Test error from dashboard'),
        StackTrace.current,
        context: {'test': 'manual_trigger'},
        hint: 'Testing Sentry integration',
      );
      
      // Test 2: Actual crash (uncomment to test)
      // throw Exception('Test crash!');
    },
    child: const Icon(Icons.bug_report),
    backgroundColor: Colors.red,
    tooltip: 'Test Crash Reporting',
  ),
}
```

---

### الخطوة 7️⃣: التحقق من Sentry Dashboard

1. **افتح** `https://sentry.io/organizations/YOUR_ORG/issues/`
2. **اضغط** زر Test في التطبيق
3. **انتظر** 10-30 ثانية
4. **تحقق** من ظهور Error في Dashboard

**ستشوف**:
- 📊 Error message
- 📍 Stack trace
- 📱 Device info
- ⏰ Timestamp
- 📋 Context data

---

## 📊 كيف تتابع النتائج؟

### في Sentry Dashboard:

#### 1. Issues Tab
- **كل الأخطاء** مرتبة حسب التكرار
- **Status**: Unresolved / Resolved / Ignored
- **Filters**: بالـ environment, level, etc.

#### 2. Performance Tab
- **أبطأ العمليات** (Transactions)
- **متوسط أوقات الاستجابة**
- **Trends** بمرور الوقت

#### 3. Releases Tab
- **مقارنة** بين إصدارات التطبيق
- **Crash-free rate** لكل إصدار
- **New issues** في كل إصدار

---

## ✅ Checklist للتأكد

بعد التطبيق:

- [ ] DSN موجود في `sentry_config.dart`
- [ ] `error_logger.dart` مُنشأ
- [ ] `main.dart` معدّل مع Sentry init
- [ ] Error boundary widget مضاف (optional)
- [ ] Test button يشتغل
- [ ] Error ظاهر في Sentry dashboard

---

## 🎯 Next Steps

بعد ما يشتغل:

1. **أزل** test button من production
2. **أضف** ErrorLogger في catch blocks الرئيسية:
   - Database operations
   - API calls
   - File operations
   - Navigation errors

3. **راقب** Dashboard أول أسبوع
4. **صلّح** الأخطاء الأكثر تكراراً أولاً

---

## 🆘 مشاكل محتملة

### Problem 1: "DSN is invalid"
**الحل**: تأكد نسخت الـ DSN كامل من Sentry

### Problem 2: "لا تظهر الأخطاء في Dashboard"
**الحل**: 
- تأكد من الإنترنت
- تأكد `sendInDebug = true` للاختبار
- انتظر 30 ثانية

### Problem 3: "Build error"
**الحل**: 
```bash
flutter clean
flutter pub get
flutter build apk
```

---

## 💰 التكلفة

**Plan المجاني**:
- ✅ 5,000 errors/month
- ✅ 10,000 performance units/month
- ✅ 1 GB attachments
- ✅ Unlimited projects

**كافي تماماً للبداية!** 🎉

---

**⏱️ الوقت الإجمالي**: 20-30 دقيقة  
**🎯 النتيجة**: تطبيق production-ready مع crash reporting!
