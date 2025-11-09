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
  TextColumn get grandFatherName => text().nullable()(); // اسم الجد
  TextColumn get familyName => text().nullable()(); // اسم العائلة
  TextColumn get altPhoneNumber => text().nullable()(); // رقم هاتف بديل
  IntColumn get familySize => integer().nullable()(); // عدد أفراد الأسرة
  TextColumn get gender => text()(); // 'male', 'female'
  TextColumn get category => text()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get maritalStatus => text().nullable()(); // الحالة الاجتماعية
  TextColumn get educationLevel => text().nullable()(); // المستوى التعليمي
  TextColumn get healthStatus => text().nullable()(); // الحالة الصحية
  BoolColumn get hasDisability =>
      boolean().withDefault(const Constant(false))(); // لديه إعاقة

  // حقول إضافية من Backend
  IntColumn get displacementStatus => integer().nullable()(); // حالة النزوح
  TextColumn get addressBeforeDisplacement =>
      text().nullable()(); // عنوان قبل النزوح
  TextColumn get currentAddress => text().nullable()(); // العنوان الحالي
  IntColumn get numberOfMales => integer().nullable()(); // عدد الذكور
  IntColumn get numberOfFemales => integer().nullable()(); // عدد الإناث
  IntColumn get chronicDiseasesCount =>
      integer().nullable()(); // عدد المصابين بأمراض مزمنة
  IntColumn get specialNeedsCount =>
      integer().nullable()(); // عدد ذوي الاحتياجات الخاصة
  IntColumn get employmentStatus => integer().nullable()(); // حالة توظيف المعيل
  IntColumn get housingStatus => integer().nullable()(); // حالة السكن
  IntColumn get housingType => integer().nullable()(); // نوع السكن
  IntColumn get requestStatus => integer().nullable()(); // حالة الطلب

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
  TextColumn get fileName => text()(); // اسم الملف
  TextColumn get filePath => text()(); // المسار الكامل
  TextColumn get type => text()(); // 'image', 'pdf', 'other'
  IntColumn get fileSize => integer()(); // حجم الملف بالبايت
  TextColumn get thumbnailPath => text().nullable()(); // مسار الصورة المصغرة
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

// Civil Registry table - السجل المدني (read-only, من قاعدة البيانات الرئيسية)
// Schema من: civilregistry.persons + civilregistry.ci_birth_cd + civilregistry.city + etc.
class CivilRegistry extends Table {
  // من جدول persons - معلومات شخصية أساسية
  IntColumn get id => integer()(); // bigint(20) unsigned - primary key
  TextColumn get nationalId =>
      text().named('CI_ID_NUM')(); // bigint(20) - الرقم الوطني
  TextColumn get firstName =>
      text().named('CI_FIRST_ARB')(); // varchar(255) - الاسم الأول
  TextColumn get fatherName =>
      text().named('CI_FATHER_ARB')(); // varchar(255) - اسم الأب
  TextColumn get grandFatherName =>
      text().named('CI_GRAND_FATHER_ARB')(); // varchar(255) - اسم الجد
  TextColumn get familyName =>
      text().named('CI_FAMILY_ARB')(); // varchar(255) - اسم العائلة

  // معلومات الولادة - من ci_birth_cd و ci_birth_tb_cd
  IntColumn get birthCertificateId =>
      integer().nullable().named('CI_BIRTH_TB_CD')(); // bigint(20)
  IntColumn get birthCodeId =>
      integer().nullable().named('CI_BIRTH_CD')(); // bigint(20)
  DateTimeColumn get birthDate =>
      dateTime().nullable().named('CI_BIRTH_DT')(); // date
  IntColumn get sexCode =>
      integer().nullable().named('CI_SEX_CD')(); // int(11) - 1=ذكر, 2=أنثى

  // المعلومات الشخصية - من ci_personal_cd
  IntColumn get personalCodeId =>
      integer().nullable().named('CI_PERSONAL_CD')(); // bigint(20)
  IntColumn get deadDate =>
      integer().nullable().named('CI_DEAD_DT')(); // bigint(20) - تاريخ الوفاة

  // اسم الأم
  TextColumn get motherName =>
      text().nullable().named('MOTHER_NAME1')(); // varchar(255)

  // معلومات العنوان - من city
  IntColumn get cityId => integer().nullable().named('CITY')(); // bigint(20)
  TextColumn get cityName => text().nullable()(); // من جدول city
  TextColumn get street => text().nullable().named('STREET')(); // varchar(255)
  TextColumn get houseNo =>
      text().nullable().named('HOUSE_NO')(); // varchar(255)

