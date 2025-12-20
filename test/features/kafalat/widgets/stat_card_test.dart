import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:benaa_offline_app/features/kafalat/presentation/widgets/stats/stat_card.dart';
import 'test_helpers.dart';

void main() {
  group('StatCard Widget Tests', () {
    testWidgets('should display icon, value, and label correctly', (tester) async {
      // Arrange
      const testIcon = Icons.handshake_rounded;
      const testLabel = 'إجمالي';
      const testValue = '150';
      const testColor = Colors.blue;

      // Act
      await pumpTestWidget(
        tester,
        StatCard(
          icon: testIcon,
          label: testLabel,
          value: testValue,
          color: testColor,
        ),
      );

      // Assert
      expect(find.byIcon(testIcon), findsOneWidget);
      expect(find.text(testValue), findsOneWidget);
      expect(find.text(testLabel), findsOneWidget);
    });

    testWidgets('should handle tap callback when provided', (tester) async {
      // Arrange
      var tapped = false;
      void onTap() => tapped = true;

      // Act
      await pumpTestWidget(
        tester,
        StatCard(
          icon: Icons.check_circle_rounded,
          label: 'نشطة',
          value: '50',
          color: Colors.green,
          onTap: onTap,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should display gradient background with correct color', (tester) async {
      // Arrange
      const testColor = Colors.orange;

      // Act
      await pumpTestWidget(
        tester,
        StatCard(
          icon: Icons.pause_circle_rounded,
          label: 'موقوفة',
          value: '25',
          color: testColor,
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(StatCard),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      expect(gradient.colors.first, testColor.withOpacity(0.15));
    });

    testWidgets('should render correctly in dark theme', (tester) async {
      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: StatCard(
                icon: Icons.check_circle_rounded,
                label: 'نشطة',
                value: '100',
                color: Colors.green,
              ),
            ),
          ),
        ),
      );

      // Assert - widget should build without errors
      expect(find.byType(StatCard), findsOneWidget);
    });

    testWidgets('should have proper padding and border radius', (tester) async {
      // Act
      await pumpTestWidget(
        tester,
        StatCard(
          icon: Icons.handshake_rounded,
          label: 'إجمالي',
          value: '150',
          color: Colors.blue,
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(InkWell),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      final borderRadius = decoration.borderRadius as BorderRadius;

      expect(borderRadius, isNotNull);
    });
  });
}
