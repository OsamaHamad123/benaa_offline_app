import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/associations/presentation/widgets/associations_skeleton_loader.dart';

void main() {
  group('AssociationsSkeletonLoader Widget Tests', () {
    testWidgets('should render default number of skeleton items',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AssociationsSkeletonLoader(),
          ),
        ),
      );

      // Assert - default itemCount is 4
      expect(find.byType(AnimatedBuilder), findsNWidgets(4));
    });

    testWidgets('should render custom number of skeleton items',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AssociationsSkeletonLoader(itemCount: 6),
          ),
        ),
      );

      // Assert
      expect(find.byType(AnimatedBuilder), findsNWidgets(6));
    });

    testWidgets('should create AnimationController',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AssociationsSkeletonLoader(itemCount: 2),
          ),
        ),
      );

      // Verify widget builds without errors
      expect(find.byType(AssociationsSkeletonLoader), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should dispose AnimationController properly',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AssociationsSkeletonLoader(),
          ),
        ),
      );

      // Verify widget is present
      expect(find.byType(AssociationsSkeletonLoader), findsOneWidget);

      // Remove widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // Verify widget is disposed without errors
      expect(find.byType(AssociationsSkeletonLoader), findsNothing);
    });

    testWidgets('should have shimmer animation running',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AssociationsSkeletonLoader(itemCount: 1),
          ),
        ),
      );

      // Pump initial frame
      await tester.pump();

      // Pump animation forward
      await tester.pump(const Duration(milliseconds: 500));

      // Verify animation continues
      await tester.pump(const Duration(milliseconds: 500));

      // Widget should still be present and animating
      expect(find.byType(AnimatedBuilder), findsOneWidget);
    });

    testWidgets('should use NeverScrollableScrollPhysics',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AssociationsSkeletonLoader(),
          ),
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
        const MaterialApp(
          home: Scaffold(
            body: AssociationsSkeletonLoader(),
          ),
        ),
      );

      // Find ListView
      final listView = tester.widget<ListView>(find.byType(ListView));

      // Assert
      expect(listView.shrinkWrap, true);
    });
  });
}
