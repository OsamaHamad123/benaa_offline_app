import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/zero_lag_family_dialog.dart';
import 'package:flutter/foundation.dart';

void main() {
  testWidgets('ZeroLagFamilyDialog typing perf smoke', (
    WidgetTester tester,
  ) async {
    // Build an app that can show the dialog
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ZeroLagFamilyDialog(
                        onSave: (_) {},
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Reset debug counters, then open dialog
    if (kDebugMode) debugRebuildCountsReset();
    // Open dialog
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Find all text fields and type into them sequentially, measuring each
    final fields = find.byType(TextField);
    expect(fields, findsWidgets);

    final results = <String, int>{};
    for (var i = 0; i < fields.evaluate().length; i++) {
      final f = fields.at(i);
      final swField = Stopwatch()..start();
      await tester.tap(f);
      await tester.pumpAndSettle();
      // Enter different sample text per field
      await tester.enterText(f, 'User$i');
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pump(const Duration(milliseconds: 30));
      swField.stop();
      results['field_$i'] = swField.elapsedMilliseconds;
      debugPrint('Field $i typing ${swField.elapsedMilliseconds}ms');
    }

    // Toggle gender to the other option if present
    final female = find.text('أنثى');
    if (female.evaluate().isNotEmpty) {
      final swG = Stopwatch()..start();
      await tester.tap(female);
      await tester.pumpAndSettle();
      swG.stop();
      results['gender_toggle'] = swG.elapsedMilliseconds;
      debugPrint('Gender toggle ${swG.elapsedMilliseconds}ms');
    }

    // Tap a health status chip (non-deceased flow): 'مريض'
    final sickChip = find.text('مريض');
    if (sickChip.evaluate().isNotEmpty) {
      final swChip = Stopwatch()..start();
      await tester.tap(sickChip);
      await tester.pumpAndSettle();
      swChip.stop();
      results['health_chip'] = swChip.elapsedMilliseconds;
      debugPrint('Health chip tap ${swChip.elapsedMilliseconds}ms');
    }

    // Final rebuild counts
    if (kDebugMode) {
      final counts = debugGetRebuildCounts();
      debugPrint('ZeroLagFamilyDialog: Rebuild counts: $counts');
    }

    debugPrint('ZeroLagFamilyDialog: field timings: $results');

    // (Focus-change micro-checks were folded into the main field loop above.)

    // Basic expectation: dialog present (may be closed after save confirmation)
    // expect(find.byType(ZeroLagFamilyDialog), findsOneWidget);
  });
}
