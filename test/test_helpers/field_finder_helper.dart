import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 🔍 Helper Functions for Finding Form Fields in Tests
///
/// Provides robust field finders that work with Material3 components,
/// validation, and input formatters.

class FieldFinderHelper {
  /// Find TextFormField by label text (works with M3TextField)
  ///
  /// Example:
  /// ```dart
  /// final firstNameField = FieldFinderHelper.findFieldByLabel(
  ///   tester,
  ///   'الاسم الأول',
  /// );
  /// ```
  static Finder findFieldByLabel(WidgetTester tester, String label) {
    // TextFormField builds TextField internally, so we find TextField and then get parent
    final textFieldFinder = find.byWidgetPredicate((widget) {
      if (widget is! TextField) return false;

      final decoration = widget.decoration;
      if (decoration == null) return false;

      // Check label widget (M3TextField with required indicator)
      if (decoration.label is Row) {
        final row = decoration.label as Row;
        final children = row.children;
        if (children.isNotEmpty && children.first is Flexible) {
          final flexible = children.first as Flexible;
          if (flexible.child is Text) {
            final text = (flexible.child as Text).data;
            if (text == label) return true;
          }
        }
      }

      // Check labelText (regular TextField)
      if (decoration.labelText != null) {
        if (decoration.labelText == label ||
            decoration.labelText == '$label *') {
          return true;
        }
        // Fallback: contains label
        if (decoration.labelText!.contains(label)) {
          return true;
        }
      }

      return false;
    });

    // Return the TextFormField ancestor if found, or TextField directly
    if (textFieldFinder.evaluate().isEmpty) {
      return find.byWidgetPredicate((widget) => false); // Empty finder
    }

    final textFormFieldFinder = find.ancestor(
      of: textFieldFinder.first,
      matching: find.byType(TextFormField),
    );

    return textFormFieldFinder.evaluate().isNotEmpty
        ? textFormFieldFinder
        : textFieldFinder;
  }

  /// Find field by index in the current visible fields
  ///
  /// Example:
  /// ```dart
  /// final secondField = FieldFinderHelper.findFieldByIndex(1);
  /// ```
  static Finder findFieldByIndex(int index) {
    return find.byType(TextFormField).at(index);
  }

  /// Find all TextFormFields in the current view
  static Finder findAllFields() {
    return find.byType(TextFormField);
  }

  /// Get the count of visible TextFormFields
  static int getFieldCount(WidgetTester tester) {
    return find.byType(TextFormField).evaluate().length;
  }

  /// Find field by controller text content
  ///
  /// Example:
  /// ```dart
  /// final fieldWithText = FieldFinderHelper.findFieldByText(
  ///   tester,
  ///   'محمد',
  /// );
  /// ```
  static Finder findFieldByText(WidgetTester tester, String text) {
    return find.ancestor(
      of: find.byWidgetPredicate((widget) {
        if (widget is! TextField) return false;
        return widget.controller?.text == text;
      }),
      matching: find.byType(TextFormField),
    );
  }

  /// Find required fields (marked with *)
  static Finder findRequiredFields() {
    return find.ancestor(
      of: find.byWidgetPredicate((widget) {
        if (widget is! TextField) return false;

        final decoration = widget.decoration;
        if (decoration == null) return false;

        // Check if label contains required indicator
        if (decoration.label is Row) {
          final row = decoration.label as Row;
          // Check if row has star icon (required indicator)
          return row.children.any(
            (child) => child is Icon && child.icon == Icons.star,
          );
        }

        // Check labelText for asterisk
        return decoration.labelText?.endsWith('*') ?? false;
      }),
      matching: find.byType(TextFormField),
    );
  }

  /// Find field by prefix icon
  ///
  /// Example:
  /// ```dart
  /// final phoneField = FieldFinderHelper.findFieldByIcon(Icons.phone);
  /// ```
  static Finder findFieldByIcon(IconData iconData) {
    return find.ancestor(
      of: find.byWidgetPredicate((widget) {
        if (widget is! TextField) return false;

        final decoration = widget.decoration;
        if (decoration == null) return false;

        final prefixIcon = decoration.prefixIcon;
        if (prefixIcon is Padding) {
          final child = prefixIcon.child;
          if (child is Icon) {
            return child.icon == iconData;
          }
        }

        if (prefixIcon is Icon) {
          return prefixIcon.icon == iconData;
        }

        return false;
      }),
      matching: find.byType(TextFormField),
    );
  }

