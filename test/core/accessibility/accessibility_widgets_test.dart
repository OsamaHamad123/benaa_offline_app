import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:benaa_offline_app/core/accessibility/accessibility_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('AccessibilityConstants', () {
    test('has correct minimum touch target size', () {
      expect(AccessibilityConstants.minTouchTarget, 48.0);
    });

    test('has correct recommended touch target size', () {
      expect(AccessibilityConstants.recommendedTouchTarget, 56.0);
    });

    test('has correct minimum spacing', () {
      expect(AccessibilityConstants.minSpacing, 8.0);
    });
  });

  group('AccessibleButton', () {
    testWidgets('creates FilledButton by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => AccessibleButton(
                onPressed: () {},
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('creates OutlinedButton when outlined=true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => AccessibleButton(
                onPressed: () {},
                outlined: true,
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('respects minimum size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => AccessibleButton(
                onPressed: () {},
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final style = button.style!;
      final minimumSize = style.minimumSize?.resolve({});

      expect(minimumSize?.width, greaterThanOrEqualTo(48.0));
      expect(minimumSize?.height, greaterThanOrEqualTo(48.0));
    });
  });

  group('AccessibleIconButton', () {
    testWidgets('creates IconButton with minimum size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => AccessibleIconButton(
                icon: Icons.add,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsOneWidget);

      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.byType(IconButton),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.minWidth, greaterThanOrEqualTo(48.0));
      expect(container.constraints?.minHeight, greaterThanOrEqualTo(48.0));
    });

    testWidgets('shows tooltip when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => const AccessibleIconButton(
                icon: Icons.add,
                tooltip: 'Add Item',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
    });
  });

  group('AccessibleListTile', () {
    testWidgets('respects minimum height', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => const AccessibleListTile(
                title: Text('Test'),
              ),
            ),
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );

      expect(
        constrainedBox.constraints.minHeight,
        greaterThanOrEqualTo(48.0),
      );
    });
  });

  group('SemanticWrapper', () {
    testWidgets('adds semantic label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SemanticWrapper(
              label: 'Test Label',
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(Semantics), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });
  });
}
