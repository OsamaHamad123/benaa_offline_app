import 'dart:io';
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
import 'daos/civil_registry_dao.dart';
import 'daos/sync_dao.dart';
import 'daos/tracking_dao.dart';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [
    Beneficiaries,
    Visits,
    Attachments,
    Taxonomies,
    SyncQueue,
    CivilRegistry,
    CivilRegistryCity,
    CivilRegistryRelations,
    CivilRegistryRelationCategories,
    CivilRegistryBirthCode,
    CivilRegistryPersonalCode,
    Activities,
    DataRequests,
  ],
  daos: [
    BeneficiariesDao,
    VisitsDao,
    AttachmentsDao,
    CivilRegistryDao,
    SyncDao,
    TrackingDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  // DAOs are automatically available as getters after generation:
  // - beneficiariesDao: All beneficiary operations
  // - visitsDao: All visit operations
  // - attachmentsDao: All attachment operations
  // - civilRegistryDao: Civil registry search
  // - syncDao: Sync queue and taxonomies

  @override
  int get schemaVersion => 6; // تحديث بسبب إعادة هيكلة جدول Beneficiaries

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createIndexes();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await _upgradeToV2(m);
        }
        if (from < 3) {
          await _upgradeToV3(m);
        }
        if (from < 4) {
          await _upgradeToV4(m);
        }
        if (from < 5) {
          await _upgradeToV5(m);
        }
        if (from < 6) {
          await _upgradeToV6(m);
        }
      },
    );
  }

  // Migration إلى النسخة 5 - تحديث السجل المدني
  Future<void> _upgradeToV5(Migrator m) async {
    await customStatement('DROP TABLE IF EXISTS civil_registry;');

    await m.createTable(civilRegistry);
    await m.createTable($CivilRegistryCityTable(attachedDatabase));
    await m.createTable($CivilRegistryRelationsTable(attachedDatabase));
    await m.createTable(
      $CivilRegistryRelationCategoriesTable(attachedDatabase),
    );
    await m.createTable($CivilRegistryBirthCodeTable(attachedDatabase));
    await m.createTable($CivilRegistryPersonalCodeTable(attachedDatabase));

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_national_id ON civil_registry(CI_ID_NUM);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_first_name ON civil_registry(CI_FIRST_ARB);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_family_name ON civil_registry(CI_FAMILY_ARB);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_full_name_norm ON civil_registry(full_name_normalized);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_city ON civil_registry(CITY);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_governorate ON civil_registry(governorate);',
    );

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_relations_person ON civil_registry_relations(CF_ID_NUM);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_relations_relative ON civil_registry_relations(CF_ID_RELATIVE);',
    );
  }

  // Migration إلى النسخة 6 - إعادة هيكلة جدول المستفيدين ليطابق Backend
  Future<void> _upgradeToV6(Migrator m) async {
    // نسخ البيانات القديمة
    await customStatement(
      'CREATE TABLE beneficiaries_backup AS SELECT * FROM beneficiaries;',
    );

    // حذف الجدول القديم
    await m.deleteTable('beneficiaries');

    // إنشاء الجدول الجديد بالهيكل المتطابق مع Backend
    await m.createTable(beneficiaries);

    // نقل البيانات من Backup مع التحويل
    await customStatement('''
      INSERT INTO beneficiaries (
        id,
        file_id_number,
        original_file_id_from_excel,
        section_id,
        request_status,
        id_number,
        first_name,
        father_name,
        grand_father_name,
        family_name,
        relationship,
        birth_date,
        gender,
        phone_number,
        alt_phone_number,
        number_of_individuals,
        marital_status,
        number_of_males,
        number_of_females,
        academic_qualification,
        employment_status_breadwinner,
        displacement_status,
        address_before_displacement,
        current_address,
        city,
        province,
        health_status,
        description_needs,
        number_of_individuals_with_chronic_diseases,
        number_of_people_with_special_needs,
        housing_status,
        current_housing_type,
        user_insert_data,
        created_at,
        updated_at,
        sync_state,
        server_id,
        last_synced_at
      )
      SELECT
        CAST(id AS INTEGER),
        file_no,
        NULL,
        CASE category
          WHEN 'poor' THEN 1
          WHEN 'orphan' THEN 2
          WHEN 'widow' THEN 3
          ELSE NULL
        END,
        COALESCE(request_status, 1),
        CAST(national_id AS INTEGER),
        SUBSTR(full_name, 1, INSTR(full_name || ' ', ' ') - 1),
        father_name,
        grand_father_name,
        family_name,
        NULL,
        birth_date,
        CASE gender
          WHEN 'male' THEN 1
          WHEN 'female' THEN 2
          ELSE NULL
        END,
        CAST(REPLACE(REPLACE(REPLACE(phone_number, '-', ''), ' ', ''), '+', '') AS INTEGER),
        CAST(REPLACE(REPLACE(REPLACE(COALESCE(alt_phone_number, '0'), '-', ''), ' ', ''), '+', '') AS INTEGER),
        family_size,
        CASE marital_status
          WHEN 'single' THEN 1
          WHEN 'married' THEN 2
          WHEN 'divorced' THEN 3
          WHEN 'widowed' THEN 4
          ELSE NULL
        END,
        number_of_males,
        number_of_females,
        CASE education_level
          WHEN 'none' THEN 1
          WHEN 'primary' THEN 2
          WHEN 'intermediate' THEN 3
          WHEN 'secondary' THEN 4
          WHEN 'bachelor' THEN 5
          WHEN 'master' THEN 6
          ELSE NULL
        END,
        employment_status,
        displacement_status,
        address_before_displacement,
        current_address,
        NULL,
        NULL,
        CASE health_status
          WHEN 'good' THEN 1
          WHEN 'fair' THEN 2
          WHEN 'chronic' THEN 3
          WHEN 'disability' THEN 4
          WHEN 'poor' THEN 5
          ELSE NULL
        END,
        notes,
        chronic_diseases_count,
        special_needs_count,
        housing_status,
        housing_type,
        NULL,
        created_at,
        updated_at,
        sync_state,
        CAST(server_id AS INTEGER),
        last_synced_at
      FROM beneficiaries_backup;
    ''');

    // حذف الـ Backup
    await customStatement('DROP TABLE beneficiaries_backup;');

    // إنشاء الـ indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiary_id_number ON beneficiaries(id_number);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiary_file_id ON beneficiaries(file_id_number);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiary_sync ON beneficiaries(sync_state);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiary_server ON beneficiaries(server_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiary_section ON beneficiaries(section_id);',
    );
  }

  // Migration إلى النسخة 4
  Future<void> _upgradeToV4(Migrator m) async {
    await m.createTable(activities);
    await m.createTable(dataRequests);

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_activity_beneficiary ON activities(beneficiary_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_activity_type ON activities(activity_type);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_request_beneficiary ON data_requests(beneficiary_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_request_status ON data_requests(status);',
    );
  }

  // Migration إلى النسخة 3 - NO LONGER USED (legacy migration)
  Future<void> _upgradeToV3(Migrator m) async {
    // This migration is skipped when upgrading from old versions
    // Users will go directly from v5 to v6 with full table recreation
  }

  // Migration إلى النسخة 2
  Future<void> _upgradeToV2(Migrator m) async {
    await m.addColumn(beneficiaries, beneficiaries.serverId);
    await m.addColumn(beneficiaries, beneficiaries.lastSyncedAt);

    await m.addColumn(visits, visits.serverId);
    await m.addColumn(visits, visits.lastSyncedAt);

    await m.addColumn(attachments, attachments.serverUrl);
    await m.addColumn(attachments, attachments.lastSyncedAt);

    await m.addColumn(taxonomies, taxonomies.parentId);
    await m.addColumn(taxonomies, taxonomies.sortOrder);

    await m.addColumn(syncQueue, syncQueue.priority);
    await m.addColumn(syncQueue, syncQueue.scheduledAt);

    await _createIndexes();
  }

  // إنشاء indexes للأداء
  Future<void> _createIndexes() async {
    // Beneficiaries indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiary_national ON beneficiaries(national_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiary_file ON beneficiaries(file_no);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiary_sync ON beneficiaries(sync_state);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_beneficiary_server ON beneficiaries(server_id);',
    );

    // Visits indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_visit_beneficiary ON visits(beneficiary_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_visit_sync ON visits(sync_state);',
    );

    // Attachments indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_attachment_beneficiary ON attachments(beneficiary_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_attachment_sync ON attachments(sync_state);',
    );

    // Taxonomies indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_taxonomy_group ON taxonomies("group", code);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_taxonomy_active ON taxonomies("group", is_active);',
    );

    // Sync Queue indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_queue_priority ON sync_queue(priority DESC, created_at ASC);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_queue_entity ON sync_queue(entity, entity_id);',
    );

    // Civil Registry indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_national ON civil_registry(CI_ID_NUM);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_name_normalized ON civil_registry(full_name_normalized);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_governorate ON civil_registry(governorate);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_composite ON civil_registry(governorate, full_name_normalized);',
    );

    // FTS5 for beneficiaries search
    await customStatement(
      '''CREATE VIRTUAL TABLE IF NOT EXISTS beneficiaries_fts USING fts5(
        full_name_norm,
        content='beneficiaries',
        content_rowid='rowid'
      );''',
    );

    // Triggers to keep FTS in sync
    await customStatement(
      '''CREATE TRIGGER IF NOT EXISTS beneficiaries_ai AFTER INSERT ON beneficiaries BEGIN
        INSERT INTO beneficiaries_fts(rowid, full_name_norm)
        VALUES (new.rowid, new.full_name_norm);
      END;''',
    );

    await customStatement(
      '''CREATE TRIGGER IF NOT EXISTS beneficiaries_ad AFTER DELETE ON beneficiaries BEGIN
        INSERT INTO beneficiaries_fts(beneficiaries_fts, rowid, full_name_norm)
        VALUES ('delete', old.rowid, old.full_name_norm);
      END;''',
    );

    await customStatement(
      '''CREATE TRIGGER IF NOT EXISTS beneficiaries_au AFTER UPDATE ON beneficiaries BEGIN
        INSERT INTO beneficiaries_fts(beneficiaries_fts, rowid, full_name_norm)
        VALUES ('delete', old.rowid, old.full_name_norm);
        INSERT INTO beneficiaries_fts(rowid, full_name_norm)
        VALUES (new.rowid, new.full_name_norm);
      END;''',
    );
  }

  // Civil registry database operations
  Future<void> attachCivilRegistry(String dbPath) async {
    await customStatement("ATTACH DATABASE ? AS civil_registry", [dbPath]);
  }

  Future<void> detachCivilRegistry() async {
    await customStatement("DETACH DATABASE civil_registry");
  }
}

// Extension to add age calculation to Beneficiary
extension BeneficiaryExtension on Beneficiary {
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
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
        db.execute("PRAGMA key = '$key';");
        db.execute("PRAGMA foreign_keys = ON;");
        db.execute("PRAGMA journal_mode = WAL;");

        // Performance optimizations
        db.execute("PRAGMA synchronous = NORMAL;");
        db.execute("PRAGMA temp_store = MEMORY;");
        db.execute("PRAGMA mmap_size = 30000000000;");
      },
    );
  });
}
