import 'package:benaa_offline_app/core/widgets/filter_chip_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for Dashboard FilterChipGroup — the 4 time-based filters.
/// Tests widget-level behavior of chip selection and RTL layout.
/// Uses no Firebase, no real DB.

Widget _buildFilterGroup({
  String? selectedFilter,
  ValueChanged<List<String>>? onChanged,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, __) => MaterialApp(
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: FilterChipGroup(
            selectedFilter: selectedFilter,
            onSelectionChanged: onChanged,
            filters: const [
              FilterChipData(label: 'الكل', value: 'all', icon: Icons.grid_view),
              FilterChipData(label: 'اليوم', value: 'today', icon: Icons.today),
              FilterChipData(label: 'هذا الأسبوع', value: 'week', icon: Icons.date_range),
              FilterChipData(label: 'تحتاج متابعة', value: 'urgent', icon: Icons.warning_amber),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('FilterChipGroup — filter labels exist', () {
    testWidgets('يعرض "الكل"', (tester) async {
      await tester.pumpWidget(_buildFilterGroup(selectedFilter: 'all'));
      await tester.pumpAndSettle();
      expect(find.text('الكل'), findsOneWidget);
    });

    testWidgets('يعرض "اليوم"', (tester) async {
      await tester.pumpWidget(_buildFilterGroup(selectedFilter: 'all'));
      await tester.pumpAndSettle();
      expect(find.text('اليوم'), findsOneWidget);
    });

    testWidgets('يعرض "هذا الأسبوع"', (tester) async {
      await tester.pumpWidget(_buildFilterGroup(selectedFilter: 'all'));
      await tester.pumpAndSettle();
      expect(find.text('هذا الأسبوع'), findsOneWidget);
    });

    testWidgets('يعرض "تحتاج متابعة"', (tester) async {
      await tester.pumpWidget(_buildFilterGroup(selectedFilter: 'all'));
      await tester.pumpAndSettle();
      expect(find.text('تحتاج متابعة'), findsOneWidget);
    });
  });

  group('FilterChipGroup — callback behavior', () {
    testWidgets('اختيار "اليوم" يستدعي callback بـ today', (tester) async {
      List<String> received = [];
      await tester.pumpWidget(_buildFilterGroup(
        selectedFilter: 'all',
        onChanged: (v) => received = v,
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('اليوم'));
      await tester.tap(find.text('اليوم'));
      await tester.pumpAndSettle();

      expect(received, contains('today'));
    });

    testWidgets('اختيار "هذا الأسبوع" يستدعي callback بـ week', (tester) async {
      List<String> received = [];
      await tester.pumpWidget(_buildFilterGroup(
        selectedFilter: 'all',
        onChanged: (v) => received = v,
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('هذا الأسبوع'));
      await tester.tap(find.text('هذا الأسبوع'));
      await tester.pumpAndSettle();

      expect(received, contains('week'));
    });

    testWidgets('اختيار "تحتاج متابعة" يستدعي callback بـ urgent', (tester) async {
      List<String> received = [];
      await tester.pumpWidget(_buildFilterGroup(
        selectedFilter: 'all',
        onChanged: (v) => received = v,
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('تحتاج متابعة'));
      await tester.tap(find.text('تحتاج متابعة'));
      await tester.pumpAndSettle();

      expect(received, contains('urgent'));
    });

    testWidgets('اختيار "الكل" يستدعي callback بـ all', (tester) async {
      List<String> received = [];
      await tester.pumpWidget(_buildFilterGroup(
        selectedFilter: 'today',
        onChanged: (v) => received = v,
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('الكل'));
      await tester.tap(find.text('الكل'));
      await tester.pumpAndSettle();

      expect(received, contains('all'));
    });
  });

  group('FilterChipGroup — RTL and layout', () {
    testWidgets('يُعرض بدون overflow في RTL', (tester) async {
      await tester.pumpWidget(_buildFilterGroup(selectedFilter: 'all'));
      await tester.pumpAndSettle();

      // No overflow means no RenderFlex overflow errors
      expect(tester.takeException(), isNull);
      expect(find.byType(FilterChipGroup), findsOneWidget);
    });

    testWidgets('الـ initial selectedFilter يُطبَّق بشكل صحيح', (tester) async {
      await tester.pumpWidget(_buildFilterGroup(selectedFilter: 'week'));
      await tester.pumpAndSettle();
      // Just confirm no crash with a pre-selected filter
      expect(find.text('هذا الأسبوع'), findsOneWidget);
    });
  });
}
