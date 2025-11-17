import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/list/filters_provider.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/list_widgets/filters_bottom_sheet.dart';

/// 🧪 Widget Tests للـ Filters Bottom Sheet
void main() {
  testWidgets('FiltersBottomSheet displays category chips', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => const FiltersBottomSheet(),
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open bottom sheet
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    // Category chips should be visible
    expect(find.text('الكل'), findsWidgets);
    expect(find.text('يتيم'), findsOneWidget);
    expect(find.text('أرملة'), findsOneWidget);
    expect(find.text('فقير'), findsOneWidget);
    expect(find.text('معاق'), findsOneWidget);
  });

  testWidgets('FiltersBottomSheet displays sort options', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => const FiltersBottomSheet(),
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    // Sort options
    expect(find.text('الاسم'), findsOneWidget);
    expect(find.text('التاريخ'), findsOneWidget);
    expect(find.text('رقم الملف'), findsOneWidget);
    expect(find.text('العمر'), findsOneWidget);
  });

  testWidgets('FiltersBottomSheet toggles pending sync filter', (tester) async {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => const FiltersBottomSheet(),
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    // Find pending sync switch
    final switches = find.byType(Switch);
    expect(switches, findsWidgets); // Multiple switches exist

    // Toggle first switch (pending sync)
    await tester.tap(switches.first);
    await tester.pumpAndSettle();

    // Verify state changed
    final filtersState = container.read(filtersProvider);
    expect(filtersState.onlyPendingSync, true);

    container.dispose();
  });
}
