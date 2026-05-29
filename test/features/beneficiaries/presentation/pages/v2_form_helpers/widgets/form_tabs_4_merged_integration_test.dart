import 'package:benaa_offline_app/core/config/app_config.dart';
import 'package:benaa_offline_app/core/providers/providers.dart' as core_providers;
import 'package:benaa_offline_app/core/sync/presentation/providers/sync_providers.dart' as sync_providers;
import 'package:benaa_offline_app/data/db/drift_database.dart' as drift_db;
import 'package:benaa_offline_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_constants.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/widgets/form_tabs_4_merged.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/widgets/tab_completion_badge.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildHarness({
    required TabController controller,
    required BeneficiaryFormControllers formControllers,
    required FocusNode firstFieldFocusNode,
    required drift_db.AppDatabase mockDb,
  }) {
    return ProviderScope(
      overrides: [
        core_providers.appConfigProvider.overrideWith((ref) => const AppConfig(apiBaseUrl: 'http://test')),
        core_providers.databaseProvider.overrideWith((ref) => mockDb),
        dashboard_providers.dashboardDatabaseProvider.overrideWith((ref) => mockDb),
        visit_providers.databaseProvider.overrideWith((ref) => mockDb),
        beneficiary_providers.databaseProvider.overrideWith((ref) => mockDb),
        sync_providers.databaseProvider.overrideWith((ref) => mockDb),
        sync_providers.apiClientProvider.overrideWith((ref) => ref.watch(core_providers.apiClientProvider)),
        // Prevent TaxonomyBridgeDropdown realtime-sync from reaching Firebase
        isAuthenticatedProvider.overrideWith((ref) => false),
        bridgeTaxonomiesByGroupProvider.overrideWith(
          (ref, group) => Stream.value(const <Taxonomy>[]),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: BeneficiaryFormTabs4Merged(
              controller: controller,
              formControllers: formControllers,
              onBirthDateTap: () {},
              firstFieldFocusNode: firstFieldFocusNode,
              beneficiaryId: null,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('loads first tab immediately and switches tab via controller animation', (tester) async {
    final tabController = TabController(
      length: FormConstants.totalTabs,
      vsync: const TestVSync(),
    );
    final formControllers = BeneficiaryFormControllers();
    final firstFieldFocusNode = FocusNode();
    final mockDb = drift_db.AppDatabase(NativeDatabase.memory());

    addTearDown(tabController.dispose);
    addTearDown(formControllers.dispose);
    addTearDown(firstFieldFocusNode.dispose);
    addTearDown(mockDb.close);

    await tester.pumpWidget(
      buildHarness(
        controller: tabController,
        formControllers: formControllers,
        firstFieldFocusNode: firstFieldFocusNode,
        mockDb: mockDb,
      ),
    );

    expect(find.byKey(const ValueKey('personal_info_merged_tab')), findsOneWidget);
    expect(find.byKey(const ValueKey('family_merged_tab')), findsNothing);

    tabController.animateTo(1);
    await tester.pumpAndSettle();

    expect(tabController.index, 1);
    expect(find.byKey(const ValueKey('family_merged_tab')), findsOneWidget);
  });

  testWidgets('tab headers do not overflow on constrained layout', (tester) async {
    final tabController = TabController(
      length: FormConstants.totalTabs,
      vsync: const TestVSync(),
    );

    addTearDown(tabController.dispose);

    tester.view.physicalSize = const Size(320, 520);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: BeneficiaryFormTabBar4(
              controller: tabController,
              currentIndex: tabController.index,
              tabStats: const <int, TabCompletionStats>{
                0: TabCompletionStats(completedFields: 2, totalFields: 5, progress: 0.40),
                1: TabCompletionStats(completedFields: 1, totalFields: 4, progress: 0.25),
                2: TabCompletionStats(completedFields: 3, totalFields: 4, progress: 0.75),
                3: TabCompletionStats(completedFields: 0, totalFields: 2, progress: 0.0),
                4: TabCompletionStats(completedFields: 0, totalFields: 1, progress: 0.0),
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('المراجعة').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
