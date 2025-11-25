import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart' as db;
import 'test_helpers/widget_wrapper.dart';
import 'package:benaa_offline_app/core/providers/providers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/list_widgets/bulk_actions_bar.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/list/selection_provider.dart';

/// 🧪 Widget Tests للـ Bulk Actions Bar
void main() {
  late db.AppDatabase testDb;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    testDb = db.AppDatabase(NativeDatabase.memory());
  });

  tearDownAll(() async {
    await testDb.close();
  });

  testWidgets('BulkActionsBar hidden when not in selection mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWrapper(
        testDb: testDb,
        child: const MaterialApp(home: Scaffold(body: BulkActionsBar())),
      ),
    );

    // Should be hidden (SizedBox.shrink)
    expect(find.byType(BulkActionsBar), findsOneWidget);
    expect(find.text('محدد'), findsNothing); // Text not visible
  });

  testWidgets('BulkActionsBar shows when items selected', (tester) async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(testDb)],
    );

    // Start selection mode with 3 items
    container.read(selectionProvider.notifier).selectAll([1, 2, 3]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: BulkActionsBar())),
      ),
    );

    expect(find.text('3 محدد'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    container.dispose();
  });

  testWidgets('Close button deselects all', (tester) async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(testDb)],
    );
    container.read(selectionProvider.notifier).selectAll([1, 2]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: BulkActionsBar())),
      ),
    );

    // Tap close button
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Selection should be cleared
    final selection = container.read(selectionProvider);
    expect(selection.isSelectionMode, false);
    expect(selection.selectedCount, 0);

    container.dispose();
  });
}
