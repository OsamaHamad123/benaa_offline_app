import 'dart:io';

import 'package:benaa_offline_app/data/db/tables/associations_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/storage/secure_store.dart';

// Import all table definitions
import 'tables/tables.dart';

// Import all DAOs
import 'daos/beneficiaries_dao.dart';
import 'daos/visits_dao.dart';
import 'daos/attachments_dao.dart';
// 🗑️ import 'daos/civil_registry_dao.dart'; - Removed (using separate database)
import 'daos/sync_dao.dart';
import 'daos/tracking_dao.dart';
import 'daos/taxonomies_dao.dart';
import 'daos/sync_metadata_dao.dart';
import 'daos/family_deceased_dao.dart';
import 'daos/family_members_dao.dart';
import 'daos/associations_dao.dart';
import 'daos/sponsorships_dao.dart';
import 'daos/file_id_reservation_dao.dart';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [
    Beneficiaries,
    Visits,
    Attachments,
    Taxonomies,
    SyncQueue,
    SyncMetadataTable,
    // 🗑️ Civil Registry tables removed - using separate database (civil_registry.db)
    Activities,
    FamilyDeceasedTable,
    FamilyMembersTable,
    Associations,
    AssociationRepresentatives,
    Sponsorships,
    FileIdReservationTable,
  ],
  daos: [
    BeneficiariesDao,
    VisitsDao,
    AttachmentsDao,
    // 🗑️ CivilRegistryDao removed - using CivilRegistryDatabase instead
    SyncDao,
    TrackingDao,
    TaxonomiesDao,
    SyncMetadataDao,
    FamilyDeceasedDao,
    FamilyMembersDao,
    AssociationsDao,
    SponsorshipsDao,
    FileIdReservationDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  // DAOs are automatically available as getters after generation:
  // - beneficiariesDao: All beneficiary operations
  // - visitsDao: All visit operations
  // - attachmentsDao: All attachment operations
  // - civilRegistryDao: Civil registry search
  // - syncDao: Sync queue and taxonomies

  @override
  int get schemaVersion => 33;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createImportBatchesTable();
        await _createFileIdReservationBatchesTable();
        await _ensureFileIdReservationCompatColumns();
        await _createLocalCodesTable();
        await _createLocalFileNumberPoolTables();
        await _backfillLocalCodesFromFileReservations();
        await _createSyncTombstonesTable();
        await _createAssociationsSponsorProfileTable();
        await _createAssociationsEmployeeProfileTable();
        await _createGuardianBankAccountsTable();
        await _createRelatedEntitiesContractParityTables();
        await _createPerformanceIndexes();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Keep migrations incremental and non-destructive.

        if (from < 12) {
          // v12: Removed Civil Registry tables (moved to separate database)
          // Legacy upgrades are not expected in production, but keep indexes consistent.
          await _createPerformanceIndexes();
        }

        if (from < 13) {
          // v13: Add Sponsorships (Kafalat) table
          await m.createTable(sponsorships);
        }

        if (from < 14) {
          // v14: Add import_batches table (Excel import audit)
          await _createImportBatchesTable();
        }

        if (from < 15) {
          // v15: Add sponsorship type + import batch link
          await m.addColumn(sponsorships, sponsorships.sponsorshipType);
          await m.addColumn(sponsorships, sponsorships.importBatchId);

          // v15: Extend import_batches audit columns (safe if table exists)
          await _ensureImportBatchesColumns();
        }

        if (from < 16) {
          // v16: Add comprehensive sponsorship fields
          // معلومات الكافل
          await m.addColumn(sponsorships, sponsorships.sponsorName);

          // معلومات المكفول
          await m.addColumn(sponsorships, sponsorships.internalFileNo);
          await m.addColumn(sponsorships, sponsorships.externalFileNo);
          await m.addColumn(sponsorships, sponsorships.guardianName);
          await m.addColumn(sponsorships, sponsorships.guardianIdNumber);
          await m.addColumn(sponsorships, sponsorships.guardianPhone);
          await m.addColumn(sponsorships, sponsorships.guardianAltPhone);

          // تفاصيل الكفالة
          await m.addColumn(sponsorships, sponsorships.durationMonths);

          // معلومات بنكية
          await m.addColumn(sponsorships, sponsorships.bankName);
          await m.addColumn(sponsorships, sponsorships.accountHolderName);
          await m.addColumn(sponsorships, sponsorships.accountHolderIdNumber);
          await m.addColumn(sponsorships, sponsorships.accountNumber);
          await m.addColumn(sponsorships, sponsorships.swiftCode);

          // معلومات الموقع
          await m.addColumn(sponsorships, sponsorships.governorate);
          await m.addColumn(sponsorships, sponsorships.city);
          await m.addColumn(sponsorships, sponsorships.address);
        }

        if (from < 17) {
          // v17: Add file_id_reservations table
          await m.createTable(fileIdReservationTable);
        }

        if (from < 18) {
          // v18: Add missing columns for sync and new tables
          // 1. Visits columns
          await m.addColumn(visits, visits.serverId);
          await m.addColumn(visits, visits.lastSyncedAt);

          // 2. Attachments columns
          await m.addColumn(attachments, attachments.syncState);
          await m.addColumn(attachments, attachments.serverUrl);
          await m.addColumn(attachments, attachments.lastSyncedAt);

          // 3. Ensure family tables exist (for users who skipped previous manual updates)
          try {
            await m.createTable(familyMembersTable);
            await m.createTable(familyDeceasedTable);
            await m.createTable(associations);
            await m.createTable(associationRepresentatives);
          } catch (e) {
            // Tables might already exist if it's a new installation
          }
        }

        if (from < 19) {
          // v19: Taxonomy local-id strategy changed to prevent cross-category ID collisions.
          // Clear taxonomy cache and force fresh sync with new IDs.
          await customStatement('DELETE FROM taxonomies;');
          await customStatement("DELETE FROM sync_metadata_table WHERE entity = 'taxonomies';");
        }

        if (from < 20) {
          // v20: Add reservation-range table for central file-id batch tracking.
          await _createFileIdReservationBatchesTable();
        }

        if (from < 21) {
          // v21: Add delete-sync tombstones table for central sync delete tracking.
          await _createSyncTombstonesTable();
        }

        if (from < 22) {
          // v22: Add associations sponsor profile table for backend-specific sponsor fields.
          await _createAssociationsSponsorProfileTable();
        }

        if (from < 23) {
          // v23: Add associations employee profile table to persist sponsor-server linkage per representative.
          await _createAssociationsEmployeeProfileTable();
        }

        if (from < 24) {
          // v24: Add association_type_code to sponsor profile for taxonomy-backed association type mapping.
          await _ensureAssociationsSponsorProfileColumns();
        }

        if (from < 25) {
          // v25: Add guarantee_type to sponsorships for separated guarantee taxonomy binding.
          await m.addColumn(sponsorships, sponsorships.guaranteeType);
        }

        if (from < 26) {
          // v26: fill taxonomy linkage gaps
          // - family_members.guarantee_type
          // - beneficiaries.(assistance_type_code, disability_type_code, income_source_code)
          await m.addColumn(familyMembersTable, familyMembersTable.guaranteeType);
          await m.addColumn(beneficiaries, beneficiaries.assistanceTypeCode);
          await m.addColumn(beneficiaries, beneficiaries.disabilityTypeCode);
          await m.addColumn(beneficiaries, beneficiaries.incomeSourceCode);
        }

        if (from < 27) {
          // v27: store beneficiary-level guarantee taxonomy selection explicitly.
          await m.addColumn(beneficiaries, beneficiaries.guaranteeTypeCode);
        }

        if (from < 28) {
          // v28: normalize legacy attachment person metadata values.
          await _normalizeLegacyAttachmentPersonMetadata();
        }

        if (from < 29) {
          // v29: add local-codes compatibility columns to file_id_reservations.
          await _ensureFileIdReservationCompatColumns();
        }

        if (from < 30) {
          // v30: add literal local_codes table (todo contract) and backfill data.
          await _createLocalCodesTable();
          await _backfillLocalCodesFromFileReservations();
        }

        if (from < 31) {
          // v31: add guardian bank accounts local sync table.
          await _createGuardianBankAccountsTable();
        }

        if (from < 32) {
          // v32: add sidecar parity tables for related entities contract fields.
          await _createRelatedEntitiesContractParityTables();
        }

        if (from < 33) {
          // v33: add offline-first file number pool tables for Firestore block reservation.
          await _createLocalFileNumberPoolTables();
        }

        await _createPerformanceIndexes();
      },
    );
  }

  Future<void> _normalizeLegacyAttachmentPersonMetadata() async {
    await customStatement('''
      UPDATE attachments
      SET
        person_id = CASE
          WHEN person_id IS NULL OR TRIM(person_id) = '' THEN
            TRIM(REPLACE(COALESCE(person_type, ''), '(متوفي)', ''))
          ELSE TRIM(person_id)
        END,
        person_type = CASE
          WHEN person_type LIKE '%(متوفي)%' THEN 'deceased_member'
          ELSE 'family_member'
        END
      WHERE person_type IS NOT NULL
        AND TRIM(person_type) != ''
        AND person_type NOT IN (
          'file_owner',
          'family_member',
          'deceased_member',
          'deceased_father',
          'deceased_mother'
        );
    ''');

    await customStatement('''
      UPDATE attachments
      SET person_id = NULL
      WHERE person_type = 'file_owner';
    ''');

    await customStatement('''
      UPDATE attachments
      SET person_id = NULL
      WHERE person_id IS NOT NULL
        AND TRIM(person_id) = '';
    ''');
  }

  Future<void> _createFileIdReservationBatchesTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS file_id_reservation_batches (
        reservation_id INTEGER PRIMARY KEY,
        device_id TEXT NOT NULL,
        start_id INTEGER NOT NULL,
        end_id INTEGER NOT NULL,
        batch_size INTEGER NOT NULL,
        used_count INTEGER NOT NULL DEFAULT 0,
        remaining_count INTEGER NOT NULL DEFAULT 0,
        next_available_id INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        expires_at TEXT,
        created_at TEXT,
        synced_at TEXT,
        updated_at TEXT,
        last_synced_used_count INTEGER NOT NULL DEFAULT 0
      );
    ''');

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_file_id_batches_status ON file_id_reservation_batches(status);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_file_id_batches_next ON file_id_reservation_batches(next_available_id);',
    );
  }

  Future<void> _ensureFileIdReservationCompatColumns() async {
    await customStatement(
      'ALTER TABLE file_id_reservations ADD COLUMN record_type TEXT;',
    ).catchError((_) {});

    await customStatement(
      'ALTER TABLE file_id_reservations ADD COLUMN record_id INTEGER;',
    ).catchError((_) {});
  }

  Future<void> _createLocalCodesTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS local_codes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE NOT NULL,
        is_used INTEGER NOT NULL DEFAULT 0,
        used_at TEXT,
        synced INTEGER NOT NULL DEFAULT 0,
        record_type TEXT,
        record_id INTEGER,
        created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP)
      );
    ''');

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_unused ON local_codes(is_used) WHERE is_used = 0;',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_unsynced ON local_codes(synced, is_used) WHERE synced = 0 AND is_used = 1;',
    );
  }

  Future<void> _createLocalFileNumberPoolTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS local_file_number_blocks (
        block_id TEXT PRIMARY KEY,
        device_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        prefix TEXT NOT NULL,
        year INTEGER NOT NULL,
        start_number INTEGER NOT NULL,
        end_number INTEGER NOT NULL,
        total_count INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'reserved',
        reserved_at TEXT,
        expires_at TEXT,
        used_count INTEGER NOT NULL DEFAULT 0,
        released_count INTEGER NOT NULL DEFAULT 0,
        app_version TEXT,
        updated_at TEXT
      );
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS local_file_numbers (
        file_number TEXT PRIMARY KEY,
        number INTEGER NOT NULL,
        year INTEGER NOT NULL,
        prefix TEXT NOT NULL,
        block_id TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'available',
        beneficiary_local_id TEXT,
        form_session_id TEXT,
        tentative_at TEXT,
        assigned_at TEXT,
        synced_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(block_id) REFERENCES local_file_number_blocks(block_id) ON DELETE CASCADE
      );
    ''');

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_file_numbers_status ON local_file_numbers(status);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_file_numbers_block ON local_file_numbers(block_id, status);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_file_numbers_session ON local_file_numbers(form_session_id, status);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_file_number_blocks_device ON local_file_number_blocks(device_id, user_id, status);',
    );
  }

  Future<void> _backfillLocalCodesFromFileReservations() async {
    await customStatement('''
      INSERT OR IGNORE INTO local_codes (
        code,
        is_used,
        used_at,
        synced,
        record_type,
        record_id,
        created_at
      )
      SELECT
        printf('%06d', file_id) AS code,
        CASE WHEN status IN ('used', 'synced', 'conflict') THEN 1 ELSE 0 END AS is_used,
        COALESCE(used_at, synced_at) AS used_at,
        CASE WHEN status = 'synced' THEN 1 ELSE 0 END AS synced,
        COALESCE(record_type, 'data') AS record_type,
        COALESCE(record_id, beneficiary_id) AS record_id,
        COALESCE(reserved_at, CURRENT_TIMESTAMP) AS created_at
      FROM file_id_reservations;
    ''');
  }

  Future<void> _createImportBatchesTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS import_batches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_name TEXT,
        imported_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
        rows_total INTEGER NOT NULL DEFAULT 0,
        rows_valid INTEGER NOT NULL DEFAULT 0,
        rows_invalid INTEGER NOT NULL DEFAULT 0,
        rows_duplicates INTEGER NOT NULL DEFAULT 0,
        rows_inserted INTEGER NOT NULL DEFAULT 0,
        rows_updated INTEGER NOT NULL DEFAULT 0,
        rows_skipped INTEGER NOT NULL DEFAULT 0,
        sponsorships_inserted INTEGER NOT NULL DEFAULT 0,
        sponsorships_skipped INTEGER NOT NULL DEFAULT 0,
        notes TEXT
      );
    ''');

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_import_batches_imported_at ON import_batches(imported_at DESC);',
    );
  }

  Future<void> _createSyncTombstonesTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS sync_tombstones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        payload TEXT,
        deleted_at TEXT NOT NULL,
        sync_state TEXT NOT NULL DEFAULT 'pending',
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        last_synced_at TEXT
      );
    ''');

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_tombstones_pending ON sync_tombstones(sync_state, entity_type, deleted_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_tombstones_entity ON sync_tombstones(entity_type, entity_id);',
    );
  }

  Future<void> _createAssociationsSponsorProfileTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS associations_sponsor_profile (
        association_id TEXT PRIMARY KEY,
        sponsor_address TEXT,
        country_code TEXT,
        country_name TEXT,
        sponsor_bank_name_id INTEGER,
        association_type_code TEXT,
        updated_at TEXT,
        FOREIGN KEY(association_id) REFERENCES associations(id) ON DELETE CASCADE
      );
    ''');

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_assoc_sponsor_profile_country ON associations_sponsor_profile(country_code);',
    );
  }

  Future<void> _createAssociationsEmployeeProfileTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS associations_employee_profile (
        representative_id TEXT PRIMARY KEY,
        sponsor_server_id INTEGER NOT NULL,
        updated_at TEXT,
        FOREIGN KEY(representative_id) REFERENCES association_representatives(id) ON DELETE CASCADE
      );
    ''');

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_assoc_employee_profile_sponsor ON associations_employee_profile(sponsor_server_id);',
    );
  }

  Future<void> _createGuardianBankAccountsTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS guardian_bank_accounts (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER UNIQUE,
        guardian_registration INTEGER NOT NULL,
        bank_name_id INTEGER,
        bank_name_label TEXT,
        iban_usd TEXT,
        iban_shekel TEXT,
        re_id_number TEXT,
        re_guardian_name TEXT,
        re_phone_number TEXT,
        person_owner_identity_number TEXT,
        check_account INTEGER NOT NULL DEFAULT 0,
        is_approved INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        sync_state TEXT NOT NULL DEFAULT 'synced',
        last_synced_at TEXT
      );
    ''');

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_guardian_bank_accounts_guardian ON guardian_bank_accounts(guardian_registration);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_guardian_bank_accounts_sync ON guardian_bank_accounts(sync_state);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_guardian_bank_accounts_server ON guardian_bank_accounts(server_id);',
    );
  }

  Future<void> _createRelatedEntitiesContractParityTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS re_people_contract_fields (
        family_member_id INTEGER PRIMARY KEY,
        server_id INTEGER,
        first_name_normalized TEXT,
        second_name_normalized TEXT,
        third_name_normalized TEXT,
        last_name_normalized TEXT,
        person_health_status_name TEXT,
        sponsorship_status_name TEXT,
        person_type_of_guarantee_name TEXT,
        updated_at TEXT,
        FOREIGN KEY(family_member_id) REFERENCES family_members(id) ON DELETE CASCADE
      );
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS dead_people_contract_fields (
        family_deceased_id INTEGER PRIMARY KEY,
        server_id INTEGER,
        re_file_id TEXT,
        death_reason_name TEXT,
        raw_parent_payload TEXT,
        updated_at TEXT,
        FOREIGN KEY(family_deceased_id) REFERENCES family_deceased(id) ON DELETE CASCADE
      );
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS attachments_contract_fields (
        attachment_id TEXT PRIMARY KEY,
        server_attachment_id INTEGER,
        person_identity_number TEXT,
        stored_file_name TEXT,
        mime_type TEXT,
        file_type_label TEXT,
        download_url TEXT,
        google_drive_file_id TEXT,
        google_drive_path TEXT,
        uploaded_to_drive_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(attachment_id) REFERENCES attachments(id) ON DELETE CASCADE
      );
    ''');

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_re_people_contract_server ON re_people_contract_fields(server_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_dead_people_contract_server ON dead_people_contract_fields(server_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_attachments_contract_server ON attachments_contract_fields(server_attachment_id);',
    );
  }

  Future<void> _ensureImportBatchesColumns() async {
    // SQLite doesn't support "ADD COLUMN IF NOT EXISTS", so we inspect PRAGMA table_info.
    final info = await customSelect('PRAGMA table_info(import_batches);').get();
    final existing = info.map((r) => r.read<String>('name')).toSet();

    if (!existing.contains('sponsorships_inserted')) {
      await customStatement(
        'ALTER TABLE import_batches ADD COLUMN sponsorships_inserted INTEGER NOT NULL DEFAULT 0;',
      );
    }

    if (!existing.contains('sponsorships_skipped')) {
      await customStatement(
        'ALTER TABLE import_batches ADD COLUMN sponsorships_skipped INTEGER NOT NULL DEFAULT 0;',
      );
    }
  }

  Future<void> _ensureAssociationsSponsorProfileColumns() async {
    final info = await customSelect('PRAGMA table_info(associations_sponsor_profile);').get();
    final existing = info.map((r) => r.read<String>('name')).toSet();

    if (!existing.contains('association_type_code')) {
      await customStatement(
        'ALTER TABLE associations_sponsor_profile ADD COLUMN association_type_code TEXT;',
      );
    }
  }

  /// ⚡ إنشاء Indexes للبحث السريع
  Future<void> _createPerformanceIndexes() async {
    // ✅ Composite index للبحث المتقدم (full_name + province + section)
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiaries_search_composite '
      'ON beneficiaries(full_name_norm, province, section_id);',
    );

    // ✅ Index للفلترة بتاريخ الإضافة + حالة المزامنة
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiaries_recent '
      'ON beneficiaries(created_at DESC, sync_state);',
    );

    // ✅ Partial index للمستفيدين غير المكتملين
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiaries_incomplete '
      'ON beneficiaries(phone_number, province) '
      'WHERE phone_number IS NULL OR province IS NULL;',
    );

    // Existing indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiaries_search ON beneficiaries(full_name, phone_number);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiaries_location ON beneficiaries(province, city);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiaries_section ON beneficiaries(section_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiaries_sync ON beneficiaries(sync_state);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiaries_birth_date ON beneficiaries(birth_date);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiaries_created ON beneficiaries(created_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiaries_updated ON beneficiaries(updated_at);',
    );

    // ✅ Trigger لتحديث full_name_norm تلقائياً
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_beneficiaries_full_name_norm_insert
      AFTER INSERT ON beneficiaries
      BEGIN
        UPDATE beneficiaries 
        SET full_name_norm = LOWER(
          COALESCE(NEW.first_name, '') || ' ' || 
          COALESCE(NEW.father_name, '') || ' ' || 
          COALESCE(NEW.grand_father_name, '') || ' ' || 
          COALESCE(NEW.family_name, '')
        )
        WHERE id = NEW.id;
      END;
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_beneficiaries_full_name_norm_update
      AFTER UPDATE ON beneficiaries
      WHEN NEW.first_name != OLD.first_name 
        OR NEW.father_name != OLD.father_name 
        OR NEW.grand_father_name != OLD.grand_father_name 
        OR NEW.family_name != OLD.family_name
      BEGIN
        UPDATE beneficiaries 
        SET full_name_norm = LOWER(
          COALESCE(NEW.first_name, '') || ' ' || 
          COALESCE(NEW.father_name, '') || ' ' || 
          COALESCE(NEW.grand_father_name, '') || ' ' || 
          COALESCE(NEW.family_name, '')
        )
        WHERE id = NEW.id;
      END;
    ''');

    // 🗑️ Civil Registry indexes removed - using separate database
    await _createIndexes();
  }

  Future<void> _createIndexes() async {
    // 🗑️ Civil Registry indexes removed - now handled by CivilRegistryDatabase

    // ⚡ Family tables indexes for better performance
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_family_deceased_beneficiary ON family_deceased(beneficiary_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_family_deceased_type ON family_deceased(deceased_type);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_family_members_beneficiary ON family_members(beneficiary_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_family_members_gender ON family_members(gender);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_family_members_birth_date ON family_members(birth_date);',
    );

    // ⚡ Additional performance indexes for common queries
    // Beneficiaries table - composite indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiaries_section_province ON beneficiaries(section_id, province);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiaries_section_sync ON beneficiaries(section_id, sync_state);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiaries_phone ON beneficiaries(phone_number) WHERE phone_number IS NOT NULL;',
    );

    // Visits table - for quick lookups
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_visits_beneficiary_date ON visits(beneficiary_id, visit_date DESC);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_visits_date ON visits(visit_date DESC);',
    );

    // Attachments table
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_attachments_beneficiary ON attachments(beneficiary_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_attachments_type ON attachments(type);',
    );

    // Sponsorships (Kafalat)
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sponsorships_beneficiary ON sponsorships(beneficiary_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sponsorships_association ON sponsorships(association_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sponsorships_status ON sponsorships(status);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sponsorships_beneficiary_status ON sponsorships(beneficiary_id, status);',
    );

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sponsorships_association_status ON sponsorships(association_id, status);',
    );

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sponsorships_type ON sponsorships(sponsorship_type);',
    );

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sponsorships_association_status_type '
      'ON sponsorships(association_id, status, sponsorship_type);',
    );

    // Sync Queue - critical for sync performance
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_queue_entity ON sync_queue(entity, created_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_queue_priority ON sync_queue(priority DESC, created_at);',
    );
  }

  // Note: All legacy migrations (v2-v7) removed
  // Database schema version 8 recreates all tables on upgrade
  // This ensures consistency and prevents migration conflicts

  // Civil registry database operations
  Future<void> attachCivilRegistry(String dbPath) async {
    await customStatement('ATTACH DATABASE ? AS civil_registry', [dbPath]);
  }

  Future<void> detachCivilRegistry() async {
    await customStatement('DETACH DATABASE civil_registry');
  }
}

// Extension to add age calculation to Beneficiary
extension BeneficiaryExtension on Beneficiary {
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }
}

// Database connection factory
LazyDatabase openEncryptedDb() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      // Apply workaround for older Android versions if needed
    }

    final dbFolder = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dbFolder.path, 'app.db');
    final file = File(dbPath);

    // Get encryption key from secure storage
    final key = await SecureStore.getDbKey();

    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // Enable SQLCipher encryption
        db.execute('PRAGMA key = \'$key\';');
        db.execute('PRAGMA foreign_keys = ON;');
        db.execute('PRAGMA journal_mode = WAL;');

        // Performance optimizations
        db.execute('PRAGMA synchronous = NORMAL;');
        db.execute('PRAGMA temp_store = MEMORY;');
        db.execute('PRAGMA busy_timeout = 10000;');
        // db.execute('PRAGMA mmap_size = 30000000000;'); // Removed excessive mmap which can cause ANRs
      },
    );
  });
}
