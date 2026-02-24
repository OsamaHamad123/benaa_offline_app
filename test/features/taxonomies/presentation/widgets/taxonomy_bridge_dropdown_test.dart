import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:benaa_offline_app/features/taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import 'package:benaa_offline_app/features/taxonomies/presentation/widgets/taxonomy_bridge_widgets.dart';

Widget _host({required Widget child, List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ),
  );
}

Taxonomy _taxonomy({
  required String id,
  required String code,
  required String label,
  required TaxonomyGroup group,
}) {
  return Taxonomy(
    id: id,
    group: group,
    code: code,
    label: label,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows loading skeleton while taxonomy options are slow', (tester) async {
    final pendingResult = Completer<List<Taxonomy>>();

    await tester.pumpWidget(
      _host(
        overrides: [
          bridgeTaxonomiesByGroupResolvedOnceProvider.overrideWith(
            (ref, group) => pendingResult.future,
          ),
        ],
        child: const TaxonomyBridgeDropdown(group: TaxonomyGroup.section),
      ),
    );

    expect(find.text('جاري تحميل التصنيف...'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('shows actionable empty state when taxonomy list is empty', (tester) async {
    await tester.pumpWidget(
      _host(
        overrides: [
          bridgeTaxonomiesByGroupResolvedOnceProvider.overrideWith(
            (ref, group) async => const <Taxonomy>[],
          ),
        ],
        child: const TaxonomyBridgeDropdown(group: TaxonomyGroup.section),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('لا توجد بيانات لهذا التصنيف'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    expect(find.text('مزامنة التصنيفات'), findsOneWidget);
  });

  testWidgets('renders dropdown options when taxonomy list is partial but valid', (tester) async {
    await tester.pumpWidget(
      _host(
        overrides: [
          bridgeTaxonomiesByGroupResolvedOnceProvider.overrideWith(
            (ref, group) async => <Taxonomy>[
              _taxonomy(
                id: 'section::1',
                code: '1',
                label: 'يتيم',
                group: TaxonomyGroup.section,
              ),
            ],
          ),
        ],
        child: const TaxonomyBridgeDropdown(group: TaxonomyGroup.section),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.text('لا توجد بيانات لهذا التصنيف'), findsNothing);
  });

  testWidgets('shows retry UI when taxonomy provider errors', (tester) async {
    await tester.pumpWidget(
      _host(
        overrides: [
          bridgeTaxonomiesByGroupResolvedOnceProvider.overrideWith(
            (ref, group) async => throw Exception('network error'),
          ),
        ],
        child: const TaxonomyBridgeDropdown(group: TaxonomyGroup.section),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('تعذر تحميل بيانات القسم.'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });
}
