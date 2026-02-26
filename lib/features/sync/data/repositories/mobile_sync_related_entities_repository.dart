import 'package:drift/drift.dart' as drift;
import 'package:logger/logger.dart';

import '../../../../data/db/drift_database.dart';

enum SyncRelatedWriteOutcome { inserted, updated, skipped }

class MobileSyncRelatedEntitiesRepository {
  static const int _deceasedFatherType = 1;
  static const int _deceasedMotherType = 2;

  final AppDatabase _db;
  final Logger _logger;

  MobileSyncRelatedEntitiesRepository({
    required AppDatabase database,
    Logger? logger,
  })  : _db = database,
        _logger = logger ?? Logger();

  Future<SyncRelatedWriteOutcome> upsertAttachment(
    Map<String, dynamic> row, {
    required int localBeneficiaryId,
    required int sequence,
  }) async {
    final serverAttachmentId = extractServerAttachmentId(row);
    final fileName = (row['file_name'] ??
            row['stored_file_name'] ??
            row['original_file_name'] ??
            row['filename'] ??
            row['name'] ??
            row['document_name'] ??
            'attachment_${sequence + 1}')
        .toString();
    final serverUrl = buildAttachmentRemoteReference(
      row,
      serverAttachmentId: serverAttachmentId,
    );
    final normalizedPersonId =
        (row['person_id'] ?? row['personId'] ?? row['person_identity_number'])?.toString().trim();
    final normalizedDocumentType = (row['document_type'] ?? row['documentType'] ?? row['file_type'])?.toString().trim();
    final attachmentId = (serverAttachmentId != null && serverAttachmentId.isNotEmpty)
        ? 'srv_att_$serverAttachmentId'
        : _buildSyntheticAttachmentId(
            localBeneficiaryId: localBeneficiaryId,
            serverUrl: serverUrl,
            fileName: fileName,
            personId: normalizedPersonId,
            documentType: normalizedDocumentType,
            sequence: sequence,
          );

    final now = DateTime.now();
    final createdAt = _parseDateTimeLoose(row['created_at']) ?? now;
    final updatedAt = _parseDateTimeLoose(row['updated_at']) ?? now;

    final companion = AttachmentsCompanion.insert(
      id: attachmentId,
      beneficiaryId: localBeneficiaryId.toString(),
      fileName: fileName,
      filePath: serverUrl ?? fileName,
      type: _resolveAttachmentType(fileName, (row['type'] ?? row['mime_type'] ?? row['file_type'])?.toString()),
      fileSize: _asInt(row['file_size'] ?? row['size'] ?? row['filesize'] ?? row['content_length']) ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncState: const drift.Value('synced'),
      serverUrl: drift.Value(serverUrl),
      lastSyncedAt: drift.Value(now),
      visitId: drift.Value((row['visit_id'] ?? row['visitId'])?.toString()),
      thumbnailPath: drift.Value((row['thumbnail_path'] ?? row['thumbnail'])?.toString()),
      documentType: drift.Value(normalizedDocumentType),
      personType: drift.Value((row['person_type'] ?? row['personType'])?.toString()),
      personId: drift.Value(normalizedPersonId),
      notes: drift.Value(row['notes']?.toString()),
    );

    Attachment? existing =
        await (_db.select(_db.attachments)..where((a) => a.id.equals(attachmentId))).getSingleOrNull();
    if (existing == null && serverUrl != null && serverUrl.isNotEmpty) {
      final existingByServerUrlRows = await (_db.select(_db.attachments)
            ..where((a) => a.beneficiaryId.equals(localBeneficiaryId.toString()) & a.serverUrl.equals(serverUrl)))
          .get();
      existing = existingByServerUrlRows.isEmpty ? null : existingByServerUrlRows.first;
    }

    if (existing == null && fileName.trim().isNotEmpty) {
      final existingByNameRows = await (_db.select(_db.attachments)
            ..where((a) => a.beneficiaryId.equals(localBeneficiaryId.toString()) & a.fileName.equals(fileName)))
          .get();
      existing = existingByNameRows.isEmpty ? null : existingByNameRows.first;
    }

    if (existing != null) {
      final normalizedCompanion = companion.copyWith(id: drift.Value(existing.id));
      await (_db.update(_db.attachments)..where((a) => a.id.equals(existing!.id))).write(normalizedCompanion);
      return SyncRelatedWriteOutcome.updated;
    }

    await _db.into(_db.attachments).insert(companion);
    return SyncRelatedWriteOutcome.inserted;
  }

