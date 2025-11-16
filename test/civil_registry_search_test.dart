// 🧪 اختبارات سريعة للبحث في السجل المدني
// استخدم هذه الاختبارات للتحقق من أن كل شيء يعمل بشكل صحيح

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Civil Registry Search - Quick Tests', () {
    // ملاحظة: هذه اختبارات مرجعية فقط
    // يجب تشغيلها مع قاعدة بيانات حقيقية

    test('اختبار 1: البحث باسم واحد - "اسامة"', () {
      // المتوقع:
      // - نتائج تبدأ بـ "اسامة" في الاسم الأول
      // - مرتبة حسب score DESC
      // - "اسامة محمد" أعلى من "محمد اسامة"

      // الكود:
      // final results = await searchByName("اسامة");
      // expect(results.length, greaterThan(0));
      // expect(results.first.firstName, startsWith("اسامة"));
    });

    test('اختبار 2: البحث باسم ثنائي - "محمد احمد"', () {
      // المتوقع:
      // - نتائج تحتوي على "محمد احمد" معاً
      // - "محمد احمد علي" أعلى من "احمد محمد علي"

      // الكود:
      // final results = await searchByName("محمد احمد");
      // expect(results.length, greaterThan(0));
    });

    test('اختبار 3: البحث باسم ثلاثي - "محمد احمد علي"', () {
      // المتوقع:
      // - نتائج تحتوي على الثلاثي بالترتيب
      // - دقة عالية في المطابقة

      // الكود:
      // final results = await searchByName("محمد احمد علي");
      // expect(results.length, greaterThan(0));
    });

    test('اختبار 4: البحث بالرقم الوطني - صيغ مختلفة', () {
      // المتوقع:
      // - كل هذه الصيغ تُرجع نفس الشخص:
      //   * "12345678"
      //   * "1234-5678"
      //   * "1234 5678"
      //   * "12 34 56 78"

      // الكود:
      // final r1 = await searchByNationalId("12345678");
      // final r2 = await searchByNationalId("1234-5678");
      // expect(r1?.nationalId, equals(r2?.nationalId));
    });

    test('اختبار 5: البحث مع فلتر المحافظة', () {
      // المتوقع:
      // - فقط نتائج من المحافظة المحددة

      // الكود:
      // final results = await searchByName(
      //   "محمد",
      //   governorate: "بغداد",
      // );
      // expect(results.every((r) => r.city.contains("بغداد")), true);
    });

    test('اختبار 6: البحث مع فلتر الجنس', () {
      // المتوقع:
      // - فقط نتائج من الجنس المحدد

      // الكود:
      // final results = await searchByName(
      //   "محمد",
      //   genderCode: 1, // ذكر
      // );
      // expect(results.every((r) => r.genderCode == 1), true);
    });

    test('اختبار 7: اختبار الأداء - 100 بحث', () {
      // المتوقع:
      // - متوسط زمن البحث < 150ms
      // - لا تجميد في الواجهة

      // الكود:
      // final stopwatch = Stopwatch()..start();
      // for (var i = 0; i < 100; i++) {
      //   await searchByName("محمد");
      // }
      // stopwatch.stop();
      // final avgTime = stopwatch.elapsedMilliseconds / 100;
      // expect(avgTime, lessThan(150));
    });

    test('اختبار 8: حروف خاصة', () {
      // المتوقع:
      // - "أحمد" = "احمد" (همزة)
      // - "فاطمة" = "فاطمه" (تاء مربوطة)
      // - "مصطفى" = "مصطفي" (ألف مقصورة)

      // الكود:
      // final r1 = await searchByName("أحمد");
      // final r2 = await searchByName("احمد");
      // expect(r1.length, equals(r2.length));
    });

    test('اختبار 9: ترتيب النتائج حسب الدقة', () {
      // المتوقع:
      // - النتيجة الأولى هي الأدق
      // - score عالي للتطابق التام

      // الكود:
      // final results = await searchByName("اسامة");
      // // أول نتيجة يجب أن تكون "اسامة" في الاسم الأول
      // expect(results.first.firstName, contains("اسامة"));
    });

    test('اختبار 10: عد النتائج', () {
      // المتوقع:
      // - getSearchCount يُرجع نفس عدد searchByName

      // الكود:
      // final results = await searchByName("محمد", limit: 100);
      // final count = await getSearchCount("محمد");
      // expect(count, greaterThanOrEqualTo(results.length));
    });
  });

  group('Edge Cases - حالات خاصة', () {
    test('نص فارغ', () {
      // المتوقع: []
      // final results = await searchByName("");
      // expect(results.isEmpty, true);
    });

    test('نص مسافات فقط', () {
      // المتوقع: []
      // final results = await searchByName("   ");
      // expect(results.isEmpty, true);
    });

    test('رقم وطني قصير جداً', () {
      // المتوقع: null
      // final result = await searchByNationalId("123");
      // expect(result, isNull);
    });

    test('رمز محافظة غير موجود', () {
      // المتوقع: []
      // final results = await searchByName(
      //   "محمد",
      //   governorate: "مدينة_غير_موجودة",
      // );
      // expect(results.isEmpty, true);
    });
  });
}

/*
 * 📝 ملاحظات للاختبار اليدوي:
 * 
 * 1. افتح التطبيق
 * 2. اذهب إلى صفحة البحث في السجل المدني
 * 3. جرّب هذه الاختبارات:
 * 
 * ✅ اكتب "اسامة" → يجب أن يظهر "اسامة" أولاً
 * ✅ اكتب "محمد احمد" → يجب أن يجد الاسم الثنائي
 * ✅ اكتب "محمد احمد علي" → يجب أن يجد الاسم الثلاثي
 * ✅ ادخل رقم وطني بأي صيغة → يجب أن يجده
 * ✅ استخدم الفلاتر → يجب أن تعمل بشكل صحيح
 * ✅ لاحظ السرعة → يجب أن تكون سريعة (<200ms)
 * 
 * 🎯 معايير النجاح:
 * - دقة النتائج: أكثر من 95%
 * - سرعة البحث: أقل من 150ms للبحث الأول
 * - لا تجميد في الواجهة
 * - النتائج مرتبة بشكل منطقي
 */
