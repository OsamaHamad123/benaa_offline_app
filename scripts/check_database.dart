import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ الاستخدام: dart run scripts/check_database.dart <مسار_القاعدة>');
    print(
      'مثال: dart run scripts/check_database.dart "assets\\databases\\civil_registry.db"',
    );
    exit(1);
  }

  final dbPath = args[0];
  final dbFile = File(dbPath);

  if (!await dbFile.exists()) {
    print('❌ الملف غير موجود: $dbPath');
    exit(1);
  }

  print('🔍 فحص قاعدة البيانات...\n');
  print('📍 الموقع: $dbPath');
  print(
    '💾 الحجم: ${(await dbFile.length() / (1024 * 1024)).toStringAsFixed(2)} MB\n',
  );

  // تهيئة SQLite FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  try {
    // استخدام المسار المطلق
    final absolutePath = dbFile.absolute.path;
    final db = await openDatabase(absolutePath, readOnly: true);

    // فحص الجداول
    print('📊 الجداول الموجودة:');
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
    );
    for (final table in tables) {
      print('   - ${table['name']}');
    }
    print('');

    // عدد الأشخاص
    final personsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM persons',
    );
    final personsCount = personsResult.first['count'] as int?;
    print('👥 عدد الأشخاص: ${personsCount ?? 0}');

    // عدد العلاقات
    try {
      final relationsResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM relations',
      );
      final relationsCount = relationsResult.first['count'] as int?;
      print('🔗 عدد العلاقات: ${relationsCount ?? 0}');
    } catch (e) {
      print('🔗 عدد العلاقات: 0 (الجدول فارغ أو غير موجود)');
    }

    // عدد أنواع العلاقات
    try {
      final categoriesResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM category_of_relations',
      );
      final categoriesCount = categoriesResult.first['count'] as int?;
      print('📋 أنواع العلاقات: ${categoriesCount ?? 0}');
    } catch (e) {
      print('📋 أنواع العلاقات: 0');
    }

    print('');

    // عينة من البيانات
    if (personsCount != null && personsCount > 0) {
      print('📋 عينة من البيانات (أول 5 أشخاص):');
      print('=' * 80);

      final sample = await db.rawQuery('SELECT * FROM persons LIMIT 5');

      for (var i = 0; i < sample.length; i++) {
        final person = sample[i];
        print('\n${i + 1}. الرقم الوطني: ${person['CI_ID_NUM']}');
        print(
          '   الاسم: ${person['CI_FIRST_ARB']} ${person['CI_FATHER_ARB']} ${person['CI_FAMILY_ARB']}',
        );
        print('   اسم الأم: ${person['MOTHER_NAME1'] ?? 'غير محدد'}');
        print('   المدينة: ${person['CITY'] ?? 'غير محدد'}');
        print('   تاريخ الميلاد: ${person['CI_BIRTH_DT'] ?? 'غير محدد'}');
        final sex = person['CI_SEX_CD'];
        print(
          '   الجنس: ${sex == 1
              ? 'ذكر'
              : sex == 2
              ? 'أنثى'
              : 'غير محدد'}',
        );
      }
      print('=' * 80);
      print('');

      // اختبار البحث
      print('🔍 اختبار البحث:');
      final searchTest = await db.rawQuery(
        "SELECT COUNT(*) as count FROM persons WHERE CI_FIRST_ARB LIKE '%محمد%'",
      );
      final muhammadCount = searchTest[0]['count'];
      print('   عدد الأشخاص باسم "محمد": $muhammadCount');

      final femaleCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM persons WHERE CI_SEX_CD = 2',
      );
      print('   عدد الإناث: ${femaleCount[0]['count']}');

      final maleCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM persons WHERE CI_SEX_CD = 1',
      );
      print('   عدد الذكور: ${maleCount[0]['count']}');

      // الفهارس
      print('\n📑 الفهارس الموجودة:');
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%'",
      );
      if (indexes.isEmpty) {
        print('   ⚠️  لا توجد فهارس (البحث سيكون بطيء)');
      } else {
        for (final index in indexes) {
          print('   ✅ ${index['name']}');
        }
      }

      // اختبار سرعة البحث
      print('\n⚡ اختبار سرعة البحث:');
      final stopwatch = Stopwatch()..start();
      await db.rawQuery(
        'SELECT * FROM persons WHERE CI_ID_NUM = 926759127 LIMIT 1',
      );
      stopwatch.stop();
      print('   بحث بالرقم الوطني: ${stopwatch.elapsedMilliseconds} ms');

      stopwatch.reset();
      stopwatch.start();
      await db.rawQuery(
        "SELECT * FROM persons WHERE CI_FIRST_ARB LIKE '%محمد%' LIMIT 10",
      );
      stopwatch.stop();
      print('   بحث بالاسم (أول 10): ${stopwatch.elapsedMilliseconds} ms');
    }

    await db.close();

    print('\n✅ الفحص مكتمل!');

    if (personsCount != null && personsCount > 0) {
      print('\n💡 الخطوة التالية:');
      print('   القاعدة جاهزة للاستخدام في التطبيق! 🎉');
      print('   يمكنك الآن:');
      print('   1. تشغيل التطبيق: flutter run');
      print('   2. اختبار صفحة السجل المدني');
      print('   3. اختبار البحث والتعبئة التلقائية');
    } else {
      print('\n⚠️  القاعدة فارغة!');
      print('   يرجى استيراد البيانات أولاً');
    }
  } catch (e, stackTrace) {
    print('❌ خطأ في فحص القاعدة: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
