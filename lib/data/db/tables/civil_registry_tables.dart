import 'package:drift/drift.dart';

/// Civil Registry table - السجل المدني (read-only, من قاعدة البيانات الرئيسية)
@DataClassName('CivilRegistryData')
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

  // معلومات الولادة
  IntColumn get birthCertificateId =>
      integer().nullable().named('CI_BIRTH_TB_CD')();
  IntColumn get birthCodeId => integer().nullable().named('CI_BIRTH_CD')();
  DateTimeColumn get birthDate => dateTime().nullable().named('CI_BIRTH_DT')();
  IntColumn get sexCode =>
      integer().nullable().named('CI_SEX_CD')(); // 1=ذكر, 2=أنثى

  // المعلومات الشخصية
  IntColumn get personalCodeId =>
      integer().nullable().named('CI_PERSONAL_CD')();
  IntColumn get deadDate => integer().nullable().named('CI_DEAD_DT')();

  // اسم الأم
  TextColumn get motherName => text().nullable().named('MOTHER_NAME1')();

  // معلومات العنوان
  IntColumn get cityId => integer().nullable().named('CITY')();
  TextColumn get cityName => text().nullable()();
  TextColumn get street => text().nullable().named('STREET')();
  TextColumn get houseNo => text().nullable().named('HOUSE_NO')();

  // العلاقات
  IntColumn get relationId => integer().nullable().named('CF_ID_NUM')();
  IntColumn get relativeCodeId =>
      integer().nullable().named('CF_RELATIVE_CD')();
  IntColumn get relativeId => integer().nullable().named('CF_ID_RELATIVE')();

  // حقول إضافية للبحث والفهرسة المحلية
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

  @override
  List<Set<Column>> get uniqueKeys => [
        {nationalId}, // الرقم الوطني فريد
      ];
}

/// City table - جدول المدن والمحافظات
@DataClassName('CivilRegistryCityData')
class CivilRegistryCity extends Table {
  IntColumn get id => integer()();
  TextColumn get city => text().named('city')();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Relations table - جدول العلاقات العائلية
@DataClassName('CivilRegistryRelation')
class CivilRegistryRelations extends Table {
  IntColumn get id => integer()();
  IntColumn get personId => integer().named('CF_ID_NUM')();
  IntColumn get relativeId => integer().named('CF_ID_RELATIVE')();
  IntColumn get relativeCodeId => integer().named('CF_RELATIVE_CD')();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Category of Relations table - أنواع العلاقات
@DataClassName('CivilRegistryRelationCategory')
class CivilRegistryRelationCategories extends Table {
  IntColumn get id => integer()();
  TextColumn get attribute => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Birth Code table - رموز شهادات الميلاد
@DataClassName('CivilRegistryBirthCodeData')
class CivilRegistryBirthCode extends Table {
  IntColumn get id => integer()();
  TextColumn get birthCode => text().named('CI_BIRTH_TB_CD')();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Personal Code table - الأكواد الشخصية
@DataClassName('CivilRegistryPersonalCodeData')
class CivilRegistryPersonalCode extends Table {
  IntColumn get id => integer()();
  TextColumn get personalCode => text().named('CI_PERSONAL_CD')();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
