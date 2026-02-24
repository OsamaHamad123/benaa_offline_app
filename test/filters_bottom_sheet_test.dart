import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/list/filters_provider.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/list_widgets/filters_bottom_sheet.dart';
import 'test_helpers/widget_wrapper.dart';
import 'package:benaa_offline_app/core/providers/providers.dart';

/// 🧪 Widget Tests للـ Filters Bottom Sheet
void main() {
  late AppDatabase testDb;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    testDb = AppDatabase(NativeDatabase.memory());
  });

  tearDownAll(() async {
    await testDb.close();
  });

  testWidgets('FiltersBottomSheet displays category chips', (tester) async {
    await tester.pumpWidget(
      appWrapper(
        testDb: testDb,
        child: Builder(
          builder: (context) => MaterialApp(
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
      ),
    );

    // Open bottom sheet
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    // Base category chip should always be visible
    expect(find.text('الكل'), findsWidgets);

    // Dynamic section chips are rendered as tappable containers
    final tappableChips = find.byType(InkWell);
    expect(tappableChips, findsWidgets);
  });

  testWidgets('FiltersBottomSheet displays sort options', (tester) async {
    await tester.pumpWidget(
      appWrapper(
        testDb: testDb,
        child: Builder(
          builder: (context) => MaterialApp(
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
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(testDb)],
    );

    await tester.pumpWidget(
      appWrapper(
        testDb: testDb,
        child: UncontrolledProviderScope(
          container: container,
          child: Builder(
            builder: (context) => MaterialApp(
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
