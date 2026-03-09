import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/associations/data/models/associations_sync_dto.dart';

void main() {
  group('Associations DTO contract', () {
    test('SponsorsListResponseDto parses extended sponsor fields from data.records', () {
      final response = SponsorsListResponseDto.fromJson(
        {
          'success': true,
          'data': {
            'records': [
              {
                'id': 1,
                'file_id': 'SP0001',
                'sponsor_name': 'جمعية الأمل للأيتام',
                'sponsor_short_name': 'الأمل',
                'sponsor_phone_number': '+970591234567',
                'sponsor_email': 'info@alamal.org',
                'sponsor_address': 'غزة، شارع الجلاء',
                'contact_person': 'أحمد محمود',
                'phone': '+970599999999',
                'email': 'old@alamal.org',
                'address': 'العنوان القديم',
                'website': 'https://alamal.org',
                'description': 'جمعية خيرية',
                'status': 1,
                'google_drive_enabled': true,
                'google_drive_folder_name': 'Alamal_Association',
                'sponsor_bank_name_id': 1,
                'sponsor_bank_name': 'بنك فلسطين',
                'sponsor_account_bank_number': '1234567890',
                'sponsor_bank_swift_code': 'PABORPS',
                'sponsor_bank_related_phone_number': '+970599123456',
                'sponsor_bank_account_currency': 'USD',
                'sponsor_currency_name': 'دولار أمريكي',
                'country_code': 'PS',
                'country_name': 'فلسطين',
                'created_at': '2026-01-01T00:00:00+00:00',
                'updated_at': '2026-01-06T12:00:00+00:00'
              }
            ],
            'pagination': {
              'current_page': 1,
              'last_page': 1,
              'per_page': 100,
              'total': 1,
            },
            'sync_timestamp': '2026-02-24T12:00:00+00:00'
          }
        },
        page: 1,
        perPage: 100,
      );

      expect(response.records, hasLength(1));
      final sponsor = response.records.single;
      expect(sponsor.id, 1);
      expect(sponsor.fileId, 'SP0001');
      expect(sponsor.sponsorName, 'جمعية الأمل للأيتام');
      expect(sponsor.contactPerson, 'أحمد محمود');
      expect(sponsor.legacyPhone, '+970599999999');
      expect(sponsor.website, 'https://alamal.org');
      expect(sponsor.status, 1);
      expect(sponsor.googleDriveEnabled, isTrue);
      expect(sponsor.googleDriveFolderName, 'Alamal_Association');
      expect(sponsor.sponsorBankRelatedPhoneNumber, '+970599123456');
      expect(sponsor.sponsorBankAccountCurrency, 'USD');
      expect(sponsor.sponsorCurrencyName, 'دولار أمريكي');
      expect(sponsor.countryCode, 'PS');
      expect(response.hasMore, isFalse);
      expect(response.syncTimestamp, isNotNull);
    });

    test('EmployeesListResponseDto parses sponsor_name and pagination contract', () {
      final response = EmployeesListResponseDto.fromJson(
        {
          'success': true,
          'data': {
            'records': [
              {
                'id': 1,
                'sponsor_id': 1,
                'sponsor_name': 'جمعية الأمل للأيتام',
                'employee_name': 'محمد أحمد الفلسطيني',
                'created_at': '2026-01-10T08:00:00+00:00',
                'updated_at': '2026-02-15T10:30:00+00:00'
              }
            ],
            'pagination': {
              'current_page': 1,
              'last_page': 1,
              'per_page': 100,
              'total': 1,
            },
            'sync_timestamp': '2026-02-24T12:00:00+00:00'
          }
        },
        page: 1,
        perPage: 100,
      );

      expect(response.records, hasLength(1));
      final employee = response.records.single;
      expect(employee.id, 1);
      expect(employee.sponsorId, 1);
      expect(employee.sponsorName, 'جمعية الأمل للأيتام');
      expect(employee.employeeName, 'محمد أحمد الفلسطيني');
      expect(response.hasMore, isFalse);
      expect(response.syncTimestamp, isNotNull);
    });

    test('SponsorDto.toCreatePayload includes extended optional fields', () {
      final dto = SponsorDto(
        id: 99,
        sponsorName: 'جمعية النور',
        sponsorShortName: 'النور',
        sponsorPhoneNumber: '+970599876543',
        sponsorEmail: 'contact@alnour.org',
        sponsorAddress: 'خان يونس',
        contactPerson: 'مسؤول التواصل',
        website: 'https://alnour.org',
        description: 'وصف',
        status: 1,
        googleDriveEnabled: true,
        googleDriveFolderName: 'Alnour_Association',
        sponsorBankNameId: 1,
        sponsorAccountBankNumber: '9876543210',
        sponsorBankSwiftCode: 'PBNKPS22',
        sponsorBankRelatedPhoneNumber: '+970599112233',
        sponsorBankAccountCurrency: 'USD',
        countryCode: 'PS',
      );

      final payload = dto.toCreatePayload();

      expect(payload['sponsor_name'], 'جمعية النور');
      expect(payload['status'], 1);
      expect(payload['google_drive_enabled'], true);
      expect(payload['google_drive_folder_name'], 'Alnour_Association');
      expect(payload['sponsor_bank_swift_code'], 'PBNKPS22');
      expect(payload['sponsor_bank_related_phone_number'], '+970599112233');
      expect(payload['sponsor_bank_account_currency'], 'USD');
      expect(payload['country_code'], 'PS');
    });
  });
}
