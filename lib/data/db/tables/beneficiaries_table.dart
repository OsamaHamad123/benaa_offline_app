import 'package:drift/drift.dart';

/// Beneficiaries table - المستفيدين
@DataClassName('Beneficiary')
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
