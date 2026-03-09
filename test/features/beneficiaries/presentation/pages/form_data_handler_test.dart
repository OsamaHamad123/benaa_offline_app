import 'package:benaa_offline_app/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_controllers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/form_data_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BeneficiaryFormDataHandler.buildBeneficiary', () {
    test('parses taxonomy codes safely (category, relationship, section, gender)', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      controllers.firstNameController.text = 'محمد';
      controllers.fatherNameController.text = 'أحمد';
      controllers.lastNameController.text = 'علي';
      controllers.nationalIdController.text = '123456789';

      controllers.selectedGender = '1';
      controllers.selectedCategory = '3';
      controllers.selectedRelationship = '4';
      controllers.selectedSection = '12';
      controllers.selectedEmploymentStatus = '2';
      controllers.selectedDisplacementStatus = '1';
      controllers.selectedHousingStatus = '2';
      controllers.selectedHousingType = '5';

      final entity = BeneficiaryFormDataHandler.buildBeneficiary(
        controllers: controllers,
        beneficiaryId: null,
        fileNo: 'F-100',
        createdAt: DateTime(2026),
      );

      expect(entity.gender, Gender.male);
      expect(entity.category, BeneficiaryCategory.widow);
      expect(entity.relationship, 4);
      expect(entity.sectionId, 12);
      expect(entity.employmentStatus, EmploymentStatus.unemployed);
      expect(entity.displacementStatus, DisplacementStatus.displaced);
      expect(entity.housingStatus, HousingStatus.rented);
      expect(entity.housingType, HousingType.caravan);
    });

    test('parses label/name values without falling to incorrect defaults', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      controllers.firstNameController.text = 'سارة';
      controllers.fatherNameController.text = 'حسين';
      controllers.lastNameController.text = 'عبدالله';
      controllers.nationalIdController.text = '987654321';

      controllers.selectedGender = 'أنثى';
      controllers.selectedCategory = 'orphan';
      controllers.selectedMaritalStatus = 'متزوج/متزوجة';
      controllers.selectedEducationLevel = 'bachelor';
      controllers.selectedHealthStatus = 'مزمن';

      final entity = BeneficiaryFormDataHandler.buildBeneficiary(
        controllers: controllers,
        beneficiaryId: 'B-1',
        fileNo: 'F-200',
        createdAt: DateTime(2026, 1, 2),
      );

      expect(entity.gender, Gender.female);
      expect(entity.category, BeneficiaryCategory.orphan);
      expect(entity.maritalStatus, MaritalStatus.married);
      expect(entity.educationLevel, EducationLevel.bachelor);
      expect(entity.healthStatus, HealthStatus.chronicDisease);
    });

    test('supports taxonomy-style ids and keeps official file id value', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      controllers.firstNameController.text = 'ليان';
      controllers.fatherNameController.text = 'عمر';
      controllers.lastNameController.text = 'خالد';
      controllers.nationalIdController.text = '111222333';

      controllers.selectedGender = 'female';
      controllers.selectedCategory = '2';
      controllers.selectedRelationship = 'relationship::9';
      controllers.selectedSection = 'section_14';

      final entity = BeneficiaryFormDataHandler.buildBeneficiary(
        controllers: controllers,
        beneficiaryId: null,
        fileNo: '9001',
        createdAt: DateTime(2026, 2, 26),
      );

      expect(entity.relationship, 9);
      expect(entity.sectionId, 14);
      expect(entity.fileNo, '9001');
      expect(entity.fileIdNumber, '9001');
    });
  });

  group('BeneficiaryFormDataHandler.populateControllers', () {
    test('strips metadata suffix from notes and restores taxonomy payload fields', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      const rawNotes = 'ملاحظة ميدانية مهمة\n\n#meta:{"assistanceType":"2","incomeSource":"5"}';
      final beneficiary = Beneficiary(
        id: 'B-10',
        fullName: 'محمد أحمد علي',
        nationalId: '123456789',
        gender: Gender.male,
        category: BeneficiaryCategory.widow,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        notes: rawNotes,
      );

      BeneficiaryFormDataHandler.populateControllers(
        controllers,
        beneficiary,
        (apply) => apply(),
      );

      expect(controllers.notesController.text, 'ملاحظة ميدانية مهمة');
      expect(controllers.selectedAssistanceType, '2');
      expect(controllers.selectedIncomeSource, '5');
    });

    test('restores specialNeedsCount and infers disability when count is positive', () {
      final controllers = BeneficiaryFormControllers();
      addTearDown(controllers.dispose);

      final beneficiary = Beneficiary(
        id: 'B-11',
        fullName: 'سارة حسين عبدالله',
        nationalId: '987654321',
        gender: Gender.female,
        category: BeneficiaryCategory.orphan,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        hasDisability: false,
        specialNeedsCount: 2,
      );

      BeneficiaryFormDataHandler.populateControllers(
        controllers,
        beneficiary,
        (apply) => apply(),
      );

      expect(controllers.specialNeedsCountController.text, '2');
      expect(controllers.hasDisability, isTrue);
    });
  });
}
