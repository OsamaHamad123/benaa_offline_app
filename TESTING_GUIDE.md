# 🧪 دليل الاختبارات (Testing Guide)

## 📚 المحتويات
1. [ما هي الاختبارات؟](#what-is-testing)
2. [كيفية تشغيل الاختبارات](#how-to-run)
3. [أنواع الاختبارات](#test-types)
4. [قراءة النتائج](#reading-results)
5. [كتابة اختبارات جديدة](#writing-tests)

---

## 🎯 ما هي الاختبارات؟ {#what-is-testing}

الاختبارات (Tests) هي كود تلقائي يتحقق من أن الكود الأساسي يعمل بشكل صحيح.

### مثال بسيط:
```dart
// الكود المراد اختباره
int add(int a, int b) => a + b;

// الاختبار
test('should add two numbers correctly', () {
  expect(add(2, 3), 5);  // ✅ ناجح
  expect(add(10, 5), 15); // ✅ ناجح
});
```

---

## ⚡ كيفية تشغيل الاختبارات {#how-to-run}

### 1️⃣ تشغيل كل الاختبارات

```powershell
# في مجلد المشروع
cd c:\Dev\benaa_offline_app

# تشغيل كل الاختبارات
flutter test
```

**النتيجة المتوقعة:**
```
00:02 +42: All tests passed!
```

---

### 2️⃣ تشغيل ملف اختبار واحد

```powershell
# اختبار ملف محدد
flutter test test/core/constants/search_constants_test.dart
```

**النتيجة المتوقعة:**
```
00:01 +18: All tests passed!
```

---

### 3️⃣ تشغيل اختبار محدد

```powershell
# اختبار بـ name محدد
flutter test --name "should add two numbers"
```

---

### 4️⃣ تشغيل مع Coverage (تغطية الكود)

```powershell
# تشغيل مع تقرير التغطية
flutter test --coverage

# فتح تقرير HTML
genhtml coverage/lcov.info -o coverage/html
start coverage/html/index.html
```

**ملاحظة:** قد تحتاج تثبيت `genhtml` (على Windows استخدم Chocolatey):
```powershell
choco install lcov
```

---

## 📊 أنواع الاختبارات {#test-types}

### 1️⃣ **Unit Tests** - اختبار الوحدات

تختبر دالة أو class واحدة بشكل منعزل.

**مثال:**
```dart
test('SearchConstants should have valid minWordLength', () {
  expect(SearchConstants.minWordLength, 2);
});
```

**ملفات الاختبار:**
- `test/core/constants/search_constants_test.dart`
- `test/features/search/data/datasources/search_query_builder_test.dart`

**تشغيل:**
```powershell
flutter test test/core
```

---

### 2️⃣ **Integration Tests** - اختبارات التكامل

تختبر عدة components تعمل مع بعض.

**مثال:**
```dart
test('should search and return results from database', () async {
  final result = await searchByNameUseCase(query: 'محمد');
  expect(result.persons, isNotEmpty);
});
```

**تشغيل:**
```powershell
flutter test test/features/search/integration
```

---

### 3️⃣ **Widget Tests** - اختبار الواجهات

تختبر الـ UI components.

**مثال:**
```dart
testWidgets('Search button should trigger search', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.tap(find.byIcon(Icons.search));
  await tester.pump();
  
  expect(find.text('جاري البحث...'), findsOneWidget);
});
```

**تشغيل:**
```powershell
flutter test test/features/search/presentation
```

---

## 📖 قراءة النتائج {#reading-results}

### ✅ اختبار ناجح

```
00:01 +1: SearchConstants should have valid minWordLength
```

- `00:01` = الوقت المستغرق (ثانية)
- `+1` = اختبار واحد نجح
- الوصف = ما تم اختباره

---

### ❌ اختبار فاشل

```
00:02 +4 -1: should add two numbers correctly
Expected: 5
  Actual: 6
   Which: differs by 1

test/example_test.dart 15:3  main.<fn>
```

**شرح الخطأ:**
- `-1` = اختبار واحد فشل
- `Expected: 5` = القيمة المتوقعة
- `Actual: 6` = القيمة الفعلية
- `test/example_test.dart 15:3` = موقع الخطأ (ملف + رقم السطر)

---

### 📊 ملخص النتائج النهائي

```
00:05 +42 -0: All tests passed!
```

- `00:05` = إجمالي الوقت (5 ثواني)
- `+42` = عدد الاختبارات الناجحة
- `-0` = عدد الاختبارات الفاشلة

---

## 🎯 أمثلة عملية

### مثال 1: تشغيل كل اختبارات Search

```powershell
flutter test test/features/search
```

**النتيجة:**
```
00:03 +87: All tests passed!

✅ 87 اختبار نجح
⏱️ 3 ثواني
```

---

### مثال 2: تشغيل اختبار محدد فقط

```powershell
flutter test --name "compound"
```

**يشغل فقط الاختبارات التي تحتوي على "compound" في اسمها:**
```
00:01 +12: All tests passed!
```

---

### مثال 3: Watch Mode (إعادة تشغيل تلقائي)

لا يوجد watch mode مدمج في Flutter، لكن يمكن استخدام:

```powershell
# استخدم package
flutter pub global activate --source git https://github.com/dart-lang/test.git --git-path pkgs/test
```

---

## ✍️ كتابة اختبارات جديدة {#writing-tests}

### 1️⃣ إنشاء ملف اختبار جديد

```dart
// test/features/my_feature/my_class_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/my_feature/my_class.dart';

void main() {
  group('MyClass -', () {
    test('should do something', () {
      // Arrange (التحضير)
      final myClass = MyClass();
      
      // Act (التنفيذ)
      final result = myClass.doSomething();
      
      // Assert (التحقق)
      expect(result, true);
    });
  });
}
```

---

### 2️⃣ Matchers (أدوات التحقق)

```dart
// مساواة
expect(actual, equals(expected));
expect(actual, expected); // نفس الشي

// أكبر/أصغر
expect(value, greaterThan(5));
expect(value, lessThan(10));

// قوائم
expect(list, contains('item'));
expect(list, isEmpty);
expect(list, isNotEmpty);

// Null
expect(value, isNull);
expect(value, isNotNull);

// String
expect(text, startsWith('Hello'));
expect(text, endsWith('World'));
expect(text, contains('test'));

// Bool
expect(value, isTrue);
expect(value, isFalse);

// Async
await expectLater(future, completion(value));
expect(() async => await future, throwsException);
```

---

### 3️⃣ Test Groups (مجموعات)

```dart
group('Search Functionality -', () {
  group('Name Search', () {
    test('should find by first name', () { ... });
    test('should find by last name', () { ... });
  });
  
  group('National ID Search', () {
    test('should find by exact ID', () { ... });
  });
});
```

---

### 4️⃣ Setup & Teardown

```dart
group('Database Tests', () {
  late Database db;
  
  setUp(() async {
    // يشتغل قبل كل test
    db = await openDatabase(':memory:');
  });
  
  tearDown(() async {
    // يشتغل بعد كل test
    await db.close();
  });
  
  test('should insert data', () async {
    await db.insert('table', {'id': 1});
    expect(await db.query('table'), isNotEmpty);
  });
});
```

---

## 🔍 نصائح مهمة

### ✅ Best Practices

1. **اسم واضح للاختبار:**
   ```dart
   // ❌ سيء
   test('test1', () { ... });
   
   // ✅ جيد
   test('should return empty list when query is empty', () { ... });
   ```

2. **اختبار واحد = حالة واحدة:**
   ```dart
   // ❌ سيء - اختبار متعدد الحالات
   test('test all cases', () {
     expect(add(1, 1), 2);
     expect(multiply(2, 3), 6);
     expect(divide(10, 2), 5);
   });
   
   // ✅ جيد - اختبار لكل حالة
   test('should add correctly', () => expect(add(1, 1), 2));
   test('should multiply correctly', () => expect(multiply(2, 3), 6));
   test('should divide correctly', () => expect(divide(10, 2), 5));
   ```

3. **Arrange-Act-Assert Pattern:**
   ```dart
   test('should search by name', () {
     // Arrange - جهّز البيانات
     final query = 'محمد';
     final searcher = SearchService();
     
     // Act - نفّذ العملية
     final results = searcher.search(query);
     
     // Assert - تحقق من النتيجة
     expect(results, isNotEmpty);
     expect(results.first.name, contains('محمد'));
   });
   ```

---

## 📈 Coverage (نسبة التغطية)

### ما هي Coverage؟
نسبة الكود الذي تم اختباره.

### كيف تشوف Coverage؟

```powershell
# تشغيل مع coverage
flutter test --coverage

# تحويل لـ HTML
genhtml coverage/lcov.info -o coverage/html

# فتح التقرير
start coverage/html/index.html
```

### قراءة التقرير:

- **🟢 أخضر (90-100%)** = ممتاز
- **🟡 أصفر (70-89%)** = جيد
- **🔴 أحمر (<70%)** = يحتاج تحسين

---

## 🚀 تشغيل سريع

```powershell
# كل الاختبارات
flutter test

# ملف واحد
flutter test test/core/constants/search_constants_test.dart

# مع coverage
flutter test --coverage

# verbose (تفاصيل أكثر)
flutter test --verbose

# تشغيل مستمر (عند التعديل)
flutter test --watch
```

---

## 💡 أمثلة من المشروع

### اختبار SearchConstants:
```powershell
flutter test test/core/constants/search_constants_test.dart
```

**النتيجة المتوقعة:**
```
00:01 +18: All tests passed!
```

### اختبار SearchQueryBuilder:
```powershell
flutter test test/features/search/data/datasources/search_query_builder_test.dart
```

**النتيجة المتوقعة:**
```
00:02 +45: All tests passed!
```

---

## 🎓 تعلم أكثر

- [Flutter Testing Docs](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Test Package Docs](https://pub.dev/packages/test)

---

## ✅ Checklist

- [ ] قرأت الدليل
- [ ] شغلت `flutter test` بنجاح
- [ ] شفت coverage report
- [ ] كتبت اختبار جديد
- [ ] كل الاختبارات تنجح

**بالتوفيق! 🚀**
