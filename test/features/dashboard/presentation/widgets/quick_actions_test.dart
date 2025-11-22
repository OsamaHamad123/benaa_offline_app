import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/widgets/quick_actions.dart';

void main() {
  group('Quick Actions Tests', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('QuickActionButton renders correctly', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: QuickActionButton(
                label: 'إضافة مستفيد',
                icon: Icons.person_add,
                color: Colors.blue,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('إضافة مستفيد'), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);

      // Tap button and verify callback
      await tester.tap(find.byType(QuickActionButton));
      await tester.pump();
      expect(tapped, true);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('QuickActionButton triggers haptic feedback on tap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      final List<MethodCall> log = <MethodCall>[];

      // تسجيل الـ haptic feedback calls
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: QuickActionButton(
                label: 'إضافة مستفيد',
                icon: Icons.person_add,
                color: Colors.blue,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true, reason: 'onTap callback should be called');
      expect(
        log,
        contains(
          isA<MethodCall>().having(
            (call) => call.method,
            'method',
            'HapticFeedback.vibrate',
          ),
        ),
        reason: 'Haptic feedback should be triggered',
      );
    });

    testWidgets('QuickActionsGrid renders all actions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: QuickActionsGrid(
                onAddBeneficiaryTap: () {},
                onSearchTap: () {},
                onSyncTap: () {},
                onReportsTap: () {},
                onCivilRegistryTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('إضافة مستفيد'), findsOneWidget);
      expect(find.text('البحث'), findsOneWidget);
      expect(find.text('المزامنة'), findsOneWidget);
      expect(find.text('التقارير'), findsOneWidget);
      expect(find.text('السجل المدني'), findsOneWidget);
      expect(find.byType(QuickActionButton), findsNWidgets(5));
    });

    testWidgets('QuickActionsGrid uses responsive grid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: QuickActionsGrid(
                onAddBeneficiaryTap: () {},
                onSearchTap: () {},
                onSyncTap: () {},
                onReportsTap: () {},
                onCivilRegistryTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(GridView), findsOneWidget);

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final gridDelegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      // في mobile يجب أن يكون 2 columns
      expect(gridDelegate.crossAxisCount, greaterThanOrEqualTo(2));
    });
  });
}
