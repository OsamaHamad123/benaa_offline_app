import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/providers/providers.dart' as core_providers;
import 'core/services/database_maintenance_service.dart';
import 'features/visits/presentation/providers/visit_providers.dart'
    as visit_providers;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for dashboard caching
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override database provider for visits feature
        visit_providers.databaseProvider.overrideWith(
          (ref) => ref.watch(core_providers.databaseProvider),
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
    print('⚠️ Database maintenance failed: $e');
  }
}
