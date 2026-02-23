import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/widgets/bottom_navigation_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildHarness(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) {
      return MaterialApp(
        home: Scaffold(body: child),
      );
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BottomNavigationButtons triggers next and previous callbacks', (tester) async {
    var nextCalled = false;
    var previousCalled = false;

    await tester.pumpWidget(
      _buildHarness(
        BottomNavigationButtons(
          currentTab: 2,
          totalTabs: 5,
          onPrevious: () => previousCalled = true,
          onNext: () => nextCalled = true,
          onSave: () {},
        ),
      ),
    );

    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('السابق'));
    await tester.pumpAndSettle();

    expect(nextCalled, isTrue);
    expect(previousCalled, isTrue);
  });

  testWidgets('BottomNavigationButtons triggers save on last tab', (tester) async {
    var saveCalled = false;

    await tester.pumpWidget(
      _buildHarness(
        BottomNavigationButtons(
          currentTab: 4,
          totalTabs: 5,
          onPrevious: () {},
          onNext: () {},
          onSave: () => saveCalled = true,
        ),
      ),
    );

    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(saveCalled, isTrue);
  });
}
