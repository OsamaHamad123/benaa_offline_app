import 'package:benaa_offline_app/core/config/app_config.dart';
import 'package:benaa_offline_app/core/network/api_client.dart';
import 'package:benaa_offline_app/core/sync/presentation/providers/sync_providers.dart' as sync_providers;
import 'package:benaa_offline_app/data/db/drift_database.dart' as db;
import 'package:benaa_offline_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/beneficiary_dependencies.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_contact_notes_merged_tab.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:benaa_offline_app/features/taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

late db.AppDatabase _testDb;
late ApiClient _testApiClient;

Map<TaxonomyGroup, List<Taxonomy>> _seededTaxonomyIndex() {
  final now = DateTime(2026, 1, 1);
  final index = <TaxonomyGroup, List<Taxonomy>>{};

  for (final group in TaxonomyGroup.values) {
    index[group] = <Taxonomy>[
      Taxonomy(
        id: '${group.value}-1',
        group: group,
        code: '1',
        label: 'خيار ${group.value}',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  index[TaxonomyGroup.bankName] = <Taxonomy>[
    Taxonomy(
      id: 'bank-name-301',
      group: TaxonomyGroup.bankName,
      code: '301',
      label: 'بنك فلسطين',
      createdAt: now,
      updatedAt: now,
    ),
  ];

  return index;
}

Widget _host(BeneficiaryFormControllers controllers) {
  return ProviderScope(
    overrides: [
      sync_providers.databaseProvider.overrideWithValue(_testDb),
      sync_providers.apiClientProvider.overrideWithValue(_testApiClient),
      civilRegistryAvailableProvider.overrideWith((ref) async => false),
      bridgeTaxonomiesIndexOnceProvider.overrideWith((ref) => _seededTaxonomyIndex()),
      // Prevent TaxonomyBridgeDropdown realtime-sync from reaching Firebase
      isAuthenticatedProvider.overrideWith((ref) => false),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        home: Scaffold(
          body: V2ContactNotesMergedTab(formControllers: controllers),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BeneficiaryFormControllers controllers;

  setUpAll(() {
    _testDb = db.AppDatabase(NativeDatabase.memory());
    _testApiClient = ApiClient(const AppConfig(apiBaseUrl: 'https://example.com'));
  });

  setUp(() {
    controllers = BeneficiaryFormControllers();
  });

  tearDownAll(() async {
    await _testDb.close();
  });

  tearDown(() {
    controllers.dispose();
  });

  testWidgets('bank taxonomy dropdown fills bank controllers and is preserved in draft map', (tester) async {
    await tester.pumpWidget(_host(controllers));
    await tester.pumpAndSettle();

    final bankDropdownFinder = find.byWidgetPredicate(
      (widget) => widget is DropdownButtonFormField<String> && widget.decoration.labelText == 'اسم البنك',
    );

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(bankDropdownFinder.first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('بنك فلسطين').last);
    await tester.pumpAndSettle();

    expect(controllers.bankNameIdController.text, '301');
    expect(controllers.bankNameLabelController.text, 'بنك فلسطين');

    final usdIbanFieldFinder = find.byWidgetPredicate(
      (widget) => widget is TextFormField && identical(widget.controller, controllers.ibanUsdController),
    );

    await tester.enterText(usdIbanFieldFinder.first, 'PS92PALS000000000400123456702');
    await tester.pumpAndSettle();

    final draftMap = controllers.toMap();
    expect(draftMap['bankNameId'], '301');
    expect(draftMap['bankNameLabel'], 'بنك فلسطين');
    expect(draftMap['ibanUsd'], 'PS92PALS000000000400123456702');
  });
}
