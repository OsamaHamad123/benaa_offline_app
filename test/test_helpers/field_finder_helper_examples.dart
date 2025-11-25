/// 📚 Examples of Using FieldFinderHelper
///
/// This file demonstrates various ways to use the FieldFinderHelper
/// in widget tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'field_finder_helper.dart';

void exampleUsage() {
  testWidgets('Example 1: Find and fill a single field', (tester) async {
    // ... setup widget ...

    // Method 1: Using helper class directly
    await FieldFinderHelper.enterTextInField(tester, 'الاسم الأول', 'محمد');

    // Method 2: Using extension method (cleaner)
    await tester.fillField('الاسم الأول', 'محمد');
  });

  testWidgets('Example 2: Fill multiple fields at once', (tester) async {
    // ... setup widget ...

    // Fill all name fields in one call
    await tester.fillMultipleFields({
      'الاسم الأول': 'محمد',
      'اسم الأب': 'أحمد',
      'اسم الجد': 'علي',
      'اللقب': 'العلي',
    });

    // Verify all fields are filled
    expect(FieldFinderHelper.getFieldValue(tester, 'الاسم الأول'), 'محمد');
    expect(FieldFinderHelper.getFieldValue(tester, 'اسم الأب'), 'أحمد');
  });

  testWidgets('Example 3: Find fields by different methods', (tester) async {
    // ... setup widget ...

    // Find by label
    final firstNameField = FieldFinderHelper.findFieldByLabel(
      tester,
      'الاسم الأول',
    );
    expect(firstNameField, findsOneWidget);

    // Find by index
    final secondField = FieldFinderHelper.findFieldByIndex(1);
    expect(secondField, findsOneWidget);

    // Find by icon
    final phoneField = FieldFinderHelper.findFieldByIcon(Icons.phone);
    expect(phoneField, findsOneWidget);

    // Find all required fields
    final requiredFields = FieldFinderHelper.findRequiredFields();
    expect(requiredFields.evaluate().length, greaterThan(0));
  });

  testWidgets('Example 4: Check field validation', (tester) async {
    // ... setup widget ...

    // Fill field with invalid data
    await tester.fillField('الرقم الوطني', '123'); // Too short

    // Trigger validation
    await FieldFinderHelper.validateAllFields(tester);

    // Check if field has error
    expect(FieldFinderHelper.hasFieldError(tester, 'الرقم الوطني'), isTrue);
  });

  testWidgets('Example 5: Debug fields', (tester) async {
    // ... setup widget ...

    // Print all visible fields for debugging
    tester.debugFields();
    // Output:
    // 📝 Found 5 TextFormFields:
    //   [0] Label: "الاسم الأول" | Value: "محمد" | Error: false
    //   [1] Label: "اسم الأب" | Value: "" | Error: false
    //   [2] Label: "اسم الجد" | Value: "" | Error: false
    //   [3] Label: "اللقب" | Value: "" | Error: true
    //   [4] Label: "الرقم الوطني" | Value: "123" | Error: true

    // Get field count
    final count = FieldFinderHelper.getFieldCount(tester);
    expect(count, 5);
  });

  testWidgets('Example 6: Real-world test scenario', (tester) async {
    // ... setup widget ...

    // Step 1: Fill all required fields
    await tester.fillMultipleFields({
      'الاسم الأول': 'محمد',
      'اللقب': 'العلي',
      'الرقم الوطني': '123456789',
    });

    // Step 2: Verify no required fields are empty
    final requiredFields = FieldFinderHelper.findRequiredFields();
    for (final field in requiredFields.evaluate()) {
      final widget = field.widget as TextFormField;
      expect(widget.controller?.text.isNotEmpty, isTrue);
    }

    // Step 3: Submit form and check for errors
    final saveButton = find.text('حفظ');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify success message
    expect(find.text('تم الحفظ بنجاح'), findsOneWidget);
  });

  testWidgets('Example 7: Testing with Material3 components', (tester) async {
    // ... setup widget with M3TextField ...

    // M3TextField adds required indicator (*) - helper handles this automatically
    await tester.fillField(
      'الاسم الأول',
      'محمد',
    ); // Works even with * indicator

    // Find by label works with both:
    // - "الاسم الأول" (without *)
    // - "الاسم الأول *" (with *)
    final field1 = tester.fieldByLabel('الاسم الأول');
    expect(field1, findsOneWidget);
  });

  testWidgets('Example 8: Error handling', (tester) async {
    // ... setup widget ...

    // Try to find non-existent field
    try {
      await tester.fillField('حقل غير موجود', 'قيمة');
    } catch (e) {
      expect(
        e.toString(),
        contains('Field with label "حقل غير موجود" not found'),
      );
    }

    // Safe way to check if field exists
    final field = FieldFinderHelper.findFieldByLabel(tester, 'حقل غير موجود');
    if (field.evaluate().isEmpty) {
      // Field doesn't exist
      print('Field not found, skipping...');
    } else {
      await tester.enterText(field, 'قيمة');
    }
  });

  testWidgets('Example 9: Complex form testing', (tester) async {
    // ... setup beneficiary form ...

    // Tab 1: Personal Info
    await tester.fillMultipleFields({
      'الاسم الأول': 'محمد',
      'اسم الأب': 'أحمد',
      'اسم الجد': 'علي',
      'اللقب': 'العلي',
      'الرقم الوطني': '123456789',
    });

    // Switch to tab 2
    await tester.tap(find.text('العائلة'));
    await tester.pumpAndSettle();

    // Add family member
    await tester.tap(find.text('إضافة فرد'));
    await tester.pumpAndSettle();

    // Fill family member form
    await tester.fillMultipleFields({'الاسم الأول': 'فاطمة', 'اللقب': 'العلي'});

    // Save
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    // Switch to tab 3
    await tester.tap(find.text('التواصل'));
    await tester.pumpAndSettle();

    // Fill contact info
    await tester.fillField('رقم الهاتف', '0123456789');

    // Verify all data is filled
    tester.debugFields();
  });

  testWidgets('Example 10: Performance testing with helper', (tester) async {
    // ... setup widget ...

    final stopwatch = Stopwatch()..start();

    // Fill multiple fields and measure time
    await tester.fillMultipleFields({
      'الاسم الأول': 'محمد',
      'اسم الأب': 'أحمد',
      'اسم الجد': 'علي',
      'اللقب': 'العلي',
    });

    stopwatch.stop();

    // Verify performance
    expect(
      stopwatch.elapsedMilliseconds,
      lessThan(500),
      reason: 'Filling 4 fields should be fast',
    );

    print('✅ Filled 4 fields in ${stopwatch.elapsedMilliseconds}ms');
  });
}
