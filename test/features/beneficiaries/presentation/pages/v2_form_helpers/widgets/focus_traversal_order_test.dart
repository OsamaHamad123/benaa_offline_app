import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/widgets/material3_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildHarness(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('next action follows NumericFocusOrder sequence', (tester) async {
    final focus10 = FocusNode();
    final focus20 = FocusNode();
    final focus30 = FocusNode();

    await tester.pumpWidget(
      buildHarness(
        FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(
            children: [
              FocusTraversalOrder(
                order: const NumericFocusOrder(20),
                child: M3TextField(
                  label: 'field-20',
                  focusNode: focus20,
                ),
              ),
              FocusTraversalOrder(
                order: const NumericFocusOrder(10),
                child: M3TextField(
                  label: 'field-10',
                  focusNode: focus10,
                ),
              ),
              FocusTraversalOrder(
                order: const NumericFocusOrder(30),
                child: M3TextField(
                  label: 'field-30',
                  focusNode: focus30,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    focus10.requestFocus();
    await tester.pump();
    expect(focus10.hasFocus, isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(focus20.hasFocus, isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(focus30.hasFocus, isTrue);

    focus10.dispose();
    focus20.dispose();
    focus30.dispose();
  });

  testWidgets('done action unfocuses field', (tester) async {
    final focus = FocusNode();

    await tester.pumpWidget(
      buildHarness(
        M3TextField(
          label: 'done-field',
          focusNode: focus,
          textInputAction: TextInputAction.done,
        ),
      ),
    );

    focus.requestFocus();
    await tester.pump();
    expect(focus.hasFocus, isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(focus.hasFocus, isFalse);
    focus.dispose();
  });
}
