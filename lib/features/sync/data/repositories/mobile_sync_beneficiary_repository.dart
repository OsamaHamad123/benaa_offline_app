import 'package:logger/logger.dart';

import '../../../../core/mappers/beneficiary_sync_mapper.dart' as mapper;
import '../../../../data/db/drift_database.dart';

enum SyncBeneficiaryWriteOutcome { inserted, updated }

class MobileSyncBeneficiaryRepository {
  final AppDatabase _db;

  MobileSyncBeneficiaryRepository({
    required AppDatabase database,
    Logger? logger,
  }) : _db = database;

  Future<({int localBeneficiaryId, int? serverBeneficiaryId, SyncBeneficiaryWriteOutcome outcome})>
      upsertFromServerRecord(
    Map<String, dynamic> record,
  ) async {
    final companion = mapper.BeneficiaryMapper.fromBackend(record);

    final serverIdRaw = record['id'];
    final serverId =
        serverIdRaw is int ? serverIdRaw : (serverIdRaw != null ? int.tryParse(serverIdRaw.toString()) : null);
    late final int localBeneficiaryId;
    late final SyncBeneficiaryWriteOutcome outcome;

    if (serverId != null) {
      final existing =
          await (_db.select(_db.beneficiaries)..where((b) => b.serverId.equals(serverId))).getSingleOrNull();
      if (existing != null) {
        await (_db.update(_db.beneficiaries)..where((b) => b.id.equals(existing.id))).write(companion);
        localBeneficiaryId = existing.id;
        outcome = SyncBeneficiaryWriteOutcome.updated;
      } else {
        localBeneficiaryId = await _db.into(_db.beneficiaries).insert(companion);
        outcome = SyncBeneficiaryWriteOutcome.inserted;
      }
    } else {
      localBeneficiaryId = await _db.into(_db.beneficiaries).insert(companion);
      outcome = SyncBeneficiaryWriteOutcome.inserted;
    }

    return (
      localBeneficiaryId: localBeneficiaryId,
      serverBeneficiaryId: serverId,
      outcome: outcome,
    );
  }

  Future<bool> deleteFromServerRow(Map<String, dynamic> row) async {
    final serverId = _asInt(row['id'] ?? row['server_id']);
    final fileId = extractFileIdCandidate(row);
    final nationalId = extractNationalIdCandidate(row);

    Beneficiary? existing;
    if (serverId != null) {
      final rows = await (_db.select(_db.beneficiaries)..where((b) => b.serverId.equals(serverId))).get();
      existing = rows.isEmpty ? null : rows.first;
    }

    if (existing == null && fileId != null && fileId.isNotEmpty) {
      final rows = await (_db.select(_db.beneficiaries)..where((b) => b.fileIdNumber.equals(fileId))).get();
      existing = rows.isEmpty ? null : rows.first;
    }

    if (existing == null && nationalId != null && nationalId.isNotEmpty) {
      final parsedNational = int.tryParse(nationalId);
      if (parsedNational != null) {
        final rows = await (_db.select(_db.beneficiaries)..where((b) => b.idNumber.equals(parsedNational))).get();
        existing = rows.isEmpty ? null : rows.first;
      }
    }

    if (existing == null) return false;

    await _db.beneficiariesDao.deleteBeneficiary(existing.id, trackSyncDelete: false);
    return true;
  }

