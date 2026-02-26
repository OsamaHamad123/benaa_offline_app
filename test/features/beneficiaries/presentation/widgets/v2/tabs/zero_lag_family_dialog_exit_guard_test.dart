import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/zero_lag_family_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('unsaved changes guard keeps dialog open on continue and closes on save draft', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => ZeroLagFamilyDialog(
                      onSave: (_) {},
                    ),
                  );
                },
                child: const Text('open-dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-dialog'));
    await tester.pumpAndSettle();

    expect(find.byType(ZeroLagFamilyDialog), findsOneWidget);

    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);

    await tester.enterText(textFields.first, 'محمد');
    await tester.pumpAndSettle();

    await tester.tap(find.text('إلغاء').first);
    await tester.pumpAndSettle();

    expect(find.text('تغييرات غير محفوظة'), findsOneWidget);

    await tester.tap(find.text('متابعة التحرير'));
    await tester.pumpAndSettle();

    expect(find.byType(ZeroLagFamilyDialog), findsOneWidget);

    await tester.tap(find.text('إلغاء').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('حفظ مسودة ثم خروج'));
    await tester.pumpAndSettle();

    expect(find.byType(ZeroLagFamilyDialog), findsNothing);
  });
}
