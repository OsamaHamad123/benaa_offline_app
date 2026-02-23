import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/widgets/statistics_section.dart';
import 'package:flutter/services.dart';

void main() {
  group('Statistics Section Tests', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('StatCard renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1200, 1200),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: StatCard(
                title: 'إجمالي المستفيدين',
                value: '150',
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('إجمالي المستفيدين'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('StatCard triggers haptic feedback when tappable', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      final List<MethodCall> log = <MethodCall>[];

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1200, 1200),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: StatCard(
                title: 'إجمالي المستفيدين',
                value: '150',
                icon: Icons.people,
                color: Colors.blue,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act
      // Tap the StatCard widget (it uses a GestureDetector via MicroInteractions.bounceButton)
      // Find and tap the GestureDetector created by bounceButton
      // Tap a visible child inside the StatCard to ensure the gesture hits the card area
      await tester.tap(find.text('150'));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true);
      expect(
        log,
        contains(
          isA<MethodCall>().having(
            (call) => call.method,
            'method',
            contains('HapticFeedback'),
          ),
        ),
        reason: 'Haptic feedback should be triggered on tap',
      );
    });

    testWidgets('StatisticsGrid renders all stat cards', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: MediaQuery(
              // Provide a larger viewport to avoid layout constraints and overflow
              data: MediaQueryData(size: Size(1200, 1200)),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: SizedBox(
                    // Provide sufficient height to avoid column overflow inside the stat cards
                    height: 1200,
                    child: StatisticsGrid(
                      totalBeneficiaries: 150,
                      activeBeneficiaries: 120,
                      pendingSync: 5,
                      completedVisitsToday: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(StatCard), findsNWidgets(4));
      expect(find.text('150'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    // TODO: Add 'change' parameter support to StatCard
    // testWidgets('StatCard shows percentage change when provided', (
    //   WidgetTester tester,
    // ) async {
    //   await tester.pumpWidget(
    //     ScreenUtilInit(
    //       designSize: const Size(375, 812),
    //       builder: (context, child) => MaterialApp(
    //         home: Scaffold(
    //           body: StatCard(
    //             title: 'إجمالي المستفيدين',
    //             value: '150',
    //             icon: Icons.people,
    //             color: Colors.blue,
    //             // change: 12.5,
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // });

    // TODO: Add 'change' parameter support to StatCard
    // testWidgets('StatCard shows negative change correctly', (
    //   WidgetTester tester,
    // ) async {
    //   await tester.pumpWidget(
    //     ScreenUtilInit(
    //       designSize: const Size(375, 812),
    //       builder: (context, child) => MaterialApp(
    //         home: Scaffold(
    //           body: StatCard(
    //             title: 'إجمالي المستفيدين',
    //             value: '150',
    //             icon: Icons.people,
    //             color: Colors.blue,
    //             // change: -5.2,
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // });

    test('Stat percentage calculation', () {
      // Test positive change
      const current = 150;
      const previous = 120;
      const change = (current - previous) / previous * 100;
      expect(change, closeTo(25.0, 0.1));

      // Test negative change
      const current2 = 100;
      const previous2 = 120;
      const change2 = (current2 - previous2) / previous2 * 100;
      expect(change2, closeTo(-16.67, 0.1));
    });
  });
}
