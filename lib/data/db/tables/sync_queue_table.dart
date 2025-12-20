import 'package:drift/drift.dart';

/// Sync queue table - طابور المزامنة
@DataClassName('SyncQueueItem')
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
