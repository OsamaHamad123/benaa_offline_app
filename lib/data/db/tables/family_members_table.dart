import 'package:drift/drift.dart';

/// جدول أفراد الأسرة (الأيتام)
/// يحتوي على بيانات تفصيلية لأفراد الأسرة
@DataClassName('FamilyMember')
class FamilyMembersTable extends Table {
  @override
  String get tableName => 'family_members';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get beneficiaryId => integer()();

  // رقم هوية اليتيم - Integer (9 أرقام)
  IntColumn get orphanNationalId => integer()();

  // الاسم الرباعي
  TextColumn get firstName => text()();
  TextColumn get secondName => text().nullable()();
  TextColumn get thirdName => text().nullable()();
  TextColumn get familyName => text()();

  // تاريخ الميلاد والعمر
  DateTimeColumn get birthDate => dateTime()();
  IntColumn get age => integer().nullable()();

  // الجنس (1=ذكر، 2=أنثى)
  IntColumn get gender => integer()(); // 1=male, 2=female

  // الحالة الصحية (1=سليم، 2=مريض، 3=مريض مزمن، 4=معاق، 5=غير معروف)
  IntColumn get healthStatus => integer()();
  // 1=سليم، 2=مريض، 3=مريض مزمن، 4=معاق، 5=غير معروف

  // ملاحظات
  TextColumn get notes => text().nullable()();

  // الملفات المرفقة (مفصولة بفاصلة)
  TextColumn get attachments => text().nullable()();
  // أنواع الملفات: صورة هوية، تقرير طبي، شهادة الميلاد،
  // آخر شهادة، صورة شخصية، صورة طولية

  // System fields
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  // Sync fields
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  IntColumn get serverId => integer().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
