import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../test_helpers/widget_wrapper.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/widgets/quick_actions.dart';
import 'package:drift/native.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart';

void main() {
  group('Quick Actions Tests', () {
    late AppDatabase testDb;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      testDb = AppDatabase(NativeDatabase.memory());
    });

    tearDownAll(() async {
      await testDb.close();
    });

    testWidgets('QuickActionButton renders correctly', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        appWrapper(
          testDb: testDb,
          child: QuickActionButton(
            label: 'إضافة مستفيد',
            icon: Icons.person_add,
            color: Colors.blue,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('إضافة مستفيد'), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);

      // Tap button and verify callback
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();
      expect(tapped, true);
      expect(find.byType(Card), findsOneWidget);
      // BounceButton uses GestureDetector via MicroInteractions.
      expect(find.byType(GestureDetector), findsOneWidget);
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
        appWrapper(
          testDb: testDb,
          child: QuickActionButton(
            label: 'إضافة مستفيد',
            icon: Icons.person_add,
            color: Colors.blue,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true, reason: 'onTap callback should be called');
      expect(log, isNotEmpty, reason: 'Haptic feedback should be triggered');
    });

    testWidgets('QuickActionsGrid renders all actions', (
      WidgetTester tester,
    ) async {
      // Set a test window size so ResponsiveUtils computes column counts
      tester.binding.window.physicalSizeTestValue = const Size(900, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });
      await tester.pumpWidget(
        appWrapper(
          testDb: testDb,
          child: SingleChildScrollView(
            child: Transform.scale(
              scale: 0.8,
              child: SizedBox(
                width: 1200,
                child: QuickActionsGrid(
                  onAddBeneficiaryTap: () {},
                  onSearchTap: () {},
                  onSyncTap: () {},
                  onReportsTap: () {},
                  onCivilRegistryTap: () {},
                ),
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
      // Set a test window size so ResponsiveUtils computes column counts
      tester.binding.window.physicalSizeTestValue = const Size(900, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });
      await tester.pumpWidget(
        appWrapper(
          testDb: testDb,
          child: SingleChildScrollView(
            child: Transform.scale(
              scale: 0.8,
              child: SizedBox(
                width: 1200,
                child: QuickActionsGrid(
                  onAddBeneficiaryTap: () {},
                  onSearchTap: () {},
                  onSyncTap: () {},
                  onReportsTap: () {},
                  onCivilRegistryTap: () {},
                ),
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
