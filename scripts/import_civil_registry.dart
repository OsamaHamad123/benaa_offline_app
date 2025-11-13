import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

/// سكريبت لتحويل MySQL dump إلى قاعدة بيانات SQLite
///
/// الاستخدام:
///   dart run scripts/import_civil_registry.dart "F:\new and clean"
///
/// يبحث عن:
/// - persons.sql (إجباري)
/// - relations.sql (اختياري)

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print(
      '❌ الاستخدام: dart run scripts/import_civil_registry.dart <مسار_المجلد>',
    );
    print(
      '📝 مثال: dart run scripts/import_civil_registry.dart "F:\\new and clean"',
    );
    exit(1);
  }

  final folderPath = args[0];
  final personsFile = File(p.join(folderPath, 'persons.sql'));
  final relationsFile = File(p.join(folderPath, 'relations.sql'));

  if (!await personsFile.exists()) {
    print('❌ ملف persons.sql غير موجود في: $folderPath');
    exit(1);
  }

  print('🚀 بدء استيراد السجل المدني\n');
  print('📂 المجلد: $folderPath');
  print('📄 persons.sql: ${await _getFileSize(personsFile)}');

  if (await relationsFile.exists()) {
    print('📄 relations.sql: ${await _getFileSize(relationsFile)}');
  } else {
    print('⚠️  relations.sql غير موجود (سيتم التخطي)');
  }
  print('');

  final converter = CivilRegistryImporter(folderPath);
  await converter.import();
}

String _getFileSize(File file) {
  final bytes = file.lengthSync();
  final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);
  return '$mb MB';
}

class CivilRegistryImporter {
  final String folderPath;
  late final String dbPath;
  late Database db;

  CivilRegistryImporter(this.folderPath) {
    dbPath = p.join(folderPath, 'civil_registry.db');
  }