  /// Helper to enter text in a field found by label
  ///
  /// Example:
  /// ```dart
  /// await FieldFinderHelper.enterTextInField(
  ///   tester,
  ///   'الاسم الأول',
  ///   'محمد',
  /// );
  /// ```
  static Future<void> enterTextInField(
    WidgetTester tester,
    String label,
    String text,
  ) async {
    final field = findFieldByLabel(tester, label);
    expect(
      field,
      findsOneWidget,
      reason: 'Field with label "$label" not found',
    );
    await tester.enterText(field, text);
    await tester.pumpAndSettle();
  }

  /// Helper to enter text in multiple fields at once
  ///
  /// Example:
  /// ```dart
  /// await FieldFinderHelper.fillFields(tester, {
  ///   'الاسم الأول': 'محمد',
  ///   'اسم الأب': 'أحمد',
  ///   'اللقب': 'العلي',
  /// });
  /// ```
  static Future<void> fillFields(
    WidgetTester tester,
    Map<String, String> fieldsData,
  ) async {
    for (final entry in fieldsData.entries) {
      await enterTextInField(tester, entry.key, entry.value);
    }
  }

  /// Get field value by label
  static String? getFieldValue(WidgetTester tester, String label) {
    final field = findFieldByLabel(tester, label);
    if (field.evaluate().isEmpty) return null;

    final widget = tester.widget<TextFormField>(field);
    return widget.controller?.text;
  }

  /// Check if field has error
  static bool hasFieldError(WidgetTester tester, String label) {
    final formField = findFieldByLabel(tester, label);
    if (formField.evaluate().isEmpty) return false;

    // Find TextField inside TextFormField
    final textField = find.descendant(
      of: formField,
      matching: find.byType(TextField),
    );
    if (textField.evaluate().isEmpty) return false;

    final widget = tester.widget<TextField>(textField);
    return widget.decoration?.errorText != null;
  }

  /// Validate all fields (trigger validation)
  static Future<void> validateAllFields(WidgetTester tester) async {
    // Find Form widget
    final formFinder = find.byType(Form);
    if (formFinder.evaluate().isEmpty) return;

    final form = tester.widget<Form>(formFinder);
    final formState = form.key as GlobalKey<FormState>;
    formState.currentState?.validate();
    await tester.pumpAndSettle();
  }

  /// Print all visible fields (for debugging)
  static void debugPrintFields(WidgetTester tester) {
    final formFields = find.byType(TextFormField);
    final count = formFields.evaluate().length;
    print('📝 Found $count TextFormFields:');

    for (int i = 0; i < count; i++) {
      // Find TextField inside TextFormField
      final textField = find.descendant(
        of: formFields.at(i),
        matching: find.byType(TextField),
      );
      if (textField.evaluate().isEmpty) continue;

      final widget = tester.widget<TextField>(textField);
      final label = _extractLabelFromTextField(widget);
      final value = widget.controller?.text ?? '';
      final decoration = widget.decoration;
      final hasError = decoration?.errorText != null;

      print('  [$i] Label: "$label" | Value: "$value" | Error: $hasError');
    }
  }

  /// Extract label from TextField
  static String _extractLabelFromTextField(TextField widget) {
    final decoration = widget.decoration;
    if (decoration == null) return 'Unknown';

    // Try labelText first
    if (decoration.labelText != null) {
      return decoration.labelText!;
    }

    // Try label widget
    if (decoration.label is Row) {
      final row = decoration.label as Row;
      if (row.children.isNotEmpty && row.children.first is Flexible) {
        final flexible = row.children.first as Flexible;
        if (flexible.child is Text) {
          return (flexible.child as Text).data ?? '';
        }
      }
    }

    if (decoration.label is Text) {
      return (decoration.label as Text).data ?? '';
    }

    return 'Unknown';
  }
}

/// Extension methods for easier usage
extension FieldFinderExtensions on WidgetTester {
  /// Find field by label
  Finder fieldByLabel(String label) {
    return FieldFinderHelper.findFieldByLabel(this, label);
  }

  /// Enter text in field by label
  Future<void> fillField(String label, String text) {
    return FieldFinderHelper.enterTextInField(this, label, text);
  }

  /// Fill multiple fields
  Future<void> fillMultipleFields(Map<String, String> fields) {
    return FieldFinderHelper.fillFields(this, fields);
  }

  /// Debug print all fields
  void debugFields() {
    FieldFinderHelper.debugPrintFields(this);
  }
}
