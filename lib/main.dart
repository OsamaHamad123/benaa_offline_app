import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/providers/providers.dart' as core_providers;
import 'features/dashboard/presentation/providers.dart';
import 'features/visits/presentation/providers/visit_providers.dart'
    as visit_providers;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for dashboard caching
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        // Override database provider for visits feature
        visit_providers.databaseProvider.overrideWith(
          (ref) => ref.watch(core_providers.databaseProvider),
        ),
      ],
      child: const BenaaApp(),
    ),
  );
}
