import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/ux/ux_widgets.dart';

void main() {
  group('LoadingOverlay Tests', () {
    testWidgets('shows loading indicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(isLoading: true, child: Text('Content')),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('hides loading indicator when isLoading is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: false,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('displays loading message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: true,
              loadingMessage: 'جاري التحميل...',
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('جاري التحميل...'), findsOneWidget);
    });
  });

  group('SkeletonLoader Tests', () {
    testWidgets('renders with required height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonLoader(height: 100))),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('respects custom width and height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonLoader(width: 200, height: 100)),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });
  });

  group('SkeletonListItem Tests', () {
    testWidgets('renders skeleton list item', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonListItem())),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(SkeletonLoader), findsWidgets);
    });
  });

  group('BadgeWidget Tests', () {
    testWidgets('displays badge with text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BadgeWidget(label: 'جديد')),
        ),
      );

      expect(find.text('جديد'), findsOneWidget);
    });

    testWidgets('applies custom color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BadgeWidget(label: 'Test', color: Colors.red),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
    });
  });

  group('NotificationBadge Tests', () {
    testWidgets('displays count when greater than 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationBadge(count: 5, child: Icon(Icons.notifications)),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('hides badge when count is 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationBadge(count: 0, child: Icon(Icons.notifications)),
          ),
        ),
      );

      expect(find.byType(NotificationBadge), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('shows 99+ for counts over 99', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationBadge(
              count: 150,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });
  });

  group('ProgressBarWidget Tests', () {
    testWidgets('renders with value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ProgressBarWidget(value: 0.5))),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays label when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProgressBarWidget(value: 0.75, label: 'التقدم')),
        ),
      );

      expect(find.text('التقدم'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('renders correctly with full progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ProgressBarWidget(value: 1.0))),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('PullToRefreshWrapper Tests', () {
    testWidgets('wraps child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PullToRefreshWrapper(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 100));
              },
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('triggers onRefresh when pulled', (tester) async {
      bool refreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PullToRefreshWrapper(
              onRefresh: () async {
                refreshed = true;
                await Future.delayed(const Duration(milliseconds: 100));
              },
              child: ListView(children: const [Text('Item 1'), Text('Item 2')]),
            ),
          ),
        ),
      );

      // Simulate pull down gesture
      await tester.fling(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
        1000.0,
      );
      await tester.pumpAndSettle();

      expect(refreshed, true);
    });
  });
}
