import 'package:drift/drift.dart';

/// Taxonomies table - التصنيفات (governorates, categories, etc.)
@DataClassName('Taxonomy')
class Taxonomies extends Table {
  TextColumn get id => text()();
  TextColumn get group => text()(); // 'governorate', 'category', 'gender'
  TextColumn get code => text()();
  TextColumn get label => text()();
  TextColumn get parentId => text().nullable()(); // للتصنيفات الهرمية
  IntColumn get sortOrder =>
      integer().withDefault(const Constant(0))(); // ترتيب العرض
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
