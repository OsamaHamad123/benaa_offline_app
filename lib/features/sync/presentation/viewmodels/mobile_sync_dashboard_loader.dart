import '../../../../data/db/drift_database.dart';
import '../../../../core/sync/mobile_sync_service.dart';
import '../../../../core/sync/sync_result_snapshot_store.dart';
import '../../domain/repositories/file_id_reservation_repository.dart';
import '../../services/file_id_service.dart';

class MobileSyncDashboardData {
  final MobileSyncResult? lastResult;
  final DateTime? lastResultAt;
  final String? lastResultOperation;
  final String? lastResultSource;
  final Map<String, int> stats;
  final FileIdDiagnostics? fileIdDiagnostics;
  final String? beneficiariesLastSyncError;

  const MobileSyncDashboardData({
    required this.lastResult,
    required this.lastResultAt,
    required this.lastResultOperation,
    required this.lastResultSource,
    required this.stats,
    required this.fileIdDiagnostics,
    required this.beneficiariesLastSyncError,
  });
}

class MobileSyncDashboardLoader {
  static Future<({int rePeopleFilled, int deadPeopleFilled, int attachmentsFilled})> backfillContractParity(
    AppDatabase db,
  ) async {
    Future<int> _count(String sql) async {
      final row = await db.customSelect(sql).getSingle();
      return row.read<int>('cnt');
    }

    final reMissingBefore = await _count(
      'SELECT COUNT(*) AS cnt FROM family_members fm '
      'LEFT JOIN re_people_contract_fields rp ON rp.family_member_id = fm.id '
      'WHERE rp.family_member_id IS NULL',
    );
    final deadMissingBefore = await _count(
      'SELECT COUNT(*) AS cnt FROM family_deceased fd '
      'LEFT JOIN dead_people_contract_fields dp ON dp.family_deceased_id = fd.id '
      'WHERE dp.family_deceased_id IS NULL',
    );
    final attMissingBefore = await _count(
      'SELECT COUNT(*) AS cnt FROM attachments a '
      'LEFT JOIN attachments_contract_fields ac ON ac.attachment_id = a.id '
      'WHERE ac.attachment_id IS NULL',
    );

    await db.customStatement('''
      INSERT OR IGNORE INTO re_people_contract_fields (
        family_member_id,
        server_id,
        first_name_normalized,
        second_name_normalized,
        third_name_normalized,
        last_name_normalized,
        person_health_status_name,
        sponsorship_status_name,
        person_type_of_guarantee_name,
        updated_at
      )
      SELECT
        fm.id,
        fm.server_id,
        fm.first_name,
        fm.second_name,
        fm.third_name,
        fm.family_name,
        CASE fm.health_status
          WHEN 1 THEN 'سليم'
          WHEN 2 THEN 'مريض'
          WHEN 3 THEN 'مريض مزمن'
          WHEN 4 THEN 'معاق'
          ELSE NULL
        END,
        CASE fm.sponsorship_status
          WHEN 1 THEN 'مكفول'
          WHEN 2 THEN 'غير مكفول'
          WHEN 3 THEN 'قيد الانتظار'
          ELSE NULL
        END,
        NULL,
        CURRENT_TIMESTAMP
      FROM family_members fm
    ''');

    await db.customStatement('''
      UPDATE re_people_contract_fields
      SET
        server_id = COALESCE(server_id, (SELECT fm.server_id FROM family_members fm WHERE fm.id = family_member_id)),
        first_name_normalized = COALESCE(first_name_normalized, (SELECT fm.first_name FROM family_members fm WHERE fm.id = family_member_id)),
        second_name_normalized = COALESCE(second_name_normalized, (SELECT fm.second_name FROM family_members fm WHERE fm.id = family_member_id)),
        third_name_normalized = COALESCE(third_name_normalized, (SELECT fm.third_name FROM family_members fm WHERE fm.id = family_member_id)),
        last_name_normalized = COALESCE(last_name_normalized, (SELECT fm.family_name FROM family_members fm WHERE fm.id = family_member_id)),
        person_health_status_name = COALESCE(
          person_health_status_name,
          (SELECT CASE fm.health_status
            WHEN 1 THEN 'سليم'
            WHEN 2 THEN 'مريض'
            WHEN 3 THEN 'مريض مزمن'
            WHEN 4 THEN 'معاق'
            ELSE NULL
          END FROM family_members fm WHERE fm.id = family_member_id)
        ),
        sponsorship_status_name = COALESCE(
          sponsorship_status_name,
          (SELECT CASE fm.sponsorship_status
            WHEN 1 THEN 'مكفول'
            WHEN 2 THEN 'غير مكفول'
            WHEN 3 THEN 'قيد الانتظار'
            ELSE NULL
          END FROM family_members fm WHERE fm.id = family_member_id)
        ),
        updated_at = CURRENT_TIMESTAMP
    ''');

    await db.customStatement('''
      INSERT OR IGNORE INTO dead_people_contract_fields (
        family_deceased_id,
        server_id,
        re_file_id,
        death_reason_name,
        raw_parent_payload,
        updated_at
      )
      SELECT
        fd.id,
        fd.server_id,
        b.file_id_number,
        CASE fd.death_cause
          WHEN 1 THEN 'طبيعية'
          WHEN 2 THEN 'مرض'
          WHEN 3 THEN 'فجأة'
          WHEN 4 THEN 'حادث'
          WHEN 5 THEN 'أخرى'
          WHEN 6 THEN 'انتحار'
          WHEN 7 THEN 'مغدور'
          ELSE NULL
        END,
        NULL,
        CURRENT_TIMESTAMP
      FROM family_deceased fd
      LEFT JOIN beneficiaries b ON b.id = fd.beneficiary_id
    ''');

    await db.customStatement('''
      UPDATE dead_people_contract_fields
      SET
        server_id = COALESCE(server_id, (SELECT fd.server_id FROM family_deceased fd WHERE fd.id = family_deceased_id)),
        re_file_id = COALESCE(
          re_file_id,
          (SELECT b.file_id_number
           FROM family_deceased fd
           LEFT JOIN beneficiaries b ON b.id = fd.beneficiary_id
           WHERE fd.id = family_deceased_id)
        ),
        death_reason_name = COALESCE(
          death_reason_name,
          (SELECT CASE fd.death_cause
            WHEN 1 THEN 'طبيعية'
            WHEN 2 THEN 'مرض'
            WHEN 3 THEN 'فجأة'
            WHEN 4 THEN 'حادث'
            WHEN 5 THEN 'أخرى'
            WHEN 6 THEN 'انتحار'
            WHEN 7 THEN 'مغدور'
            ELSE NULL
          END FROM family_deceased fd WHERE fd.id = family_deceased_id)
        ),
        updated_at = CURRENT_TIMESTAMP
    ''');

    await db.customStatement('''
      INSERT OR IGNORE INTO attachments_contract_fields (
        attachment_id,
        server_attachment_id,
        person_identity_number,
        stored_file_name,
        mime_type,
        file_type_label,
        download_url,
        google_drive_file_id,
        google_drive_path,
        uploaded_to_drive_at,
        updated_at
      )
      SELECT
        a.id,
        NULL,
        a.person_id,
        a.file_name,
        CASE
          WHEN a.type = 'image' THEN 'image/jpeg'
          WHEN a.type = 'pdf' THEN 'application/pdf'
          ELSE NULL
        END,
        a.document_type,
        a.server_url,
        NULL,
        NULL,
        NULL,
        CURRENT_TIMESTAMP
      FROM attachments a
    ''');

    await db.customStatement('''
      UPDATE attachments_contract_fields
      SET
        person_identity_number = COALESCE(person_identity_number, (SELECT a.person_id FROM attachments a WHERE a.id = attachment_id)),
        stored_file_name = COALESCE(stored_file_name, (SELECT a.file_name FROM attachments a WHERE a.id = attachment_id)),
        mime_type = COALESCE(
          mime_type,
          (SELECT CASE
            WHEN a.type = 'image' THEN 'image/jpeg'
            WHEN a.type = 'pdf' THEN 'application/pdf'
            ELSE NULL
          END FROM attachments a WHERE a.id = attachment_id)
        ),
        file_type_label = COALESCE(file_type_label, (SELECT a.document_type FROM attachments a WHERE a.id = attachment_id)),
        download_url = COALESCE(download_url, (SELECT a.server_url FROM attachments a WHERE a.id = attachment_id)),
        updated_at = CURRENT_TIMESTAMP
    ''');

    final reMissingAfter = await _count(
      'SELECT COUNT(*) AS cnt FROM family_members fm '
      'LEFT JOIN re_people_contract_fields rp ON rp.family_member_id = fm.id '
      'WHERE rp.family_member_id IS NULL',
    );
    final deadMissingAfter = await _count(
      'SELECT COUNT(*) AS cnt FROM family_deceased fd '
      'LEFT JOIN dead_people_contract_fields dp ON dp.family_deceased_id = fd.id '
      'WHERE dp.family_deceased_id IS NULL',
    );
    final attMissingAfter = await _count(
      'SELECT COUNT(*) AS cnt FROM attachments a '
      'LEFT JOIN attachments_contract_fields ac ON ac.attachment_id = a.id '
      'WHERE ac.attachment_id IS NULL',
    );

    return (
      rePeopleFilled: (reMissingBefore - reMissingAfter) < 0 ? 0 : (reMissingBefore - reMissingAfter),
      deadPeopleFilled: (deadMissingBefore - deadMissingAfter) < 0 ? 0 : (deadMissingBefore - deadMissingAfter),
      attachmentsFilled: (attMissingBefore - attMissingAfter) < 0 ? 0 : (attMissingBefore - attMissingAfter),
    );
  }

