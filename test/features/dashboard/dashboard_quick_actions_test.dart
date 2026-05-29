import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/widgets/quick_actions.dart';
import '../../test_helpers/widget_wrapper.dart';

void main() {
  group('QuickActionsGrid', () {
    late AppDatabase testDb;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      testDb = AppDatabase(NativeDatabase.memory());
    });

    tearDownAll(() async {
      await testDb.close();
    });

    Widget buildGrid() => appWrapper(
          testDb: testDb,
          child: QuickActionsGrid(
            onAddBeneficiaryTap: () {},
            onSearchTap: () {},
            onVisitsTap: () {},
            onKafalatTap: () {},
            onAssociationsTap: () {},
            onSyncTap: () {},
          ),
        );

    // ── اختبار وجود الإجراءات الستة الصحيحة ─────────────────────────────────

    testWidgets('يعرض "إضافة مستفيد"', (tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pump();
      expect(find.text('إضافة مستفيد'), findsOneWidget);
    });

    testWidgets('يعرض "المستفيدون"', (tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pump();
      expect(find.text('المستفيدون'), findsOneWidget);
    });

    testWidgets('يعرض "زيارات اليوم"', (tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pump();
      expect(find.text('زيارات اليوم'), findsOneWidget);
    });

    testWidgets('يعرض "الكفالات"', (tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pump();
      expect(find.text('الكفالات'), findsOneWidget);
    });

    testWidgets('يعرض "الجمعيات"', (tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pump();
      expect(find.text('الجمعيات'), findsOneWidget);
    });

    testWidgets('يعرض "المزامنة"', (tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pump();
      expect(find.text('المزامنة'), findsOneWidget);
    });

    // ── اختبار عدم وجود إجراءات ممنوعة ──────────────────────────────────────

    testWidgets('لا يعرض "التقارير"', (tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pump();
      expect(find.text('التقارير'), findsNothing);
    });

    testWidgets('لا يعرض "السجل المدني"', (tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pump();
      expect(find.textContaining('السجل المدني'), findsNothing);
    });

    testWidgets('لا يعرض "Debug" أو "Test" أو "Seed"', (tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pump();
      expect(find.textContaining('Debug'), findsNothing);
      expect(find.textContaining('Test'), findsNothing);
      expect(find.textContaining('Seed'), findsNothing);
    });

    // ── اختبار أن الكفالات والجمعيات تظهر حتى بدون callbacks ────────────────

    testWidgets('يعرض الكفالات والجمعيات حتى بدون callbacks', (tester) async {
      await tester.pumpWidget(
        appWrapper(
          testDb: testDb,
          child: const QuickActionsGrid(), // بدون callbacks
        ),
      );
      await tester.pump();
      expect(find.text('الكفالات'), findsOneWidget);
      expect(find.text('الجمعيات'), findsOneWidget);
    });

    // ── اختبار badge المزامنة ─────────────────────────────────────────────────

    testWidgets('يعرض badge المزامنة عند وجود سجلات معلقة', (tester) async {
      await tester.pumpWidget(
        appWrapper(
          testDb: testDb,
          child: QuickActionsGrid(
            onSyncTap: () {},
            syncBadge: 5,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('5'), findsOneWidget);
    });

    // ── اختبار RTL ────────────────────────────────────────────────────────────

    testWidgets('يعمل في وضع RTL بدون overflow', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: buildGrid(),
        ),
      );
      await tester.pump();
      // لا يجب أن يكون هناك overflow
      expect(tester.takeException(), isNull);
    });

    // ── اختبار النقر ─────────────────────────────────────────────────────────

    testWidgets('يستدعي onAddBeneficiaryTap عند النقر', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        appWrapper(
          testDb: testDb,
          child: QuickActionsGrid(
            onAddBeneficiaryTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();
      // QuickActionCard يلف GestureDetector خارج Card — ننقر على Card الأول
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
