import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/storage/secure_store.dart';

part 'drift_database.g.dart';

// Beneficiaries table - المستفيدين
class Beneficiaries extends Table {
  TextColumn get id => text()(); // Local UUID
  TextColumn get fullName => text()();
  TextColumn get fullNameNorm => text()(); // للبحث المحلي
  TextColumn get nationalId => text()();
  TextColumn get fileNo => text()();
  TextColumn get governorate => text()();
  TextColumn get district => text().nullable()(); // القضاء
  TextColumn get address => text().nullable()(); // العنوان الكامل
  TextColumn get phoneNumber => text().nullable()(); // رقم الهاتف
  TextColumn get motherName => text().nullable()(); // اسم الأم
  TextColumn get fatherName => text().nullable()(); // اسم الأب
  IntColumn get familySize => integer().nullable()(); // عدد أفراد الأسرة
  TextColumn get gender => text()(); // 'male', 'female'
  TextColumn get category => text()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get maritalStatus => text().nullable()(); // الحالة الاجتماعية
  TextColumn get educationLevel => text().nullable()(); // المستوى التعليمي
  TextColumn get healthStatus => text().nullable()(); // الحالة الصحية
  BoolColumn get hasDisability => boolean().withDefault(const Constant(false))(); // لديه إعاقة
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get associationName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState => text().withDefault(
    const Constant('pending'),
  )(); // 'pending', 'synced', 'failed', 'syncing'
  TextColumn get serverId => text().nullable()(); // ID من السيرفر بعد المزامنة
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Visits table - الزيارات
class Visits extends Table {
  TextColumn get id => text()();
  TextColumn get beneficiaryId => text()();
  DateTimeColumn get visitDate => dateTime()();
  TextColumn get staffName => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get isSubmitted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  TextColumn get serverId => text().nullable()(); // ID من السيرفر بعد المزامنة
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Attachments table - المرفقات
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get beneficiaryId => text()();
  TextColumn get visitId => text().nullable()();
  TextColumn get type => text()(); // 'image', 'pdf', 'document'
  TextColumn get path => text()();
  TextColumn get hash => text()();
  IntColumn get size => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  TextColumn get serverUrl => text().nullable()(); // URL على السيرفر بعد الرفع
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Taxonomies table - التصنيفات (governorates, categories, etc.)
class Taxonomies extends Table {
  TextColumn get id => text()();
  TextColumn get group => text()(); // 'governorate', 'category', 'gender'
  TextColumn get code => text()();
  TextColumn get label => text()();
  TextColumn get parentId => text().nullable()(); // للتصنيفات الهرمية
  IntColumn get sortOrder =>
      integer().withDefault(const Constant(0))(); // ترتيب العرض
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Sync queue table - طابور المزامنة
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entity => text()(); // 'beneficiary', 'visit', 'attachment'
  TextColumn get entityId => text()();
  TextColumn get operation =>
      text()(); // 'create', 'update', 'delete', 'upload'
  TextColumn get payload => text()(); // JSON
  IntColumn get priority => integer().withDefault(
    const Constant(0),
  )(); // 10=Auth, 9=Beneficiary, 8=Visit, 7=Attachment
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get scheduledAt =>
      dateTime().nullable()(); // لإعادة المحاولة لاحقاً

  @override
  Set<Column> get primaryKey => {id};
}

// Civil Registry table - السجل المدني (read-only, 17GB database)
class CivilRegistry extends Table {
  TextColumn get nationalId => text()();
  TextColumn get fileNo => text()();
  TextColumn get fullNameNorm => text()(); // الاسم مطبع للبحث
  TextColumn get fullNameRaw => text()(); // الاسم الأصلي
  TextColumn get governorate => text()();
  TextColumn get district => text().nullable()(); // المنطقة/القضاء
  TextColumn get birthDate => text().nullable()(); // تاريخ الميلاد
  TextColumn get fatherName => text().nullable()(); // اسم الأب
  TextColumn get motherName => text().nullable()(); // اسم الأم
  TextColumn get address => text().nullable()(); // العنوان

