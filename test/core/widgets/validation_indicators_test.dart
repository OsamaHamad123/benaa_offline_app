import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:benaa_offline_app/core/widgets/validation_indicators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  // Initialize ScreenUtil for tests
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('ValidationIndicator', () {
    testWidgets('shows success state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => const ValidationIndicator(
                isValid: true,
                successMessage: 'صحيح ✓',
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('صحيح ✓'), findsOneWidget);
    });

    testWidgets('shows error state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => const ValidationIndicator(
                isValid: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('hides when isValid is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationIndicator(),
          ),
        ),
      );

      expect(find.byType(ValidationIndicator), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.error), findsNothing);
    });
  });

  group('FieldHelperText', () {
    testWidgets('displays helper text with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => const FieldHelperText(
                text: 'مثال: 0595735352',
              ),
            ),
          ),
        ),
      );

      expect(find.text('مثال: 0595735352'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('applies custom color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => const FieldHelperText(
                text: 'Test',
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, Colors.blue);
    });
  });

  group('RealTimeValidatedField', () {
    testWidgets('validates on text change', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => RealTimeValidatedField(
                controller: controller,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (value.length < 3) return 'Too short';
                  return null;
                },
                child: TextField(controller: controller),
              ),
            ),
          ),
        ),
      );

      // Initially empty
      expect(find.byType(ValidationIndicator), findsNothing);

      // Type invalid text
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump();
      expect(find.byType(ValidationIndicator), findsNothing); // Error state doesn't show indicator

      // Type valid text
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(find.byType(ValidationIndicator), findsOneWidget);

      controller.dispose();
    });
  });
}
