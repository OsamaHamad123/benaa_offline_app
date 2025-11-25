import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart' as db;
import 'package:benaa_offline_app/core/providers/providers.dart';

import 'package:benaa_offline_app/app.dart';

void main() {
  late db.AppDatabase testDb;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    testDb = db.AppDatabase(NativeDatabase.memory());
  });

  tearDownAll(() async {
    await testDb.close();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(testDb)],
        child: const BenaaApp(),
      ),
    );

    // Verify app launches without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
