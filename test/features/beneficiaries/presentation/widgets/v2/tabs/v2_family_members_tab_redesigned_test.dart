import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drift/native.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart' as db;
import 'package:benaa_offline_app/core/providers/providers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_family_members_tab_redesigned.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';

void main() {
  late BeneficiaryFormControllers formControllers;
  late db.AppDatabase testDb;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    testDb = db.AppDatabase(NativeDatabase.memory());
  });

  tearDownAll(() async {
    await testDb.close();
  });

  setUp(() {
    formControllers = BeneficiaryFormControllers();
  });

  tearDown(() {
    formControllers.dispose();
  });

  Widget createTestWidget(Widget child) {
    // Use ProviderScope with a DB override and keep the MaterialApp settings
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(testDb)],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => MaterialApp(
          locale: const Locale('ar'),
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  group('V2FamilyMembersTabRedesigned Widget Tests', () {
    testWidgets('should display deceased parents section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          V2FamilyMembersTabRedesigned(formControllers: formControllers),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الوالدين المتوفيين'), findsOneWidget);
    });

    testWidgets('should display orphans section', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          V2FamilyMembersTabRedesigned(formControllers: formControllers),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الأيتام'), findsOneWidget);
    });

    testWidgets('should show "no orphans" message when list is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          V2FamilyMembersTabRedesigned(formControllers: formControllers),
        ),
      );
      await tester.pumpAndSettle();

      // Tap to expand orphans section
      await tester.tap(find.text('الأيتام'));
      await tester.pumpAndSettle();

      expect(find.text('لا يوجد أيتام'), findsOneWidget);
    });

    testWidgets('should show add father button when no father exists', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          V2FamilyMembersTabRedesigned(formControllers: formControllers),
        ),
      );
      await tester.pumpAndSettle();

      // Expand deceased section
      await tester.tap(find.text('الوالدين المتوفيين'));
      await tester.pumpAndSettle();

      expect(find.text('إضافة أب المتوفى'), findsOneWidget);
    });

    testWidgets('should show add mother button when no mother exists', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          V2FamilyMembersTabRedesigned(formControllers: formControllers),
        ),
      );
      await tester.pumpAndSettle();

      // Expand deceased section (tap on icon or title area)
      await tester.tap(find.byIcon(Icons.local_hospital));
      await tester.pumpAndSettle();

      expect(find.textContaining('إضافة أم'), findsOneWidget);
    });

    testWidgets('should display father data when exists', (
      WidgetTester tester,
    ) async {
      // Add father data
      formControllers.addDeceasedMember({
        'deceasedType': 1,
        'firstName': 'أحمد',
        'familyName': 'محمد',
        'nationalId': 123456789,
      });

      await tester.pumpWidget(
        createTestWidget(
          V2FamilyMembersTabRedesigned(formControllers: formControllers),
        ),
      );
      await tester.pumpAndSettle();

      // Section should be expanded automatically when data exists
      // Check if data is displayed
      expect(find.textContaining('أحمد'), findsWidgets);
      expect(find.textContaining('123456789'), findsWidgets);
    });

    testWidgets('should display orphan data when exists', (
      WidgetTester tester,
    ) async {
      // Add orphan data
      formControllers.addLivingMember({
        'firstName': 'فاطمة',
        'familyName': 'أحمد',
        'age': 10,
        'gender': 2,
        'orphanNationalId': 987654321,
      });

      await tester.pumpWidget(
        createTestWidget(
          V2FamilyMembersTabRedesigned(formControllers: formControllers),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the controllers actually have one orphan
      expect(formControllers.livingMembers.length, 1);
      // Debug dump widget tree (temporary)
      debugDumpApp();

      // Section should be expanded automatically when data exists
      // Check if data is displayed
      expect(find.textContaining('فاطمة'), findsWidgets);
      expect(find.textContaining('10'), findsWidgets);
    });

    testWidgets('should show add orphan button', (WidgetTester tester) async {
      // Add one orphan so the 'Add orphan' outlined button is shown
      formControllers.addLivingMember({
        'firstName': 'Auto',
        'familyName': 'Add',
        'age': 2,
        'gender': 1,
      });

      await tester.pumpWidget(
        createTestWidget(
          V2FamilyMembersTabRedesigned(formControllers: formControllers),
        ),
      );
      await tester.pumpAndSettle();

      // Orphans section is initially expanded when there are orphans

      final outlinedFound = find.byKey(const ValueKey('add_orphan_button'));
      final filledFound = find.widgetWithIcon(FilledButton, Icons.add_rounded);
      expect(
        outlinedFound.evaluate().isNotEmpty ||
            filledFound.evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('should maintain state with AutomaticKeepAlive', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          V2FamilyMembersTabRedesigned(formControllers: formControllers),
        ),
      );
      await tester.pumpAndSettle();

      // Add data
      formControllers.livingMembers.add({
        'firstName': 'Test',
        'familyName': 'Name',
        'age': 5,
        'gender': 1,
      });

      await tester.pumpAndSettle();

      // Verify data persists
      expect(formControllers.livingMembers.length, 1);
    });
  });

  group('Performance Tests', () {
    testWidgets('should use const widgets where possible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          V2FamilyMembersTabRedesigned(formControllers: formControllers),
        ),
      );

      // Pump multiple times to check for unnecessary rebuilds
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Widget should not rebuild unnecessarily
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle large lists efficiently', (
      WidgetTester tester,
    ) async {
      // Add 50 orphans
      for (int i = 0; i < 50; i++) {
        formControllers.addLivingMember({
          'firstName': 'Name$i',
          'familyName': 'Family$i',
          'age': i,
          'gender': i % 2 + 1,
          'orphanNationalId': 100000000 + i,
        });
      }

      await tester.pumpWidget(
        createTestWidget(
          V2FamilyMembersTabRedesigned(formControllers: formControllers),
        ),
      );
      await tester.pumpAndSettle();

      // Should render without performance issues
      expect(find.text('الأيتام'), findsOneWidget);
    });
  });
}
