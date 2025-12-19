import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app.dart';
import 'core/providers/providers.dart' as core_providers;
import 'core/services/database_maintenance_service.dart';
import 'core/sync/presentation/providers/sync_providers.dart' as sync_providers;
import 'features/visits/presentation/providers/visit_providers.dart'
    as visit_providers;
import 'features/search/presentation/providers/search_dependencies.dart'
    as search_providers;
import 'features/beneficiaries/presentation/providers/beneficiary_dependencies.dart'
    as beneficiary_providers;
import 'features/dashboard/presentation/providers/activity_providers.dart'
    as dashboard_providers;
import 'core/config/sentry_config.dart';
import 'core/error_handling/error_logger.dart';
import 'core/widgets/error_boundary.dart';
import 'core/widgets/safe_widgets.dart';

/// 🚀 RELEASE MODE ENTRY POINT
/// This is the production entry point with:
/// - Sentry enabled for crash reporting
/// - Performance monitoring (20% sample rate)
/// - No debug features
/// - Optimized for production use
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize safe widgets to prevent overflow errors
  FlutterErrorHandler.initialize();

  // Initialize SharedPreferences for dashboard caching & recent searches
  final sharedPreferences = await SharedPreferences.getInstance();

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
    appRunner: () => _runApp(sharedPreferences),
  );
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
      context: {'operation': 'database_maintenance', 'mode': 'release'},
      hint: 'Background database maintenance failed',
    );
  }
}
