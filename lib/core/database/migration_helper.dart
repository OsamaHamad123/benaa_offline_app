import 'package:sqflite/sqflite.dart';
import '../utils/arabic_normalizer.dart';

/// 🔄 Database Migration Helper for ArabicNormalizer
///
/// Provides utilities to migrate existing database records by normalizing
/// Arabic text fields for better search performance.
class DatabaseMigrationHelper {
  /// 📊 Normalize all records in a table
  ///
  /// This method reads all records from the specified table,
  /// normalizes the Arabic text in the specified column,
  /// and writes it to the normalized column.
  ///
  /// Example:
  /// ```dart
  /// await DatabaseMigrationHelper.normalizeTableColumn(
  ///   database: db,
  ///   tableName: 'beneficiaries',
  ///   sourceColumn: 'first_name',
  ///   targetColumn: 'first_name_normalized',
  /// );
  /// ```
  static Future<int> normalizeTableColumn({
    required Database database,
    required String tableName,
    required String sourceColumn,
    required String targetColumn,
  }) async {
    try {
      // Read all records with non-null source column
      final records = await database.query(
        tableName,
        where: '$sourceColumn IS NOT NULL',
      );

      int updatedCount = 0;

      // Process in batches for better performance
      const batchSize = 100;
      for (int i = 0; i < records.length; i += batchSize) {
        final batch = database.batch();
        final end =
            (i + batchSize < records.length) ? i + batchSize : records.length;

        for (int j = i; j < end; j++) {
          final record = records[j];
          final id = record['id'];
          final sourceValue = record[sourceColumn] as String?;

          if (sourceValue != null && sourceValue.isNotEmpty) {
            final normalized = ArabicNormalizer.normalize(sourceValue);

            batch.update(
              tableName,
              {targetColumn: normalized},
              where: 'id = ?',
              whereArgs: [id],
            );
            updatedCount++;
          }
        }

        await batch.commit(noResult: true);
      }

      return updatedCount;
    } catch (e) {
      // Log error for debugging
      print(
          'Migration Error: Failed to normalize $tableName.$sourceColumn: $e');
      rethrow;
    }
  }

  /// 🔄 Normalize all beneficiaries records
  ///
  /// Normalizes first_name, father_name, grandfather_name, last_name
  /// for better Arabic search in beneficiaries table.
  static Future<Map<String, int>> normalizeAllBeneficiaries({
    required Database database,
  }) async {
    final results = <String, int>{};

    // Normalize first name
    results['first_name'] = await normalizeTableColumn(
      database: database,
      tableName: 'beneficiaries',
      sourceColumn: 'first_name',
      targetColumn: 'first_name_normalized',
    );

    // Normalize father name
    results['father_name'] = await normalizeTableColumn(
      database: database,
      tableName: 'beneficiaries',
      sourceColumn: 'father_name',
      targetColumn: 'father_name_normalized',
    );

    // Normalize grandfather name
    results['grandfather_name'] = await normalizeTableColumn(
      database: database,
      tableName: 'beneficiaries',
      sourceColumn: 'grandfather_name',
      targetColumn: 'grandfather_name_normalized',
    );

    // Normalize last name
    results['last_name'] = await normalizeTableColumn(
      database: database,
      tableName: 'beneficiaries',
      sourceColumn: 'last_name',
      targetColumn: 'last_name_normalized',
    );

    return results;
  }

  /// 🔄 Normalize all civil registry records
  ///
  /// Normalizes full_name for better Arabic search in civil registry.
  static Future<int> normalizeAllCivilRegistry({
    required Database database,
  }) async {
    return await normalizeTableColumn(
      database: database,
      tableName: 'civil_registry',
      sourceColumn: 'full_name',
      targetColumn: 'full_name_normalized',
    );
  }

  /// 📊 Get normalization statistics
  ///
  /// Returns counts of records with/without normalized values.
  static Future<Map<String, dynamic>> getNormalizationStats({
    required Database database,
    required String tableName,
    required String normalizedColumn,
  }) async {
    final totalResult = await database.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName',
    );
    final total = totalResult.first['count'] as int;

    final normalizedResult = await database.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE $normalizedColumn IS NOT NULL AND $normalizedColumn != ""',
    );
    final normalized = normalizedResult.first['count'] as int;

    return {
      'total': total,
      'normalized': normalized,
      'pending': total - normalized,
      'percentage':
          total > 0 ? (normalized / total * 100).toStringAsFixed(1) : '0',
    };
  }
}
