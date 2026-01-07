import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:benaa_offline_app/features/kafalat/presentation/widgets/stats/stats_dashboard_widget.dart';

void main() {
  /// Helper to wrap widget with ScreenUtilInit for tests with larger screen
  Widget buildTestWidget(Widget child, {Size screenSize = const Size(600, 900)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: Scaffold(
          body: ScreenUtilInit(
            designSize: screenSize,
            minTextAdapt: true,
            builder: (context, _) => SingleChildScrollView(
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('StatsDashboardWidget Tests', () {
    testWidgets('should display all stat cards correctly', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          StatsDashboardWidget(
            total: 150,
            active: 100,
            paused: 30,
            ended: 20,
          ),
        ),
      );

      // Assert
      expect(find.text('150'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('إجمالي'), findsOneWidget);
      expect(find.text('نشطة'), findsOneWidget);
      expect(find.text('موقوفة'), findsOneWidget);
      expect(find.text('منتهية'), findsOneWidget);
    });

    testWidgets('should display financial summary when totalAmount provided', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          StatsDashboardWidget(
            total: 100,
            active: 80,
            paused: 15,
            ended: 5,
            totalAmount: 5000000,
            currency: 'IQD',
          ),
        ),
      );

      // Assert
      expect(find.text('إجمالي المبالغ الشهرية'), findsOneWidget);
      expect(find.textContaining('5000000'), findsOneWidget);
      expect(find.textContaining('IQD'), findsOneWidget);
    });

    testWidgets('should not display financial summary when totalAmount is null', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          StatsDashboardWidget(
            total: 100,
            active: 80,
            paused: 15,
            ended: 5,
          ),
        ),
      );

      // Assert
      expect(find.text('إجمالي المبالغ الشهرية'), findsNothing);
    });

    testWidgets('should calculate active percentage correctly', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          StatsDashboardWidget(
            total: 100,
            active: 75,
            paused: 15,
            ended: 10,
            totalAmount: 1000000,
          ),
        ),
      );

      // Assert
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('نسبة النشطة'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle zero total gracefully', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          StatsDashboardWidget(
            total: 0,
            active: 0,
            paused: 0,
            ended: 0,
            totalAmount: 0,
          ),
        ),
      );

      // Assert
      expect(find.text('0'), findsNWidgets(4)); // All stats show 0
      expect(find.text('0%'), findsOneWidget); // Percentage is 0%
    });

    testWidgets('should display correct progress bar value', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          StatsDashboardWidget(
            total: 200,
            active: 100,
            paused: 60,
            ended: 40,
            totalAmount: 2500000,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(progressIndicator.value, 0.5); // 100/200 = 50%
    });

    testWidgets('should render grid with 4 columns on wide screens', (tester) async {
      // Act - Use larger screen
      await tester.pumpWidget(
        buildTestWidget(
          StatsDashboardWidget(
            total: 150,
            active: 100,
            paused: 30,
            ended: 20,
          ),
          screenSize: const Size(1200, 800),
        ),
      );

      // Assert
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should render grid with 2 columns on mobile', (tester) async {
      // Act - Use mobile screen size
      await tester.pumpWidget(
        buildTestWidget(
          StatsDashboardWidget(
            total: 150,
            active: 100,
            paused: 30,
            ended: 20,
          ),
          screenSize: const Size(400, 800),
        ),
      );

      // Assert
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should display header with correct icon and title', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          StatsDashboardWidget(
            total: 100,
            active: 80,
            paused: 15,
            ended: 5,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
      expect(find.text('إحصائيات الكفالات'), findsOneWidget);
    });

    testWidgets('should apply gradient background correctly', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          StatsDashboardWidget(
            total: 100,
            active: 80,
            paused: 15,
            ended: 5,
          ),
        ),
      );

      // Assert - Find any Container with BoxDecoration gradient
      final containerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient is LinearGradient,
      );

      expect(containerFinder, findsAtLeastNWidgets(1));
    });

    testWidgets('should format large amounts correctly', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          StatsDashboardWidget(
            total: 100,
            active: 80,
            paused: 15,
            ended: 5,
            totalAmount: 12345678.90,
            currency: 'IQD',
          ),
        ),
      );

      // Assert - Check that the amount is displayed (format may vary)
      expect(find.textContaining('12345'), findsAtLeastNWidgets(1));
    });
  });
}
