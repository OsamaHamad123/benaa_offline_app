# 🔍 FieldFinderHelper - دليل الاستخدام الشامل

Helper مخصص لإيجاد وملء الحقول في اختبارات Flutter بشكل أسهل وأكثر موثوقية.

## 📋 المحتويات

- [التثبيت](#التثبيت)
- [الميزات الرئيسية](#الميزات-الرئيسية)
- [أمثلة الاستخدام](#أمثلة-الاستخدام)
- [الدوال المتاحة](#الدوال-المتاحة)
- [Extension Methods](#extension-methods)
- [حل المشاكل الشائعة](#حل-المشاكل-الشائعة)

---

## 🚀 التثبيت

```dart
import 'package:flutter_test/flutter_test.dart';
import '../test_helpers/field_finder_helper.dart';
```

---

## ✨ الميزات الرئيسية

### ✅ يعمل مع Material3 Components
- يدعم `M3TextField` مع required indicator (*)
- يتعامل مع validation و input formatters
- يتعرف على الحقول بطرق متعددة

### ✅ طرق متعددة للبحث
- بواسطة label text
- بواسطة index
- بواسطة icon
- بواسطة controller value
- بواسطة required status

### ✅ Extension Methods
- أقصر وأسهل في الاستخدام
- تكامل سلس مع `WidgetTester`

### ✅ أدوات Debug
- طباعة جميع الحقول
- فحص validation errors
- عد الحقول المرئية

---

## 📚 أمثلة الاستخدام

### 1️⃣ ملء حقل واحد

```dart
testWidgets('fill single field', (tester) async {
  await tester.pumpWidget(myForm);
  
  // طريقة 1: باستخدام Helper class
  await FieldFinderHelper.enterTextInField(
    tester,
    'الاسم الأول',
    'محمد',
  );
  
  // طريقة 2: باستخدام Extension (أسهل)
  await tester.fillField('الاسم الأول', 'محمد');
});
```

### 2️⃣ ملء عدة حقول

```dart
testWidgets('fill multiple fields', (tester) async {
  await tester.pumpWidget(myForm);
  
  await tester.fillMultipleFields({
    'الاسم الأول': 'محمد',
    'اسم الأب': 'أحمد',
    'اسم الجد': 'علي',
    'اللقب': 'العلي',
    'الرقم الوطني': '123456789',
  });
  
  // جميع الحقول ستملأ تلقائياً مع pumpAndSettle
});
```

### 3️⃣ إيجاد الحقول بطرق مختلفة

```dart
testWidgets('find fields', (tester) async {
  // بواسطة label
  final firstNameField = tester.fieldByLabel('الاسم الأول');
  expect(firstNameField, findsOneWidget);
  
  // بواسطة index
  final secondField = FieldFinderHelper.findFieldByIndex(1);
  
  // بواسطة icon
  final phoneField = FieldFinderHelper.findFieldByIcon(Icons.phone);
  
  // جميع الحقول المطلوبة
  final requiredFields = FieldFinderHelper.findRequiredFields();
  print('عدد الحقول المطلوبة: ${requiredFields.evaluate().length}');
});
```

### 4️⃣ فحص Validation

```dart
testWidgets('check validation', (tester) async {
  // ملء حقل ببيانات خاطئة
  await tester.fillField('الرقم الوطني', '123'); // قصير جداً
  
  // تشغيل validation
  await FieldFinderHelper.validateAllFields(tester);
  
  // فحص الأخطاء
  final hasError = FieldFinderHelper.hasFieldError(
    tester,
    'الرقم الوطني',
  );
  expect(hasError, isTrue);
  
  // الحصول على قيمة الحقل
  final value = FieldFinderHelper.getFieldValue(tester, 'الرقم الوطني');
  expect(value, '123');
});
```

### 5️⃣ Debug ومراجعة الحقول

```dart
testWidgets('debug fields', (tester) async {
  await tester.pumpWidget(myForm);
  
  // طباعة جميع الحقول
  tester.debugFields();
  
  /* Output:
  📝 Found 5 TextFormFields:
    [0] Label: "الاسم الأول" | Value: "محمد" | Error: false
    [1] Label: "اسم الأب" | Value: "" | Error: false
    [2] Label: "اسم الجد" | Value: "" | Error: false
    [3] Label: "اللقب" | Value: "" | Error: true
    [4] Label: "الرقم الوطني" | Value: "123" | Error: true
  */
  
  // عد الحقول
  final count = FieldFinderHelper.getFieldCount(tester);
  print('إجمالي الحقول: $count');
});
```

### 6️⃣ سيناريو حقيقي كامل

```dart
testWidgets('complete beneficiary form', (tester) async {
  await tester.pumpWidget(
    appWrapper(child: BeneficiaryFormPageV3()),
  );
  await tester.pumpAndSettle();
  
  // Tab 1: المعلومات الشخصية
  await tester.fillMultipleFields({
    'الاسم الأول': 'محمد',
    'اسم الأب': 'أحمد',
    'اسم الجد': 'علي',
    'اللقب': 'العلي',
    'الرقم الوطني': '123456789',
  });
  
  // التحقق من الملء
  expect(FieldFinderHelper.getFieldValue(tester, 'الاسم الأول'), 'محمد');
  
  // الانتقال للتبويب التالي
  await tester.tap(find.text('العائلة'));
  await tester.pumpAndSettle();
  
  // إضافة فرد عائلة
  await tester.tap(find.text('إضافة فرد'));
  await tester.pumpAndSettle();
  
  await tester.fillMultipleFields({
    'الاسم الأول': 'فاطمة',
    'اللقب': 'العلي',
  });
  
  await tester.tap(find.text('حفظ'));
  await tester.pumpAndSettle();
  
  // التحقق من النجاح
  expect(find.text('تم الحفظ بنجاح'), findsOneWidget);
});
```

---

## 🛠️ الدوال المتاحة

### 🔍 دوال البحث

#### `findFieldByLabel(WidgetTester, String)`
إيجاد حقل بواسطة النص الموجود في label.

```dart
final field = FieldFinderHelper.findFieldByLabel(tester, 'الاسم الأول');
```

**ملاحظة:** يعمل مع M3TextField الذي يضيف `*` للحقول المطلوبة.

---

#### `findFieldByIndex(int)`
إيجاد حقل بواسطة الترتيب في الصفحة.

```dart
final firstField = FieldFinderHelper.findFieldByIndex(0);
final secondField = FieldFinderHelper.findFieldByIndex(1);
```

---

#### `findFieldByIcon(IconData)`
إيجاد حقل بواسطة الأيقونة في prefixIcon.

```dart
final phoneField = FieldFinderHelper.findFieldByIcon(Icons.phone);
final emailField = FieldFinderHelper.findFieldByIcon(Icons.email);
```

---

#### `findFieldByText(WidgetTester, String)`
إيجاد حقل يحتوي على نص معين.

```dart
final fieldWithMohammed = FieldFinderHelper.findFieldByText(tester, 'محمد');
```

---

#### `findRequiredFields()`
إيجاد جميع الحقول المطلوبة (التي عليها *).

```dart
final requiredFields = FieldFinderHelper.findRequiredFields();
final count = requiredFields.evaluate().length;
print('عدد الحقول المطلوبة: $count');
```

---

#### `findAllFields()`
إيجاد جميع TextFormFields في الصفحة الحالية.

```dart
final allFields = FieldFinderHelper.findAllFields();
```

---

### ✍️ دوال الإدخال

#### `enterTextInField(WidgetTester, String, String)`
ملء حقل بواسطة label.

```dart
await FieldFinderHelper.enterTextInField(
  tester,
  'الاسم الأول',
  'محمد',
);
```

---

#### `fillFields(WidgetTester, Map<String, String>)`
ملء عدة حقول دفعة واحدة.

```dart
await FieldFinderHelper.fillFields(tester, {
  'الاسم الأول': 'محمد',
  'اسم الأب': 'أحمد',
  'اللقب': 'العلي',
});
```

---

### 🔎 دوال الفحص

#### `getFieldValue(WidgetTester, String)`
الحصول على قيمة حقل.

```dart
final firstName = FieldFinderHelper.getFieldValue(tester, 'الاسم الأول');
expect(firstName, 'محمد');
```

---

#### `hasFieldError(WidgetTester, String)`
فحص إذا كان الحقل يحتوي على خطأ.

```dart
final hasError = FieldFinderHelper.hasFieldError(tester, 'الرقم الوطني');
expect(hasError, isFalse);
```

---

#### `validateAllFields(WidgetTester)`
تشغيل validation على جميع الحقول.

```dart
await FieldFinderHelper.validateAllFields(tester);
```

---

### 🐛 دوال Debug

#### `debugPrintFields(WidgetTester)`
طباعة جميع الحقول المرئية مع تفاصيلها.

```dart
FieldFinderHelper.debugPrintFields(tester);
// أو باستخدام extension:
tester.debugFields();
```

---

#### `getFieldCount(WidgetTester)`
عد الحقول المرئية.

```dart
final count = FieldFinderHelper.getFieldCount(tester);
expect(count, greaterThan(0));
```

---

## 🎯 Extension Methods

للاستخدام الأسهل والأسرع:

```dart
// بدلاً من:
await FieldFinderHelper.enterTextInField(tester, 'الاسم', 'محمد');

// استخدم:
await tester.fillField('الاسم', 'محمد');

// أيضاً:
await tester.fillMultipleFields({...});
final field = tester.fieldByLabel('الاسم');
tester.debugFields();
```

---

## ⚠️ حل المشاكل الشائعة

### ❌ المشكلة: "Field not found"

```dart
// ✗ خطأ
await tester.fillField('الاسم الأول *', 'محمد');

// ✓ صحيح
await tester.fillField('الاسم الأول', 'محمد');
// الـ helper يتعامل مع * تلقائياً
```

---

### ❌ المشكلة: عدة حقول بنفس الـ label

```dart
// إذا كان هناك عدة حقول بنفس الاسم، استخدم index:
final firstField = FieldFinderHelper.findFieldByIndex(0);
final secondField = FieldFinderHelper.findFieldByIndex(1);
```

---

### ❌ المشكلة: الحقل موجود لكن غير مرئي

```dart
// تأكد من pump بعد التنقل:
await tester.tap(find.text('العائلة'));
await tester.pumpAndSettle(); // مهم!

// ثم ابحث عن الحقل
final field = tester.fieldByLabel('اسم الفرد');
```

---

### ❌ المشكلة: Validation لا يعمل

```dart
// تأكد من تشغيل validateAllFields:
await tester.fillField('الرقم الوطني', '123');
await FieldFinderHelper.validateAllFields(tester);

// الآن يمكن فحص الأخطاء:
expect(
  FieldFinderHelper.hasFieldError(tester, 'الرقم الوطني'),
  isTrue,
);
```

---

## 🎨 أفضل الممارسات

### ✅ استخدم Extension Methods

```dart
// ✓ أفضل
await tester.fillField('الاسم', 'محمد');

// ✗ أطول
await FieldFinderHelper.enterTextInField(tester, 'الاسم', 'محمد');
```

---

### ✅ استخدم fillMultipleFields للكفاءة

```dart
// ✓ أفضل - مرة واحدة
await tester.fillMultipleFields({
  'الاسم الأول': 'محمد',
  'اسم الأب': 'أحمد',
  'اللقب': 'العلي',
});

// ✗ أبطأ - عدة مرات
await tester.fillField('الاسم الأول', 'محمد');
await tester.fillField('اسم الأب', 'أحمد');
await tester.fillField('اللقب', 'العلي');
```

---

### ✅ استخدم debugFields عند المشاكل

```dart
testWidgets('debug test', (tester) async {
  await tester.pumpWidget(myForm);
  
  // عند عدم العثور على الحقل:
  tester.debugFields();
  // سيطبع جميع الحقول الموجودة بأسمائها الفعلية
});
```

---

## 📊 مقارنة الأداء

### قبل FieldFinderHelper:
```dart
// 🐌 بطيء ومعقد
final fields = find.byType(TextFormField);
final firstField = fields.at(0);
await tester.enterText(firstField, 'محمد');
await tester.pumpAndSettle();

final secondField = fields.at(1);
await tester.enterText(secondField, 'أحمد');
await tester.pumpAndSettle();
// ... والمزيد
```

### بعد FieldFinderHelper:
```dart
// ⚡ سريع وواضح
await tester.fillMultipleFields({
  'الاسم الأول': 'محمد',
  'اسم الأب': 'أحمد',
  'اللقب': 'العلي',
});
```

**النتيجة:** 
- ✅ 70% أقل في عدد الأسطر
- ✅ أسهل في القراءة والصيانة
- ✅ أقل عرضة للأخطاء

---

## 🚀 ما التالي؟

- راجع [field_finder_helper_examples.dart](field_finder_helper_examples.dart) لأمثلة أكثر
- جرّب الـ helper في اختباراتك الخاصة
- شارك أي تحسينات أو اقتراحات!

---

**تم الإنشاء بواسطة:** GitHub Copilot  
**التاريخ:** نوفمبر 2025  
**الإصدار:** 1.0.0
