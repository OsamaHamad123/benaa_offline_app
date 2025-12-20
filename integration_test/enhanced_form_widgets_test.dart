import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:benaa_offline_app/core/widgets/validation_indicators.dart';
import 'package:benaa_offline_app/core/widgets/visual_enhancements.dart';
import 'package:benaa_offline_app/core/accessibility/accessibility_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Integration Test for Enhanced Form Widgets
///
/// هذا الاختبار يتأكد من أن جميع الـ widgets تعمل معاً بشكل صحيح
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Enhanced Form Integration Tests', () {
    testWidgets('Complete form workflow with all enhancements', (WidgetTester tester) async {
      final nameController = TextEditingController();
      final idController = TextEditingController();
      bool formSubmitted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Name field with real-time validation
                    RealTimeValidatedField(
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'الاسم مطلوب';
                        if (value.length < 3) return 'الاسم قصير جداً';
                        return null;
                      },
                      successMessage: 'الاسم صحيح ✓',
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'الاسم',
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ID field with helper text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: idController,
                          decoration: const InputDecoration(
                            labelText: 'الرقم الوطني',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const FieldHelperText(
                          text: 'مثال: 123456789',
                          icon: Icons.info_outline,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Submit button with accessibility
                    AccessibleButton(
                      key: const Key('submit_button'),
                      onPressed: () {
                        formSubmitted = true;
                      },
                      child: const Text('حفظ'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Test 1: Enter invalid name (too short)
      await tester.enterText(find.widgetWithText(TextField, 'الاسم'), 'ab');
      await tester.pump(const Duration(milliseconds: 500));

      // Validation indicator should not show (invalid state)
      expect(find.byType(ValidationIndicator), findsNothing);

      // Test 2: Enter valid name
      await tester.enterText(find.widgetWithText(TextField, 'الاسم'), 'أحمد محمد');
      await tester.pump(const Duration(milliseconds: 500));

      // Validation indicator should show success
      expect(find.byType(ValidationIndicator), findsOneWidget);
      expect(find.text('الاسم صحيح ✓'), findsOneWidget);

      // Test 3: Enter ID
      await tester.enterText(find.widgetWithText(TextField, 'الرقم الوطني'), '123456789');
      await tester.pump();

      // Helper text should be visible
      expect(find.text('مثال: 123456789'), findsOneWidget);

      // Test 4: Tap submit button
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pump();

      expect(formSubmitted, true);

      // Cleanup
      nameController.dispose();
      idController.dispose();
    });

    testWidgets('Accessibility widgets have correct touch targets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => Column(
                children: [
                  AccessibleButton(
                    key: const Key('accessible_button'),
                    onPressed: () {},
                    child: const Text('زر'),
                  ),
                  AccessibleIconButton(
                    key: const Key('accessible_icon_button'),
                    icon: Icons.add,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Find button
      final buttonFinder = find.byKey(const Key('accessible_button'));
      expect(buttonFinder, findsOneWidget);

      // Check button size
      final buttonSize = tester.getSize(buttonFinder);
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));

      // Find icon button container
      final iconButtonFinder = find.byKey(const Key('accessible_icon_button'));
      expect(iconButtonFinder, findsOneWidget);

      final iconButtonSize = tester.getSize(iconButtonFinder);
      expect(iconButtonSize.width, greaterThanOrEqualTo(48.0));
      expect(iconButtonSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Visual enhancements work correctly', (WidgetTester tester) async {
      bool isLoading = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      // Shimmer loading
                      ShimmerLoading(
                        key: const Key('shimmer'),
                        isLoading: isLoading,
                        child: Container(
                          width: 200,
                          height: 100,
                          color: Colors.grey[300],
                        ),
                      ),

                      // Fade in widget
                      const FadeInWidget(
                        key: Key('fade_in'),
                        child: Text('محتوى'),
                      ),

                      // Success checkmark
                      const SuccessCheckmark(
                        key: Key('checkmark'),
                        size: 100,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // All widgets should be present
      expect(find.byKey(const Key('shimmer')), findsOneWidget);
      expect(find.byKey(const Key('fade_in')), findsOneWidget);
      expect(find.byKey(const Key('checkmark')), findsOneWidget);

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Content should be visible
      expect(find.text('محتوى'), findsOneWidget);
    });
  });
}
