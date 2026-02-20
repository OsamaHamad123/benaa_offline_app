import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'app.dart';
import 'core/providers/providers.dart' as core_providers;
import 'core/widgets/safe_widgets.dart';
import 'core/sync/presentation/providers/sync_providers.dart' as sync_providers;
import 'features/visits/presentation/providers/visit_providers.dart' as visit_providers;
import 'features/search/presentation/providers/search_dependencies.dart' as search_providers;
import 'features/beneficiaries/presentation/providers/beneficiary_dependencies.dart' as beneficiary_providers;
import 'features/dashboard/presentation/providers/activity_providers.dart' as dashboard_providers;
import 'features/taxonomies/presentation/providers/taxonomy_providers.dart' as taxonomy_providers;
import 'core/widgets/error_boundary.dart';
import 'core/storage/secure_storage.dart';

import 'package:benaa_offline_app/core/config/app_config.dart';

/// 🐛 DEBUG MODE ENTRY POINT
/// This is the development entry point with:
/// - Sentry enabled in debug mode (sendInDebug = true)
/// - Debug logging enabled
/// - Test page accessible via Developer Mode
/// - Full error stack traces
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize safe widgets to prevent overflow errors
  FlutterErrorHandler.initialize();

  // Initialize SharedPreferences and AppConfig for synchronous provider access
  final results = await Future.wait([
    SharedPreferences.getInstance(),
    AppConfig.load(),
  ]);

  final sharedPreferences = results[0] as SharedPreferences;
  final appConfig = results[1] as AppConfig;

  // 🌐 Initialize Dio for API calls (with auth interceptor)
  final dio = await _createAuthenticatedDio();

  // Run app directly
  _runApp(sharedPreferences, appConfig, dio);
}

/// 🔑 Create authenticated Dio instance with auth interceptor
Future<Dio> _createAuthenticatedDio() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://palestine.benaadev.org',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json'},
  ));

  // Auth interceptor - adds Bearer token to all requests
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await SecureStorage().getAuthToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (error, handler) {
      if (error.response?.statusCode == 401) {
        debugPrint('🔐 Token expired or invalid');
      }
      return handler.next(error);
    },
  ));

  return dio;
}

void _runApp(SharedPreferences sharedPreferences, AppConfig appConfig, Dio dio) {
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
          taxonomy_providers.taxonomyDioProvider.overrideWithValue(dio),
        ],
        child: const BenaaApp(),
      ),
    ),
  );

  // Performance: Run database maintenance is now handled by DatabaseMaintenanceManager in app.dart
}
