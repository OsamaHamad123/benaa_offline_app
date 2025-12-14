import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app.dart';
import 'core/utils/unified_logger.dart';
import 'core/providers/providers.dart' as core_providers;
import 'core/services/database_maintenance_service.dart';
import 'core/sync/presentation/providers/sync_providers.dart' as sync_providers;
import 'features/visits/presentation/providers/visit_providers.dart' as visit_providers;
import 'features/search/presentation/providers/search_dependencies.dart' as search_providers;
import 'features/beneficiaries/presentation/providers/beneficiary_dependencies.dart' as beneficiary_providers;
import 'features/dashboard/presentation/providers/activity_providers.dart' as dashboard_providers;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for dashboard caching & recent searches
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Sentry for error tracking (DISABLED)
  // 👉 To enable: Add your Sentry DSN from https://sentry.io
  // Uncomment the code below and replace 'YOUR_SENTRY_DSN_HERE' with actual DSN
  /*
  await SentryFlutter.init((options) {
    options.dsn = 'YOUR_SENTRY_DSN_HERE'; // Get from Sentry project settings
    options.tracesSampleRate = 1.0;
    options.environment = 'production';
    options.enableAutoPerformanceTracing = true;
    options.attachStacktrace = true;
    options.attachScreenshot = true;
    options.beforeSend = (event, hint) {
      // Don't send in debug mode
      if (const bool.fromEnvironment('dart.vm.product', defaultValue: false) == false) {
        return null;
      }
      return event;
    };
  }, appRunner: () => _runApp(sharedPreferences));
  return; // Exit early when Sentry is enabled
  */

  // Run app directly without Sentry
  _runApp(sharedPreferences);
}

void _runApp(SharedPreferences sharedPreferences) {
  runApp(
    ProviderScope(
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
    UnifiedLogger.warning('Database maintenance failed: $e');
    // Report to Sentry
    await Sentry.captureException(e, stackTrace: stackTrace);
  }
}
