import 'package:drift/drift.dart';

/// جدول أفراد العائلة الأحياء
@DataClassName('FamilyMember')
class FamilyMembersTable extends Table {
  @override
  String get tableName => 'family_members';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get beneficiaryId => integer()();

  // Personal Info
  TextColumn get fullName => text()();
  TextColumn get relationship =>
      text()(); // ابن، ابنة، أخ، أخت، زوج، زوجة، أب، أم
  TextColumn get gender => text()(); // male, female
  TextColumn get nationalId => text().nullable()();

  DateTimeColumn get birthDate => dateTime().nullable()();
  IntColumn get age => integer().nullable()();

  // Social & Education
  TextColumn get maritalStatus => text().nullable()();
  TextColumn get educationLevel => text().nullable()();
  TextColumn get occupation => text().nullable()();

  // Health
  TextColumn get healthStatus => text().nullable()();
  BoolColumn get hasDisability =>
      boolean().withDefault(const Constant(false))();
  TextColumn get disabilityType => text().nullable()();
  BoolColumn get hasChronicDisease =>
      boolean().withDefault(const Constant(false))();
  TextColumn get chronicDiseaseType => text().nullable()();

  // Living situation
  BoolColumn get livesWithBeneficiary =>
      boolean().withDefault(const Constant(true))();
  TextColumn get phone => text().nullable()();

  TextColumn get notes => text().nullable()();

  // System fields
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  // Sync fields
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  IntColumn get serverId => integer().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
