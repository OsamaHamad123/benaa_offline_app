import 'package:benaa_offline_app/core/providers/providers.dart' as core_providers;
import 'package:benaa_offline_app/core/config/app_config.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart' as drift_db;
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/beneficiary_form_page_v3.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/providers/activity_providers.dart'
    as dashboard_providers;
import 'package:benaa_offline_app/features/visits/presentation/providers/visit_providers.dart' as visit_providers;
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/beneficiary_dependencies.dart'
    as beneficiary_providers;
import 'package:benaa_offline_app/core/sync/presentation/providers/sync_providers.dart' as sync_providers;
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy.dart';
import 'package:benaa_offline_app/features/taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BeneficiaryFormPageV3 renders correctly', (WidgetTester tester) async {
    // Create a mock database
    final mockDb = drift_db.AppDatabase(NativeDatabase.memory());

    // Build the widget tree with overrides
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Core
          core_providers.appConfigProvider.overrideWith((ref) => const AppConfig(apiBaseUrl: 'http://test')),
          core_providers.sharedPreferencesProvider
              .overrideWith((ref) => SharedPreferences.setMockInitialValues({}) as dynamic),
          core_providers.databaseProvider.overrideWith((ref) => mockDb),

          // Feature specific database overrides
          dashboard_providers.dashboardDatabaseProvider.overrideWith((ref) => mockDb),
          visit_providers.databaseProvider.overrideWith((ref) => mockDb),
          beneficiary_providers.databaseProvider.overrideWith((ref) => mockDb),
          sync_providers.databaseProvider.overrideWith((ref) => mockDb),

          // Sync API overrides
          sync_providers.apiClientProvider.overrideWith((ref) => ref.watch(core_providers.apiClientProvider)),

          // Avoid drift-backed taxonomy stream timers in widget tests.
          bridgeTaxonomiesByGroupProvider.overrideWith(
            (ref, group) => Stream.value(const <Taxonomy>[]),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return const MaterialApp(
              home: BeneficiaryFormPageV3(),
            );
          },
        ),
      ),
    );

    // Allow animations and async operations to complete
    // We explicitly pump to handle the timers (tour guide, auto-save checks)
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify that the form is present
    expect(find.byType(BeneficiaryFormPageV3), findsOneWidget);

    // Explicitly unmount to avoid pending timer assertions from providers/streams.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(seconds: 1));

    await mockDb.close();
  });
}
