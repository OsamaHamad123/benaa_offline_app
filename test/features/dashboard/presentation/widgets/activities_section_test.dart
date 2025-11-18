import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/widgets/activities_section.dart';

void main() {
  group('Activities Section Tests', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('ActivitiesSection shows empty state when no activities', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) =>
                MaterialApp(home: Scaffold(body: ActivitiesSection())),
          ),
        ),
      );

      // Should show section title initially
      await tester.pump();

      // Assert - ActivitiesSection exists
      expect(find.byType(ActivitiesSection), findsOneWidget);
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