  // العلاقات - من relations و category_of_relations
  IntColumn get relationId =>
      integer().nullable().named('CF_ID_NUM')(); // bigint(20) - ID العلاقة
  IntColumn get relativeCodeId => integer().nullable().named(
    'CF_RELATIVE_CD',
  )(); // bigint(20) - نوع العلاقة
  IntColumn get relativeId => integer().nullable().named(
    'CF_ID_RELATIVE',
  )(); // bigint(20) - ID الشخص المرتبط

  // حقول إضافية للبحث والفهرسة المحلية
  TextColumn get fullName => text().nullable()(); // الاسم الكامل المجمّع
  TextColumn get fullNameNormalized => text().nullable()(); // للبحث
  TextColumn get governorate =>
      text().nullable()(); // المحافظة (مستخرج من city)
  TextColumn get district => text().nullable()(); // القضاء (مستخرج من city)

  // حقول المزامنة
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {nationalId}, // الرقم الوطني فريد
  ];
}

// City table - جدول المدن والمحافظات من قاعدة البيانات الرئيسية
class CivilRegistryCity extends Table {
  IntColumn get id => integer()(); // bigint(20) unsigned - primary key
  TextColumn get city =>
      text().named('city')(); // varchar(255) - اسم المدينة/القضاء
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Relations table - جدول العلاقات العائلية
class CivilRegistryRelations extends Table {
  IntColumn get id => integer()(); // bigint(20) unsigned - primary key
  IntColumn get personId =>
      integer().named('CF_ID_NUM')(); // bigint(20) - الشخص
  IntColumn get relativeId =>
      integer().named('CF_ID_RELATIVE')(); // bigint(20) - القريب
  IntColumn get relativeCodeId =>
      integer().named('CF_RELATIVE_CD')(); // bigint(20) - نوع العلاقة
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Category of Relations table - أنواع العلاقات (أب، أم، أخ، الخ)
class CivilRegistryRelationCategories extends Table {
  IntColumn get id => integer()(); // bigint(20) unsigned - primary key
  TextColumn get attribute =>
      text()(); // varchar(255) - نوع العلاقة (father, mother, etc.)
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Birth Code table - رموز شهادات الميلاد
class CivilRegistryBirthCode extends Table {
  IntColumn get id => integer()(); // bigint(20) unsigned - primary key
  TextColumn get birthCode => text().named('CI_BIRTH_TB_CD')(); // varchar(255)
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Personal Code table - الأكواد الشخصية
class CivilRegistryPersonalCode extends Table {
  IntColumn get id => integer()(); // bigint(20) unsigned - primary key
  TextColumn get personalCode =>
      text().named('CI_PERSONAL_CD')(); // varchar(255)
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Activities table - سجل الأنشطة والتعديلات
class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get beneficiaryId => text()();
  TextColumn get userId => text()(); // معرف المستخدم الذي قام بالنشاط
  TextColumn get activityType =>
      text()(); // 'create', 'update', 'delete', 'visit', 'attachment'
  TextColumn get description => text()(); // وصف النشاط
  TextColumn get changes => text().nullable()(); // JSON للتغييرات
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

// Data Requests table - طلبات البيانات/المساعدات
class DataRequests extends Table {
  TextColumn get id => text()();
  TextColumn get beneficiaryId => text()();
  TextColumn get requestType => text()(); // نوع الطلب
  TextColumn get status =>
      text()(); // 'pending', 'approved', 'rejected', 'completed'
  TextColumn get details => text().nullable()(); // تفاصيل الطلب JSON
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get requestDate => dateTime()();
  DateTimeColumn get responseDate => dateTime().nullable()();
  TextColumn get respondedBy => text().nullable()(); // من قام بالرد
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  TextColumn get serverId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

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
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 5; // زيادة رقم الإصدار للتعديلات الجديدة

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
      },
    );
  }

  // Migration إلى النسخة 5 - تحديث السجل المدني
  Future<void> _upgradeToV5(Migrator m) async {
    // حذف الجدول القديم
    await customStatement('DROP TABLE IF EXISTS civil_registry;');

    // إنشاء الجداول الجديدة
    await m.createTable(civilRegistry);
    await m.createTable($CivilRegistryCityTable(attachedDatabase));
    await m.createTable($CivilRegistryRelationsTable(attachedDatabase));
    await m.createTable(
      $CivilRegistryRelationCategoriesTable(attachedDatabase),
    );
    await m.createTable($CivilRegistryBirthCodeTable(attachedDatabase));
    await m.createTable($CivilRegistryPersonalCodeTable(attachedDatabase));

    // إنشاء indexes لجدول CivilRegistry
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

    // indexes للعلاقات
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_relations_person ON civil_registry_relations(CF_ID_NUM);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_relations_relative ON civil_registry_relations(CF_ID_RELATIVE);',
    );
  }

