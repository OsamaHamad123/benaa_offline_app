import 'package:drift/drift.dart';
import 'beneficiaries_table.dart';

/// 🆔 File ID Reservation Table
///
/// Stores reserved file IDs from the server to be used when creating
/// new beneficiaries or records while offline.
@DataClassName('FileIdReservation')
class FileIdReservationTable extends Table {
  @override
  String get tableName => 'file_id_reservations';

  IntColumn get id => integer().autoIncrement()();

  // The actual File ID reserved from the server
  IntColumn get fileId => integer().unique()();

  // Status: available, used, synced
  TextColumn get status => text().withLength(min: 1, max: 20).withDefault(const Constant('available'))();

  // Reference to the beneficiary using this ID (if used)
  IntColumn get beneficiaryId => integer().nullable().references(Beneficiaries, #id)();

  DateTimeColumn get reservedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get usedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}
