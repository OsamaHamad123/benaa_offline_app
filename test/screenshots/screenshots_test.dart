// Portfolio screenshots of real app pages, rendered with fictional data.
//
// Skipped in the normal `flutter test` run (see dart_test.yaml). Regenerate:
//   flutter test --run-skipped --tags screenshots test/screenshots/
//   python3 test/screenshots/postprocess.py   # optimise + overview.png
@Tags(['screenshots'])
library;

import 'package:benaa_offline_app/core/providers/providers.dart' as core;
import 'package:benaa_offline_app/core/settings/settings_provider.dart'
    as settings;
import 'package:benaa_offline_app/core/sync/presentation/providers/sync_providers.dart'
    as sync;
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/beneficiary_dependencies.dart'
    as beneficiaries;
import 'package:benaa_offline_app/features/dashboard/presentation/providers/activity_providers.dart'
    as activities;
import 'package:benaa_offline_app/features/search/presentation/providers/search_dependencies.dart'
    as search;
import 'package:benaa_offline_app/features/visits/presentation/providers/visit_providers.dart'
    as visits;
import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/beneficiaries_list_page_v2.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/beneficiary_details_page_v2.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/pages/all_activities_page_m3.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_data.dart';
import 'harness.dart';

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  setUpAll(() async {
    await setUpScreenshotEnvironment();
  });

  tearDownAll(() async {
    await tearDownScreenshotEnvironment();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'welcome_banner_shown': true});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase(NativeDatabase.memory());
    await seedFakeData(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> shoot(
    WidgetTester tester,
    String name,
    Widget page, {
    Future<void> Function(WidgetTester tester)? before,
  }) async {
    // flutter_test replaces elevation shadows with black outlines by default.
    debugDisableShadows = false;
    usePhoneView(tester);
    installPlatformMocks(tester);
    await tester.pumpWidget(screenshotApp(
      // Same wiring as lib/main.dart, with the in-memory database.
      overrides: [
        core.databaseProvider.overrideWithValue(db),
        core.sharedPreferencesProvider.overrideWith((ref) => prefs),
        settings.sharedPreferencesProvider.overrideWith((ref) => prefs),
        sync.databaseProvider.overrideWithValue(db),
        visits.databaseProvider.overrideWithValue(db),
        beneficiaries.databaseProvider.overrideWithValue(db),
        activities.dashboardDatabaseProvider.overrideWithValue(db),
        search.sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      home: page,
    ));
    await settle(tester);
    if (before != null) {
      await before(tester);
      await settle(tester, rounds: 6);
    }
    await capture(tester, name);
    // Tear the tree down and flush keep-alive / refresh timers.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(minutes: 5));
    debugDisableShadows = true;
  }

  /// Scrolls the vertical list so [finder] sits at the top of the viewport,
  /// then [extra] logical pixels further (negative scrolls back up).
  Future<void> Function(WidgetTester) scrollTo(Finder finder,
      {double extra = 0}) {
    return (tester) async {
      final vertical = find.byWidgetPredicate((w) =>
          w is Scrollable && axisDirectionToAxis(w.axisDirection) == Axis.vertical);
      await tester.scrollUntilVisible(finder, 300, scrollable: vertical.first);
      await tester.pump();
      final target = tester.element(finder);
      await Scrollable.ensureVisible(target);
      if (extra != 0) {
        final position =
            tester.state<ScrollableState>(vertical.first).position;
        position.jumpTo((position.pixels + extra)
            .clamp(position.minScrollExtent, position.maxScrollExtent));
      }
      await tester.pump();
    };
  }

  testWidgets('dashboard', (tester) async {
    await shoot(tester, '01_dashboard', const DashboardPage());
  });

  testWidgets('dashboard insights', (tester) async {
    await shoot(tester, '02_dashboard_insights', const DashboardPage(),
        before: scrollTo(find.text('الإحصائيات التفاعلية'), extra: -24));
  });

  testWidgets('beneficiaries list', (tester) async {
    await shoot(tester, '03_beneficiaries', const BeneficiariesListPageV2());
  });

  // Scrolled to the attachments + visit timeline: the top of this page shows
  // an identity-number row, which the screenshots deliberately leave out.
  testWidgets('beneficiary file', (tester) async {
    await shoot(
      tester,
      '04_beneficiary_visits',
      const BeneficiaryDetailsPageV2(beneficiaryId: '2'),
      before: scrollTo(find.text('سجل الزيارات')),
    );
  });

  testWidgets('activity log', (tester) async {
    // Opened from the dashboard ("عرض الكل"), as in the app, so the shared
    // dashboard state is already loaded when the page first builds.
    await shoot(tester, '05_activity_log', const DashboardPage(),
        before: (tester) async {
      Navigator.of(tester.element(find.byType(DashboardPage))).push(
          MaterialPageRoute<void>(builder: (_) => const AllActivitiesPageM3()));
      await tester.pumpAndSettle();
    });
  });
}
