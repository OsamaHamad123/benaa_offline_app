import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:benaa_offline_app/core/utils/unified_logger.dart';

import 'civil_registry_database.dart';
import 'text_normalization_service.dart';

/// 🔧 One-time utility to update full_name_norm with enhanced hamza handling
///
/// Run this ONCE after updating the normalization logic
class UpdateNormalizationUtility {
  /// Update all records with new normalization (handles word-ending hamza)
  static Future<void> updateAllNormalization() async {
    final db = await CivilRegistryDatabase.instance.database;
    if (db == null) {
      UnifiedLogger.error('❌ Cannot update normalization: Database not available');
      return;
    }

    UnifiedLogger.info('🔄 Starting normalization update...');
    final stopwatch = Stopwatch()..start();

    // Get total count
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM persons',
    );
    final total = countResult.first['total'] as int;
    UnifiedLogger.info('📊 Total records to update: ${_formatNumber(total)}');

    // Process in batches to avoid memory issues
    const batchSize = 10000;
    var updated = 0;
    var batch = db.batch();

    for (var offset = 0; offset < total; offset += batchSize) {
      UnifiedLogger.info(
        '📦 Processing batch: ${offset + 1} to ${offset + batchSize}...',
      );

      // Get batch of records
      final records = await db.rawQuery(
        '''
        SELECT 
          CI_NATIONAL_ID,
          CI_FIRST_ARB,
          CI_FATHER_ARB,
          CI_GRAND_FATHER_ARB,
          CI_FAMILY_ARB
        FROM persons
        LIMIT ? OFFSET ?
      ''',
        [batchSize, offset],
      );

      // Update each record
      for (final row in records) {
        final normalizedName = TextNormalizationService.buildNormalizedName(
          row,
        );

        batch.update(
          'persons',
          {'full_name_norm': normalizedName},
          where: 'CI_NATIONAL_ID = ?',
          whereArgs: [row['CI_NATIONAL_ID']],
        );

        updated++;
      }

      // Commit batch
      await batch.commit(noResult: true);
      batch = db.batch();

      // Progress
      final progress = ((offset + records.length) / total * 100).toStringAsFixed(1);
      if (kDebugMode) {
        debugPrint(
          '✅ Progress: $progress% (${_formatNumber(offset + records.length)}/${_formatNumber(total)})',
        );
      }
    }

    stopwatch.stop();
    UnifiedLogger.log('');
    UnifiedLogger.success('🎉 Normalization update completed!');
    UnifiedLogger.info('📊 Updated records: ${_formatNumber(updated)}');
    UnifiedLogger.info('⏱️ Time taken: ${stopwatch.elapsed.inSeconds}s');
    UnifiedLogger.log('');
    UnifiedLogger.info('🔍 Testing sample records:');
    await _testSampleRecords(db);
  }

  /// Test sample records to verify normalization
  static Future<void> _testSampleRecords(Database db) async {
    // Test names with word-ending hamza
    final testNames = ['ولاء', 'هناء', 'سناء', 'دعاء', 'رجاء'];

    for (final name in testNames) {
      final results = await db.rawQuery(
        '''
        SELECT 
          CI_FIRST_ARB,
          CI_FATHER_ARB,
          CI_FAMILY_ARB,
          full_name_norm
        FROM persons
        WHERE CI_FIRST_ARB LIKE ?
        LIMIT 3
      ''',
        ['$name%'],
      );

      if (results.isNotEmpty) {
        UnifiedLogger.log('');
        UnifiedLogger.info('🔍 Testing: $name');
        for (final row in results) {
          final fullName = '${row['CI_FIRST_ARB']} ${row['CI_FATHER_ARB']} ${row['CI_FAMILY_ARB']}';
          if (kDebugMode) {
            debugPrint('  Original: $fullName');
            debugPrint('  Normalized: ${row['full_name_norm']}');
          }
        }
      }
    }
  }

  /// Format number with thousands separator
  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// Quick test: Check if normalization is working
  static Future<bool> testNormalization() async {
    if (kDebugMode) debugPrint('🧪 Testing normalization logic...');

    // Test cases
    final tests = {
      'ولاء': 'ولا', // Word-ending hamza should be removed
      'هناء': 'هنا',
      'سناء': 'سنا',
      'دعاء': 'دعا',
      'رجاء': 'رجا',
      'محمد': 'محمد', // No hamza - should stay same
      'أحمد': 'احمد', // Alef hamza → regular alef
    };

    var allPassed = true;

    for (final entry in tests.entries) {
      final input = entry.key;
      final expected = entry.value;
      final actual = TextNormalizationService.normalize(input);

      final passed = actual == expected;
      final status = passed ? '✅' : '❌';

      if (kDebugMode) {
        debugPrint('$status "$input" → "$actual" (expected: "$expected")');
      }

      if (!passed) {
        allPassed = false;
      }
    }

    if (kDebugMode) {
      debugPrint('');
      if (allPassed) {
        debugPrint('🎉 All normalization tests passed!');
      } else {
        debugPrint('⚠️ Some normalization tests failed!');
      }
    }

    return allPassed;
  }
}
