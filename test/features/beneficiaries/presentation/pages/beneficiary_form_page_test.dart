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

Future<void> _pumpFormPage(
  WidgetTester tester, {
  required drift_db.AppDatabase mockDb,
  required List<Taxonomy> Function(Object? group) taxonomyBuilder,
}) async {
  SharedPreferences.setMockInitialValues({});

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
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

Future<void> _teardownFormPage(WidgetTester tester, drift_db.AppDatabase mockDb) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump(const Duration(seconds: 1));
  await mockDb.close();
}

Future<void> _animateToTab(WidgetTester tester, int index) async {
  final tabBar = tester.widget<TabBar>(find.byType(TabBar));
  final controller = tabBar.controller;
  expect(controller, isNotNull);

  controller!.animateTo(index);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BeneficiaryFormPageV3 opens with missing taxonomy groups', (WidgetTester tester) async {
    final mockDb = drift_db.AppDatabase(NativeDatabase.memory());

    await _pumpFormPage(
      tester,
      mockDb: mockDb,
      taxonomyBuilder: (_) => const <Taxonomy>[],
    );

    expect(find.byType(BeneficiaryFormPageV3), findsOneWidget);

    await _teardownFormPage(tester, mockDb);
  });

  testWidgets('BeneficiaryFormPageV3 opens with unexpected taxonomy codes', (WidgetTester tester) async {
    final mockDb = drift_db.AppDatabase(NativeDatabase.memory());

    await _pumpFormPage(
      tester,
      mockDb: mockDb,
      taxonomyBuilder: (group) {
        final dynamic dynamicGroup = group;
        return [
          Taxonomy(
            id: '${dynamicGroup?.value}_unknown',
            group: dynamicGroup,
            code: 'unexpected_code',
            label: 'قيمة غير متوقعة',
            createdAt: DateTime(2026, 1),
            updatedAt: DateTime(2026, 1),
          ),
        ];
      },
    );

    expect(find.byType(BeneficiaryFormPageV3), findsOneWidget);

    await _teardownFormPage(tester, mockDb);
  });

  testWidgets('BeneficiaryFormPageV3 updates content when navigating back from review tab',
      (WidgetTester tester) async {
    final mockDb = drift_db.AppDatabase(NativeDatabase.memory());
    const reviewHeader = 'مراجعة جميع المعلومات المدخلة';

    await _pumpFormPage(
      tester,
      mockDb: mockDb,
      taxonomyBuilder: (_) => const <Taxonomy>[],
    );

    // Go to review tab by tab bar controller (same path used by tab indicator)
    await _animateToTab(tester, 4);

    expect(find.text(reviewHeader), findsOneWidget);

    // Go back to personal tab and ensure review content is gone
    await _animateToTab(tester, 0);

    expect(find.text(reviewHeader), findsNothing);

    // Navigate forward again
    await _animateToTab(tester, 4);

    expect(find.text(reviewHeader), findsOneWidget);

    // Navigate back and ensure tab view updates
    await _animateToTab(tester, 3);

    expect(find.text(reviewHeader), findsNothing);

    await _teardownFormPage(tester, mockDb);
  });
}