  Future<void> import() async {
    final stopwatch = Stopwatch()..start();

    try {
      // تهيئة SQLite FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // حذف القاعدة القديمة
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
        print('🗑️  حذف القاعدة القديمة\n');
      }

      // فتح القاعدة وإنشاء الجداول
      print('🗄️  إنشاء قاعدة البيانات...');
      db = await openDatabase(dbPath, version: 1, onCreate: _createTables);
      print('✅ تم إنشاء الجداول\n');

      // استيراد persons
      final personsFile = File(p.join(folderPath, 'persons.sql'));
      print('📥 استيراد جدول الأشخاص...');
      final personsCount = await _importPersons(personsFile);
      print('✅ تم استيراد $personsCount شخص\n');

      // استيراد relations
      final relationsFile = File(p.join(folderPath, 'relations.sql'));
      if (await relationsFile.exists()) {
        print('📥 استيراد جدول العلاقات...');
        final relationsCount = await _importRelations(relationsFile);
        print('✅ تم استيراد $relationsCount علاقة\n');
      }

      // إنشاء الفهارس
      print('🔍 إنشاء الفهارس للأداء...');
      await _createIndexes();
      print('✅ تم إنشاء الفهارس\n');

      await db.close();

      stopwatch.stop();

      // الإحصائيات
      await _showStats(stopwatch.elapsed);

      print('\n🎉 تم بنجاح! القاعدة جاهزة للاستخدام');
      print('📍 الموقع: $dbPath');
      print('\n💡 الخطوة التالية:');
      print('   انسخ القاعدة إلى: assets\\databases\\civil_registry.db');
    } catch (e, stack) {
      print('❌ خطأ: $e');
      print('Stack trace: $stack');
      exit(1);
    }
  }

  Future<void> _createTables(Database db, int version) async {
    // جدول الأشخاص
    await db.execute('''
      CREATE TABLE persons (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        CI_ID_NUM INTEGER UNIQUE,
        CI_FIRST_ARB TEXT,
        CI_FATHER_ARB TEXT,
        CI_GRAND_FATHER_ARB TEXT,
        CI_FAMILY_ARB TEXT,
        CI_BIRTH_TB_CD INTEGER,
        CI_BIRTH_CD INTEGER,
        CI_BIRTH_DT TEXT,
        CI_SEX_CD INTEGER,
        CI_PERSONAL_CD INTEGER,
        CI_DEAD_DT INTEGER,
        MOTHER_NAME1 TEXT,
        CITY INTEGER,
        STREET TEXT,
        HOUSE_NO TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // جدول العلاقات
    await db.execute('''
      CREATE TABLE relations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        CF_ID_NUM INTEGER,
        CF_RELATIVE_CD INTEGER,
        CF_ID_RELATIVE INTEGER
      )
    ''');

    // جدول أنواع العلاقات
    await db.execute('''
      CREATE TABLE category_of_relations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        attribute TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // إضافة أنواع العلاقات الشائعة
    await db.insert('category_of_relations', {'id': 1, 'attribute': 'أب'});
    await db.insert('category_of_relations', {'id': 2, 'attribute': 'أم'});
    await db.insert('category_of_relations', {'id': 3, 'attribute': 'ابن'});
    await db.insert('category_of_relations', {'id': 4, 'attribute': 'ابنة'});
    await db.insert('category_of_relations', {'id': 5, 'attribute': 'زوج'});
    await db.insert('category_of_relations', {'id': 6, 'attribute': 'زوجة'});
  }

  Future<int> _importPersons(File sqlFile) async {
    var count = 0;
    var batchCount = 0;
    final batch = db.batch();
    final maxBatchSize = 1000;

    // قراءة الملف سطر بسطر
    final lines = await sqlFile.readAsLines();
    var isInsertSection = false;
    var currentRow = StringBuffer();

    for (var line in lines) {
      // بداية INSERT
      if (line.contains('INSERT INTO `persons`') && line.contains('VALUES')) {
        isInsertSection = true;
        // استخراج الصف الأول من نفس السطر
        final valuesIndex = line.indexOf('VALUES');
        if (valuesIndex != -1) {
          final afterValues = line.substring(valuesIndex + 6).trim();
          currentRow.write(afterValues);
        }
        continue;
      }

      // داخل قسم INSERT
      if (isInsertSection) {
        currentRow.write(line.trim());

        // نهاية صف (فاصلة أو فاصلة منقوطة)
        final rowStr = currentRow.toString().trim();
        if (rowStr.endsWith('),') || rowStr.endsWith(');')) {
          // استخراج القيم
          final values = _extractRowValues(rowStr);
          if (values.length >= 18) {
            batch.insert('persons', {
              'ID': values[0],
              'CI_ID_NUM': values[1],
              'CI_FIRST_ARB': values[2],
              'CI_FATHER_ARB': values[3],
              'CI_GRAND_FATHER_ARB': values[4],
              'CI_FAMILY_ARB': values[5],
              'CI_BIRTH_TB_CD': values[6],
              'CI_BIRTH_CD': values[7],
              'CI_BIRTH_DT': values[8],
              'CI_SEX_CD': values[9],
              'CI_PERSONAL_CD': values[10],
              'CI_DEAD_DT': values[11],
              'MOTHER_NAME1': values[12],
              'CITY': values[13],
              'STREET': values[14],
              'HOUSE_NO': values[15],
              'created_at': values[16],
              'updated_at': values[17],
            }, conflictAlgorithm: ConflictAlgorithm.replace);

            count++;
            batchCount++;

            if (batchCount >= maxBatchSize) {
              await batch.commit(noResult: true);
              batchCount = 0;
              stdout.write('\r   تقدم: $count شخص');
            }
          }

          // إعادة تعيين
          currentRow.clear();

          // نهاية INSERT
          if (rowStr.endsWith(');')) {
            isInsertSection = false;
          }
        }
      }
    }

    if (batchCount > 0) {
      await batch.commit(noResult: true);
    }

    print('\r   ✓ تم: $count شخص         ');
    return count;
  }

  Future<int> _importRelations(File sqlFile) async {
    var count = 0;
    var batchCount = 0;
    final batch = db.batch();
    final maxBatchSize = 1000;

    // قراءة الملف سطر بسطر
    final lines = await sqlFile.readAsLines();
    var isInsertSection = false;
    var currentRow = StringBuffer();

    for (var line in lines) {
      // بداية INSERT
      if (line.contains('INSERT INTO `relations`') && line.contains('VALUES')) {
        isInsertSection = true;
        final valuesIndex = line.indexOf('VALUES');
        if (valuesIndex != -1) {
          final afterValues = line.substring(valuesIndex + 6).trim();
          currentRow.write(afterValues);
        }
        continue;
      }

      // داخل قسم INSERT
      if (isInsertSection) {
        currentRow.write(line.trim());

        // نهاية صف
        final rowStr = currentRow.toString().trim();
        if (rowStr.endsWith('),') || rowStr.endsWith(');')) {
          final values = _extractRowValues(rowStr);
          if (values.length >= 4) {
            batch.insert('relations', {
              'id': values[0],
              'CF_ID_NUM': values[1],
              'CF_RELATIVE_CD': values[2],
              'CF_ID_RELATIVE': values[3],
            }, conflictAlgorithm: ConflictAlgorithm.replace);

            count++;
            batchCount++;

            if (batchCount >= maxBatchSize) {
              await batch.commit(noResult: true);
              batchCount = 0;
              stdout.write('\r   تقدم: $count علاقة');
            }
          }

          currentRow.clear();

          if (rowStr.endsWith(');')) {
            isInsertSection = false;
          }
        }
      }
    }

    if (batchCount > 0) {
      await batch.commit(noResult: true);
    }

    print('\r   ✓ تم: $count علاقة         ');
    return count;
  }

  List<dynamic> _parseValues(String row) {
    final values = <dynamic>[];
    var current = StringBuffer();
    var inString = false;
    var stringChar = '';

    for (var i = 0; i < row.length; i++) {
      final char = row[i];
      final prevChar = i > 0 ? row[i - 1] : '';

      if ((char == "'" || char == '"') && prevChar != '\\') {
        if (!inString) {
          inString = true;
          stringChar = char;
          continue;
        } else if (char == stringChar) {
          inString = false;
          continue;
        }
      }

      if (char == ',' && !inString) {
        values.add(_convertValue(current.toString().trim()));
        current.clear();
      } else {
        current.write(char);
      }
    }

    // آخر قيمة
    if (current.isNotEmpty) {
      values.add(_convertValue(current.toString().trim()));
    }

    return values;
  }

  dynamic _convertValue(String value) {
    if (value == 'NULL' || value.isEmpty) return null;

    // محاولة تحويل لرقم
    final intValue = int.tryParse(value);
    if (intValue != null) return intValue;

    // إزالة escape characters
    return value.replaceAll("\\'", "'").replaceAll('\\"', '"');
  }

  List<dynamic> _extractRowValues(String rowStr) {
    // إزالة الأقواس والفاصلة/الفاصلة المنقوطة من النهاية
    var cleaned = rowStr.trim();
    if (cleaned.startsWith('(')) cleaned = cleaned.substring(1);
    if (cleaned.endsWith('),'))
      cleaned = cleaned.substring(0, cleaned.length - 2);
    if (cleaned.endsWith(');'))
      cleaned = cleaned.substring(0, cleaned.length - 2);
    if (cleaned.endsWith(')'))
      cleaned = cleaned.substring(0, cleaned.length - 1);

    return _parseValues(cleaned);
  }

  Future<void> _createIndexes() async {
    // فهارس persons
    await db.execute('CREATE INDEX idx_ci_id_num ON persons(CI_ID_NUM)');
    await db.execute('CREATE INDEX idx_first_name ON persons(CI_FIRST_ARB)');
    await db.execute('CREATE INDEX idx_father_name ON persons(CI_FATHER_ARB)');
    await db.execute('CREATE INDEX idx_family_name ON persons(CI_FAMILY_ARB)');
    await db.execute(
      'CREATE INDEX idx_full_name ON persons(CI_FIRST_ARB, CI_FATHER_ARB, CI_FAMILY_ARB)',
    );
    await db.execute('CREATE INDEX idx_city ON persons(CITY)');

    // فهارس relations
    await db.execute('CREATE INDEX idx_cf_id_num ON relations(CF_ID_NUM)');
    await db.execute(
      'CREATE INDEX idx_cf_id_relative ON relations(CF_ID_RELATIVE)',
    );
    await db.execute(
      'CREATE INDEX idx_cf_relative_cd ON relations(CF_RELATIVE_CD)',
    );
  }

  Future<void> _showStats(Duration elapsed) async {
    final reopenedDb = await openDatabase(dbPath);

    final personsResult = await reopenedDb.rawQuery(
      'SELECT COUNT(*) as count FROM persons',
    );
    final personsCount = personsResult.first['count'] as int;

    final relationsResult = await reopenedDb.rawQuery(
      'SELECT COUNT(*) as count FROM relations',
    );
    final relationsCount = relationsResult.first['count'] as int;

    await reopenedDb.close();

    final dbFile = File(dbPath);
    final sizeBytes = await dbFile.length();
    final sizeMB = (sizeBytes / (1024 * 1024)).toStringAsFixed(2);

    print('📊 الإحصائيات النهائية:');
    print('   👥 عدد الأشخاص: $personsCount');
    print('   🔗 عدد العلاقات: $relationsCount');
    print('   💾 حجم القاعدة: $sizeMB MB');
    print(
      '   ⏱️  الوقت: ${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
    );
  }
}
