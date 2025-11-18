import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for dashboard caching & recent searches
  final sharedPreferences = await SharedPreferences.getInstance();

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
        // Override SharedPreferences for search feature (recent searches)
        search_providers.sharedPreferencesProvider.overrideWithValue(
          sharedPreferences,
        ),
      ],
      child: const BenaaApp(),
    ),
  );

  // Performance: Run database maintenance in background
  _performDatabaseMaintenance(sharedPreferences);
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
  } catch (e) {
    debugPrint('⚠️ Database maintenance failed: $e');
  }
}
