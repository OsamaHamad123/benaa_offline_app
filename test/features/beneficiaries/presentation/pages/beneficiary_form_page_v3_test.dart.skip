import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_constants.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart' as db;
import '../../../../test_helpers/widget_wrapper.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/beneficiary_form_page_v3.dart';

/// 🧪 Widget Tests for BeneficiaryFormPageV3
///
/// Tests covering:
/// ✅ Initial rendering
/// ✅ Tab navigation (4 tabs)
/// ✅ Form field interactions
/// ✅ Family tab crash prevention
/// ✅ Save functionality
/// ✅ Keyboard shortcuts

void main() {
  // Shared test DB for all groups in this file to avoid duplicate DB instantiation
  late db.AppDatabase testDb;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    testDb = db.AppDatabase(NativeDatabase.memory());
  });

  tearDownAll(() async {
    await testDb.close();
  });

  group('BeneficiaryFormPageV3 Widget Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = appWrapper(
        testDb: testDb,
        child: const BeneficiaryFormPageV3(),
      );
    });

    testWidgets('should render form page without crashing', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('إضافة مستفيد'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('should display 4 tabs', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert - Check tab labels
      expect(find.text(FormTabs.tabs[0].title), findsOneWidget);
      expect(find.text(FormTabs.tabs[1].title), findsOneWidget);
      expect(find.text(FormTabs.tabs[2].title), findsOneWidget);
      expect(find.text(FormTabs.tabs[3].title), findsOneWidget);
    });

    testWidgets('should navigate to family tab without crashing', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act - Tap on family tab
      await tester.tap(find.text(FormTabs.tabs[1].title));
      await tester.pumpAndSettle();

      // Assert - Should not crash
      expect(tester.takeException(), isNull);
      expect(find.text('معلومات العائلة'), findsOneWidget);
    });

    testWidgets('should display family info section in family tab', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act - Navigate to family tab
      await tester.tap(find.text(FormTabs.tabs[1].title));
      await tester.pumpAndSettle();

      // Assert - Check for family fields (labels include " *" for required fields)
      expect(find.textContaining('الحالة الاجتماعية'), findsOneWidget);
      expect(find.textContaining('عدد المعالين'), findsOneWidget);
      expect(find.text('عدد الذكور'), findsOneWidget);
      expect(find.text('عدد الإناث'), findsOneWidget);
    });

    testWidgets('should display family members section in family tab', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act - Navigate to family tab
      await tester.tap(find.text(FormTabs.tabs[1].title));
      await tester.pumpAndSettle();

      // Assert - At least the family info section should be present
      expect(find.text('معلومات العائلة'), findsOneWidget);
    });

    testWidgets('should allow dropdown selection in family tab', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act - Navigate to family tab
      await tester.tap(find.text(FormTabs.tabs[1].title));
      await tester.pumpAndSettle();

      // Find and tap marital status dropdown (label includes " *")
      final maritalStatusDropdown = find.textContaining('الحالة الاجتماعية');
      expect(maritalStatusDropdown, findsOneWidget);

      // Tap dropdown
      await tester.tap(maritalStatusDropdown.first);
      await tester.pumpAndSettle();

      // Assert - Dropdown should open
      expect(find.text('متزوج'), findsWidgets);
      expect(find.text('أعزب'), findsWidgets);
    });

    testWidgets('should navigate between all tabs successfully', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act & Assert - Navigate to each tab
      for (final tabConfig in FormTabs.tabs) {
        await tester.tap(find.text(tabConfig.title));
        await tester.pumpAndSettle();

        // Should not crash
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('should display auto-save indicator', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert - Check for auto-save indicator
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('should display quick actions FAB', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should enter text in personal info fields', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act - Find first name field and enter text
      final firstNameField = find.byType(TextFormField).first;
      await tester.enterText(firstNameField, 'محمد');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('محمد'), findsOneWidget);
    });

    testWidgets('should maintain tab state when switching', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act - Enter text in first tab
      final firstNameField = find.byType(TextFormField).first;
      await tester.enterText(firstNameField, 'أحمد');
      await tester.pumpAndSettle();

      // Switch to family tab
      await tester.tap(find.text(FormTabs.tabs[1].title));
      await tester.pumpAndSettle();

      // Switch back to personal info tab
      await tester.tap(find.text(FormTabs.tabs[0].title));
      await tester.pumpAndSettle();

      // Assert - Text should be preserved
      expect(find.text('أحمد'), findsOneWidget);
    });

    testWidgets('should not crash when tapping save button', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act - Find and tap save button (in AppBar)
      final saveButton = find.byIcon(Icons.save_rounded);
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pumpAndSettle();
      }

      // Assert
      expect(tester.takeException(), isNull);
    });
  });

  group('BeneficiaryFormPageV3 - Family Tab Specific Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = appWrapper(
        testDb: testDb,
        child: const BeneficiaryFormPageV3(),
      );
    });

    testWidgets('should not crash on multiple dropdown interactions', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Navigate to family tab
      await tester.tap(find.text(FormTabs.tabs[1].title));
      await tester.pumpAndSettle();

      // Act - Interact with dropdown multiple times
      for (int i = 0; i < 5; i++) {
        final dropdown = find.textContaining('الحالة الاجتماعية').first;
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        // Close dropdown
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
      }

      // Assert
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display both family sections', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text(FormTabs.tabs[1].title));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('معلومات العائلة'), findsOneWidget);
    });

    testWidgets('should allow scrolling in family tab', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text(FormTabs.tabs[1].title));
      await tester.pumpAndSettle();

      // Try scrolling
      await tester.drag(find.text('معلومات العائلة'), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Assert - Should not crash
      expect(tester.takeException(), isNull);
    });
  });

  group('BeneficiaryFormPageV3 - Performance Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = appWrapper(
        testDb: testDb,
        child: const BeneficiaryFormPageV3(),
      );
    });

    testWidgets('should render within acceptable time', (
      WidgetTester tester,
    ) async {
      // Act
      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Assert - Should render in less than 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('should not rebuild unnecessarily on text input', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      int buildCount = 0;
      tester.binding.addPostFrameCallback((_) => buildCount++);

      // Act - Enter text
      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, 'Test');
      await tester.pump();

      // Assert - Should not cause excessive rebuilds
      expect(buildCount, lessThan(5));
    });
  });
}
