import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_constants.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/beneficiary_dependencies.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/tabs/v2_personal_info_merged_tab.dart';
import 'package:benaa_offline_app/core/config/app_config.dart';
import 'package:benaa_offline_app/core/network/api_client.dart';
import 'package:benaa_offline_app/core/sync/presentation/providers/sync_providers.dart' as sync_providers;
import 'package:benaa_offline_app/data/db/drift_database.dart' as db;
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

Widget _host({
  required BeneficiaryFormControllers controllers,
  VoidCallback? onRequestNextTab,
}) {
  final seededTaxonomyIndex = <TaxonomyGroup, List<Taxonomy>>{
    for (final group in TaxonomyGroup.values)
      group: <Taxonomy>[
        Taxonomy(
          id: '${group.value}-1',
          group: group,
          code: '1',
          label: 'خيار ${group.value}',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ],
  };

  return ProviderScope(
    overrides: [
      sync_providers.databaseProvider.overrideWithValue(_testDb),
      sync_providers.apiClientProvider.overrideWithValue(_testApiClient),
      civilRegistryAvailableProvider.overrideWith((ref) async => false),
      bridgeTaxonomiesIndexOnceProvider.overrideWith((ref) => seededTaxonomyIndex),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        home: Scaffold(
          body: V2PersonalInfoMergedTab(
            formControllers: controllers,
            onBirthDateTap: () {},
            onRequestNextTab: onRequestNextTab,
          ),
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

  group('V2PersonalInfoMergedTab critical validation status', () {
    testWidgets('shows critical warning and missing issues when required inputs are empty', (tester) async {
      await tester.pumpWidget(_host(controllers: controllers));
      await tester.pumpAndSettle();

      expect(find.text('تحقق سريع قبل المتابعة:'), findsOneWidget);
      expect(find.textContaining('أدخل الرقم الوطني • أدخل الاسم الأول'), findsOneWidget);
    });

    testWidgets('shows ready state when personal critical fields are complete', (tester) async {
      controllers.nationalIdController.text = '123456789';
      controllers.firstNameController.text = 'محمد';
      controllers.fatherNameController.text = 'أحمد';
      controllers.lastNameController.text = 'خالد';
      controllers.selectedGender = '1';

      await tester.pumpWidget(
        _host(
          controllers: controllers,
          onRequestNextTab: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('المدخلات الحرجة مكتملة. يمكنك المتابعة لباقي الحقول بثقة.'),
        findsOneWidget,
      );
      expect(find.text('تحقق سريع قبل المتابعة:'), findsNothing);
      expect(find.text('انتقل لتبويب العائلة'), findsOneWidget);
      expect(
        controllers.nationalIdController.text.length,
        FormConstants.nationalIdLength,
      );
    });
  });
}
