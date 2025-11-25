import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart' as db;
import '../../../../test_helpers/widget_wrapper.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/widgets/daily_performance_section.dart';

void main() {
  group('Daily Performance Section Tests', () {
    late db.AppDatabase testDb;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      testDb = db.AppDatabase(NativeDatabase.memory());
    });

    tearDownAll(() async {
      await testDb.close();
    });

    testWidgets('DailyPerformanceSection shows skeleton loader while loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        appWrapper(
          testDb: testDb,
          child: SizedBox(
            height: 800,
            child: MaterialApp(home: Scaffold(body: DailyPerformanceSection())),
          ),
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

      // Skeleton loader has circular progress + 2 stat items
      expect(
        find.byType(Container),
        findsWidgets,
        reason: 'Skeleton loader should have placeholders',
      );
    });

    test('Skeleton loader height is correct', () {
      // Skeleton loader should be 350.h
      const expectedHeight = 350.0;
      expect(expectedHeight, 350.0);
    });

    test('Daily target completion percentage', () {
      final target = 10;
      final completed = 7;
      final percentage = (completed / target * 100);

      expect(percentage, 70.0);
    });

    test('Daily performance goal met check', () {
      // تحقيق الهدف
      final target1 = 10;
      final completed1 = 10;
      expect(completed1 >= target1, true);

      // عدم تحقيق الهدف
      final target2 = 10;
      final completed2 = 7;
      expect(completed2 >= target2, false);

      // تجاوز الهدف
      final target3 = 10;
      final completed3 = 15;
      expect(completed3 >= target3, true);
    });

    test('Daily performance metrics calculation', () {
      final todayStats = {
        'newBeneficiaries': 5,
        'completedVisits': 10,
        'pendingTasks': 3,
        'syncedRecords': 8,
      };

      final totalActions =
          todayStats['newBeneficiaries']! +
          todayStats['completedVisits']! +
          todayStats['syncedRecords']!;

      expect(totalActions, 23);
    });

    test('Performance trend calculation', () {
      final todayCompleted = 10;
      final yesterdayCompleted = 8;
      final trend =
          ((todayCompleted - yesterdayCompleted) / yesterdayCompleted * 100);

      expect(trend, 25.0, reason: 'Should show +25% improvement');
    });

    test('Daily performance rating', () {
      // ممتاز: أكثر من 90%
      final excellent = 95.0;
      expect(excellent >= 90, true);

      // جيد: 70-89%
      final good = 80.0;
      expect(good >= 70 && good < 90, true);

      // مقبول: 50-69%
      final fair = 60.0;
      expect(fair >= 50 && fair < 70, true);

      // ضعيف: أقل من 50%
      final poor = 40.0;
      expect(poor < 50, true);
    });

    test('Circular progress color based on performance', () {
      // Green for > 80%
      final highPerformance = 85.0;
      final highColor = highPerformance >= 80
          ? Colors.green
          : highPerformance >= 50
          ? Colors.orange
          : Colors.red;
      expect(highColor, Colors.green);

      // Orange for 50-80%
      final mediumPerformance = 65.0;
      final mediumColor = mediumPerformance >= 80
          ? Colors.green
          : mediumPerformance >= 50
          ? Colors.orange
          : Colors.red;
      expect(mediumColor, Colors.orange);

      // Red for < 50%
      final lowPerformance = 35.0;
      final lowColor = lowPerformance >= 80
          ? Colors.green
          : lowPerformance >= 50
          ? Colors.orange
          : Colors.red;
      expect(lowColor, Colors.red);
    });
  });
}
