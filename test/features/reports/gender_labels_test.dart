import 'package:benaa_offline_app/core/constants/category_colors.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/data/repositories/reports_repository_impl.dart';
import 'package:benaa_offline_app/features/reports/domain/entities/report_data.dart';
import 'package:benaa_offline_app/features/reports/domain/entities/summary_statistics.dart';
import 'package:benaa_offline_app/features/reports/providers/reports_providers.dart';
import 'package:benaa_offline_app/features/reports/widgets/summary_statistics_widget.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _insertBeneficiary(AppDatabase db, int n, int gender) {
  return db.into(db.beneficiaries).insert(
        BeneficiariesCompanion.insert(
          idNumber: n,
          // full_name is generated from all four name parts, so none may be null.
          firstName: Value('اسم$n'),
          fatherName: const Value('أب'),
          grandFatherName: const Value('جد'),
          familyName: const Value('تجريبي'),
          gender: Value(gender),
          phoneNumber: 599000000 + n,
          altPhoneNumber: 599000100 + n,
        ),
      );
}

void main() {
  test('the repository labels genders with the shared GenderCount labels',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    for (var i = 1; i <= 3; i++) {
      await _insertBeneficiary(db, i, 1);
    }
    for (var i = 4; i <= 5; i++) {
      await _insertBeneficiary(db, i, 2);
    }

    final repository = ReportsRepositoryImpl(
      beneficiariesDao: db.beneficiariesDao,
      taxonomiesDao: db.taxonomiesDao,
    );
    final counts = await repository.getGenderReport();

    expect(
      counts,
      containsAll(const [
        GenderCount(gender: GenderCount.maleLabel, count: 3),
        GenderCount(gender: GenderCount.femaleLabel, count: 2),
      ]),
    );
  });

  testWidgets('the summary card shows the repository gender counts',
      (tester) async {
    // Regression: the card looked for 'ذكر'/'أنثى' while the repository
    // emits 'ذكور'/'إناث', so both counts always read 0.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          summaryStatisticsProvider.overrideWith(
            (ref) async => const SummaryStatistics(
                total: 5, orphans: 1, poor: 2, pending: 0),
          ),
          genderReportProvider.overrideWith(
            (ref) async => const [
              GenderCount(gender: GenderCount.maleLabel, count: 3),
              GenderCount(gender: GenderCount.femaleLabel, count: 2),
            ],
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, child) => MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: child)),
          ),
          child: const SummaryStatisticsWidget(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('60.0%'), findsOneWidget);
    expect(find.text('40.0%'), findsOneWidget);
  });

  test('donut colours recognise the report labels', () {
    expect(GenderColors.getColor(GenderCount.maleLabel), GenderColors.male);
    expect(GenderColors.getColor(GenderCount.femaleLabel), GenderColors.female);
    expect(GenderColors.getColor('ذكر'), GenderColors.male);
    expect(GenderColors.getColor('أنثى'), GenderColors.female);
  });
}
