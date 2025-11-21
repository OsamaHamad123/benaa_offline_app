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
import 'daos/taxonomies_dao.dart';
import 'daos/sync_metadata_dao.dart';
import 'daos/family_deceased_dao.dart';
import 'daos/family_members_dao.dart';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [
    Beneficiaries,
    Visits,
    Attachments,
    Taxonomies,
    SyncQueue,
    SyncMetadataTable,
    CivilRegistry,
    CivilRegistryCity,
    CivilRegistryRelations,
    CivilRegistryRelationCategories,
    CivilRegistryBirthCode,
    CivilRegistryPersonalCode,
    Activities,
    DataRequests,
    FamilyDeceasedTable,
    FamilyMembersTable,
  ],
  daos: [
    BeneficiariesDao,
    VisitsDao,
    AttachmentsDao,
    CivilRegistryDao,
    SyncDao,
    TrackingDao,
    TaxonomiesDao,
    SyncMetadataDao,
    FamilyDeceasedDao,
    FamilyMembersDao,
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
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createPerformanceIndexes();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 8 && to == 9) {
          // ⚡ Performance indexes only
          await _createPerformanceIndexes();
        } else if (to == 9) {
          // إضافة indexes للأداء
          await _createPerformanceIndexes();
        } else if (to == 8) {
          // إضافة indexes للأداء
          await _createPerformanceIndexes();
        } else {
          // حذف قاعدة البيانات القديمة وإعادة إنشائها من الصفر
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
          await _createPerformanceIndexes();
        }
      },
    );
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

    // Civil Registry indexes (existing)
    await _createIndexes();
  }

  Future<void> _createIndexes() async {
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

  // Note: All legacy migrations (v2-v7) removed
  // Database schema version 8 recreates all tables on upgrade
  // This ensures consistency and prevents migration conflicts

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
