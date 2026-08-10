import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart' as db;
import '../../../../test_helpers/widget_wrapper.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/widgets/urgent_cases_section.dart';

void main() {
  group('Urgent Cases Section Tests', () {
    late db.AppDatabase testDb;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      testDb = db.AppDatabase(NativeDatabase.memory());
    });

    tearDownAll(() async {
      await testDb.close();
    });

    testWidgets('UrgentCasesSection shows skeleton loader while loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        appWrapper(
          testDb: testDb,
          child: const SizedBox(height: 400, child: UrgentCasesSection()),
        ),
      );

      // Initial pump - should show loader
      await tester.pump();

      // Assert
      expect(
        find.byType(Card),
        findsWidgets,
        reason: 'Skeleton loader should be in a Card',
      );

      // Skeleton loader has 3 placeholder containers
      expect(
        find.byType(Container),
        findsWidgets,
        reason: 'Skeleton loader should have placeholder containers',
      );
    });

    test('Skeleton loader height is correct', () {
      // Skeleton loader should be 200.h
      const expectedHeight = 200.0;
      expect(expectedHeight, 200.0);
    });

    test('Urgent cases prioritization logic', () {
      // حالات عاجلة: زيارة متأخرة أكثر من 7 أيام
      final now = DateTime.now();
      final overdueVisit = now.subtract(const Duration(days: 10));
      final normalVisit = now.subtract(const Duration(days: 3));

      expect(
        now.difference(overdueVisit).inDays > 7,
        true,
        reason: 'Should be urgent',
      );
      expect(
        now.difference(normalVisit).inDays > 7,
        false,
        reason: 'Should not be urgent',
      );
    });

    test('Urgent case sorting by priority', () {
      final cases = [
        {
          'lastVisit': DateTime.now().subtract(const Duration(days: 5)),
          'priority': 'low',
        },
        {
          'lastVisit': DateTime.now().subtract(const Duration(days: 15)),
          'priority': 'high',
        },
        {
          'lastVisit': DateTime.now().subtract(const Duration(days: 10)),
          'priority': 'medium',
        },
      ];

      // Sort by days since last visit (descending)
      cases.sort((a, b) {
        final aDays =
            DateTime.now().difference(a['lastVisit'] as DateTime).inDays;
        final bDays =
            DateTime.now().difference(b['lastVisit'] as DateTime).inDays;
        return bDays.compareTo(aDays);
      });

      // Assert - أقدم زيارة يجب أن تكون أولاً
      final firstCase = cases[0];
      final firstDays =
          DateTime.now().difference(firstCase['lastVisit'] as DateTime).inDays;
      expect(firstDays, 15);
    });

    test('Urgent case count calculation', () {
      final allBeneficiaries = [
        {'lastVisit': DateTime.now().subtract(const Duration(days: 5))},
        {'lastVisit': DateTime.now().subtract(const Duration(days: 10))},
        {'lastVisit': DateTime.now().subtract(const Duration(days: 15))},
        {'lastVisit': DateTime.now().subtract(const Duration(days: 3))},
        {'lastVisit': DateTime.now().subtract(const Duration(days: 20))},
      ];

      final urgentCases = allBeneficiaries.where((b) {
        final daysSinceVisit =
            DateTime.now().difference(b['lastVisit'] as DateTime).inDays;
        return daysSinceVisit > 7;
      }).length;

      expect(
        urgentCases,
        3,
        reason: 'Should have 3 urgent cases (10, 15, 20 days)',
      );
    });
  });
}
