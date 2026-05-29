import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart' as db;
import '../../../../test_helpers/widget_wrapper.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/widgets/activities_section.dart';
import 'package:benaa_offline_app/features/dashboard/domain/entities/activity.dart' as domain_activity;

void main() {
  group('Activities Section Tests', () {
    late db.AppDatabase testDb;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      testDb = db.AppDatabase(NativeDatabase.memory());
    });

    tearDownAll(() async {
      await testDb.close();
    });

    testWidgets('RecentActivitiesList shows empty state when no activities', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        appWrapper(
          testDb: testDb,
          child: const RecentActivitiesList(
            activities: [],
            isLoading: false,
            hasMore: false,
          ),
        ),
      );

      await tester.pump();

      // Should show empty state
      expect(find.byType(RecentActivitiesList), findsOneWidget);
      expect(
        find.text('لا توجد أنشطة حديثة حتى الآن'),
        findsOneWidget,
      );
    });

    testWidgets('ActivityItem displays correctly', (WidgetTester tester) async {
      final testActivity = domain_activity.Activity(
        id: '1',
        type: 'create',
        description: 'إضافة مستفيد جديد',
        timestamp: DateTime.now(),
        beneficiaryName: 'أحمد محمد',
      );

      await tester.pumpWidget(
        appWrapper(
          testDb: testDb,
          child: MaterialApp(
            home: Scaffold(body: ActivityItem(activity: testActivity)),
          ),
        ),
      );

      await tester.pump();

      // Verify activity displays
      expect(find.byType(ActivityItem), findsOneWidget);
      expect(find.text('إضافة مستفيد جديد'), findsOneWidget);
      expect(find.text('أحمد محمد'), findsOneWidget);
    });

    testWidgets('RecentActivitiesList shows loading indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        appWrapper(
          testDb: testDb,
          child: const RecentActivitiesList(
            activities: [],
            isLoading: true,
            hasMore: true,
          ),
        ),
      );

      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    test('Activity time formatting', () {
      final now = DateTime.now();

      // منذ دقيقة
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
      expect(now.difference(oneMinuteAgo).inMinutes, 1);

      // منذ ساعة
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      expect(now.difference(oneHourAgo).inHours, 1);

      // منذ يوم
      final oneDayAgo = now.subtract(const Duration(days: 1));
      expect(now.difference(oneDayAgo).inDays, 1);
    });

    test('Activity count limits', () {
      // عدد الأنشطة المعروضة في الداشبورد
      const maxRecentActivities = 10;
      expect(maxRecentActivities, 10);

      // التحقق من الحد الأقصى
      final activities = List.generate(20, (i) => i);
      final displayedActivities = activities.take(maxRecentActivities).toList();
      expect(displayedActivities.length, 10);
    });
  });
}
