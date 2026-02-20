import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:benaa_offline_app/features/search/data/datasources/civil_registry_database.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/beneficiary_builder.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';

void main() {
  // Setup sqflite ffi for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Diagnostic: Beneficiary Creation & Civil Registry', () {
    test('Check Civil Registry Access', () async {
      print('🔍 Testing Civil Registry Availability...');
      // We use the static method to check if the file exists
      final isAvail = await CivilRegistryDatabase.isAvailable();
      print('Registry Available: $isAvail');

      if (isAvail) {
        try {
          final db = CivilRegistryDatabase.instance;
          // Trigger DB initialization
          await db.database;
          print('✅ Database connection established');

          final startTime = DateTime.now();
          final result = await db.searchByNationalId('12345678'); // Test ID
          final endTime = DateTime.now();

          print('⏱️ Search took: ${endTime.difference(startTime).inMilliseconds}ms');
          print('Result: $result');
        } catch (e) {
          print('❌ Database Crash/Error: $e');
        }
      } else {
        print('⚠️ Civil Registry file not found. Skipping DB tests.');
      }
    });

    test('Test Beneficiary Builder Logic', () {
      print('🏗️ Testing Beneficiary Building Logic...');
      final controllers = BeneficiaryFormControllers();

      try {
        controllers.firstNameController.text = 'Mohammad';
        controllers.lastNameController.text = 'Gaza';
        controllers.nationalIdController.text = '123456789';
        controllers.selectedGender = 'ذكر';

        final beneficiary = BeneficiaryEntityBuilder.build(
          controllers: controllers,
          existingId: null,
          existingFileNo: null,
          existingCreatedAt: null,
        );

        print('✅ Beneficiary built successfully: ${beneficiary.fullName}');
      } catch (e, stack) {
        print('❌ Builder Crash: $e');
        print(stack);
      }
    });
  });
}