  Future<SyncRelatedWriteOutcome> upsertFamilyMember(
    Map<String, dynamic> row, {
    required int localBeneficiaryId,
  }) async {
    final now = DateTime.now();
    final serverId = _asInt(row['id'] ?? row['server_id'] ?? row['member_id']);

    final companion = FamilyMembersTableCompanion(
      beneficiaryId: drift.Value(localBeneficiaryId),
      orphanNationalId: drift.Value(
        _asInt(
              row['orphan_national_id'] ??
                  row['person_id'] ??
                  row['person_identity_number'] ??
                  row['national_id'] ??
                  row['id_number'],
            ) ??
            0,
      ),
      firstName: drift.Value((row['first_name'] ?? row['name'] ?? '').toString().isEmpty
          ? 'غير محدد'
          : (row['first_name'] ?? row['name']).toString()),
      secondName: drift.Value(row['second_name']?.toString()),
      thirdName: drift.Value(row['third_name']?.toString()),
      familyName: drift.Value((row['family_name'] ?? row['last_name'] ?? 'غير محدد').toString()),
      birthDate: drift.Value(_parseDateTimeLoose(row['birth_date'] ?? row['person_birth_date']) ?? now),
      age: drift.Value(_asInt(row['age'])),
      gender: drift.Value(_parseGender(row['gender'] ?? row['person_gender'])),
      healthStatus: drift.Value(_parseHealthStatus(row['health_status'] ?? row['person_health_status'])),
      sponsorshipStatus: drift.Value(_asInt(row['sponsorship_status'])),
      sponsorshipType: drift.Value(_asInt(row['sponsorship_type'] ?? row['person_type_of_guarantee'])),
      guaranteeType: drift.Value(
        _asInt(row['guarantee_type'] ?? row['guarantee_type_id'] ?? row['person_type_of_guarantee']),
      ),
      sponsorName: drift.Value(row['sponsor_name']?.toString()),
      sponsorshipStartDate: drift.Value(_parseDateTimeLoose(row['sponsorship_start_date'])),
      notes: drift.Value(row['notes']?.toString()),
      attachments: drift.Value(row['attachments']?.toString()),
      createdAt: drift.Value(_parseDateTimeLoose(row['created_at'])),
      updatedAt: drift.Value(_parseDateTimeLoose(row['updated_at']) ?? now),
      syncState: const drift.Value('synced'),
      serverId: drift.Value(serverId),
      lastSyncedAt: drift.Value(now),
    );

    if (serverId != null) {
      final existingRows = await (_db.select(_db.familyMembersTable)
            ..where((t) => t.serverId.equals(serverId) & t.beneficiaryId.equals(localBeneficiaryId)))
          .get();
      final existing = existingRows.isEmpty ? null : existingRows.first;
      if (existing != null) {
        await (_db.update(_db.familyMembersTable)..where((t) => t.id.equals(existing.id))).write(companion);
        await _cleanupDuplicateFamilyMembersRows(existingRows, keepId: existing.id);
        return SyncRelatedWriteOutcome.updated;
      }
    }

    await _db.into(_db.familyMembersTable).insert(companion);
    return SyncRelatedWriteOutcome.inserted;
  }

