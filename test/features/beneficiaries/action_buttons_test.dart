import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/details_widgets/sections/action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildHost({VoidCallback? onOpenRelations}) {
    return MaterialApp(
      home: Scaffold(
        body: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => ActionButtons(
            onEdit: () {},
            onAddVisit: () {},
            onOpenRelations: onOpenRelations,
          ),
        ),
      ),
    );
  }

  testWidgets('renders relations action when callback provided', (tester) async {
    await tester.pumpWidget(buildHost(onOpenRelations: () {}));
    await tester.pumpAndSettle();

    expect(find.text('العلاقات والمتابعة'), findsOneWidget);
  });

  testWidgets('fires relations callback on tap', (tester) async {
    var called = false;
    await tester.pumpWidget(buildHost(onOpenRelations: () => called = true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('العلاقات والمتابعة'));
    await tester.pump();

    expect(called, isTrue);
  });
}
