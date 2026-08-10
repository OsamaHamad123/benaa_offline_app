import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:benaa_offline_app/features/kafalat/presentation/widgets/stats/stats_dashboard_widget.dart';

void main() {
  group('StatsDashboardWidget Tests', () {
    testWidgets('should display all stat cards correctly', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsDashboardWidget(
              total: 150,
              active: 100,
              paused: 30,
              ended: 20,
            ),
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
        MaterialApp(
          home: Scaffold(
            body: StatsDashboardWidget(
              total: 100,
              active: 80,
              paused: 15,
              ended: 5,
              totalAmount: 5000000,
              currency: 'IQD',
            ),
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
        MaterialApp(
          home: Scaffold(
            body: StatsDashboardWidget(
              total: 100,
              active: 80,
              paused: 15,
              ended: 5,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('إجمالي المبالغ الشهرية'), findsNothing);
    });

    testWidgets('should calculate active percentage correctly', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsDashboardWidget(
              total: 100,
              active: 75,
              paused: 15,
              ended: 10,
              totalAmount: 1000000,
            ),
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
        MaterialApp(
          home: Scaffold(
            body: StatsDashboardWidget(
              total: 0,
              active: 0,
              paused: 0,
              ended: 0,
              totalAmount: 0,
            ),
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
        MaterialApp(
          home: Scaffold(
            body: StatsDashboardWidget(
              total: 200,
              active: 100,
              paused: 60,
              ended: 40,
              totalAmount: 2500000,
            ),
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
      // Arrange
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1200,
              child: StatsDashboardWidget(
                total: 150,
                active: 100,
                paused: 30,
                ended: 20,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(GridView), findsOneWidget);

      // Reset
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should render grid with 2 columns on mobile', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: StatsDashboardWidget(
                total: 150,
                active: 100,
                paused: 30,
                ended: 20,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(GridView), findsOneWidget);

      // Reset
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should display header with correct icon and title', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsDashboardWidget(
              total: 100,
              active: 80,
              paused: 15,
              ended: 5,
            ),
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
        MaterialApp(
          home: Scaffold(
            body: StatsDashboardWidget(
              total: 100,
              active: 80,
              paused: 15,
              ended: 5,
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(StatsDashboardWidget),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('should format large amounts correctly', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsDashboardWidget(
              total: 100,
              active: 80,
              paused: 15,
              ended: 5,
              totalAmount: 12345678.90,
              currency: 'IQD',
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('12345679'), findsOneWidget); // Rounded to nearest integer
    });
  });
}
