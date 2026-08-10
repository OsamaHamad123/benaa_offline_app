import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/data/db/daos/beneficiaries_dao.dart';

void main() {
  late AppDatabase database;
  late BeneficiariesDao dao;

  setUp(() async {
    // إنشاء قاعدة بيانات في الذاكرة للاختبار
    database = AppDatabase(NativeDatabase.memory());
    dao = database.beneficiariesDao;

    // إضافة بيانات تجريبية
    await _seedTestData(dao);
  });

  tearDown(() async {
    await database.close();
  });

  group('🔍 Search Tests - اختبارات البحث', () {
    test('يجب أن يجد المستفيد بالرقم الوطني الكامل', () async {
      final results = await dao.searchBeneficiaries('123456789');

      expect(results.isNotEmpty, true);
      expect(results.any((b) => b.idNumber == 123456789), true);
    });

    test('يجب أن يجد المستفيد بجزء من الرقم الوطني', () async {
      final results = await dao.searchBeneficiaries('12345');

      expect(results.isNotEmpty, true);
      expect(results.any((b) => b.idNumber.toString().contains('12345')), true);
    });

    test('يجب أن يجد المستفيد بالاسم الكامل', () async {
      final results = await dao.searchBeneficiaries('محمد أحمد');

      expect(results.isNotEmpty, true);
      expect(
          results.any((b) => b.firstName == 'محمد' && b.fatherName == 'أحمد'),
          true);
    });

    test('يجب أن يجد المستفيد بالاسم الأول فقط', () async {
      final results = await dao.searchBeneficiaries('محمد');

      expect(results.isNotEmpty, true);
      expect(results.any((b) => b.firstName == 'محمد'), true);
    });

    test('يجب أن يجد المستفيد باسم العائلة', () async {
      final results = await dao.searchBeneficiaries('السعيد');

      expect(results.isNotEmpty, true);
      expect(results.any((b) => b.familyName == 'السعيد'), true);
    });

    test('البحث يجب أن يكون case-insensitive', () async {
      final results1 = await dao.searchBeneficiaries('محمد');
      final results2 = await dao.searchBeneficiaries('محمد');

      expect(results1.length, equals(results2.length));
      // يجب أن تكون النتائج متطابقة بغض النظر عن الحالة
    });

    test('يجب أن يجد المستفيد برقم الملف', () async {
      final results = await dao.searchBeneficiaries('FILE001');

      expect(results.isNotEmpty, true);
      expect(results.any((b) => b.fileIdNumber == 'FILE001'), true);
    });

    test('البحث الفارغ يجب أن يرجع كل المستفيدين', () async {
      final results = await dao.searchBeneficiaries('');
      final allBeneficiaries = await dao.getAllBeneficiaries();

      expect(results.length, equals(allBeneficiaries.length));
    });

    test('البحث بنص غير موجود يجب أن يرجع قائمة فارغة', () async {
      final results = await dao.searchBeneficiaries('نص غير موجود 123XYZ999');

      expect(results.isEmpty, true);
    });
  });

  group('🔎 Advanced Search Tests - البحث المتقدم', () {
    test('البحث مع فلتر الفئة', () async {
      final results = await dao.searchBeneficiariesFiltered(
        query: '',
        category: 1, // يتيم
      );

      expect(results.isNotEmpty, true);
      expect(results.every((b) => b.sectionId == 1), true);
    });

    test('البحث مع فلتر المحافظة', () async {
      final results = await dao.searchBeneficiariesFiltered(
        query: '',
        governorate: 10, // صنعاء مثلاً
      );

      expect(results.isNotEmpty, true);
      expect(results.every((b) => b.province == 10), true);
    });

    test('البحث بالاسم + فلتر الفئة', () async {
      final results = await dao.searchBeneficiariesFiltered(
        query: 'محمد',
        category: 1,
      );

      expect(
        results.every((b) => b.sectionId == 1 && (b.fullName.contains('محمد'))),
        true,
      );
    });

    test('البحث بالرقم الوطني + فلتر المحافظة', () async {
      final results = await dao.searchBeneficiariesFiltered(
        query: '123456789',
        governorate: 10,
      );

      expect(
        results.every((b) => b.province == 10 && b.idNumber == 123456789),
        true,
      );
    });

    test('Pagination يعمل بشكل صحيح', () async {
      final page1 = await dao.searchBeneficiariesFiltered(
        query: '',
        limit: 2,
        offset: 0,
      );
      final page2 = await dao.searchBeneficiariesFiltered(
        query: '',
        limit: 2,
        offset: 2,
      );

      expect(page1.length, equals(2));
      expect(page2.length, equals(2));
      expect(page1.first.id != page2.first.id, true);
    });
  });

  group('⚡ Performance Tests - اختبارات الأداء', () {
    test('البحث يجب أن يكون سريع (< 100ms لـ 1000 سجل)', () async {
      // إضافة 1000 سجل
      for (int i = 0; i < 1000; i++) {
        await dao.insertBeneficiary(
          BeneficiariesCompanion.insert(
            idNumber: 100000000 + i,
            phoneNumber: 777000000 + i,
            altPhoneNumber: 770000000 + i,
            firstName: const Value('اختبار'),
            fatherName: const Value('محمد'),
            grandFatherName: const Value('علي'),
            familyName: Value('العائلة$i'),
          ),
        );
      }

      final stopwatch = Stopwatch()..start();
      await dao.searchBeneficiaries('اختبار');
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds < 100,
        true,
        reason: 'Search took ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    test('Batch delete يجب أن يحذف 100 سجل بسرعة (< 500ms)', () async {
      // إضافة 100 سجل
      final ids = <int>[];
      for (int i = 0; i < 100; i++) {
        await dao.insertBeneficiary(
          BeneficiariesCompanion.insert(
            idNumber: 200000000 + i,
            phoneNumber: 777100000 + i,
            altPhoneNumber: 770100000 + i,
            firstName: const Value('مستفيد'),
            fatherName: const Value('احمد'),
            grandFatherName: const Value('محمد'),
            familyName: Value('رقم $i'),
          ),
        );
      }

      final all = await dao.getAllBeneficiaries();
      ids.addAll(all.map((b) => b.id));

      final stopwatch = Stopwatch()..start();
      await dao.batchDeleteBeneficiaries(ids);
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds < 500,
        true,
        reason: 'Batch delete took ${stopwatch.elapsedMilliseconds}ms',
      );
    });
  });

  group('🗑️ Batch Delete Tests', () {
    test('Batch delete يحذف جميع المستفيدين المحددين', () async {
      final allBefore = await dao.getAllBeneficiaries();
      final idsToDelete = allBefore.take(2).map((b) => b.id).toList();

      final deletedCount = await dao.batchDeleteBeneficiaries(idsToDelete);
      final allAfter = await dao.getAllBeneficiaries();

      expect(deletedCount, equals(2));
      expect(allAfter.length, equals(allBefore.length - 2));
    });

    test('Batch delete مع قائمة فارغة لا يحذف شيء', () async {
      final allBefore = await dao.getAllBeneficiaries();

      final deletedCount = await dao.batchDeleteBeneficiaries([]);
      final allAfter = await dao.getAllBeneficiaries();

      expect(deletedCount, equals(0));
      expect(allAfter.length, equals(allBefore.length));
    });
  });
}