  // Migration إلى النسخة 4
  Future<void> _upgradeToV4(Migrator m) async {
    await m.createTable(activities);
    await m.createTable(dataRequests);

    // إنشاء indexes للجداول الجديدة
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

    // ملاحظة: السجل المدني سيتم إعادة بنائه بالكامل في V5
    // لذلك لا نضيف أعمدة هنا

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

  Future<int> countIncompleteBeneficiaries() async {
    // حساب البيانات الناقصة: beneficiaries بدون phone أو address
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM beneficiaries WHERE phone_number IS NULL OR phone_number = \'\' OR address IS NULL OR address = \'\'',
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

  // Search beneficiaries with filters (OPTIMIZED) - محسّنة للأداء
  Future<List<Beneficiary>> searchBeneficiariesFiltered({
    String query = '',
    String? category,
    String? governorate,
    int limit = 50,
    int offset = 0,
  }) async {
    final normalized = query.trim().toLowerCase();

    // Build query with all filters in SQL (faster than Dart filtering)
    var selectQuery = select(beneficiaries);

    // Apply filters
    selectQuery = selectQuery
      ..where((b) {
        Expression<bool> condition = const Constant(true);

        // Search filter
        if (normalized.isNotEmpty) {
          condition =
              condition &
              (b.fullNameNorm.like('%$normalized%') |
                  b.nationalId.like('%$normalized%') |
                  b.fileNo.like('%$normalized%'));
        }

        // Category filter
        if (category != null && category != 'all') {
          condition = condition & b.category.equals(category);
        }

        // Governorate filter
        if (governorate != null && governorate != 'all') {
          condition = condition & b.governorate.equals(governorate);
        }

        return condition;
      });

    // Apply pagination
    selectQuery = selectQuery
      ..orderBy([(b) => OrderingTerm.asc(b.fullName)])
      ..limit(limit, offset: offset);

    return await selectQuery.get();
  }

  // Get beneficiary by ID
  Future<Beneficiary?> getBeneficiaryById(String id) async {
    return await (select(
      beneficiaries,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
  }

  // Get beneficiary by server ID
  Future<Beneficiary?> getBeneficiaryByServerId(String serverId) async {
    return await (select(
      beneficiaries,
    )..where((b) => b.serverId.equals(serverId))).getSingleOrNull();
  }

  // Insert beneficiary
  Future<void> insertBeneficiary(BeneficiariesCompanion beneficiary) async {
    await into(beneficiaries).insert(beneficiary);
  }

  // Update beneficiary (using Companion)
  Future<void> updateBeneficiaryCompanion(
    String id,
    BeneficiariesCompanion beneficiary,
  ) async {
    await (update(
      beneficiaries,
    )..where((b) => b.id.equals(id))).write(beneficiary);
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
  // ATTACHMENTS QUERIES - المرفقات
  // ============================================================================

  // Get all attachments for a beneficiary
  Future<List<Attachment>> getBeneficiaryAttachments(
    String beneficiaryId,
  ) async {
    return await (select(attachments)
          ..where((a) => a.beneficiaryId.equals(beneficiaryId))
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
        .get();
  }

  // Add attachment
  Future<void> addAttachment(AttachmentsCompanion attachment) async {
    await into(attachments).insert(attachment);
  }

  // Delete attachment
  Future<void> deleteAttachment(String id) async {
    await (delete(attachments)..where((a) => a.id.equals(id))).go();
  }

  // Delete all attachments for a beneficiary
  Future<void> deleteBeneficiaryAttachments(String beneficiaryId) async {
    await (delete(
      attachments,
    )..where((a) => a.beneficiaryId.equals(beneficiaryId))).go();
  }

  // Get attachment by ID
  Future<Attachment?> getAttachment(String id) async {
    return await (select(
      attachments,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  // Update attachment sync state
  Future<void> updateAttachmentSyncState(
    String id,
    String syncState, {
    String? serverUrl,
  }) async {
    await (update(attachments)..where((a) => a.id.equals(id))).write(
      AttachmentsCompanion(
        syncState: Value(syncState),
        serverUrl: Value(serverUrl),
        lastSyncedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
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

  // Search by name
  Future<List<CivilRegistryData>> searchCivilByName(
    String name, {
    String? governorate,
    int limit = 50,
  }) async {
    final normalized = _normalizeName(name);
    var query = select(civilRegistry)
      ..where((r) => r.fullNameNormalized.like('%$normalized%'));

    if (governorate != null) {
      query = query..where((r) => r.governorate.equals(governorate));
    }

    return await (query
          ..limit(limit)
          ..orderBy([(r) => OrderingTerm.asc(r.fullNameNormalized)]))
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