  static Future<MobileSyncDashboardData> load({
    required AppDatabase db,
    required FileIdService fileIdService,
  }) async {
    final beneficiaries = await db.select(db.beneficiaries).get();
    final benPending = beneficiaries.where((b) => b.syncState == 'pending').length;
    final benModified = beneficiaries.where((b) => b.syncState == 'modified').length;
    final benSynced = beneficiaries.where((b) => b.syncState == 'synced').length;
    final benFailed = beneficiaries.where((b) => b.syncState == 'failed').length;

    final beneficiariesSyncMeta =
        await (db.select(db.syncMetadataTable)..where((t) => t.entity.equals('beneficiaries'))).getSingleOrNull();
    final beneficiariesLastError = beneficiariesSyncMeta?.lastError?.trim();

    final associations = await db.select(db.associations).get();
    final assocTotal = associations.length;
    final assocPending = associations.where((a) => a.syncState == 'pending').length;
    final assocModified = associations.where((a) => a.syncState == 'modified').length;
    final assocNeedsSync = assocPending + assocModified;
    final assocSynced = associations.where((a) => a.isActive).length;

    final representatives = await db.select(db.associationRepresentatives).get();
    final repTotal = representatives.length;
    final repPending = representatives.where((r) => r.syncState == 'pending').length;
    final repModified = representatives.where((r) => r.syncState == 'modified').length;
    final repNeedsSync = repPending + repModified;

    final sponsorships = await db.select(db.sponsorships).get();
    final sponsorshipsTotal = sponsorships.length;
    final sponsorshipsPending = sponsorships.where((s) => s.syncState == 'pending').length;
    final sponsorshipsModified = sponsorships.where((s) => s.syncState == 'modified').length;
    final sponsorshipsSynced = sponsorships.where((s) => s.syncState == 'synced').length;
    final sponsorshipsNeedsSync = sponsorshipsPending + sponsorshipsModified;

    final attachmentsTotal = await db.select(db.attachments).get().then((rows) => rows.length);
    final familyMembersTotal = await db.select(db.familyMembersTable).get().then((rows) => rows.length);
    final deadPeopleTotal = await db.select(db.familyDeceasedTable).get().then((rows) => rows.length);

    Future<int> countFromSql(String sql) async {
      final row = await db.customSelect(sql).getSingle();
      return row.read<int>('cnt');
    }

    final rePeopleContractRows = await countFromSql('SELECT COUNT(*) AS cnt FROM re_people_contract_fields');
    final deadPeopleContractRows = await countFromSql('SELECT COUNT(*) AS cnt FROM dead_people_contract_fields');
    final attachmentsContractRows = await countFromSql('SELECT COUNT(*) AS cnt FROM attachments_contract_fields');
    final attachmentsContractWithDownloadUrl = await countFromSql(
      "SELECT COUNT(*) AS cnt FROM attachments_contract_fields WHERE download_url IS NOT NULL AND TRIM(download_url) != ''",
    );

    final rePeopleContractMissing =
        (familyMembersTotal - rePeopleContractRows) < 0 ? 0 : (familyMembersTotal - rePeopleContractRows);
    final deadPeopleContractMissing =
        (deadPeopleTotal - deadPeopleContractRows) < 0 ? 0 : (deadPeopleTotal - deadPeopleContractRows);
    final attachmentsContractMissing =
        (attachmentsTotal - attachmentsContractRows) < 0 ? 0 : (attachmentsTotal - attachmentsContractRows);

    final fileIdDiagnostics = await fileIdService.getDiagnostics();

    final snapshot = await SyncResultSnapshotStore.load();

    return MobileSyncDashboardData(
      lastResult: snapshot?.toMobileSyncResult(),
      lastResultAt: snapshot?.timestamp,
      lastResultOperation: snapshot?.operation,
      lastResultSource: snapshot?.source,
      stats: {
        'ben_total': beneficiaries.length,
        'ben_pending': benPending,
        'ben_modified': benModified,
        'ben_synced': benSynced,
        'ben_failed': benFailed,
        'ben_needsSync': benPending + benModified,
        'assoc_total': assocTotal,
        'assoc_active': assocSynced,
        'assoc_pending': assocPending,
        'assoc_modified': assocModified,
        'assoc_needsSync': assocNeedsSync,
        'rep_total': repTotal,
        'rep_pending': repPending,
        'rep_modified': repModified,
        'rep_needsSync': repNeedsSync,
        'sponsorship_total': sponsorshipsTotal,
        'sponsorship_synced': sponsorshipsSynced,
        'sponsorship_pending': sponsorshipsPending,
        'sponsorship_modified': sponsorshipsModified,
        'sponsorship_needsSync': sponsorshipsNeedsSync,
        'attachments_total': attachmentsTotal,
        'family_members_total': familyMembersTotal,
        'dead_people_total': deadPeopleTotal,
        're_people_contract_rows': rePeopleContractRows,
        'dead_people_contract_rows': deadPeopleContractRows,
        'attachments_contract_rows': attachmentsContractRows,
        're_people_contract_missing': rePeopleContractMissing,
        'dead_people_contract_missing': deadPeopleContractMissing,
        'attachments_contract_missing': attachmentsContractMissing,
        'attachments_contract_download_url_count': attachmentsContractWithDownloadUrl,
        'total': beneficiaries.length + assocTotal + repTotal + sponsorshipsTotal,
        'needsSync': benPending + benModified + assocNeedsSync + repNeedsSync + sponsorshipsNeedsSync,
      },
      fileIdDiagnostics: fileIdDiagnostics,
      beneficiariesLastSyncError:
          (beneficiariesLastError == null || beneficiariesLastError.isEmpty) ? null : beneficiariesLastError,
    );
  }
}