  Future<SyncRelatedWriteOutcome> upsertFamilyDeceased(
    Map<String, dynamic> row, {
    required int localBeneficiaryId,
    int? forcedType,
  }) async {
    final normalizedRow = _normalizeDeceasedRow(row);
    final now = DateTime.now();
    final baseServerId = _asInt(normalizedRow['id'] ?? normalizedRow['server_id'] ?? normalizedRow['deceased_id']);
    final hasFather = _hasDeceasedBranchData(normalizedRow, _deceasedFatherType);
    final hasMother = _hasDeceasedBranchData(normalizedRow, _deceasedMotherType);
    final splitPayload = hasFather && hasMother;

    if (forcedType == null) {
      await _pruneExplicitlyEmptyParentBranches(
        localBeneficiaryId: localBeneficiaryId,
        row: normalizedRow,
        hasFather: hasFather,
        hasMother: hasMother,
      );
    }

    if (forcedType == null && hasFather && hasMother) {
      final fatherOutcome = await upsertFamilyDeceased(
        normalizedRow,
        localBeneficiaryId: localBeneficiaryId,
        forcedType: _deceasedFatherType,
      );
      final motherOutcome = await upsertFamilyDeceased(
        normalizedRow,
        localBeneficiaryId: localBeneficiaryId,
        forcedType: _deceasedMotherType,
      );

      if (fatherOutcome == SyncRelatedWriteOutcome.inserted || motherOutcome == SyncRelatedWriteOutcome.inserted) {
        return SyncRelatedWriteOutcome.inserted;
      }
      if (fatherOutcome == SyncRelatedWriteOutcome.updated || motherOutcome == SyncRelatedWriteOutcome.updated) {
        return SyncRelatedWriteOutcome.updated;
      }
      return SyncRelatedWriteOutcome.skipped;
    }

    final type = forcedType ??
        _parseDeceasedType(
          normalizedRow['deceased_type'] ??
              normalizedRow['type'] ??
              (hasFather ? 'father' : (hasMother ? 'mother' : null)),
        );

    final resolvedServerId = _resolveDeceasedServerId(
      baseServerId: baseServerId,
      type: type,
      splitPayload: splitPayload,
    );

    final selectedFirstName = type == 1
        ? (normalizedRow['father_first_name'] ??
            normalizedRow['father_name'] ??
            normalizedRow['first_name'] ??
            normalizedRow['name'])
        : (normalizedRow['mother_first_name'] ??
            normalizedRow['mother_name'] ??
            normalizedRow['first_name'] ??
            normalizedRow['name']);
    final selectedSecondName = type == 1
        ? (normalizedRow['father_second_name'] ?? normalizedRow['second_name'])
        : (normalizedRow['mother_second_name'] ?? normalizedRow['second_name']);
    final selectedThirdName = type == 1
        ? (normalizedRow['father_third_name'] ?? normalizedRow['third_name'])
        : (normalizedRow['mother_third_name'] ?? normalizedRow['third_name']);
    final selectedFamilyName = type == 1
        ? (normalizedRow['father_last_name'] ??
            normalizedRow['father_family_name'] ??
            normalizedRow['family_name'] ??
            normalizedRow['last_name'])
        : (normalizedRow['mother_last_name'] ??
            normalizedRow['mother_family_name'] ??
            normalizedRow['family_name'] ??
            normalizedRow['last_name']);
    final selectedNationalId = type == 1
        ? (normalizedRow['father_id'] ?? normalizedRow['national_id'] ?? normalizedRow['id_number'])
        : (normalizedRow['mother_id'] ?? normalizedRow['national_id'] ?? normalizedRow['id_number']);
    final selectedDeathDate = type == 1
        ? (normalizedRow['father_death_date'] ?? (splitPayload ? null : normalizedRow['death_date']))
        : (normalizedRow['mother_death_date'] ?? (splitPayload ? null : normalizedRow['death_date']));
    final selectedDeathCause = type == 1
        ? (normalizedRow['father_death_reason'] ?? (splitPayload ? null : normalizedRow['death_cause']))
        : (normalizedRow['mother_death_reason'] ?? (splitPayload ? null : normalizedRow['death_cause']));
    final incomingFirstName = _normalizedText(selectedFirstName);
    final incomingSecondName = _normalizedText(selectedSecondName);
    final incomingThirdName = _normalizedText(selectedThirdName);
    final incomingFamilyName = _normalizedText(selectedFamilyName);
    final incomingNationalId = _asInt(selectedNationalId);
    final incomingDeathDate = _parseDateTimeLoose(selectedDeathDate);
    final incomingDeathCause = _parseDeathCauseOrNull(selectedDeathCause);
    final incomingDocumentType = _asPositiveInt(type == 1
        ? (normalizedRow['father_document_type'] ?? normalizedRow['document_type'])
        : (normalizedRow['mother_document_type'] ?? normalizedRow['document_type']));
    final incomingDocumentPath = _normalizedText(
      type == 1
          ? (normalizedRow['father_document_path'] ?? normalizedRow['document_path'])
          : (normalizedRow['mother_document_path'] ?? normalizedRow['document_path']),
    );
    final incomingNotes = _normalizedText(
      type == 1
          ? (normalizedRow['father_notes'] ?? normalizedRow['notes'])
          : (normalizedRow['mother_notes'] ?? normalizedRow['notes']),
    );
    final incomingCreatedAt = _parseDateTimeLoose(normalizedRow['created_at']);
    final incomingUpdatedAt = _parseDateTimeLoose(normalizedRow['updated_at']) ?? now;
    final hasMeaningfulIncomingData = incomingFirstName != null ||
        incomingSecondName != null ||
        incomingThirdName != null ||
        incomingFamilyName != null ||
        (incomingNationalId != null && incomingNationalId > 0) ||
        incomingDeathDate != null;

    FamilyDeceased? existing;
    List<FamilyDeceased> duplicateRows = const [];

    if (resolvedServerId != null) {
      final existingRows = await (_db.select(_db.familyDeceasedTable)
            ..where((t) => t.serverId.equals(resolvedServerId) & t.beneficiaryId.equals(localBeneficiaryId)))
          .get();
      existing = existingRows.isEmpty ? null : existingRows.first;
      duplicateRows = existingRows;
      if (existing != null) {
        final companion = _buildMergedDeceasedCompanion(
          localBeneficiaryId: localBeneficiaryId,
          type: type,
          now: now,
          incomingFirstName: incomingFirstName,
          incomingSecondName: incomingSecondName,
          incomingThirdName: incomingThirdName,
          incomingFamilyName: incomingFamilyName,
          incomingNationalId: incomingNationalId,
          incomingDeathDate: incomingDeathDate,
          incomingDeathCause: incomingDeathCause,
          incomingDocumentType: incomingDocumentType,
          incomingDocumentPath: incomingDocumentPath,
          incomingNotes: incomingNotes,
          incomingCreatedAt: incomingCreatedAt,
          incomingUpdatedAt: incomingUpdatedAt,
          resolvedServerId: resolvedServerId,
          existing: existing,
        );
        await (_db.update(_db.familyDeceasedTable)..where((t) => t.id.equals(existing!.id))).write(companion);
        await _cleanupDuplicateFamilyDeceasedRows(duplicateRows, keepId: existing.id);
        return SyncRelatedWriteOutcome.updated;
      }
    } else {
      final selectedNationalIdInt = incomingNationalId ?? 0;
      final existingByTypeRows = await (_db.select(_db.familyDeceasedTable)
            ..where((t) => t.beneficiaryId.equals(localBeneficiaryId) & t.deceasedType.equals(type)))
          .get();
      final existingByType = existingByTypeRows.isEmpty ? null : existingByTypeRows.first;
      if (existingByType != null) {
        final companion = _buildMergedDeceasedCompanion(
          localBeneficiaryId: localBeneficiaryId,
          type: type,
          now: now,
          incomingFirstName: incomingFirstName,
          incomingSecondName: incomingSecondName,
          incomingThirdName: incomingThirdName,
          incomingFamilyName: incomingFamilyName,
          incomingNationalId: incomingNationalId,
          incomingDeathDate: incomingDeathDate,
          incomingDeathCause: incomingDeathCause,
          incomingDocumentType: incomingDocumentType,
          incomingDocumentPath: incomingDocumentPath,
          incomingNotes: incomingNotes,
          incomingCreatedAt: incomingCreatedAt,
          incomingUpdatedAt: incomingUpdatedAt,
          resolvedServerId: resolvedServerId,
          existing: existingByType,
        );
        await (_db.update(_db.familyDeceasedTable)..where((t) => t.id.equals(existingByType.id))).write(companion);
        await _cleanupDuplicateFamilyDeceasedRows(existingByTypeRows, keepId: existingByType.id);
        return SyncRelatedWriteOutcome.updated;
      }

      if (selectedNationalIdInt > 0) {
        final existingByNationalIdRows = await (_db.select(_db.familyDeceasedTable)
              ..where((t) => t.beneficiaryId.equals(localBeneficiaryId) & t.nationalId.equals(selectedNationalIdInt)))
            .get();
        final existingByNationalId = existingByNationalIdRows.isEmpty ? null : existingByNationalIdRows.first;
        if (existingByNationalId != null) {
          final companion = _buildMergedDeceasedCompanion(
            localBeneficiaryId: localBeneficiaryId,
            type: type,
            now: now,
            incomingFirstName: incomingFirstName,
            incomingSecondName: incomingSecondName,
            incomingThirdName: incomingThirdName,
            incomingFamilyName: incomingFamilyName,
            incomingNationalId: incomingNationalId,
            incomingDeathDate: incomingDeathDate,
            incomingDeathCause: incomingDeathCause,
            incomingDocumentType: incomingDocumentType,
            incomingDocumentPath: incomingDocumentPath,
            incomingNotes: incomingNotes,
            incomingCreatedAt: incomingCreatedAt,
            incomingUpdatedAt: incomingUpdatedAt,
            resolvedServerId: resolvedServerId,
            existing: existingByNationalId,
          );
          await (_db.update(_db.familyDeceasedTable)..where((t) => t.id.equals(existingByNationalId.id)))
              .write(companion);
          await _cleanupDuplicateFamilyDeceasedRows(existingByNationalIdRows, keepId: existingByNationalId.id);
          return SyncRelatedWriteOutcome.updated;
        }
      }
    }

    if (!hasMeaningfulIncomingData) {
      _logger.d('Skipping deceased insert due to empty payload for beneficiary $localBeneficiaryId (type=$type).');
      return SyncRelatedWriteOutcome.skipped;
    }

    final insertCompanion = FamilyDeceasedTableCompanion(
      beneficiaryId: drift.Value(localBeneficiaryId),
      deceasedType: drift.Value(type),
      firstName: drift.Value(incomingFirstName ?? 'غير محدد'),
      secondName: drift.Value(incomingSecondName),
      thirdName: drift.Value(incomingThirdName),
      familyName: drift.Value(incomingFamilyName ?? 'غير محدد'),
      nationalId: drift.Value(incomingNationalId ?? 0),
      deathDate: drift.Value(incomingDeathDate ?? now),
      deathCause: drift.Value(incomingDeathCause ?? 8),
      documentType: drift.Value(incomingDocumentType),
      documentPath: drift.Value(incomingDocumentPath),
      notes: drift.Value(incomingNotes),
      createdAt: drift.Value(incomingCreatedAt),
      updatedAt: drift.Value(incomingUpdatedAt),
      syncState: const drift.Value('synced'),
      serverId: drift.Value(resolvedServerId),
      lastSyncedAt: drift.Value(now),
    );

    await _db.into(_db.familyDeceasedTable).insert(insertCompanion);
    return SyncRelatedWriteOutcome.inserted;
  }

