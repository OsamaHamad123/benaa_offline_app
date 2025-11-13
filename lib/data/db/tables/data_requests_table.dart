import 'package:drift/drift.dart';

/// Data Requests table - طلبات البيانات/المساعدات
@DataClassName('DataRequest')
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
