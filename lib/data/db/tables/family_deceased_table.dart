import 'package:drift/drift.dart';

/// جدول الأب/الأم المتوفى
/// يحتوي على بيانات تفصيلية للوالدين المتوفيين
@DataClassName('FamilyDeceased')
class FamilyDeceasedTable extends Table {
  @override
  String get tableName => 'family_deceased';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get beneficiaryId => integer()();

  // نوع المتوفى (1=أب، 2=أم)
  IntColumn get deceasedType => integer()(); // 1=father, 2=mother

  // الاسم الرباعي
  TextColumn get firstName => text()();
  TextColumn get secondName => text().nullable()();
  TextColumn get thirdName => text().nullable()();
  TextColumn get familyName => text()();

  // رقم الهوية - Integer (9 أرقام)
  IntColumn get nationalId => integer()();

  // تاريخ وسبب الوفاة
  DateTimeColumn get deathDate => dateTime()();
  IntColumn get deathCause => integer()();
  // 1=طبيعية، 2=مرض، 3=فجأة، 4=حادث، 5=أخرى، 6=انتحار، 7=مغدور، 8=غير معروف

  // الوثائق
  IntColumn get documentType =>
      integer().nullable()(); // 1=شهادة وفاة، 2=إفادة شهيد
  TextColumn get documentPath => text().nullable()(); // مسار الوثيقة المرفقة

  TextColumn get notes => text().nullable()();

  // System fields
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  // Sync fields
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  IntColumn get serverId => integer().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