  @override
  Set<Column> get primaryKey => {nationalId};
}

@DriftDatabase(
  tables: [
    Beneficiaries,
    Visits,
    Attachments,
    Taxonomies,
    SyncQueue,
    CivilRegistry,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 3;

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
      },
    );
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

    // Civil Registry indexes - مهمة جداً للبحث السريع
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_national ON civil_registry(national_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_file ON civil_registry(file_no);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_name ON civil_registry(full_name_norm);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_governorate ON civil_registry(governorate);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_civil_composite ON civil_registry(governorate, full_name_norm);',
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

  // Upgrade من النسخة 1 إلى 2
  Future<void> _upgradeToV2(Migrator m) async {
    // إضافة أعمدة المزامنة للمستفيدين
    await m.addColumn(beneficiaries, beneficiaries.serverId);
    await m.addColumn(beneficiaries, beneficiaries.lastSyncedAt);

    // إضافة أعمدة المزامنة للزيارات
    await m.addColumn(visits, visits.serverId);
    await m.addColumn(visits, visits.lastSyncedAt);

    // إضافة أعمدة المزامنة للمرفقات
    await m.addColumn(attachments, attachments.serverUrl);
    await m.addColumn(attachments, attachments.lastSyncedAt);

    // إضافة أعمدة التصنيفات الهرمية
    await m.addColumn(taxonomies, taxonomies.parentId);
    await m.addColumn(taxonomies, taxonomies.sortOrder);

    // إضافة أعمدة طابور المزامنة
    await m.addColumn(syncQueue, syncQueue.priority);
    await m.addColumn(syncQueue, syncQueue.scheduledAt);

    // إضافة أعمدة السجل المدني
    await m.addColumn(civilRegistry, civilRegistry.district);
    await m.addColumn(civilRegistry, civilRegistry.birthDate);
    await m.addColumn(civilRegistry, civilRegistry.fatherName);
    await m.addColumn(civilRegistry, civilRegistry.motherName);
    await m.addColumn(civilRegistry, civilRegistry.address);

    // إعادة إنشاء indexes
    await _createIndexes();
  }

  // Upgrade من النسخة 2 إلى 3
  Future<void> _upgradeToV3(Migrator m) async {
    // إضافة حقول المستفيد الإضافية
    await m.addColumn(beneficiaries, beneficiaries.district);
    await m.addColumn(beneficiaries, beneficiaries.address);
    await m.addColumn(beneficiaries, beneficiaries.phoneNumber);
    await m.addColumn(beneficiaries, beneficiaries.motherName);
    await m.addColumn(beneficiaries, beneficiaries.fatherName);
    await m.addColumn(beneficiaries, beneficiaries.familySize);
    await m.addColumn(beneficiaries, beneficiaries.maritalStatus);
    await m.addColumn(beneficiaries, beneficiaries.educationLevel);
    await m.addColumn(beneficiaries, beneficiaries.healthStatus);
    await m.addColumn(beneficiaries, beneficiaries.hasDisability);
  }

  // Attach civil registry database (read-only)
  Future<void> attachCivilRegistry(String dbPath) async {
    await customStatement("ATTACH DATABASE ? AS civil_registry", [dbPath]);
  }

  // Detach civil registry
  Future<void> detachCivilRegistry() async {
    await customStatement("DETACH DATABASE civil_registry");
  }

  // Helper methods for statistics
  Future<int> countBeneficiaries() async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries',
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  Future<int> countPendingSync() async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries WHERE sync_state = ?',
      variables: [Variable.withString('pending')],
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  Future<int> countBeneficiariesByCategory(String category) async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries WHERE category = ?',
      variables: [Variable.withString(category)],
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  Future<int> countBeneficiariesByGovernorate(String governorate) async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries WHERE governorate = ?',
      variables: [Variable.withString(governorate)],
      readsFrom: {beneficiaries},
    ).getSingle();
    return result.read<int>('count');
  }

  // Get all beneficiaries
  Future<List<Beneficiary>> getAllBeneficiaries() async {
    return await select(beneficiaries).get();
  }

