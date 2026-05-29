import 'package:benaa_offline_app/core/config/app_config.dart';
import 'package:benaa_offline_app/core/providers/providers.dart' as core_providers;
import 'package:benaa_offline_app/core/sync/presentation/providers/sync_providers.dart' as sync_providers;
import 'package:benaa_offline_app/data/db/drift_database.dart' as drift_db;
import 'package:benaa_offline_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/beneficiary_form_page_v3.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/beneficiary_dependencies.dart'
    as beneficiary_providers;
import 'package:benaa_offline_app/features/dashboard/presentation/providers/activity_providers.dart'
    as dashboard_providers;
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy.dart';
import 'package:benaa_offline_app/features/taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import 'package:benaa_offline_app/features/visits/presentation/providers/visit_providers.dart' as visit_providers;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpFormPage(WidgetTester tester, drift_db.AppDatabase mockDb) async {
  SharedPreferences.setMockInitialValues({});

  List<Taxonomy> taxonomyBuilder(Object? group) {
    final dynamic dynamicGroup = group;
    return [
      Taxonomy(
        id: '${dynamicGroup?.value ?? 'unknown'}_default',
        group: dynamicGroup,
        code: 'default_code',
        label: 'Default',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    ];
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        core_providers.appConfigProvider.overrideWith((ref) => const AppConfig(apiBaseUrl: 'http://test')),
        core_providers.sharedPreferencesProvider.overrideWith((ref) async => SharedPreferences.getInstance()),
        core_providers.databaseProvider.overrideWith((ref) => mockDb),
        dashboard_providers.dashboardDatabaseProvider.overrideWith((ref) => mockDb),
        visit_providers.databaseProvider.overrideWith((ref) => mockDb),
        beneficiary_providers.databaseProvider.overrideWith((ref) => mockDb),
        sync_providers.databaseProvider.overrideWith((ref) => mockDb),
        sync_providers.apiClientProvider.overrideWith((ref) => ref.watch(core_providers.apiClientProvider)),
        // Prevent TaxonomyBridgeDropdown realtime-sync from reaching Firebase
        isAuthenticatedProvider.overrideWith((ref) => false),
        bridgeTaxonomiesByGroupProvider.overrideWith(
          (ref, group) => Stream.value(taxonomyBuilder(group)),
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

  await tester.pump();
}

Future<void> _teardownFormPage(WidgetTester tester, drift_db.AppDatabase mockDb) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump(const Duration(seconds: 1));
  await mockDb.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Beneficiary form open CI guard', () {
    testWidgets('opens first frame under baseline threshold', (tester) async {
      const baselineFromEnv = int.fromEnvironment('FORM_OPEN_BASELINE_MS', defaultValue: 3000);
      final baselineMs = baselineFromEnv < 300 ? 300 : baselineFromEnv;

      final mockDb = drift_db.AppDatabase(NativeDatabase.memory());
      final stopwatch = Stopwatch()..start();

      await _pumpFormPage(tester, mockDb);

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      expect(find.byType(BeneficiaryFormPageV3), findsOneWidget);
      expect(
        elapsedMs,
        lessThanOrEqualTo(baselineMs),
        reason: 'Beneficiary form first frame took $elapsedMs ms (baseline: $baselineMs ms).',
      );

      await _teardownFormPage(tester, mockDb);
    });
  });
}
