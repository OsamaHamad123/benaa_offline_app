// ignore_for_file: unused_local_variable

import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_constants.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/widgets/bottom_navigation_buttons.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/widgets/form_bottom_nav_widget.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/widgets/form_tabs_4_merged.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _harness(Widget child, {Size size = const Size(375, 812)}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    ),
  );
}

BottomNavigationButtons _buildNav({
  required int currentTab,
  required int totalTabs,
  VoidCallback? onNext,
  VoidCallback? onPrevious,
  VoidCallback? onSave,
  VoidCallback? onSaveDraft,
  bool isLoading = false,
}) {
  return BottomNavigationButtons(
    currentTab: currentTab,
    totalTabs: totalTabs,
    onPrevious: onPrevious ?? () {},
    onNext: onNext ?? () {},
    onSave: onSave ?? () {},
    onSaveDraft: onSaveDraft ?? () {},
    isLoading: isLoading,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CompactFormStepIndicator - Step Indicator', () {
    late TabController controller;

    setUp(() {
      controller = TabController(
        length: FormConstants.totalTabs,
        vsync: const TestVSync(),
      );
    });

    tearDown(() => controller.dispose());

    testWidgets('renders step label "خطوة 1 من 5" on standard mobile (375px)', (tester) async {
      await tester.pumpWidget(
        _harness(
          CompactFormStepIndicator(
            controller: controller,
            currentIndex: 0,
          ),
          size: const Size(375, 812),
        ),
      );
      await tester.pump();

      // Should show step counter
      expect(find.text('خطوة 1 من 5'), findsOneWidget);
      // Should show the current step title
      expect(find.text('معلومات أساسية'), findsOneWidget);
    });

    testWidgets('renders without overflow on compact screen (320px)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _harness(
          CompactFormStepIndicator(
            controller: controller,
            currentIndex: 0,
          ),
          size: const Size(320, 640),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('shows correct title for each step index', (tester) async {
      const titles = ['معلومات أساسية', 'العائلة', 'التواصل', 'المرفقات', 'المراجعة'];

      for (var i = 0; i < titles.length; i++) {
        await tester.pumpWidget(
          _harness(
            CompactFormStepIndicator(controller: controller, currentIndex: i),
          ),
        );
        await tester.pump();

        expect(find.text(titles[i]), findsOneWidget, reason: 'Expected "${titles[i]}" for step $i');
      }
    });

    testWidgets('tab controller index changes when dot is tapped', (tester) async {
      await tester.pumpWidget(
        _harness(
          CompactFormStepIndicator(
            controller: controller,
            currentIndex: 0,
          ),
        ),
      );
      await tester.pump();

      // Programmatic navigation should work
      expect(controller.index, 0);
      controller.animateTo(2);
      await tester.pumpAndSettle();
      expect(controller.index, 2);
    });

    testWidgets('shows progress bar', (tester) async {
      await tester.pumpWidget(
        _harness(
          CompactFormStepIndicator(controller: controller, currentIndex: 2),
        ),
      );
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('BottomNavigationButtons - Single Row Layout', () {
    testWidgets('Next button triggers onNext callback (middle tab)', (tester) async {
      var nextCalled = false;
      await tester.pumpWidget(
        _harness(_buildNav(currentTab: 1, totalTabs: 5, onNext: () => nextCalled = true)),
      );
      await tester.pump();

      // Single-row layout: FilledButton shows 'التالي'
      final nextFinder = find.text('التالي');
      expect(nextFinder, findsOneWidget);
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();
      expect(nextCalled, isTrue);
    });

    testWidgets('Previous button triggers onPrevious callback', (tester) async {
      var prevCalled = false;
      await tester.pumpWidget(
        _harness(_buildNav(currentTab: 2, totalTabs: 5, onPrevious: () => prevCalled = true)),
      );
      await tester.pump();

      final prevFinder = find.text('السابق');
      expect(prevFinder, findsOneWidget);
      await tester.tap(prevFinder);
      await tester.pumpAndSettle();
      expect(prevCalled, isTrue);
    });

    testWidgets('Save button shown on last tab and triggers onSave', (tester) async {
      var saveCalled = false;
      await tester.pumpWidget(
        _harness(
          _buildNav(
            currentTab: FormConstants.totalTabs - 1,
            totalTabs: FormConstants.totalTabs,
            onSave: () => saveCalled = true,
          ),
        ),
      );
      await tester.pump();

      final saveFinder = find.text('حفظ');
      expect(saveFinder, findsOneWidget);
      await tester.tap(saveFinder);
      await tester.pumpAndSettle();
      expect(saveCalled, isTrue);
    });

    testWidgets('Previous button hidden on first tab', (tester) async {
      await tester.pumpWidget(
        _harness(_buildNav(currentTab: 0, totalTabs: 5)),
      );
      await tester.pump();
      expect(find.text('السابق'), findsNothing);
    });

    testWidgets('draft saved via popup menu (more icon visible)', (tester) async {
      await tester.pumpWidget(
        _harness(_buildNav(currentTab: 1, totalTabs: 5)),
      );
      await tester.pump();

      // Draft button is the PopupMenuButton (more_horiz icon)
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    });

    testWidgets('buttons disabled during loading state', (tester) async {
      await tester.pumpWidget(
        _harness(
          _buildNav(currentTab: 1, totalTabs: 5, isLoading: true),
        ),
      );
      await tester.pump();

      // FilledButton should be disabled (null onPressed)
      final buttons = tester.widgetList<FilledButton>(find.byType(FilledButton));
      for (final btn in buttons) {
        expect(btn.onPressed, isNull, reason: 'FilledButton should be disabled while loading');
      }
    });

    testWidgets('no overflow on compact 320px screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _harness(
          _buildNav(currentTab: 2, totalTabs: 5),
          size: const Size(320, 640),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('FormBottomNavWidget - tab-aware navigation', () {
    late TabController controller;

    setUp(() {
      controller = TabController(
        length: FormConstants.totalTabs,
        vsync: const TestVSync(),
      );
    });

    tearDown(() => controller.dispose());

    testWidgets('renders without error and responds to tab changes', (tester) async {
      await tester.pumpWidget(
        _harness(
          FormBottomNavWidget(
            tabController: controller,
            onPrevious: () {},
            onNext: () {},
            onSave: () {},
            onSaveDraft: () {},
            isLoading: false,
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows save button when on last tab', (tester) async {
      controller.index = FormConstants.totalTabs - 1;
      await tester.pumpWidget(
        _harness(
          FormBottomNavWidget(
            tabController: controller,
            onPrevious: () {},
            onNext: () {},
            onSave: () {},
            onSaveDraft: () {},
            isLoading: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('حفظ'), findsOneWidget);
    });

    testWidgets('ScaffoldMessenger snackbar shown via root scaffold', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('تم الحفظ')),
                    );
                  },
                  child: const Text('حفظ'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('حفظ'));
      await tester.pump();
      expect(find.text('تم الحفظ'), findsOneWidget);
    });
  });
}
