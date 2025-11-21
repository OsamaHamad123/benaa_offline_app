import 'package:drift/drift.dart';

/// جدول الأموات في العائلة
@DataClassName('FamilyDeceased')
class FamilyDeceasedTable extends Table {
  @override
  String get tableName => 'family_deceased';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get beneficiaryId => integer()();

  TextColumn get fullName => text()();
  TextColumn get relationship =>
      text()(); // أب، أم، ابن، ابنة، أخ، أخت، زوج، زوجة
  TextColumn get gender => text()(); // male, female

  DateTimeColumn get deathDate => dateTime().nullable()();
  TextColumn get deathCause => text().nullable()();
  IntColumn get ageAtDeath => integer().nullable()();

  TextColumn get notes => text().nullable()();

  // System fields
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  // Sync fields
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  IntColumn get serverId => integer().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
