import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/visits/presentation/pages/visits_list_page_m3.dart';
import 'package:benaa_offline_app/features/visits/presentation/providers/visit_providers.dart'
    as visit_providers;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the filter chips fit a 390-wide phone without overflowing',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [visit_providers.databaseProvider.overrideWithValue(db)],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, child) => MaterialApp(
            home:
                Directionality(textDirection: TextDirection.rtl, child: child!),
          ),
          child: const VisitsListPageM3(),
        ),
      ),
    );
    await tester.pump();

    // Regression: the three chips sat in a plain Row and overflowed by ~191 px.
    expect(tester.takeException(), isNull);
    expect(find.text('قيد المزامنة'), findsOneWidget);
  });
}
