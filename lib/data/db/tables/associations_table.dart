import 'package:drift/drift.dart';

/// 🏢 Associations Table - جدول الجمعيات
///
/// يحتوي على جميع المعلومات الأساسية والمالية للجمعيات
@DataClassName('Association')
class Associations extends Table {
  // Primary Key
  TextColumn get id => text()();

  // Basic Information
  TextColumn get name => text()(); // اسم الجمعية
  TextColumn get shortName => text().nullable()(); // الاسم المختصر

  // Contact Information
  TextColumn get phone => text()(); // رقم الهاتف
  TextColumn get email => text().nullable()(); // البريد الإلكتروني

  // Banking Information
  TextColumn get bankName => text()(); // اسم البنك
  TextColumn get accountNumber => text()(); // رقم الحساب
  TextColumn get swiftCode => text().nullable()(); // رمز السويفت
  TextColumn get bankPhone => text().nullable()(); // رقم هاتف البنك
  TextColumn get accountCurrency => text().nullable()(); // عملة الحساب (IQD, USD, EUR)

  // Representative Link
  TextColumn get representativeId => text().nullable().references(AssociationRepresentatives, #id)(); // مندوب الجمعية

  // Status
  BoolColumn get isActive => boolean().withDefault(const Constant(true))(); // نشط/معطل

  // Timestamps
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Sync Fields
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  // 'pending', 'synced', 'failed'
  IntColumn get serverId => integer().nullable()(); // ID من السيرفر
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 👤 Association Representatives Table - جدول مندوبي الجمعيات
///
/// يحتوي على أسماء مندوبي الجمعيات فقط (بدون تفاصيل إضافية)
@DataClassName('Representative')
class AssociationRepresentatives extends Table {
  // Primary Key
  TextColumn get id => text()();

  // Basic Information
  TextColumn get name => text()(); // اسم المندوب

  // Timestamps
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Sync Fields
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  IntColumn get serverId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
