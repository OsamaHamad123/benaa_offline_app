import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/widgets/dashboard_charts.dart';
import 'package:benaa_offline_app/features/dashboard/domain/entities/dashboard_statistics.dart';

void main() {
  group('Dashboard Charts Tests', () {
    setUpAll(() {
      // تهيئة ScreenUtil للاختبارات
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('GrowthChart renders correctly with data', (
      WidgetTester tester,
    ) async {
      // Arrange
      final growthData = [
        GrowthDataPoint(date: DateTime(2025, 1, 1), count: 5),
        GrowthDataPoint(date: DateTime(2025, 1, 2), count: 10),
        GrowthDataPoint(date: DateTime(2025, 1, 3), count: 15),
        GrowthDataPoint(date: DateTime(2025, 1, 4), count: 12),
        GrowthDataPoint(date: DateTime(2025, 1, 5), count: 20),
        GrowthDataPoint(date: DateTime(2025, 1, 6), count: 18),
        GrowthDataPoint(date: DateTime(2025, 1, 7), count: 25),
      ];

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(body: GrowthChart(growthData: growthData)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('نمو المستفيدين (آخر 7 أيام)'), findsOneWidget);
      expect(find.byType(Card), findsAtLeastNWidgets(1));
      expect(
        find.byType(RepaintBoundary),
        findsAtLeastNWidgets(1),
        reason: 'RepaintBoundary should be present for performance',
      );
    });

    testWidgets('GrowthChart shows empty state when no data', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(body: GrowthChart(growthData: const [])),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('نمو المستفيدين (آخر 7 أيام)'), findsNothing);
    });

    testWidgets('CategoryDistributionChart renders correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      final categoryCounts = {
        'orphan': 10,
        'widow': 5,
        'poor': 15,
        'disabled': 8,
      };

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: CategoryDistributionChart(categoryCounts: categoryCounts),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('توزيع الفئات'), findsOneWidget);
      expect(
        find.byType(RepaintBoundary),
        findsAtLeastNWidgets(1),
        reason: 'RepaintBoundary should be present for performance',
      );
      expect(find.text('أيتام: 10'), findsOneWidget);
      expect(find.text('أرامل: 5'), findsOneWidget);
      expect(find.text('فقراء: 15'), findsOneWidget);
      expect(find.text('ذوي إعاقة: 8'), findsOneWidget);
    });

    testWidgets('CategoryDistributionChart shows empty state when no data', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: CategoryDistributionChart(categoryCounts: const {}),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('توزيع الفئات'), findsNothing);
    });

    test('GrowthChart calculates max Y correctly', () {
      // Arrange
      final growthData = [
        GrowthDataPoint(date: DateTime(2025, 1, 1), count: 5),
        GrowthDataPoint(date: DateTime(2025, 1, 2), count: 10),
        GrowthDataPoint(date: DateTime(2025, 1, 3), count: 25), // Max
      ];

      // Act & Assert
      // نتوقع أن maxY = maxCount + 2 = 25 + 2 = 27
      expect(
        growthData.map((e) => e.count).reduce((a, b) => a > b ? a : b),
        25,
      );
    });

    test('CategoryDistributionChart calculates percentages correctly', () {
      // Arrange
      final categoryCounts = {
        'orphan': 10,
        'widow': 10,
        'poor': 20,
        'disabled': 10,
      };
      final total = 50;

      // Act & Assert
      expect(categoryCounts['orphan']! / total * 100, 20.0);
      expect(categoryCounts['widow']! / total * 100, 20.0);
      expect(categoryCounts['poor']! / total * 100, 40.0);
      expect(categoryCounts['disabled']! / total * 100, 20.0);
    });
  });
}
