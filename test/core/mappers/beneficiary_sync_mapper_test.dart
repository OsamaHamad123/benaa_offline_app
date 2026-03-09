import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/mappers/beneficiary_sync_mapper.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart';

void main() {
  group('BeneficiaryMapper contract mapping', () {
    test('fromBackend maps contract-style data payload fields', () {
      final companion = BeneficiaryMapper.fromBackend({
        'id': 999,
        'data': {
          'file_id_number': '001234',
          'original_file_id_from_excel': 'EX-001234',
          'data_section_id': 7,
          'data_request_status': 2,
          'data_id_number': '123456789',
          'data_first_name': 'محمد',
          'data_father_name': 'أحمد',
          'data_grand_father_name': 'علي',
          'data_family_name': 'الغزاوي',
          'data_phone_number': '+970-59-1234567',
          'data_alt_phone_number': '0599876543',
          'data_city': 11,
          'data_province': 3,
          'data_birth_date': '1990-08-20',
          'created_at': '2026-03-01T10:00:00Z',
          'updated_at': '2026-03-02T10:00:00Z',
        }
      });

      expect(companion.serverId.value, 999);
      expect(companion.fileIdNumber.value, '001234');
      expect(companion.originalFileIdFromExcel.value, 'EX-001234');
      expect(companion.sectionId.value, 7);
      expect(companion.requestStatus.value, 2);
      expect(companion.idNumber.value, 123456789);
      expect(companion.firstName.value, 'محمد');
      expect(companion.fatherName.value, 'أحمد');
      expect(companion.grandFatherName.value, 'علي');
      expect(companion.familyName.value, 'الغزاوي');
      expect(companion.phoneNumber.value, 970591234567);
      expect(companion.altPhoneNumber.value, 599876543);
      expect(companion.city.value, 11);
      expect(companion.province.value, 3);
      expect(companion.birthDate.value?.toIso8601String().startsWith('1990-08-20'), isTrue);
      expect(companion.syncState.value, 'synced');
    });

    test('toBackend emits central contract keys from local beneficiary', () {
      final beneficiary = Beneficiary(
        id: 1,
        fullName: 'سارة محمد أحمد النجار',
        idNumber: 123456789,
        phoneNumber: 599111111,
        altPhoneNumber: 599222222,
        requestStatus: 1,
        syncState: 'pending',
        firstName: 'سارة',
        fatherName: 'محمد',
        grandFatherName: 'أحمد',
        familyName: 'النجار',
        fileIdNumber: '008888',
        sectionId: 3,
        city: 5,
        province: 2,
        healthStatus: 1,
        createdAt: DateTime.parse('2026-03-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-03-02T00:00:00Z'),
      );

      final payload = BeneficiaryMapper.toBackend(beneficiary);

      expect(payload['file_id_number'], '008888');
      expect(payload['data_id_number'], 123456789);
      expect(payload['data_first_name'], 'سارة');
      expect(payload['data_father_name'], 'محمد');
      expect(payload['data_family_name'], 'النجار');
      expect(payload['data_city'], 5);
      expect(payload['data_province'], 2);
      expect(payload['data_health_status'], 1);
      expect(payload['created_at'], '2026-03-01T00:00:00.000Z');
      expect(payload['updated_at'], '2026-03-02T00:00:00.000Z');
    });
  });
}
