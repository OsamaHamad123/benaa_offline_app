import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: unused_import
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app.dart';
import 'core/providers/providers.dart' as core_providers;
import 'core/widgets/safe_widgets.dart';
import 'core/services/database_maintenance_service.dart';
import 'core/sync/presentation/providers/sync_providers.dart' as sync_providers;
import 'features/visits/presentation/providers/visit_providers.dart' as visit_providers;
import 'features/search/presentation/providers/search_dependencies.dart' as search_providers;
import 'features/beneficiaries/presentation/providers/beneficiary_dependencies.dart' as beneficiary_providers;
import 'features/dashboard/presentation/providers/activity_providers.dart' as dashboard_providers;
import 'core/config/sentry_config.dart';
import 'core/error_handling/error_logger.dart';
import 'core/widgets/error_boundary.dart';

/// 🐛 DEBUG MODE ENTRY POINT
/// This is the development entry point with:
/// - Sentry enabled in debug mode (sendInDebug = true)
/// - Debug logging enabled
/// - Test page accessible via Developer Mode
/// - Full error stack traces
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تطبيق ميداني يعمل أوفلاين: في نسخة الإصدار لا نحاول جلب خط Cairo من الشبكة
  // (كان الجهاز الميداني بلا إنترنت يفشل صامتاً في تحميل الخط عند أول تشغيل).
  // ⚠️ لإظهار خط Cairo فعلاً أوفلاين: ضع ملفات Cairo-*.ttf في assets/fonts/
  // وأعلِنها في قسم fonts داخل pubspec.yaml. بدون ذلك يُستخدم الخط الاحتياطي.
  if (kReleaseMode) {
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  // Initialize safe widgets to prevent overflow errors
  FlutterErrorHandler.initialize();

  // Initialize SharedPreferences for dashboard caching & recent searches
  final sharedPreferences = await SharedPreferences.getInstance();

  // ⚠️ SENTRY TEMPORARILY DISABLED FOR DEBUGGING
  // Initialize Sentry for debug error tracking
  // await SentryFlutter.init(
  //   (options) {
  //     options.dsn = SentryConfig.dsn;

  //     // Environment
  //     options.environment = kReleaseMode
  //         ? SentryConfig.prodEnvironment
  //         : SentryConfig.devEnvironment;

  //     // Performance monitoring (20% sample rate)
  //     options.tracesSampleRate = SentryConfig.tracesSampleRate;

  //     // Enable features
  //     options.enableAutoSessionTracking = true;
  //     options.attachStacktrace = true;
  //     options.attachScreenshot = true; // Debug: capture screenshots

  //     // Always send in debug mode (for testing)
  //     options.beforeSend = (event, hint) {
  //       if (kDebugMode && !SentryConfig.sendInDebug) {
  //         debugPrint('🐛 Sentry event blocked in debug: ${event.message}');
  //         return null; // Don't send
  //       }
  //       return event;
  //     };

  //     // Debug config
  //     options.debug = true;
  //     options.diagnosticLevel = SentryLevel.debug;
  //   },
  //   appRunner: () => _runApp(sharedPreferences),
  // );

  // Run app directly without Sentry
  _runApp(sharedPreferences);
}

void _runApp(SharedPreferences sharedPreferences) {
  runApp(
    ErrorBoundary(
      child: ProviderScope(
        overrides: [
          // Override Sync infrastructure providers
          sync_providers.databaseProvider.overrideWith(
            (ref) => ref.watch(core_providers.databaseProvider),
          ),
          sync_providers.apiClientProvider.overrideWith(
            (ref) => ref.watch(core_providers.apiClientProvider),
          ),

          // Override database provider for visits feature
          visit_providers.databaseProvider.overrideWith(
            (ref) => ref.watch(core_providers.databaseProvider),
          ),
          // Override database provider for beneficiaries feature
          beneficiary_providers.databaseProvider.overrideWith(
            (ref) => ref.watch(core_providers.databaseProvider),
          ),
          // Override database provider for dashboard/activities feature
          dashboard_providers.dashboardDatabaseProvider.overrideWith(
            (ref) => ref.watch(core_providers.databaseProvider),
          ),
          // Override SharedPreferences for search feature (recent searches)
          search_providers.sharedPreferencesProvider.overrideWithValue(
            sharedPreferences,
          ),
        ],
        child: const BenaaApp(),
      ),
    ),
  );

  // Performance: Run database maintenance in background (after UI is ready)
  Future.delayed(const Duration(seconds: 2), () {
    _performDatabaseMaintenance(sharedPreferences);
  });
}

/// Perform database maintenance in background
Future<void> _performDatabaseMaintenance(SharedPreferences prefs) async {
  try {
    final container = ProviderContainer();
    final database = container.read(core_providers.databaseProvider);
    final maintenanceService = DatabaseMaintenanceService(
      database: database,
      prefs: prefs,
    );
    await maintenanceService.performMaintenanceIfNeeded();
    container.dispose();
  } catch (e, stackTrace) {
    await ErrorLogger.logError(
      e,
      stackTrace,
      context: {'operation': 'database_maintenance', 'mode': 'debug'},
      hint: 'Background database maintenance failed',
    );
  }
}
