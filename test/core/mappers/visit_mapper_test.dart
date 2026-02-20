import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/mappers/visit_sync_mapper.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart';

void main() {
  group('VisitSyncMapper Tests', () {
    test('toBackend should convert Visit to correct dynamic map', () {
      final visit = Visit(
        id: 'visit_123',
        beneficiaryId: 'ben_456',
        visitDate: DateTime(2023, 10, 1),
        staffName: 'Staff User',
        notes: 'Test notes',
        isSubmitted: true,
        createdAt: DateTime(2023, 10, 1, 10, 0),
        updatedAt: DateTime(2023, 10, 1, 10, 0),
        syncState: 'pending',
      );

      final json = VisitSyncMapper.toBackend(visit);

      expect(json['local_id'], 'visit_123');
      expect(json['beneficiary_id'], 'ben_456');
      expect(json['staff_name'], 'Staff User');
      expect(json['notes'], 'Test notes');
      expect(json['is_submitted'], isTrue);
      expect(json['visit_date'], contains('2023-10-01'));
    });

    test('fromBackend should create correct VisitsCompanion', () {
      final json = {
        'id': 'server_789',
        'beneficiary_id': 'ben_456',
        'visit_date': '2023-11-01T10:00:00Z',
        'staff_name': 'Server User',
        'notes': 'Server notes',
        'is_submitted': true,
        'created_at': '2023-11-01T09:00:00Z',
        'updated_at': '2023-11-01T09:30:00Z',
      };

      final companion = VisitSyncMapper.fromBackend(json);

      expect(companion.serverId.value, 'server_789');
      expect(companion.beneficiaryId.value, 'ben_456');
      expect(companion.staffName.value, 'Server User');
      expect(companion.notes.value, 'Server notes');
      expect(companion.syncState.value, 'synced');
    });
  });
}
