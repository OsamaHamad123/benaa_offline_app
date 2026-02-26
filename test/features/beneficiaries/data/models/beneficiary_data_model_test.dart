import 'package:flutter_test/flutter_test.dart';

import 'package:benaa_offline_app/features/beneficiaries/data/models/beneficiary_data_model.dart';
import 'package:benaa_offline_app/features/beneficiaries/domain/entities/beneficiary.dart' as entity;

void main() {
  group('BeneficiaryDataModel.fromEntity', () {
    test('maps firstName from fullName and prioritizes sectionId over category code', () {
      final now = DateTime(2026, 2, 23);
      final beneficiary = entity.Beneficiary(
        id: '123',
        fullName: 'أحمد علي حسن',
        nationalId: '400000001',
        gender: entity.Gender.male,
        category: entity.BeneficiaryCategory.orphan,
        sectionId: 7,
        createdAt: now,
        updatedAt: now,
      );

      final model = BeneficiaryDataModel.fromEntity(beneficiary);

      expect(model.firstName, 'أحمد');
      expect(model.sectionId, 7);
    });

    test('parses taxonomy-formatted location values into numeric city/province', () {
      final now = DateTime(2026, 2, 23);
      final beneficiary = entity.Beneficiary(
        id: '124',
        fullName: 'سارة محمد',
        nationalId: '400000002',
        gender: entity.Gender.female,
        category: entity.BeneficiaryCategory.poor,
        governorate: 'governorate::12',
        district: 'province_9',
        createdAt: now,
        updatedAt: now,
      );

      final model = BeneficiaryDataModel.fromEntity(beneficiary);

      expect(model.city, 12);
      expect(model.province, 9);
    });

    test('maps requestStatus and relationship from entity', () {
      final now = DateTime(2026, 2, 23);
      final beneficiary = entity.Beneficiary(
        id: '125',
        fullName: 'محمود يوسف',
        nationalId: '400000003',
        gender: entity.Gender.male,
        category: entity.BeneficiaryCategory.widow,
        requestStatus: entity.RequestStatus.approved,
        relationship: 4,
        createdAt: now,
        updatedAt: now,
      );

      final model = BeneficiaryDataModel.fromEntity(beneficiary);

      expect(model.requestStatus, entity.RequestStatus.approved.code);
      expect(model.relationship, 4);
    });

    test('prioritizes fileIdNumber over legacy fileNo when mapping to model', () {
      final now = DateTime(2026, 2, 23);
      final beneficiary = entity.Beneficiary(
        id: '126',
        fullName: 'آدم ياسر',
        nationalId: '400000005',
        gender: entity.Gender.male,
        category: entity.BeneficiaryCategory.poor,
        fileNo: 'LEGACY-123',
        fileIdNumber: '7777',
        createdAt: now,
        updatedAt: now,
      );

      final model = BeneficiaryDataModel.fromEntity(beneficiary);
      expect(model.fileIdNumber, '7777');
    });
  });

  group('BeneficiaryDataModel.toEntity', () {
    test('round-trips section, relationship, request status, and location values', () {
      final now = DateTime(2026, 2, 23);
      final model = BeneficiaryDataModel(
        id: 200,
        sectionId: 7,
        relationship: 3,
        requestStatus: entity.RequestStatus.completed.code,
        city: 12,
        province: 9,
        firstName: 'ليلى',
        fatherName: 'أحمد',
        familyName: 'حسن',
        idNumber: 400000004,
        gender: 2,
        createdAt: now,
        updatedAt: now,
      );

      final beneficiary = model.toEntity();

      expect(beneficiary.sectionId, 7);
      expect(beneficiary.relationship, 3);
      expect(beneficiary.requestStatus, entity.RequestStatus.completed);
      expect(beneficiary.governorate, '12');
      expect(beneficiary.district, '9');
    });
  });
}
