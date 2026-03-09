import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/sync/data/parsers/mobile_sync_response_parser.dart';

void main() {
  group('MobileSyncResponseParser contract alignment', () {
    late MobileSyncResponseParser parser;

    setUp(() {
      parser = MobileSyncResponseParser();
    });

    test('parseRelatedRowsResponse prefers data.records for standard endpoints', () {
      final result = parser.parseRelatedRowsResponse(
        raw: {
          'success': true,
          'data': {
            'records': [
              {'id': 1, 'name': 'record-row'},
            ],
            'attachments': [
              {'id': 99, 'name': 'attachment-row'},
            ],
            'pagination': {
              'current_page': 1,
              'last_page': 1,
            },
          },
        },
        page: 1,
        pageSize: 100,
        listKeys: const ['records', 'items', 'data'],
      );

      expect(result.rows.length, 1);
      expect(result.rows.first['id'], 1);
      expect(result.hasMore, isFalse);
    });

    test('parseRelatedRowsResponse uses data.attachments for attachments endpoint', () {
      final result = parser.parseRelatedRowsResponse(
        raw: {
          'success': true,
          'data': {
            'records': [
              {'id': 1, 'name': 'generic-record'},
            ],
            'attachments': [
              {'id': 10, 'stored_file_name': 'proof.pdf'},
            ],
            'pagination': {
              'current_page': 1,
              'last_page': 1,
            },
          },
        },
        page: 1,
        pageSize: 100,
        listKeys: const ['attachments', 'records', 'items', 'data'],
      );

      expect(result.rows.length, 1);
      expect(result.rows.first['id'], 10);
      expect(result.rows.first['stored_file_name'], 'proof.pdf');
      expect(result.hasMore, isFalse);
    });

    test('parseRelatedRowsResponse uses data.bank_accounts for guardian bank accounts endpoint', () {
      final result = parser.parseRelatedRowsResponse(
        raw: {
          'success': true,
          'data': {
            'bank_accounts': [
              {'id': 77, 'guardian_registration': 1001},
            ],
            'records': [
              {'id': 1, 'guardian_registration': 9999},
            ],
            'pagination': {
              'current_page': 1,
              'last_page': 1,
            },
          },
        },
        page: 1,
        pageSize: 100,
        listKeys: const ['bank_accounts', 'guardian_bank_accounts', 'records', 'items', 'data'],
      );

      expect(result.rows.length, 1);
      expect(result.rows.first['id'], 77);
      expect(result.rows.first['guardian_registration'], 1001);
      expect(result.hasMore, isFalse);
    });

    test('parseBeneficiariesResponse reads beneficiaries from data.records', () {
      final result = parser.parseBeneficiariesResponse(
        {
          'success': true,
          'data': {
            'records': [
              {'id': 501, 'file_id_number': '000501'},
            ],
            'pagination': {
              'current_page': 1,
              'last_page': 1,
            },
            'sync_timestamp': '2026-02-25T10:00:00Z',
          },
        },
        1,
        100,
      );

      expect(result.records.length, 1);
      expect((result.records.first as Map<String, dynamic>)['id'], 501);
      expect(result.hasMore, isFalse);
    });

    test('parseBeneficiariesResponse normalizes deceased_parents father/mother into rows', () {
      final result = parser.parseBeneficiariesResponse(
        {
          'success': true,
          'data': {
            'records': [
              {'id': 7001, 'file_id_number': '007001'},
            ],
            'deceased_parents': {
              'father': {
                'first_name': 'أحمد',
                'last_name': 'النجار',
                'id_number': 123456789,
                'death_date': '2024-10-15',
                'death_reason': 1,
              },
              'mother': {
                'first_name': 'فاطمة',
                'last_name': 'النجار',
                'id_number': 987654321,
                'death_date': '2023-05-20',
                'death_reason': 2,
              },
            },
            'pagination': {
              'current_page': 1,
              'last_page': 1,
            },
          },
        },
        1,
        100,
      );

      expect(result.familyDeceased, hasLength(2));
      expect(result.familyDeceased.any((row) => row['deceased_type'] == 'father'), isTrue);
      expect(result.familyDeceased.any((row) => row['deceased_type'] == 'mother'), isTrue);
      expect(result.familyDeceased.where((row) => row['deceased_type'] == 'father').first['death_cause'], 1);
      expect(result.familyDeceased.where((row) => row['deceased_type'] == 'mother').first['death_cause'], 2);
    });

    test('parseRelatedRowsResponse preserves normalized/label fields for contract parity rows', () {
      final result = parser.parseRelatedRowsResponse(
        raw: {
          'success': true,
          'data': {
            'records': [
              {
                'id': 300,
                'data_first_name': 'محمد',
                'data_first_name_normalized': 'محمد',
                'data_province_name': 'غزة',
                'person_type_of_guarantee_name': 'كفالة شاملة',
                'download_url': '/api/mobile/database/attachments/300/download',
              },
            ],
            'pagination': {
              'current_page': 1,
              'last_page': 1,
            },
          },
        },
        page: 1,
        pageSize: 100,
        listKeys: const ['records', 'attachments', 'items', 'data'],
      );

      expect(result.rows, hasLength(1));
      expect(result.rows.first['data_first_name_normalized'], 'محمد');
      expect(result.rows.first['data_province_name'], 'غزة');
      expect(result.rows.first['person_type_of_guarantee_name'], 'كفالة شاملة');
      expect(result.rows.first['download_url'], '/api/mobile/database/attachments/300/download');
      expect(result.hasMore, isFalse);
    });

    test('parseRelatedRowsResponse handles malformed payload safely', () {
      final result = parser.parseRelatedRowsResponse(
        raw: {
          'success': true,
          'data': 'not-a-map',
        },
        page: 1,
        pageSize: 100,
        listKeys: const ['records', 'attachments', 'items', 'data'],
      );

      expect(result.rows, isEmpty);
      expect(result.hasMore, isFalse);
    });

    test('parseBeneficiariesResponse tolerates non-list related nodes', () {
      final result = parser.parseBeneficiariesResponse(
        {
          'success': true,
          'data': {
            'records': [
              {'id': 7, 'file_id_number': '000007'},
            ],
            'attachments': {'unexpected': 'object'},
            'family_members': 'invalid',
            'dead_people': 123,
            'pagination': {
              'current_page': 1,
              'last_page': 1,
            },
          },
        },
        1,
        100,
      );

      expect(result.records, hasLength(1));
      expect((result.records.first as Map<String, dynamic>)['id'], 7);
      expect(result.attachments, hasLength(1));
      expect(result.attachments.first['unexpected'], 'object');
      expect(result.familyMembers, isEmpty);
      expect(result.familyDeceased, isEmpty);
      expect(result.hasMore, isFalse);
    });
  });
}