  Future<void> _pruneExplicitlyEmptyParentBranches({
    required int localBeneficiaryId,
    required Map<String, dynamic> row,
    required bool hasFather,
    required bool hasMother,
  }) async {
    final fatherMentioned = _hasDeceasedBranchKeys(row, _deceasedFatherType);
    final motherMentioned = _hasDeceasedBranchKeys(row, _deceasedMotherType);

    if (fatherMentioned && !hasFather) {
      await _deleteDeceasedRowsByType(
        localBeneficiaryId: localBeneficiaryId,
        type: _deceasedFatherType,
      );
    }

    if (motherMentioned && !hasMother) {
      await _deleteDeceasedRowsByType(
        localBeneficiaryId: localBeneficiaryId,
        type: _deceasedMotherType,
      );
    }
  }

  Future<void> _deleteDeceasedRowsByType({
    required int localBeneficiaryId,
    required int type,
  }) async {
    final rows = await (_db.select(_db.familyDeceasedTable)
          ..where((t) => t.beneficiaryId.equals(localBeneficiaryId) & t.deceasedType.equals(type)))
        .get();

    if (rows.isEmpty) return;

    final ids = rows.map((r) => r.id).toList(growable: false);
    await (_db.delete(_db.familyDeceasedTable)..where((t) => t.id.isIn(ids))).go();
  }

