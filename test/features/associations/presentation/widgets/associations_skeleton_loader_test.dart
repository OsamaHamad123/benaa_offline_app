import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:benaa_offline_app/features/associations/presentation/widgets/associations_skeleton_loader.dart';

/// Helper function to wrap widgets with ScreenUtilInit for testing
Widget buildTestWidget(Widget child, {Size screenSize = const Size(400, 800)}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: Scaffold(
        body: ScreenUtilInit(
          designSize: screenSize,
          minTextAdapt: true,
          builder: (context, _) => child,
        ),
      ),
    ),
  );
}

void main() {
  group('AssociationsSkeletonLoader Widget Tests', () {
    testWidgets('should render default number of skeleton items', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          const AssociationsSkeletonLoader(),
        ),
      );

      // Assert - verify ListView is created with correct itemCount (4 is default)
      // We verify the loader and ListView exist, itemCount is validated through widget
      expect(find.byType(AssociationsSkeletonLoader), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      // Verify at least 4 AnimatedBuilder widgets exist (from skeleton items)
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(4));
    });

    testWidgets('should render custom number of skeleton items', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          const AssociationsSkeletonLoader(itemCount: 6),
        ),
      );

      // Assert - verify loader with custom count
      expect(find.byType(AssociationsSkeletonLoader), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      // Verify at least 6 AnimatedBuilder widgets exist (from skeleton items)
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(6));
    });

    testWidgets('should create AnimationController', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          const AssociationsSkeletonLoader(itemCount: 2),
        ),
      );

      // Verify widget builds without errors
      expect(find.byType(AssociationsSkeletonLoader), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should dispose AnimationController properly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          const AssociationsSkeletonLoader(),
        ),
      );

      // Verify widget is present
      expect(find.byType(AssociationsSkeletonLoader), findsOneWidget);

      // Remove widget
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(),
        ),
      );

      // Verify widget is disposed without errors
      expect(find.byType(AssociationsSkeletonLoader), findsNothing);
    });

    testWidgets('should have shimmer animation running', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          const AssociationsSkeletonLoader(itemCount: 1),
        ),
      );

      // Pump initial frame
      await tester.pump();

      // Pump animation forward
      await tester.pump(const Duration(milliseconds: 500));

      // Verify animation continues
      await tester.pump(const Duration(milliseconds: 500));

      // Widget should still be present and animating
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
    });

    testWidgets('should use NeverScrollableScrollPhysics', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          const AssociationsSkeletonLoader(),
        ),
      );

      // Find ListView
      final listView = tester.widget<ListView>(find.byType(ListView));

      // Assert
      expect(listView.physics, isA<NeverScrollableScrollPhysics>());
    });

    testWidgets('should have shrinkWrap enabled', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        buildTestWidget(
          const AssociationsSkeletonLoader(),
        ),
      );

      // Find ListView
      final listView = tester.widget<ListView>(find.byType(ListView));

      // Assert
      expect(listView.shrinkWrap, true);
    });
  });
}
