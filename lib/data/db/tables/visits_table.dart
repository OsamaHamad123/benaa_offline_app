import 'package:drift/drift.dart';

/// Visits table - الزيارات
@DataClassName('Visit')
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
