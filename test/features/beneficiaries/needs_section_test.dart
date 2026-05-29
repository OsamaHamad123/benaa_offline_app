import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/details_widgets/sections/needs_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBeneficiary {
  _FakeBeneficiary(this.notes);
  final String notes;
}

void main() {
  testWidgets('hides technical metadata keys and shows clean values', (tester) async {
    final raw =
        '{"needs":["سلة غذائية","مساعدة نقدية","علاج"],"notes":"حالة بحاجة متابعة","metadata":{"data.json":"x","debug":true},"syncStatus":"pending_upload"}';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, __) => NeedsSection(beneficiary: _FakeBeneficiary(raw)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('سلة غذائية'), findsOneWidget);
    expect(find.text('مساعدة نقدية'), findsOneWidget);
    expect(find.text('علاج'), findsOneWidget);
    expect(find.text('حالة بحاجة متابعة'), findsOneWidget);
    expect(find.text('الاحتياجات'), findsOneWidget);
    expect(find.text('ملاحظات'), findsOneWidget);

    expect(find.textContaining('{"needs"'), findsNothing);
    expect(find.textContaining('metadata'), findsNothing);
    expect(find.textContaining('data.json'), findsNothing);
    expect(find.textContaining('syncStatus'), findsNothing);
    expect(find.textContaining('debug'), findsNothing);
  });

  testWidgets('falls back to default note text for raw json-like technical content', (tester) async {
    const raw = '{"metadata":{"raw":"{\"a\":1}"},"payload":{"json":"x"}}';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, __) => NeedsSection(beneficiary: _FakeBeneficiary(raw)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('لا توجد ملاحظات مسجلة'), findsOneWidget);
    expect(find.textContaining('metadata'), findsNothing);
    expect(find.textContaining('data.json'), findsNothing);
    expect(find.textContaining('payload'), findsNothing);
    expect(find.textContaining('json'), findsNothing);
  });
}
