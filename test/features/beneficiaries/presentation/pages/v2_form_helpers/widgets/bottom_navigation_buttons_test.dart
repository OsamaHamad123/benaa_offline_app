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

Widget _buildHarnessWithSize(Widget child, Size size) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) {
      return MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(
          home: Scaffold(body: child),
        ),
      );
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BottomNavigationButtons triggers next and previous callbacks', (tester) async {
    var nextCalled = false;
    var previousCalled = false;
    var saveDraftCalled = false;

    await tester.pumpWidget(
      _buildHarness(
        BottomNavigationButtons(
          currentTab: 2,
          totalTabs: 5,
          onPrevious: () => previousCalled = true,
          onNext: () => nextCalled = true,
          onSave: () {},
          onSaveDraft: () => saveDraftCalled = true,
        ),
      ),
    );

    await tester.tap(find.text('حفظ مسودة'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('السابق'));
    await tester.pumpAndSettle();

    expect(nextCalled, isTrue);
    expect(previousCalled, isTrue);
    expect(saveDraftCalled, isTrue);
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
          onSaveDraft: () {},
        ),
      ),
    );

    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(saveCalled, isTrue);
  });

  testWidgets('BottomNavigationButtons shows overflow draft action on compact screens', (tester) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(320, 700));

    var saveDraftCalled = false;

    await tester.pumpWidget(
      _buildHarnessWithSize(
        BottomNavigationButtons(
          currentTab: 1,
          totalTabs: 5,
          onPrevious: () {},
          onNext: () {},
          onSave: () {},
          onSaveDraft: () => saveDraftCalled = true,
        ),
        const Size(320, 700),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('حفظ مسودة'));
    await tester.pumpAndSettle();

    expect(saveDraftCalled, isTrue);
  });

  testWidgets('BottomNavigationButtons shows inline draft button on regular phone screens', (tester) async {
    await tester.pumpWidget(
      _buildHarnessWithSize(
        BottomNavigationButtons(
          currentTab: 1,
          totalTabs: 5,
          onPrevious: () {},
          onNext: () {},
          onSave: () {},
          onSaveDraft: () {},
        ),
        const Size(390, 844),
      ),
    );

    expect(find.text('حفظ مسودة'), findsOneWidget);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });

  testWidgets('BottomNavigationButtons keeps inline draft button on tablet screens', (tester) async {
    await tester.pumpWidget(
      _buildHarnessWithSize(
        BottomNavigationButtons(
          currentTab: 1,
          totalTabs: 5,
          onPrevious: () {},
          onNext: () {},
          onSave: () {},
          onSaveDraft: () {},
        ),
        const Size(800, 1280),
      ),
    );

    expect(find.text('حفظ مسودة'), findsOneWidget);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });
}
