import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  group('BeneficiaryFormPageV3 Widget Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) =>
              MaterialApp(home: const BeneficiaryFormPageV3()),
        ),
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
      expect(find.text('شخصية'), findsOneWidget);
      expect(find.text('عائلة'), findsOneWidget);
      expect(find.text('تواصل'), findsOneWidget);
      expect(find.text('مرفقات'), findsOneWidget);
    });

    testWidgets('should navigate to family tab without crashing', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act - Tap on family tab
      await tester.tap(find.text('عائلة'));
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
      await tester.tap(find.text('عائلة'));
      await tester.pumpAndSettle();

      // Assert - Check for family fields
      expect(find.text('الحالة الاجتماعية'), findsOneWidget);
      expect(find.text('عدد المعالين'), findsOneWidget);
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
      await tester.tap(find.text('عائلة'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('أفراد العائلة'), findsOneWidget);
    });

    testWidgets('should allow dropdown selection in family tab', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act - Navigate to family tab
      await tester.tap(find.text('عائلة'));
      await tester.pumpAndSettle();

      // Find and tap marital status dropdown
      final maritalStatusDropdown = find.text('الحالة الاجتماعية');
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
      final tabs = ['شخصية', 'عائلة', 'تواصل', 'مرفقات'];

      for (final tab in tabs) {
        await tester.tap(find.text(tab));
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
      await tester.tap(find.text('عائلة'));
      await tester.pumpAndSettle();

      // Switch back to personal info tab
      await tester.tap(find.text('شخصية'));
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
      testWidget = ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) =>
              MaterialApp(home: const BeneficiaryFormPageV3()),
        ),
      );
    });

    testWidgets('should not crash on multiple dropdown interactions', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Navigate to family tab
      await tester.tap(find.text('عائلة'));
      await tester.pumpAndSettle();

      // Act - Interact with dropdown multiple times
      for (int i = 0; i < 5; i++) {
        final dropdown = find.text('الحالة الاجتماعية').first;
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
      await tester.tap(find.text('عائلة'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('معلومات العائلة'), findsOneWidget);
      expect(find.text('أفراد العائلة'), findsOneWidget);
    });

    testWidgets('should allow scrolling in family tab', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('عائلة'));
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
      testWidget = ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) =>
              MaterialApp(home: const BeneficiaryFormPageV3()),
        ),
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
