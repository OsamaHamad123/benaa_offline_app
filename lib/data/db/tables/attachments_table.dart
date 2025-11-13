import 'package:drift/drift.dart';

/// Attachments table - المرفقات
@DataClassName('Attachment')
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get beneficiaryId => text()();
  TextColumn get visitId => text().nullable()();
  TextColumn get fileName => text()(); // اسم الملف
  TextColumn get filePath => text()(); // المسار الكامل
  TextColumn get type => text()(); // 'image', 'pdf', 'other'
  IntColumn get fileSize => integer()(); // حجم الملف بالبايت
  TextColumn get thumbnailPath => text().nullable()(); // مسار الصورة المصغرة
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  TextColumn get serverUrl => text().nullable()(); // URL على السيرفر بعد الرفع
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