  Map<String, dynamic> _normalizeDeceasedRow(Map<String, dynamic> row) {
    final normalized = Map<String, dynamic>.from(row);

    void mergeParent(Map<String, dynamic> source, String prefix) {
      final firstName = source['first_name'] ?? source['name'];
      final secondName = source['second_name'];
      final thirdName = source['third_name'];
      final familyName = source['family_name'] ?? source['last_name'];
      final nationalId = source['id'] ?? source['national_id'] ?? source['person_id'] ?? source['id_number'];
      final deathDate = source['death_date'] ?? source['deceased_at'];
      final deathReason = source['death_reason'] ?? source['death_reason_id'] ?? source['death_cause'];
      final documentType = source['document_type'];
      final documentPath = source['document_path'];
      final notes = source['notes'];

      if (_hasMeaningfulValue(firstName)) normalized['${prefix}_first_name'] = firstName;
      if (_hasMeaningfulValue(secondName)) normalized['${prefix}_second_name'] = secondName;
      if (_hasMeaningfulValue(thirdName)) normalized['${prefix}_third_name'] = thirdName;
      if (_hasMeaningfulValue(familyName)) normalized['${prefix}_last_name'] = familyName;
      if (_hasMeaningfulValue(nationalId)) normalized['${prefix}_id'] = nationalId;
      if (_hasMeaningfulValue(deathDate)) normalized['${prefix}_death_date'] = deathDate;
      if (_hasMeaningfulValue(deathReason)) normalized['${prefix}_death_reason'] = deathReason;
      if (_hasMeaningfulValue(documentType)) normalized['${prefix}_document_type'] = documentType;
      if (_hasMeaningfulValue(documentPath)) normalized['${prefix}_document_path'] = documentPath;
      if (_hasMeaningfulValue(notes)) normalized['${prefix}_notes'] = notes;
    }

    final deceasedParents = _toMap(normalized['deceased_parents'] ?? normalized['deceasedParents']);
    final father = _toMap(deceasedParents?['father'] ?? normalized['father']);
    final mother = _toMap(deceasedParents?['mother'] ?? normalized['mother']);

    if (father != null) {
      mergeParent(father, 'father');
    }
    if (mother != null) {
      mergeParent(mother, 'mother');
    }

    return normalized;
  }

