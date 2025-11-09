# 🔄 تحديث قاعدة بيانات السجل المدني للمزامنة

## 📊 التعديلات المطبقة

### 1️⃣ **تحديث جدول `CivilRegistry`** ✅

تم تعديل الجدول ليطابق schema قاعدة البيانات الرئيسية:

```dart
class CivilRegistry extends Table {
  // Primary Key
  IntColumn get id => integer()(); // من جدول persons.id
  
  // البيانات الأساسية (من جدول persons)
  TextColumn get nationalId => text().named('CI_ID_NUM')(); // الرقم الوطني
  TextColumn get firstName => text().named('CI_FIRST_ARB')(); // الاسم الأول
  TextColumn get fatherName => text().named('CI_FATHER_ARB')(); // اسم الأب
  TextColumn get grandFatherName => text().named('CI_GRAND_FATHER_ARB')(); // اسم الجد
  TextColumn get familyName => text().named('CI_FAMILY_ARB')(); // اسم العائلة
  
  // معلومات الولادة (من ci_birth_cd, ci_birth_tb_cd)
  IntColumn get birthCertificateId => integer().nullable().named('CI_BIRTH_TB_CD')();
  IntColumn get birthCodeId => integer().nullable().named('CI_BIRTH_CD')();
  DateTimeColumn get birthDate => dateTime().nullable().named('CI_BIRTH_DT')();
  IntColumn get sexCode => integer().nullable().named('CI_SEX_CD')(); // 1=ذكر, 2=أنثى
  
  // معلومات شخصية إضافية (من ci_personal_cd)
  IntColumn get personalCodeId => integer().nullable().named('CI_PERSONAL_CD')();
  IntColumn get deadDate => integer().nullable().named('CI_DEAD_DT')(); // تاريخ الوفاة
  TextColumn get motherName => text().nullable().named('MOTHER_NAME1')(); // اسم الأم
  
  // معلومات العنوان (من city)
  IntColumn get cityId => integer().nullable().named('CITY')();
  TextColumn get cityName => text().nullable()(); // من جدول city
  TextColumn get street => text().nullable().named('STREET')();
  TextColumn get houseNo => text().nullable().named('HOUSE_NO')();
  
  // العلاقات (من relations, category_of_relations)
  IntColumn get relationId => integer().nullable().named('CF_ID_NUM')();
  IntColumn get relativeCodeId => integer().nullable().named('CF_RELATIVE_CD')();
  IntColumn get relativeId => integer().nullable().named('CF_ID_RELATIVE')();
  
  // حقول للبحث المحلي
  TextColumn get fullName => text().nullable()(); // الاسم الكامل المجمّع
  TextColumn get fullNameNormalized => text().nullable()(); // للبحث
  TextColumn get governorate => text().nullable()(); // المحافظة
  TextColumn get district => text().nullable()(); // القضاء
  
  // حقول المزامنة
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 2️⃣ **إضافة جداول مساعدة** ✅

#### جدول المدن (CivilRegistryCity)
```dart
class CivilRegistryCity extends Table {
  IntColumn get id => integer()(); // primary key
  TextColumn get city => text().named('city')(); // اسم المدينة/القضاء
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

#### جدول العلاقات (CivilRegistryRelations)
```dart
class CivilRegistryRelations extends Table {
  IntColumn get id => integer()(); // primary key
  IntColumn get personId => integer().named('CF_ID_NUM')(); // الشخص
  IntColumn get relativeId => integer().named('CF_ID_RELATIVE')(); // القريب
  IntColumn get relativeCodeId => integer().named('CF_RELATIVE_CD')(); // نوع العلاقة
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

#### جدول أنواع العلاقات (CivilRegistryRelationCategories)
```dart
class CivilRegistryRelationCategories extends Table {
  IntColumn get id => integer()(); // primary key
  TextColumn get attribute => text()(); // father, mother, brother, etc.
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

#### جدول رموز الميلاد (CivilRegistryBirthCode)
```dart
class CivilRegistryBirthCode extends Table {
  IntColumn get id => integer()(); // primary key
  TextColumn get birthCode => text().named('CI_BIRTH_TB_CD')();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

#### جدول الأكواد الشخصية (CivilRegistryPersonalCode)
```dart
class CivilRegistryPersonalCode extends Table {
  IntColumn get id => integer()(); // primary key
  TextColumn get personalCode => text().named('CI_PERSONAL_CD')();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 3️⃣ **Migration إلى Schema Version 5** ✅

```dart
@override
int get schemaVersion => 5; // زيادة الإصدار

Future<void> _upgradeToV5(Migrator m) async {
  // حذف الجدول القديم
  await customStatement('DROP TABLE IF EXISTS civil_registry;');
  
  // إنشاء الجداول الجديدة
  await m.createTable(civilRegistry);
  await m.createTable(civilRegistryCity);
  await m.createTable(civilRegistryRelations);
  await m.createTable(civilRegistryRelationCategories);
  await m.createTable(civilRegistryBirthCode);
  await m.createTable(civilRegistryPersonalCode);

  // إنشاء Indexes للأداء
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
```

---

## 🔄 خطوات المزامنة

### المرحلة 1: إعداد API للمزامنة

```dart
class CivilRegistrySyncService {
  /// مزامنة السجل المدني من قاعدة البيانات الرئيسية
  Future<void> syncCivilRegistry({
    DateTime? lastSyncDate,
    int batchSize = 1000,
  }) async {
    // 1. طلب البيانات المحدثة من السيرفر
    final response = await _apiClient.get('/api/civil-registry/sync', {
      'last_sync': lastSyncDate?.toIso8601String(),
      'limit': batchSize,
    });
    
    // 2. حفظ البيانات محلياً
    await _saveCivilRecords(response['records']);
    await _saveCities(response['cities']);
    await _saveRelations(response['relations']);
    
    // 3. تحديث آخر وقت مزامنة
    await _updateLastSyncTime();
  }
  
  /// حفظ سجلات السجل المدني
  Future<void> _saveCivilRecords(List<dynamic> records) async {
    final db = await database;
    
    await db.batch((batch) {
      for (final record in records) {
        batch.insert(
          db.civilRegistry,
          CivilRegistryCompanion.insert(
            id: Value(record['id']),
            nationalId: record['CI_ID_NUM']?.toString() ?? '',
            firstName: record['CI_FIRST_ARB'] ?? '',
            fatherName: record['CI_FATHER_ARB'] ?? '',
            grandFatherName: record['CI_GRAND_FATHER_ARB'] ?? '',
            familyName: record['CI_FAMILY_ARB'] ?? '',
            
            // بناء الاسم الكامل
            fullName: Value(_buildFullName(record)),
            fullNameNormalized: Value(_normalizeFullName(record)),
            
            // باقي الحقول...
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            lastSyncedAt: Value(DateTime.now()),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
  
  /// بناء الاسم الكامل
  String _buildFullName(Map<String, dynamic> record) {
    return [
      record['CI_FIRST_ARB'],
      record['CI_FATHER_ARB'],
      record['CI_GRAND_FATHER_ARB'],
      record['CI_FAMILY_ARB'],
    ].where((e) => e != null && e.isNotEmpty).join(' ');
  }
  
  /// تطبيع الاسم للبحث
  String _normalizeFullName(Map<String, dynamic> record) {
    return ArabicNormalizer.normalize(_buildFullName(record));
  }
}
```

### المرحلة 2: Schedule للمزامنة التلقائية

```dart
class AutoSyncScheduler {
  Timer? _syncTimer;
  
  /// بدء المزامنة التلقائية كل ساعة
  void startAutoSync() {
    _syncTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _performSync(),
    );
  }
  
  Future<void> _performSync() async {
    try {
      final syncService = CivilRegistrySyncService();
      final lastSync = await _getLastSyncTime();
      
      await syncService.syncCivilRegistry(
        lastSyncDate: lastSync,
      );
      
      print('✅ Civil Registry synced successfully');
    } catch (e) {
      print('❌ Sync failed: $e');
    }
  }
}
```

---

## 📝 ملاحظات هامة

### ⚠️ حجم البيانات
- قاعدة البيانات الرئيسية **17GB**
- يجب استخدام **Pagination** و **Incremental Sync**
- مزامنة **التحديثات فقط** وليس كل البيانات

### 🔑 Mapping الحقول

| قاعدة البيانات الرئيسية | قاعدة البيانات المحلية |
|---------------------------|-------------------------|
| `persons.id` | `CivilRegistry.id` |
| `persons.CI_ID_NUM` | `CivilRegistry.nationalId` |
| `persons.CI_FIRST_ARB` | `CivilRegistry.firstName` |
| `persons.CI_FATHER_ARB` | `CivilRegistry.fatherName` |
| `persons.CI_GRAND_FATHER_ARB` | `CivilRegistry.grandFatherName` |
| `persons.CI_FAMILY_ARB` | `CivilRegistry.familyName` |
| `persons.CI_BIRTH_DT` | `CivilRegistry.birthDate` |
| `persons.CI_SEX_CD` | `CivilRegistry.sexCode` |
| `persons.MOTHER_NAME1` | `CivilRegistry.motherName` |
| `persons.CITY` | `CivilRegistry.cityId` |
| `city.city` | `CivilRegistry.cityName` |
| `relations.CF_ID_NUM` | `CivilRegistryRelations.personId` |
| `relations.CF_ID_RELATIVE` | `CivilRegistryRelations.relativeId` |
| `category_of_relations.attribute` | `CivilRegistryRelationCategories.attribute` |

### 🚀 الخطوات التالية

1. **تشغيل Build Runner**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **تحديث CivilRecord Model** ليستخدم الحقول الجديدة

3. **تحديث OptimizedCivilSearchService** ليقرأ من الجدول الجديد

4. **بناء API Sync Service** للمزامنة

5. **إضافة UI** لعرض حالة المزامنة

---

## ✅ الفوائد

- ✅ **Schema موحد** مع قاعدة البيانات الرئيسية
- ✅ **مزامنة سلسة** للتحديثات
- ✅ **علاقات واضحة** بين الجداول
- ✅ **بحث محسّن** مع Indexes
- ✅ **جاهز للتوسع** مع ميزات جديدة

---

**تم بحمد الله ✅**