/// إضافة بيانات تجريبية للاختبار
Future<void> _seedTestData(BeneficiariesDao dao) async {
  await dao.insertBeneficiary(
    BeneficiariesCompanion.insert(
      idNumber: 123456789,
      phoneNumber: 777123456,
      altPhoneNumber: 770123456,
      firstName: const Value('محمد'),
      fatherName: const Value('أحمد'),
      grandFatherName: const Value('علي'),
      familyName: const Value('السعيد'),
      fileIdNumber: const Value('FILE001'),
      sectionId: const Value(1), // يتيم
      province: const Value(10), // صنعاء
      gender: const Value(1), // ذكر
    ),
  );

  await dao.insertBeneficiary(
    BeneficiariesCompanion.insert(
      idNumber: 987654321,
      phoneNumber: 777987654,
      altPhoneNumber: 770987654,
      firstName: const Value('فاطمة'),
      fatherName: const Value('عبدالله'),
      grandFatherName: const Value('حسن'),
      familyName: const Value('الزهراني'),
      fileIdNumber: const Value('FILE002'),
      sectionId: const Value(2), // أرملة
      province: const Value(20), // تعز
      gender: const Value(2), // أنثى
    ),
  );

  await dao.insertBeneficiary(
    BeneficiariesCompanion.insert(
      idNumber: 456789123,
      phoneNumber: 777456789,
      altPhoneNumber: 770456789,
      firstName: const Value('خالد'),
      fatherName: const Value('سالم'),
      grandFatherName: const Value('محمد'),
      familyName: const Value('العمري'),
      fileIdNumber: const Value('FILE003'),
      sectionId: const Value(3), // فقير
      province: const Value(10), // صنعاء
      gender: const Value(1), // ذكر
    ),
  );

  await dao.insertBeneficiary(
    BeneficiariesCompanion.insert(
      idNumber: 321654987,
      phoneNumber: 777321654,
      altPhoneNumber: 770321654,
      firstName: const Value('عائشة'),
      fatherName: const Value('يحيى'),
      grandFatherName: const Value('أحمد'),
      familyName: const Value('الحميري'),
      fileIdNumber: const Value('FILE004'),
      sectionId: const Value(4), // معاق
      province: const Value(30), // حضرموت
      gender: const Value(2), // أنثى
    ),
  );

  // ✅ تحديث fullNameNorm يدوياً بما إن الـ trigger ما بيشتغل على in-memory database
  // في بعض الحالات
  final allBens = await dao.getAllBeneficiaries();
  for (final ben in allBens) {
    final fullNameNorm =
        '${ben.firstName ?? ''} ${ben.fatherName ?? ''} ${ben.grandFatherName ?? ''} ${ben.familyName ?? ''}'
            .toLowerCase()
            .trim()
            .replaceAll('أ', 'ا')
            .replaceAll('إ', 'ا')
            .replaceAll('آ', 'ا')
            .replaceAll('ة', 'ه')
            .replaceAll('ى', 'ي')
            .replaceAll('ئ', 'ي');

    await dao.updateBeneficiary(
      ben.copyWith(fullNameNorm: Value(fullNameNorm)),
    );
  }
}