  FamilyDeceasedTableCompanion _buildMergedDeceasedCompanion({
    required int localBeneficiaryId,
    required int type,
    required DateTime now,
    required String? incomingFirstName,
    required String? incomingSecondName,
    required String? incomingThirdName,
    required String? incomingFamilyName,
    required int? incomingNationalId,
    required DateTime? incomingDeathDate,
    required int? incomingDeathCause,
    required int? incomingDocumentType,
    required String? incomingDocumentPath,
    required String? incomingNotes,
    required DateTime? incomingCreatedAt,
    required DateTime incomingUpdatedAt,
    required int? resolvedServerId,
    required FamilyDeceased existing,
  }) {
    return FamilyDeceasedTableCompanion(
      beneficiaryId: drift.Value(localBeneficiaryId),
      deceasedType: drift.Value(type),
      firstName: drift.Value(incomingFirstName ?? existing.firstName),
      secondName: drift.Value(incomingSecondName ?? existing.secondName),
      thirdName: drift.Value(incomingThirdName ?? existing.thirdName),
      familyName: drift.Value(incomingFamilyName ?? existing.familyName),
      nationalId: drift.Value(incomingNationalId ?? (existing.nationalId > 0 ? existing.nationalId : 0)),
      deathDate: drift.Value(incomingDeathDate ?? existing.deathDate),
      deathCause: drift.Value(incomingDeathCause ?? existing.deathCause),
      documentType: drift.Value(incomingDocumentType ?? existing.documentType),
      documentPath: drift.Value(incomingDocumentPath ?? existing.documentPath),
      notes: drift.Value(incomingNotes ?? existing.notes),
      createdAt: drift.Value(incomingCreatedAt ?? existing.createdAt),
      updatedAt: drift.Value(incomingUpdatedAt),
      syncState: const drift.Value('synced'),
      serverId: drift.Value(resolvedServerId ?? existing.serverId),
      lastSyncedAt: drift.Value(now),
    );
  }

