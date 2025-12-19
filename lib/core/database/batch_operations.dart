import 'package:sqflite/sqflite.dart';

/// 📦 Batch Operations Helper
///
/// Provides efficient batch insert/update/delete operations for database
/// to improve sync performance and reduce transaction overhead.
///
/// Features:
/// - Automatic batching (default 100 records per batch)
/// - Transaction management
/// - Error handling with partial success tracking
/// - Memory-efficient processing
class BatchOperations {
  /// Default batch size for optimal performance
  static const int defaultBatchSize = 100;

  /// 📥 Batch Insert
  ///
  /// Inserts multiple records efficiently using batched transactions.
  ///
  /// Example:
  /// ```dart
  /// await BatchOperations.batchInsert(
  ///   database: db,
  ///   table: 'beneficiaries',
  ///   records: beneficiariesList,
  ///   batchSize: 50,
  /// );
  /// ```
  static Future<BatchResult> batchInsert({
    required Database database,
    required String table,
    required List<Map<String, dynamic>> records,
    int batchSize = defaultBatchSize,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    if (records.isEmpty) {
      return BatchResult(
        totalRecords: 0,
        successCount: 0,
        failureCount: 0,
        batches: 0,
      );
    }

    int successCount = 0;
    int failureCount = 0;
    int batchCount = 0;

    try {
      // Process in batches
      for (int i = 0; i < records.length; i += batchSize) {
        final end =
            (i + batchSize < records.length) ? i + batchSize : records.length;
        final batchRecords = records.sublist(i, end);

        try {
          await database.transaction((txn) async {
            final batch = txn.batch();

            for (final record in batchRecords) {
              batch.insert(
                table,
                record,
                conflictAlgorithm: conflictAlgorithm,
              );
            }

            await batch.commit(noResult: true);
          });

          successCount += batchRecords.length;
          batchCount++;
        } catch (e) {
          failureCount += batchRecords.length;
          print('❌ Batch insert error (batch ${batchCount + 1}): $e');
        }
      }

      return BatchResult(
        totalRecords: records.length,
        successCount: successCount,
        failureCount: failureCount,
        batches: batchCount,
      );
    } catch (e) {
      print('❌ Critical error in batchInsert: $e');
      rethrow;
    }
  }

  /// 🔄 Batch Update
  ///
  /// Updates multiple records efficiently using batched transactions.
  /// Each record must have a unique identifier field (default: 'id').
  ///
  /// Example:
  /// ```dart
  /// await BatchOperations.batchUpdate(
  ///   database: db,
  ///   table: 'beneficiaries',
  ///   records: updatedBeneficiaries,
  ///   idField: 'id',
  /// );
  /// ```
  static Future<BatchResult> batchUpdate({
    required Database database,
    required String table,
    required List<Map<String, dynamic>> records,
    String idField = 'id',
    int batchSize = defaultBatchSize,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    if (records.isEmpty) {
      return BatchResult(
        totalRecords: 0,
        successCount: 0,
        failureCount: 0,
        batches: 0,
      );
    }

    int successCount = 0;
    int failureCount = 0;
    int batchCount = 0;

    try {
      for (int i = 0; i < records.length; i += batchSize) {
        final end =
            (i + batchSize < records.length) ? i + batchSize : records.length;
        final batchRecords = records.sublist(i, end);

        try {
          await database.transaction((txn) async {
            final batch = txn.batch();

            for (final record in batchRecords) {
              final id = record[idField];
              if (id == null) {
                failureCount++;
                continue;
              }

              batch.update(
                table,
                record,
                where: '$idField = ?',
                whereArgs: [id],
                conflictAlgorithm: conflictAlgorithm,
              );
            }

            await batch.commit(noResult: true);
          });

          successCount += batchRecords.length;
          batchCount++;
        } catch (e) {
          failureCount += batchRecords.length;
          print('❌ Batch update error (batch ${batchCount + 1}): $e');
        }
      }

      return BatchResult(
        totalRecords: records.length,
        successCount: successCount,
        failureCount: failureCount,
        batches: batchCount,
      );
    } catch (e) {
      print('❌ Critical error in batchUpdate: $e');
      rethrow;
    }
  }

  /// 🗑️ Batch Delete
  ///
  /// Deletes multiple records by IDs efficiently.
  ///
  /// Example:
  /// ```dart
  /// await BatchOperations.batchDelete(
  ///   database: db,
  ///   table: 'beneficiaries',
  ///   ids: [1, 2, 3, 4, 5],
  /// );
  /// ```
  static Future<BatchResult> batchDelete({
    required Database database,
    required String table,
    required List<dynamic> ids,
    String idField = 'id',
    int batchSize = defaultBatchSize,
  }) async {
    if (ids.isEmpty) {
      return BatchResult(
        totalRecords: 0,
        successCount: 0,
        failureCount: 0,
        batches: 0,
      );
    }

    int successCount = 0;
    int failureCount = 0;
    int batchCount = 0;

    try {
      for (int i = 0; i < ids.length; i += batchSize) {
        final end = (i + batchSize < ids.length) ? i + batchSize : ids.length;
        final batchIds = ids.sublist(i, end);

        try {
          await database.transaction((txn) async {
            final batch = txn.batch();

            batch.delete(
              table,
              where:
                  '$idField IN (${List.filled(batchIds.length, '?').join(', ')})',
              whereArgs: batchIds,
            );

            await batch.commit(noResult: true);
          });

          successCount += batchIds.length;
          batchCount++;
        } catch (e) {
          failureCount += batchIds.length;
          print('❌ Batch delete error (batch ${batchCount + 1}): $e');
        }
      }

      return BatchResult(
        totalRecords: ids.length,
        successCount: successCount,
        failureCount: failureCount,
        batches: batchCount,
      );
    } catch (e) {
      print('❌ Critical error in batchDelete: $e');
      rethrow;
    }
  }

  /// 🔄 Batch Upsert (Insert or Update)
  ///
  /// Performs batch upsert using REPLACE conflict algorithm.
  /// This is more efficient than checking existence first.
  static Future<BatchResult> batchUpsert({
    required Database database,
    required String table,
    required List<Map<String, dynamic>> records,
    int batchSize = defaultBatchSize,
  }) async {
    return await batchInsert(
      database: database,
      table: table,
      records: records,
      batchSize: batchSize,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 📊 Execute raw batch SQL
  ///
  /// For custom SQL operations that need batching.
  static Future<BatchResult> executeBatch({
    required Database database,
    required List<String> sqlStatements,
    List<List<dynamic>>? arguments,
    int batchSize = defaultBatchSize,
  }) async {
    if (sqlStatements.isEmpty) {
      return BatchResult(
        totalRecords: 0,
        successCount: 0,
        failureCount: 0,
        batches: 0,
      );
    }

    int successCount = 0;
    int failureCount = 0;
    int batchCount = 0;

    try {
      for (int i = 0; i < sqlStatements.length; i += batchSize) {
        final end = (i + batchSize < sqlStatements.length)
            ? i + batchSize
            : sqlStatements.length;
        final batchSql = sqlStatements.sublist(i, end);
        final batchArgs = arguments?.sublist(i, end);

        try {
          await database.transaction((txn) async {
            final batch = txn.batch();

            for (int j = 0; j < batchSql.length; j++) {
              batch.rawInsert(
                batchSql[j],
                batchArgs?[j] ?? [],
              );
            }

            await batch.commit(noResult: true);
          });

          successCount += batchSql.length;
          batchCount++;
        } catch (e) {
          failureCount += batchSql.length;
          print('❌ Batch SQL error (batch ${batchCount + 1}): $e');
        }
      }

      return BatchResult(
        totalRecords: sqlStatements.length,
        successCount: successCount,
        failureCount: failureCount,
        batches: batchCount,
      );
    } catch (e) {
      print('❌ Critical error in executeBatch: $e');
      rethrow;
    }
  }
}

/// 📊 Batch Operation Result
///
/// Contains statistics about batch operation execution.
class BatchResult {
  final int totalRecords;
  final int successCount;
  final int failureCount;
  final int batches;

  BatchResult({
    required this.totalRecords,
    required this.successCount,
    required this.failureCount,
    required this.batches,
  });

  /// Success rate percentage
  double get successRate =>
      totalRecords > 0 ? (successCount / totalRecords * 100) : 0;

  /// Whether all operations succeeded
  bool get isFullSuccess => failureCount == 0 && successCount == totalRecords;

  /// Whether operation partially succeeded
  bool get isPartialSuccess => successCount > 0 && failureCount > 0;

  /// Whether operation completely failed
  bool get isFailure => successCount == 0 && failureCount > 0;

  @override
  String toString() {
    return 'BatchResult('
        'total: $totalRecords, '
        'success: $successCount, '
        'failed: $failureCount, '
        'batches: $batches, '
        'rate: ${successRate.toStringAsFixed(1)}%)';
  }
}