  // Search beneficiaries
  Future<List<Beneficiary>> searchBeneficiaries(String query) async {
    if (query.isEmpty) {
      return await getAllBeneficiaries();
    }

    final normalized = query.trim().toLowerCase();
    return await (select(beneficiaries)..where(
          (b) =>
              b.fullNameNorm.like('%$normalized%') |
              b.nationalId.like('%$normalized%') |
              b.fileNo.like('%$normalized%'),
        ))
        .get();
  }

  // Get beneficiary by ID
  Future<Beneficiary?> getBeneficiaryById(String id) async {
    return await (select(
      beneficiaries,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
  }

  // Insert beneficiary
  Future<void> insertBeneficiary(BeneficiariesCompanion beneficiary) async {
    await into(beneficiaries).insert(beneficiary);
  }

  // Update beneficiary
  Future<void> updateBeneficiary(Beneficiary beneficiary) async {
    await update(beneficiaries).replace(beneficiary);
  }

  // Delete beneficiary
  Future<void> deleteBeneficiary(String id) async {
    await (delete(beneficiaries)..where((b) => b.id.equals(id))).go();
  }

  // ============================================================================
  // CIVIL REGISTRY QUERIES - السجل المدني
  // ============================================================================

  // Search by national ID
  Future<CivilRegistryData?> searchCivilByNationalId(String nationalId) async {
    return await (select(
      civilRegistry,
    )..where((r) => r.nationalId.equals(nationalId))).getSingleOrNull();
  }

  // Search by file number
  Future<CivilRegistryData?> searchCivilByFileNo(String fileNo) async {
    return await (select(
      civilRegistry,
    )..where((r) => r.fileNo.equals(fileNo))).getSingleOrNull();
  }

  // Search by name
  Future<List<CivilRegistryData>> searchCivilByName(
    String name, {
    String? governorate,
    int limit = 50,
  }) async {
    final normalized = _normalizeName(name);
    var query = select(civilRegistry)
      ..where((r) => r.fullNameNorm.like('%$normalized%'));

    if (governorate != null) {
      query = query..where((r) => r.governorate.equals(governorate));
    }

    return await (query
          ..limit(limit)
          ..orderBy([(r) => OrderingTerm.asc(r.fullNameNorm)]))
        .get();
  }

  // ============================================================================
  // SYNC QUEUE QUERIES - طابور المزامنة
  // ============================================================================

  // Add to sync queue
  Future<void> addToSyncQueue(SyncQueueCompanion item) async {
    await into(syncQueue).insert(item, mode: InsertMode.insertOrReplace);
  }

  // Get sync queue items
  Future<List<SyncQueueData>> getSyncQueue({int limit = 100}) async {
    return await (select(syncQueue)
          ..orderBy([
            (q) => OrderingTerm.desc(q.priority),
            (q) => OrderingTerm.asc(q.createdAt),
          ])
          ..limit(limit))
        .get();
  }

  // Remove from sync queue
  Future<void> removeFromSyncQueue(String id) async {
    await (delete(syncQueue)..where((q) => q.id.equals(id))).go();
  }

  // Update sync queue error
  Future<void> updateSyncQueueError(
    String id,
    String error,
    int attempts,
  ) async {
    await (update(syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(lastError: Value(error), attempts: Value(attempts)),
    );
  }

  // ============================================================================
  // TAXONOMIES QUERIES - التصنيفات
  // ============================================================================

  // Get taxonomies by group
  Future<List<Taxonomy>> getTaxonomiesByGroup(String group) async {
    return await (select(taxonomies)
          ..where((t) => t.group.equals(group) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  // Sync taxonomies from server
  Future<void> syncTaxonomies(List<TaxonomiesCompanion> items) async {
    await batch((batch) {
      batch.insertAll(taxonomies, items, mode: InsertMode.insertOrReplace);
    });
  }

  // ============================================================================
  // UTILITY FUNCTIONS - دوال مساعدة
  // ============================================================================

  // تطبيع الأسماء للبحث
  String _normalizeName(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[\u064B-\u065F]'), '') // إزالة الحركات
        .replaceAll(RegExp(r'[إأآ]'), 'ا') // توحيد الهمزات
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'\s+'), ' ');
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
    // Initialize sqlite3 for Flutter
    if (Platform.isAndroid) {
      // Apply workaround for older Android versions if needed
      // await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
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
