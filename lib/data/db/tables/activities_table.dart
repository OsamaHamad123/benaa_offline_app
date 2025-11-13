import 'package:drift/drift.dart';

/// Activities table - سجل الأنشطة والتعديلات
@DataClassName('Activity')
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
