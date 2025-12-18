import 'package:drift/drift.dart';

import 'associations_table.dart';
import 'beneficiaries_table.dart';

/// 🤝 Sponsorships (Kafalat) Table - جدول الكفالات
///
/// Business rules:
/// - `fileNo` هو رقم الملف الفريد على مستوى النظام بالكامل (Auto Increment).
/// - المستفيد يمكن أن يملك أكثر من كفالة (حتى من أكثر من جمعية).
/// - عند انتهاء جميع الكفالات (status = ended) يعود ضمن "غير مكفول" في واجهة الكفالات.
@DataClassName('Sponsorship')
class Sponsorships extends Table {
  /// رقم الملف (File No) - فريد على مستوى النظام
  IntColumn get fileNo => integer().autoIncrement()();

  /// Foreign keys
  IntColumn get beneficiaryId => integer().references(Beneficiaries, #id)();
  TextColumn get associationId => text().references(Associations, #id)();

  /// Optional business fields
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  RealColumn get amount => real().nullable()();
  TextColumn get currency => text().nullable()();

  /// active | paused | ended
  TextColumn get status => text().withDefault(const Constant('active'))();

  TextColumn get notes => text().nullable()();

  /// System fields
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Sync fields (kept consistent with other tables)
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  IntColumn get serverId => integer().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