  String? _normalizedText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;
    if (text == 'غير محدد') return null;
    return text;
  }

  int? _parseDeathCauseOrNull(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty || raw == 'null') return null;
    return _parseDeathCause(value);
  }

  Future<bool> deleteFamilyMemberFromServerRow(Map<String, dynamic> row) async {
    final serverId = _asInt(row['id'] ?? row['server_id'] ?? row['member_id']);
    if (serverId == null) return false;

    final existingRows = await (_db.select(_db.familyMembersTable)..where((t) => t.serverId.equals(serverId))).get();
    final existing = existingRows.isEmpty ? null : existingRows.first;
    if (existing == null) return false;

    await _db.familyMembersDao.deleteMember(existing.id, trackSyncDelete: false);
    return true;
  }

  Future<bool> deleteFamilyDeceasedFromServerRow(Map<String, dynamic> row) async {
    final serverId = _asInt(row['id'] ?? row['server_id'] ?? row['deceased_id']);
    if (serverId == null) return false;

    final existingRows = await (_db.select(_db.familyDeceasedTable)..where((t) => t.serverId.equals(serverId))).get();
    final existing = existingRows.isEmpty ? null : existingRows.first;
    if (existing == null) return false;

    await _db.familyDeceasedDao.deleteDeceased(existing.id, trackSyncDelete: false);
    return true;
  }

  Future<bool> deleteAttachmentFromServerRow(Map<String, dynamic> row) async {
    final rawServerId = extractServerAttachmentId(row);
    final localCandidateId = rawServerId == null || rawServerId.isEmpty ? null : 'srv_att_$rawServerId';

    Attachment? existing;
    if (localCandidateId != null) {
      final rows = await (_db.select(_db.attachments)..where((a) => a.id.equals(localCandidateId))).get();
      existing = rows.isEmpty ? null : rows.first;
    }

    final serverUrl = buildAttachmentRemoteReference(row);
    if (existing == null && serverUrl != null && serverUrl.isNotEmpty) {
      final rows = await (_db.select(_db.attachments)..where((a) => a.serverUrl.equals(serverUrl))).get();
      existing = rows.isEmpty ? null : rows.first;
    }

    if (existing == null && rawServerId != null && rawServerId.isNotEmpty) {
      final rows = await (_db.select(_db.attachments)..where((a) => a.id.equals(rawServerId))).get();
      existing = rows.isEmpty ? null : rows.first;
    }

    if (existing == null) return false;
    await _db.attachmentsDao.deleteAttachment(existing.id, trackSyncDelete: false);
    return true;
  }

  String? extractServerAttachmentId(Map<String, dynamic> row) {
    final attachmentId = row['attachment_id']?.toString().trim();
    if (attachmentId != null && attachmentId.isNotEmpty) {
      return attachmentId;
    }

    final serverId = row['server_id']?.toString().trim();
    if (serverId != null && serverId.isNotEmpty) {
      return serverId;
    }

    final id = row['id']?.toString().trim();
    if (id != null && id.isNotEmpty) {
      return id;
    }

    return null;
  }

  String? buildAttachmentRemoteReference(
    Map<String, dynamic> row, {
    String? serverAttachmentId,
  }) {
    final entryPath = _pickStringValue(
      row,
      const [
        'entry_path',
        'entryPath',
        'archive_entry',
        'archiveEntry',
        'internal_path',
        'internalPath',
        'zip_entry',
        'zipEntry',
      ],
    );

    final archiveUrl = _pickStringValue(
      row,
      const [
        'archive_url',
        'archiveUrl',
        'zip_url',
        'zipUrl',
        'archive_path',
        'archivePath',
      ],
    );

    if (entryPath != null && archiveUrl != null) {
      return '$archiveUrl!$entryPath';
    }

    final remoteUrl = _pickBestAttachmentRemoteReference(
      row,
      serverAttachmentId: serverAttachmentId,
    );
    return _normalizeAttachmentDownloadUrl(remoteUrl, serverAttachmentId: serverAttachmentId);
  }

  Future<void> _cleanupDuplicateFamilyMembersRows(
    List<FamilyMember> rows, {
    required int keepId,
  }) async {
    if (rows.length <= 1) return;

    final duplicateIds = rows.where((row) => row.id != keepId).map((row) => row.id).toList(growable: false);
    if (duplicateIds.isEmpty) return;

    _logger.w('Detected duplicate family member rows, cleaning up: keep=$keepId, remove=${duplicateIds.length}');
    await (_db.delete(_db.familyMembersTable)..where((t) => t.id.isIn(duplicateIds))).go();
  }

  Future<void> _cleanupDuplicateFamilyDeceasedRows(
    List<FamilyDeceased> rows, {
    required int keepId,
  }) async {
    if (rows.length <= 1) return;

    final duplicateIds = rows.where((row) => row.id != keepId).map((row) => row.id).toList(growable: false);
    if (duplicateIds.isEmpty) return;

    _logger.w('Detected duplicate family deceased rows, cleaning up: keep=$keepId, remove=${duplicateIds.length}');
    await (_db.delete(_db.familyDeceasedTable)..where((t) => t.id.isIn(duplicateIds))).go();
  }

  bool _hasDeceasedBranchData(Map<String, dynamic> row, int type) {
    if (type == _deceasedFatherType) {
      return _hasMeaningfulValue(row['father_first_name']) ||
          _hasMeaningfulValue(row['father_second_name']) ||
          _hasMeaningfulValue(row['father_last_name']) ||
          _hasMeaningfulValue(row['father_id']) ||
          _hasMeaningfulValue(row['father_death_date']);
    }

    return _hasMeaningfulValue(row['mother_first_name']) ||
        _hasMeaningfulValue(row['mother_second_name']) ||
        _hasMeaningfulValue(row['mother_last_name']) ||
        _hasMeaningfulValue(row['mother_id']) ||
        _hasMeaningfulValue(row['mother_death_date']);
  }

  bool _hasDeceasedBranchKeys(Map<String, dynamic> row, int type) {
    final keys = type == _deceasedFatherType
        ? const [
            'father',
            'father_first_name',
            'father_second_name',
            'father_third_name',
            'father_last_name',
            'father_id',
            'father_death_date',
            'father_death_reason',
            'father_document_type',
            'father_document_path',
            'father_notes',
          ]
        : const [
            'mother',
            'mother_first_name',
            'mother_second_name',
            'mother_third_name',
            'mother_last_name',
            'mother_id',
            'mother_death_date',
            'mother_death_reason',
            'mother_document_type',
            'mother_document_path',
            'mother_notes',
          ];

    for (final key in keys) {
      if (row.containsKey(key)) {
        return true;
      }
    }
    return false;
  }

  int? _resolveDeceasedServerId({
    required int? baseServerId,
    required int type,
    required bool splitPayload,
  }) {
    if (baseServerId == null) {
      return null;
    }

    if (!splitPayload) {
      return baseServerId;
    }

    return (baseServerId * 10) + type;
  }

  bool _hasMeaningfulValue(dynamic value) {
    if (value == null) return false;
    final raw = value.toString().trim().toLowerCase();
    if (raw.isEmpty) return false;
    if (raw == 'null' || raw == '0' || raw == 'false') return false;
    return true;
  }

  DateTime? _parseDateTimeLoose(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  String _resolveAttachmentType(String fileName, String? hintedType) {
    if (hintedType != null && hintedType.trim().isNotEmpty) {
      final hint = hintedType.toLowerCase().trim();
      if (hint.contains('image') || hint == 'jpg' || hint == 'jpeg' || hint == 'png' || hint == 'webp') {
        return 'image';
      }
      if (hint.contains('pdf')) {
        return 'pdf';
      }
      if (hint == 'other') {
        return 'other';
      }
    }

    final name = fileName.toLowerCase();
    if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png') || name.endsWith('.webp')) {
      return 'image';
    }
    if (name.endsWith('.pdf')) return 'pdf';
    return 'other';
  }

  String _buildSyntheticAttachmentId({
    required int localBeneficiaryId,
    required String? serverUrl,
    required String fileName,
    required String? personId,
    required String? documentType,
    required int sequence,
  }) {
    String normalize(String value) {
      final lowered = value.toLowerCase().trim();
      return lowered.replaceAll(RegExp(r'[^a-z0-9._-]+'), '_');
    }

    final ref = serverUrl?.trim();
    if (ref != null && ref.isNotEmpty) {
      final token = normalize('${localBeneficiaryId}_$ref');
      final bounded = token.length > 140 ? token.substring(0, 140) : token;
      return 'srv_att_ref_$bounded';
    }

    final token = normalize(
      '${localBeneficiaryId}_${fileName}_${personId ?? ''}_${documentType ?? ''}_$sequence',
    );
    final bounded = token.length > 140 ? token.substring(0, 140) : token;
    return 'srv_att_local_$bounded';
  }

  int _parseGender(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == '1' || raw == 'male' || raw == 'ذكر') return 1;
    if (raw == '2' || raw == 'female' || raw == 'أنثى') return 2;
    return 1;
  }

  int _parseHealthStatus(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == '1' || raw == 'healthy' || raw == 'سليم') return 1;
    if (raw == '2' || raw == 'sick' || raw == 'مريض') return 2;
    if (raw == '3' || raw == 'chronic' || raw == 'مريض مزمن') return 3;
    if (raw == '4' || raw == 'disabled' || raw == 'معاق') return 4;
    return 5;
  }

  int _parseDeceasedType(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == '1' || raw == 'father' || raw == 'أب') return 1;
    if (raw == '2' || raw == 'mother' || raw == 'أم') return 2;
    return 1;
  }

  int _parseDeathCause(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == '1' || raw == 'طبيعية' || raw == 'natural') return 1;
    if (raw == '2' || raw == 'مرض' || raw == 'disease') return 2;
    if (raw == '3' || raw == 'فجأة' || raw == 'sudden') return 3;
    if (raw == '4' || raw == 'حادث' || raw == 'accident') return 4;
    if (raw == '5' || raw == 'أخرى' || raw == 'other') return 5;
    if (raw == '6' || raw == 'انتحار' || raw == 'suicide') return 6;
    if (raw == '7' || raw == 'مغدور' || raw == 'murdered') return 7;
    return 8;
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      final out = <String, dynamic>{};
      for (final entry in value.entries) {
        out[entry.key.toString()] = entry.value;
      }
      return out;
    }
    return null;
  }

  String? _pickBestAttachmentRemoteReference(
    Map<String, dynamic> row, {
    String? serverAttachmentId,
  }) {
    const keys = ['server_url', 'download_url', 'url', 'file_url', 'full_url', 'path'];
    final candidates = <String>[];

    for (final key in keys) {
      final value = row[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        candidates.add(value);
      }
    }

    if (candidates.isEmpty) {
      return null;
    }

    String? best;
    var bestScore = -1;

    for (final candidate in candidates) {
      final normalized = _normalizeAttachmentDownloadUrl(
        candidate,
        serverAttachmentId: serverAttachmentId,
      );
      final score = _scoreAttachmentRemoteReference(normalized ?? candidate);
      if (score > bestScore) {
        bestScore = score;
        best = normalized ?? candidate;
      }
    }

    return best ?? candidates.first;
  }

  int _scoreAttachmentRemoteReference(String value) {
    final lower = value.toLowerCase();

    final hasStaticFilePath = lower.contains('/storage/') || lower.contains('/uploads/') || lower.contains('/files/');
    final hasFileLikeExtension = RegExp(r'\.(jpg|jpeg|png|webp|gif|pdf|zip)(\?|$)').hasMatch(lower);
    final isDownloadEndpoint = lower.contains('/api/mobile/database/attachments/') && lower.contains('/download');

    if (hasStaticFilePath && hasFileLikeExtension) return 100;
    if (hasStaticFilePath) return 95;
    if (hasFileLikeExtension) return 90;
    if (isDownloadEndpoint) return 60;
    if (lower.startsWith('http://') || lower.startsWith('https://')) return 70;
    return 50;
  }

  String? _normalizeAttachmentDownloadUrl(String? remoteUrl, {String? serverAttachmentId}) {
    if (remoteUrl == null || remoteUrl.trim().isEmpty) {
      return remoteUrl;
    }

    if (serverAttachmentId == null || serverAttachmentId.isEmpty) {
      return remoteUrl;
    }

    final match = RegExp(r'(/api/mobile/database/attachments/)(\d+)(/download)').firstMatch(remoteUrl);
    if (match == null) {
      return remoteUrl;
    }

    final currentId = match.group(2);
    if (currentId == null || currentId == serverAttachmentId) {
      return remoteUrl;
    }

    return remoteUrl.replaceFirst(
      '/api/mobile/database/attachments/$currentId/download',
      '/api/mobile/database/attachments/$serverAttachmentId/download',
    );
  }

  String? _pickStringValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final raw = source[key];
      if (raw == null) {
        continue;
      }
      final value = raw.toString().trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  int? _asPositiveInt(dynamic value) {
    final parsed = _asInt(value);
    if (parsed == null || parsed <= 0) {
      return null;
    }
    return parsed;
  }
}
