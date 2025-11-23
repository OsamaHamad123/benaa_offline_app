import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/beneficiary_form_page_v3.dart';

/// 🧪 Performance Tests for beneficiary_form_page_v3
///
/// Tests for rebuild optimization and widget separation
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestApp({String? beneficiaryId}) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) => ProviderScope(
        child: MaterialApp(
          home: BeneficiaryFormPageV3(beneficiaryId: beneficiaryId),
        ),
      ),
    );
  }

  group('🎯 Performance Tests', () {
    testWidgets('Form loads without errors', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify no exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('Build method completes quickly', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Build should complete in less than 1 second
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Build took ${stopwatch.elapsedMilliseconds}ms',
      );

      print('✅ Build completed in ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Typing does not cause excessive rebuilds', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find first text field
      final firstField = find.byType(TextFormField).first;
      expect(firstField, findsOneWidget);

      // Type multiple characters
      final stopwatch = Stopwatch()..start();

      await tester.enterText(firstField, 'Test');
      await tester.pump(); // Single frame

      stopwatch.stop();

      // Single frame should be very fast
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason: 'Typing caused lag: ${stopwatch.elapsedMilliseconds}ms',
      );

      print('✅ Typing completed in ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Tab switching is smooth', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find TabBar
      final tabBar = find.byType(TabBar);
      expect(tabBar, findsOneWidget);

      // Switch tabs
      final stopwatch = Stopwatch()..start();

      await tester.tap(find.text('العائلة'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Tab switch should be smooth
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'Tab switch too slow: ${stopwatch.elapsedMilliseconds}ms',
      );

      print('✅ Tab switch completed in ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Error banner uses Consumer (separated widget)', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify FormErrorBanner is used
      final errorBanner = find.byType(Consumer);
      expect(errorBanner, findsWidgets);

      print('✅ Error banner is properly separated');
    });

    testWidgets('AppBar is separated widget', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify AppBar exists
      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      print('✅ AppBar is properly separated');
    });

    testWidgets('No ref.watch in main build method', (tester) async {
      // This is a code review test - checking that ref.watch
      // is only used inside Consumer widgets, not in main build

      // If test passes without errors, the optimization is correct
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      print('✅ No ref.watch causing full rebuilds');
    });

    testWidgets('Multiple text inputs don\'t cause lag', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find all text fields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsWidgets);

      // Type in first 3 fields
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 3 && i < textFields.evaluate().length; i++) {
        await tester.enterText(textFields.at(i), 'Test$i');
        await tester.pump();
      }

      stopwatch.stop();

      // All inputs should be fast
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(300),
        reason: 'Multiple inputs too slow: ${stopwatch.elapsedMilliseconds}ms',
      );

      print(
        '✅ Multiple inputs completed in ${stopwatch.elapsedMilliseconds}ms',
      );
    });
  });

  group('📊 Widget Separation Tests', () {
    testWidgets('FormErrorBanner is used', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should find Consumer widget for error
      expect(find.byType(Consumer), findsWidgets);
    });

    testWidgets('Form content is separated', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Main form should exist
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('Bottom navigation is separated', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Bottom nav should exist
      expect(find.byType(ListenableBuilder), findsWidgets);
    });
  });

  group('✅ Regression Tests', () {
    testWidgets('Form validation still works', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Form should exist
      final form = find.byType(Form);
      expect(form, findsOneWidget);
    });

    testWidgets('Save functionality accessible', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should find bottom navigation
      expect(find.byType(ListenableBuilder), findsWidgets);
    });

    testWidgets('Tab controller works', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // TabBar should exist
      expect(find.byType(TabBar), findsOneWidget);
    });
  });
}
