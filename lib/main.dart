import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'core/backend/firebase/firebase_backend.dart';
import 'core/providers/providers.dart' as core_providers;
import 'core/widgets/safe_widgets.dart';
import 'core/sync/presentation/providers/sync_providers.dart' as sync_providers;
import 'core/sync/background_sync_worker.dart';
import 'features/visits/presentation/providers/visit_providers.dart' as visit_providers;
import 'features/search/presentation/providers/search_dependencies.dart' as search_providers;
import 'features/beneficiaries/presentation/providers/beneficiary_dependencies.dart' as beneficiary_providers;
import 'features/dashboard/presentation/providers/activity_providers.dart' as dashboard_providers;
import 'features/taxonomies/presentation/providers/taxonomy_providers.dart' as taxonomy_providers;
import 'core/widgets/error_boundary.dart';

import 'package:benaa_offline_app/core/config/app_config.dart';

/// 🐛 DEBUG MODE ENTRY POINT
/// This is the development entry point with:
/// - Sentry enabled in debug mode (sendInDebug = true)
/// - Debug logging enabled
/// - Test page accessible via Developer Mode
/// - Full error stack traces
Future<void> main() async {
  await runZonedGuarded(() async {
    final startupStopwatch = Stopwatch()..start();

    WidgetsFlutterBinding.ensureInitialized();
    _logStartup('Widgets binding initialized', startupStopwatch);

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _logStartup('Firebase initialized with FlutterFire options', startupStopwatch);
    } catch (error, stackTrace) {
      debugPrint('🔥 [Firebase Init Failed - Debug] $error');
      debugPrint('📍 [Firebase Init Stack]\n$stackTrace');
    }

    await FirebaseBackend.initializeFirebaseAtStartup();
    _logStartup('Firebase startup initialization attempted', startupStopwatch);

    await BackgroundSyncWorker.initialize();
    _logStartup('Background worker initialized', startupStopwatch);

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      final stack = details.stack ?? StackTrace.current;
      debugPrint('❌ [FlutterError] ${details.exceptionAsString()}');
      debugPrint('📍 [FlutterError stack]\n$stack');
      Zone.current.handleUncaughtError(details.exception, stack);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      debugPrint('❌ [PlatformDispatcher] $error');
      debugPrint('📍 [PlatformDispatcher stack]\n$stack');
      return false;
    };

    FlutterErrorHandler.initialize();
    _logStartup('Safe widgets initialized', startupStopwatch);

    final results = await Future.wait([
      SharedPreferences.getInstance(),
      AppConfig.load(),
    ]);
    _logStartup('SharedPreferences + AppConfig loaded', startupStopwatch);

    final sharedPreferences = results[0] as SharedPreferences;
    final appConfig = results[1] as AppConfig;

    _runApp(sharedPreferences, appConfig);
    _logStartup('runApp called', startupStopwatch);
  }, (Object error, StackTrace stack) {
    debugPrint('❌ [Uncaught Zoned Error] $error');
    debugPrint('📍 [Zoned stack]\n$stack');
  });
}

void _logStartup(String message, Stopwatch stopwatch) {
  debugPrint('⏱️ [STARTUP +${stopwatch.elapsedMilliseconds}ms] $message');
}

void _runApp(SharedPreferences sharedPreferences, AppConfig appConfig) {
  runApp(
    ErrorBoundary(
      child: ProviderScope(
        overrides: [
          // Override Core Async Providers with pre-loaded values
          core_providers.sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
          core_providers.appConfigProvider.overrideWith((ref) => appConfig),

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

          // 🏷️ Taxonomy providers (for dynamic categories from server)
          taxonomy_providers.taxonomyDatabaseProvider.overrideWith(
            (ref) => ref.watch(core_providers.databaseProvider),
          ),
          taxonomy_providers.taxonomyDioProvider.overrideWith(
            (ref) => ref.watch(core_providers.apiClientProvider).dio,
          ),
        ],
        child: const BenaaApp(),
      ),
    ),
  );

  // Performance: Run database maintenance is now handled by DatabaseMaintenanceManager in app.dart
}
