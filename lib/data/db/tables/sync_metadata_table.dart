import 'package:drift/drift.dart';

/// Sync Metadata Table - لحفظ آخر وقت مزامنة لكل نوع
@DataClassName('SyncMetadata')
class SyncMetadataTable extends Table {
  /// نوع البيانات: 'beneficiaries', 'visits', 'taxonomies', etc.
  TextColumn get entity => text()();

  /// آخر وقت مزامنة ناجحة
  DateTimeColumn get lastSyncTime => dateTime()();

  /// عدد العناصر التي تمت مزامنتها
  IntColumn get totalSynced => integer().withDefault(const Constant(0))();

  /// عدد العناصر الفاشلة
  IntColumn get failedSyncs => integer().withDefault(const Constant(0))();

  /// آخر خطأ حصل
  TextColumn get lastError => text().nullable()();

  /// وقت آخر خطأ
  DateTimeColumn get lastErrorTime => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {entity};
}
