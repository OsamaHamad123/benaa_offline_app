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
  /// رقم الملف (File No) - فريد على مستوى النظام (Auto-generated)
  IntColumn get fileNo => integer().autoIncrement()();

  /// Foreign keys
  IntColumn get beneficiaryId => integer().references(Beneficiaries, #id)();
  TextColumn get associationId => text().references(Associations, #id)();

  // ========== معلومات الكافل ==========
  /// اسم الكافل (الشخص أو المؤسسة)
  TextColumn get sponsorName => text().nullable()();

  // ========== معلومات المكفول ==========
  /// رقم الملف الداخلي (Internal File Number)
  TextColumn get internalFileNo => text().nullable()();

  /// رقم الملف الخارجي (External File Number)
  TextColumn get externalFileNo => text().nullable()();

  /// اسم المعيل (Guardian Name)
  TextColumn get guardianName => text().nullable()();

  /// رقم هوية المعيل (Guardian ID Number)
  IntColumn get guardianIdNumber => integer().nullable()();

  /// رقم هاتف المعيل (Guardian Phone)
  TextColumn get guardianPhone => text().nullable()();

  /// جوال بديل للمعيل (Guardian Alt Phone)
  TextColumn get guardianAltPhone => text().nullable()();

  // ========== تفاصيل الكفالة ==========
  /// مدة الكفالة بالأشهر (Sponsorship Duration in Months)
  IntColumn get durationMonths => integer().nullable()();

  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();

  /// القيمة المالية
  RealColumn get amount => real().nullable()();
  TextColumn get currency => text().nullable()();

  /// active | paused | ended
  TextColumn get status => text().withDefault(const Constant('active'))();

  /// monthly | one_time | other
  TextColumn get sponsorshipType =>
      text().withDefault(const Constant('monthly'))();

  // ========== معلومات بنكية للمكفول ==========
  /// اسم البنك (Bank Name)
  TextColumn get bankName => text().nullable()();

  /// اسم صاحب الحساب (Account Holder Name)
  TextColumn get accountHolderName => text().nullable()();

  /// رقم هوية صاحب الحساب (Account Holder ID)
  IntColumn get accountHolderIdNumber => integer().nullable()();

  /// رقم الحساب البنكي (Account Number)
  TextColumn get accountNumber => text().nullable()();

  /// رمز Swift (Swift Code)
  TextColumn get swiftCode => text().nullable()();

  // ========== معلومات الموقع ==========
  /// المحافظة (Governorate)
  TextColumn get governorate => text().nullable()();

  /// المدينة (City)
  TextColumn get city => text().nullable()();

  /// العنوان التفصيلي (Detailed Address)
  TextColumn get address => text().nullable()();

  // ========== معلومات إضافية ==========
  /// Optional link to import_batches.id
  IntColumn get importBatchId => integer().nullable()();

  TextColumn get notes => text().nullable()();

  /// System fields
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Sync fields (kept consistent with other tables)
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  IntColumn get serverId => integer().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