  int? resolveServerBeneficiaryId(Map<String, dynamic> row) {
    const directKeys = <String>[
      'beneficiary_id',
      'beneficiaryId',
      'data_id',
      'dataId',
      'data_record_id',
      'beneficiary_data_id',
      'main_beneficiary_id',
      'main_person_id',
      'primary_person_id',
      'beneficiary_server_id',
      'beneficiaryServerId',
      'beneficiary_server',
      're_people_id',
      'rePeopleId',
      're_person_id',
      'person_id',
      'owner_id',
      'related_beneficiary_id',
      'parent_beneficiary_id',
      'orphan_parent_id',
    ];

    for (final key in directKeys) {
      final parsed = _asIntLoose(row[key]);
      if (parsed != null) return parsed;
    }

    const nestedKeys = <String>[
      'beneficiary',
      'data',
      'beneficiary_data',
      're_people',
      'person',
      'owner',
      'main_person',
      'primary_person',
      'related_beneficiary',
    ];
    for (final nestedKey in nestedKeys) {
      final nested = row[nestedKey];
      if (nested is Map<String, dynamic>) {
        final parsed = _asIntLoose(
          nested['id'] ??
              nested['data_id'] ??
              nested['beneficiary_data_id'] ??
              nested['server_id'] ??
              nested['beneficiary_id'] ??
              nested['beneficiary_server_id'] ??
              nested['re_people_id'],
        );
        if (parsed != null) return parsed;
      }
    }

    return null;
  }

  String? extractFileIdCandidate(Map<String, dynamic> row) {
    final value = row['file_id_number'] ??
        row['fileIdNumber'] ??
        row['data_file_id'] ??
        row['dataFileId'] ??
        row['data_file_number'] ??
        row['dataFileNumber'] ??
        row['beneficiary_file_id'] ??
        row['beneficiary_file_no'] ??
        row['data_file_id_number'] ??
        row['data_file_no'] ??
        row['file_no'] ??
        row['registration_id'] ??
        row['registrationId'] ??
        row['re_file_id'] ??
        row['file_id'] ??
        row['owner_file_id'] ??
        row['beneficiary_code'];

    if (value == null) {
      for (final nestedKey in const [
        'beneficiary',
        'data',
        'beneficiary_data',
        're_people',
        'person',
        'owner',
        'main_person',
        'primary_person',
      ]) {
        final nested = row[nestedKey];
        if (nested is Map<String, dynamic>) {
          final nestedValue = nested['file_id_number'] ??
              nested['fileIdNumber'] ??
              nested['data_file_id'] ??
              nested['dataFileId'] ??
              nested['file_no'] ??
              nested['file_id'] ??
              nested['data_file_id_number'] ??
              nested['data_file_no'];
          if (nestedValue != null) {
            final parsedNested = _asIntLoose(nestedValue);
            if (parsedNested != null) return parsedNested.toString();
            final rawNested = nestedValue.toString().trim();
            if (rawNested.isNotEmpty) return rawNested;
          }
        }
      }
    }

    final parsed = _asIntLoose(value);
    if (parsed != null) return parsed.toString();

    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  String? extractNationalIdCandidate(Map<String, dynamic> row) {
    final value = row['beneficiary_national_id'] ??
        row['beneficiaryNationalId'] ??
        row['person_identity_number'] ??
        row['data_national_id'] ??
        row['dataNationalId'] ??
        row['national_id'] ??
        row['nationalId'] ??
        row['data_id_number'] ??
        row['data_national_id'] ??
        row['id_number'] ??
        row['person_national_id'] ??
        row['identity_number'];

    if (value != null) {
      final raw = value.toString().trim();
      if (raw.isNotEmpty) return raw;
    }

    for (final nestedKey in const [
      'beneficiary',
      'data',
      'beneficiary_data',
      're_people',
      'person',
      'owner',
      'main_person',
      'primary_person',
    ]) {
      final nested = row[nestedKey];
      if (nested is Map<String, dynamic>) {
        final nestedValue = nested['national_id'] ??
            nested['nationalId'] ??
            nested['person_identity_number'] ??
            nested['data_national_id'] ??
            nested['dataNationalId'] ??
            nested['id_number'] ??
            nested['data_id_number'] ??
            nested['data_national_id'] ??
            nested['identity_number'];
        if (nestedValue != null) {
          final raw = nestedValue.toString().trim();
          if (raw.isNotEmpty) return raw;
        }
      }
    }

    return null;
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  int? _asIntLoose(dynamic value) {
    final direct = _asInt(value);
    if (direct != null) return direct;
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }
}
