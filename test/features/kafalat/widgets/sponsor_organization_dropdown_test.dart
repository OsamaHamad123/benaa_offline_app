import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/kafalat/presentation/providers/kafalat_providers.dart';
import 'package:benaa_offline_app/features/kafalat/presentation/widgets/common/sponsor_organization_dropdown.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

Association _makeAssociation({required String id, required String name}) {
  final now = DateTime(2026, 1, 1);
  return Association(
    id: id,
    name: name,
    phone: '07700000000',
    bankName: 'بنك الرافدين',
    accountNumber: '000000',
    isActive: true,
    createdAt: now,
    updatedAt: now,
    syncState: 'synced',
  );
}

Widget _build(
  Widget child, {
  required List<Override> overrides,
  Size screenSize = const Size(360, 800),
}) {
  return ProviderScope(
    overrides: overrides,
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (_, __) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQueryData(size: screenSize),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// ─── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Loading state ────────────────────────────────────────────────────────────
  group('SponsorOrganizationDropdown — loading state', () {
    testWidgets('يعرض LinearProgressIndicator أثناء التحميل', (tester) async {
      await tester.pumpWidget(
        _build(
          SponsorOrganizationDropdown(value: null, onChanged: (_) {}),
          overrides: [
            kafalatActiveAssociationsProvider.overrideWith(
              (ref) => Future.delayed(const Duration(minutes: 1), () => []),
            ),
          ],
        ),
      );
      // لا pump إضافي — نبقى في حالة loading
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('لا overflow أثناء التحميل في شاشة ضيقة', (tester) async {
      await tester.pumpWidget(
        _build(
          SponsorOrganizationDropdown(value: null, onChanged: (_) {}),
          overrides: [
            kafalatActiveAssociationsProvider.overrideWith(
              (ref) => Future.delayed(const Duration(minutes: 1), () => []),
            ),
          ],
          screenSize: const Size(300, 600),
        ),
      );
      // لا overflow = لا exception
      expect(tester.takeException(), isNull);
    });
  });

  // ── Error state ──────────────────────────────────────────────────────────────
  group('SponsorOrganizationDropdown — error state', () {
    testWidgets('يعرض رسالة الخطأ', (tester) async {
      await tester.pumpWidget(
        _build(
          SponsorOrganizationDropdown(value: null, onChanged: (_) {}),
          overrides: [
            kafalatActiveAssociationsProvider.overrideWith(
              (ref) => Future.error('network error'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('فشل تحميل المؤسسات'), findsOneWidget);
    });
  });

  // ── Empty state ──────────────────────────────────────────────────────────────
  group('SponsorOrganizationDropdown — empty state', () {
    testWidgets('يعرض رسالة "لا توجد مؤسسات" بدون overflow', (tester) async {
      await tester.pumpWidget(
        _build(
          SponsorOrganizationDropdown(value: null, onChanged: (_) {}),
          overrides: [
            kafalatActiveAssociationsProvider.overrideWith(
              (ref) => Future.value([]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('لا توجد مؤسسات كافلة متاحة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Data state ───────────────────────────────────────────────────────────────
  group('SponsorOrganizationDropdown — data state', () {
    final shortAssoc = _makeAssociation(id: 'a1', name: 'جمعية الأمل');
    final longAssoc = _makeAssociation(
      id: 'a2',
      name: 'مؤسسة الكافلة للتنمية الاجتماعية والخدمات الإنسانية طويلة الاسم جداً',
    );
    final longEnAssoc = _makeAssociation(
      id: 'a3',
      name: 'Al-Kafala International Sponsorship Organization For Humanitarian Development',
    );

    testWidgets('يعرض Dropdown بدون overflow مع اسم قصير', (tester) async {
      await tester.pumpWidget(
        _build(
          SponsorOrganizationDropdown(
            value: shortAssoc.id,
            onChanged: (_) {},
          ),
          overrides: [
            kafalatActiveAssociationsProvider.overrideWith(
              (ref) => Future.value([shortAssoc]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('يعرض اسم المؤسسة الطويل (عربي) بدون overflow في شاشة ضيقة', (tester) async {
      await tester.pumpWidget(
        _build(
          SponsorOrganizationDropdown(
            value: longAssoc.id,
            onChanged: (_) {},
          ),
          overrides: [
            kafalatActiveAssociationsProvider.overrideWith(
              (ref) => Future.value([longAssoc]),
            ),
          ],
          screenSize: const Size(300, 600),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('يعرض اسم المؤسسة الطويل (إنجليزي) بدون overflow', (tester) async {
      await tester.pumpWidget(
        _build(
          SponsorOrganizationDropdown(
            value: longEnAssoc.id,
            onChanged: (_) {},
          ),
          overrides: [
            kafalatActiveAssociationsProvider.overrideWith(
              (ref) => Future.value([longEnAssoc]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('يعمل بدون overflow مع عدة مؤسسات وأسماء متنوعة', (tester) async {
      await tester.pumpWidget(
        _build(
          SponsorOrganizationDropdown(
            value: null,
            onChanged: (_) {},
          ),
          overrides: [
            kafalatActiveAssociationsProvider.overrideWith(
              (ref) => Future.value([shortAssoc, longAssoc, longEnAssoc]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('يعمل في RTL بدون overflow', (tester) async {
      await tester.pumpWidget(
        _build(
          SponsorOrganizationDropdown(
            value: longAssoc.id,
            onChanged: (_) {},
          ),
          overrides: [
            kafalatActiveAssociationsProvider.overrideWith(
              (ref) => Future.value([shortAssoc, longAssoc]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final directionality = tester.widget<Directionality>(find.byType(Directionality).first);
      expect(directionality.textDirection, TextDirection.rtl);
      expect(tester.takeException(), isNull);
    });

    testWidgets('يستدعي onChanged عند اختيار مؤسسة', (tester) async {
      String? chosen;
      await tester.pumpWidget(
        _build(
          SponsorOrganizationDropdown(
            value: null,
            onChanged: (v) => chosen = v,
          ),
          overrides: [
            kafalatActiveAssociationsProvider.overrideWith(
              (ref) => Future.value([shortAssoc, longAssoc]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // افتح القائمة
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // اختر الجمعية الأولى
      await tester.tap(find.text(shortAssoc.name).last);
      await tester.pumpAndSettle();

      expect(chosen, equals(shortAssoc.id));
    });

    testWidgets('disabled عند enabled: false', (tester) async {
      String? chosen;
      await tester.pumpWidget(
        _build(
          SponsorOrganizationDropdown(
            value: null,
            onChanged: (v) => chosen = v,
            enabled: false,
          ),
          overrides: [
            kafalatActiveAssociationsProvider.overrideWith(
              (ref) => Future.value([shortAssoc]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // محاولة فتح القائمة
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // لم يتغير chosen
      expect(chosen, isNull);
    });
  });

  // ── Narrow container ─────────────────────────────────────────────────────────
  group('SponsorOrganizationDropdown — شاشات ضيقة جداً', () {
    testWidgets('يعمل في container عرضه 280dp', (tester) async {
      final assoc = _makeAssociation(
        id: 'x',
        name: 'جمعية الرحمة العالمية لرعاية الأيتام والأسر المتعففة - فرع المدينة',
      );
      await tester.pumpWidget(
        _build(
          SizedBox(
            width: 280,
            child: SponsorOrganizationDropdown(
              value: assoc.id,
              onChanged: (_) {},
            ),
          ),
          overrides: [
            kafalatActiveAssociationsProvider.overrideWith(
              (ref) => Future.value([assoc]),
            ),
          ],
          screenSize: const Size(320, 600),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
