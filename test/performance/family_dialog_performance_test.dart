import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart' as db;
import '../test_helpers/widget_wrapper.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/zero_lag_family_dialog.dart';

/// 🧪 Performance Test - Zero Lag Family Dialog
void main() {
  group('Zero Lag Dialog Performance', () {
    late db.AppDatabase testDb;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      testDb = db.AppDatabase(NativeDatabase.memory());
    });

    tearDownAll(() async {
      await testDb.close();
    });

    testWidgets('Dialog should have instant keyboard response', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        appWrapper(
          testDb: testDb,
          child: const MaterialApp(home: _TestScreen()),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Find first name field
      final firstNameField = find.byType(TextField).first;
      expect(firstNameField, findsOneWidget);

      // Measure typing performance
      final stopwatch = Stopwatch()..start();
      await tester.enterText(firstNameField, 'محمد');
      await tester.pump();
      stopwatch.stop();

      // Zero lag target: < 200ms (adjusted for validation + input filters)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(200),
        reason: 'Typing should be instant',
      );

      print('⚡ Typing performance: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Should not rebuild parent widgets', (
      WidgetTester tester,
    ) async {
      int buildCount = 0;

      await tester.pumpWidget(
        appWrapper(
          testDb: testDb,
          child: MaterialApp(
            home: _TestScreenWithCounter(onBuild: () => buildCount++),
          ),
        ),
      );

      final initialCount = buildCount;

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      final field = find.byType(TextField).first;
      await tester.enterText(field, 'Test');
      await tester.pump();

      expect(buildCount, equals(initialCount));
      print('✅ No parent rebuilds: $buildCount');
    });
  });
}

class _TestScreen extends StatelessWidget {
  const _TestScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const ZeroLagFamilyDialog(
                isDeceased: true,
                presetDeceasedType: 1,
                onSave: _dummySave,
              ),
            );
          },
          child: const Text('Open Dialog'),
        ),
      ),
    );
  }
}

class _TestScreenWithCounter extends StatelessWidget {
  final VoidCallback onBuild;

  const _TestScreenWithCounter({required this.onBuild});

  @override
  Widget build(BuildContext context) {
    onBuild();
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const ZeroLagFamilyDialog(
                onSave: _dummySave,
              ),
            );
          },
          child: const Text('Open Dialog'),
        ),
      ),
    );
  }
}

void _dummySave(Map<String, dynamic> data) {}
