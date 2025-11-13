import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// سكريبت لإضافة فهارس (Indexes) لتسريع البحث
void main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ الاستخدام: dart run scripts/add_indexes.dart <مسار_القاعدة>');
    print(
      'مثال: dart run scripts/add_indexes.dart "assets\\databases\\civil_registry.db"',
    );
    exit(1);
  }

  final dbPath = args[0];
  final dbFile = File(dbPath);

  if (!await dbFile.exists()) {
    print('❌ الملف غير موجود: $dbPath');
    exit(1);
  }

  print('🚀 إضافة فهارس لتسريع البحث...\n');
  print('📍 القاعدة: $dbPath');
  print(
    '💾 الحجم: ${(await dbFile.length() / (1024 * 1024)).toStringAsFixed(2)} MB\n',
  );

  // تهيئة SQLite FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  try {
    final absolutePath = dbFile.absolute.path;
    final db = await openDatabase(absolutePath);

    print('🔍 إنشاء الفهارس...\n');

    final stopwatch = Stopwatch()..start();

    // فهارس جدول persons
    await _createIndex(db, 'idx_ci_id_num', 'persons', ['CI_ID_NUM']);
    await _createIndex(db, 'idx_first_name', 'persons', ['CI_FIRST_ARB']);
    await _createIndex(db, 'idx_father_name', 'persons', ['CI_FATHER_ARB']);
    await _createIndex(db, 'idx_family_name', 'persons', ['CI_FAMILY_ARB']);
    await _createIndex(db, 'idx_full_name', 'persons', [
      'CI_FIRST_ARB',
      'CI_FATHER_ARB',
      'CI_FAMILY_ARB',
    ]);
    await _createIndex(db, 'idx_mother_name', 'persons', ['MOTHER_NAME1']);
    await _createIndex(db, 'idx_city', 'persons', ['CITY']);
    await _createIndex(db, 'idx_sex', 'persons', ['CI_SEX_CD']);
    await _createIndex(db, 'idx_birth_date', 'persons', ['CI_BIRTH_DT']);

    // فهارس جدول relations
    await _createIndex(db, 'idx_cf_id_num', 'relations', ['CF_ID_NUM']);
    await _createIndex(db, 'idx_cf_id_relative', 'relations', [
      'CF_ID_RELATIVE',
    ]);
    await _createIndex(db, 'idx_cf_relative_cd', 'relations', [
      'CF_RELATIVE_CD',
    ]);
    await _createIndex(db, 'idx_relation_lookup', 'relations', [
      'CF_ID_NUM',
      'CF_RELATIVE_CD',
    ]);

    stopwatch.stop();

    print('\n⚡ تم إنشاء 13 فهرس في ${stopwatch.elapsedMilliseconds} ms');

    // اختبار السرعة
    print('\n🎯 اختبار السرعة:');
    await _testSpeed(db);

    // عرض حجم القاعدة بعد الفهارس
    await db.close();
    final newSize = (await dbFile.length() / (1024 * 1024)).toStringAsFixed(2);
    print('\n💾 الحجم بعد الفهارس: $newSize MB');

    print('\n✅ تم بنجاح! القاعدة الآن فائقة السرعة ⚡');
  } catch (e, stackTrace) {
    print('❌ خطأ: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

Future<void> _createIndex(
  Database db,
  String indexName,
  String tableName,
  List<String> columns,
) async {
  try {
    final columnsList = columns.join(', ');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS $indexName ON $tableName($columnsList)',
    );
    print('   ✅ $indexName');
  } catch (e) {
    print('   ⚠️  فشل $indexName: $e');
  }
}

Future<void> _testSpeed(Database db) async {
  // اختبار 1: البحث بالرقم الوطني
  var stopwatch = Stopwatch()..start();
  await db.rawQuery(
    'SELECT * FROM persons WHERE CI_ID_NUM = 926759127 LIMIT 1',
  );
  stopwatch.stop();
  print('   البحث بالرقم الوطني: ${stopwatch.elapsedMilliseconds} ms ⚡');

  // اختبار 2: البحث بالاسم
  stopwatch.reset();
  stopwatch.start();
  await db.rawQuery(
    "SELECT * FROM persons WHERE CI_FIRST_ARB LIKE '%محمد%' LIMIT 10",
  );
  stopwatch.stop();
  print('   البحث بالاسم: ${stopwatch.elapsedMilliseconds} ms');

  // اختبار 3: البحث بالاسم الكامل
  stopwatch.reset();
  stopwatch.start();
  await db.rawQuery("""
    SELECT * FROM persons 
    WHERE CI_FIRST_ARB LIKE '%محمد%' 
      AND CI_FATHER_ARB LIKE '%أحمد%'
    LIMIT 10
  """);
  stopwatch.stop();
  print('   البحث بالاسم الكامل: ${stopwatch.elapsedMilliseconds} ms');

  // اختبار 4: البحث بالجنس
  stopwatch.reset();
  stopwatch.start();
  await db.rawQuery('SELECT COUNT(*) FROM persons WHERE CI_SEX_CD = 1');
  stopwatch.stop();
  print('   عد الذكور: ${stopwatch.elapsedMilliseconds} ms');

  // اختبار 5: البحث في العلاقات
  stopwatch.reset();
  stopwatch.start();
  final relationsTest = await db.rawQuery(
    'SELECT COUNT(*) as count FROM relations WHERE CF_ID_NUM = 926759127',
  );
  stopwatch.stop();
  final hasRelations = (relationsTest.first['count'] as int) > 0;
  if (hasRelations) {
    print('   البحث في العلاقات: ${stopwatch.elapsedMilliseconds} ms ⚡');
  }
}
