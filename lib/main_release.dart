import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app.dart';
import 'core/providers/providers.dart' as core_providers;
import 'core/sync/presentation/providers/sync_providers.dart' as sync_providers;
import 'features/visits/presentation/providers/visit_providers.dart' as visit_providers;
import 'features/search/presentation/providers/search_dependencies.dart' as search_providers;
import 'features/beneficiaries/presentation/providers/beneficiary_dependencies.dart' as beneficiary_providers;
import 'features/dashboard/presentation/providers/activity_providers.dart' as dashboard_providers;
import 'core/config/sentry_config.dart';
import 'core/widgets/error_boundary.dart';
import 'core/widgets/safe_widgets.dart';
import 'core/sync/background_sync_worker.dart';
import 'features/taxonomies/presentation/providers/taxonomy_providers.dart' as taxonomy_providers;

import 'package:benaa_offline_app/core/config/app_config.dart';

/// 🚀 RELEASE MODE ENTRY POINT
/// This is the production entry point with:
/// - Sentry enabled for crash reporting
/// - Performance monitoring (20% sample rate)
/// - No debug features
/// - Optimized for production use
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await BackgroundSyncWorker.initialize();

  // Initialize safe widgets to prevent overflow errors
  FlutterErrorHandler.initialize();

  // Initialize SharedPreferences and AppConfig for synchronous provider access
  final results = await Future.wait([
    SharedPreferences.getInstance(),
    AppConfig.load(),
  ]);

  final sharedPreferences = results[0] as SharedPreferences;
  final appConfig = results[1] as AppConfig;

  // Initialize Sentry for production error tracking
  await SentryFlutter.init(
    (options) {
      options.dsn = SentryConfig.dsn;

      // Force production environment
      options.environment = SentryConfig.prodEnvironment;

      // Performance monitoring (20% sample rate)
      options.tracesSampleRate = SentryConfig.tracesSampleRate;

      // Enable production features
      options.enableAutoSessionTracking = true;
      options.attachStacktrace = true;
      options.attachScreenshot = false; // Privacy
      options.enableAutoNativeBreadcrumbs = true;

      // Release config
      options.debug = false;
      options.diagnosticLevel = SentryLevel.error;

      // Sample rate for errors (100% in production)
      options.sampleRate = 1.0;
    },
    appRunner: () => _runApp(sharedPreferences, appConfig),
  );
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
