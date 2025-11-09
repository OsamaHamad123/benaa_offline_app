# تحديث قاعدة البيانات - الإصدار 3

## التاريخ: 2024
## المشروع: نظام إدارة المستفيدين

---

## ملخص التحديث

تم تحديث قاعدة البيانات من الإصدار 2 إلى الإصدار 3 لإضافة حقول شاملة لجمع بيانات المستفيدين بشكل أكثر تفصيلاً.

---

## الحقول الجديدة المضافة

تم إضافة 10 حقول جديدة إلى جدول `Beneficiaries`:

### 1. معلومات التواصل
- **phoneNumber** (String, nullable) - رقم الهاتف
  - التحقق: يجب أن يبدأ بـ 07 ويحتوي على 11 رقم
  - مثال: `07801234567`

- **district** (String, nullable) - القضاء
  - مثال: `الكرادة`

- **address** (String, nullable) - العنوان الكامل
  - مثال: `حي الجامعة، شارع فلسطين، بناية رقم 15`

### 2. معلومات العائلة
- **fatherName** (String, nullable) - اسم الأب
  - مثال: `أحمد محمد علي`

- **motherName** (String, nullable) - اسم الأم
  - مثال: `فاطمة حسين`

- **familySize** (int, nullable) - عدد أفراد الأسرة
  - القيمة الافتراضية: 1
  - التحقق: يجب أن يكون أكبر من 0
  - مثال: `5`

- **maritalStatus** (String, nullable) - الحالة الاجتماعية
  - القيم المسموحة:
    - `single` - أعزب
    - `married` - متزوج
    - `divorced` - مطلق
    - `widowed` - أرمل
  - القيمة الافتراضية: `single`

### 3. التعليم والصحة
- **educationLevel** (String, nullable) - المستوى التعليمي
  - القيم المسموحة:
    - `none` - بدون تعليم
    - `primary` - ابتدائي
    - `secondary` - متوسط/ثانوي
    - `university` - جامعي
  - القيمة الافتراضية: `none`

- **healthStatus** (String, nullable) - الحالة الصحية
  - القيم المسموحة:
    - `good` - جيدة
    - `fair` - متوسطة
    - `poor` - ضعيفة
    - `chronic` - مرض مزمن
  - القيمة الافتراضية: `good`

- **hasDisability** (bool, nullable) - لديه إعاقة
  - القيمة الافتراضية: `false`
  - يستخدم لتحديد إذا كان المستفيد لديه أي نوع من الإعاقة

---

## التغييرات في الكود

### 1. Database Schema (`lib/data/db/drift_database.dart`)

```dart
class Beneficiaries extends Table {
  // ... الحقول الموجودة ...
  
  // حقول جديدة - الإصدار 3
  TextColumn get district => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get motherName => text().nullable()();
  TextColumn get fatherName => text().nullable()();
  IntColumn get familySize => integer().nullable()();
  TextColumn get maritalStatus => text().nullable()();
  TextColumn get educationLevel => text().nullable()();
  TextColumn get healthStatus => text().nullable()();
  BoolColumn get hasDisability => boolean().nullable()();
}

@override
int get schemaVersion => 3;
```

### 2. Migration Function

```dart
Future<void> _upgradeToV3(Migrator m) async {
  await m.addColumn(beneficiaries, beneficiaries.district);
  await m.addColumn(beneficiaries, beneficiaries.address);
  await m.addColumn(beneficiaries, beneficiaries.phoneNumber);
  await m.addColumn(beneficiaries, beneficiaries.motherName);
  await m.addColumn(beneficiaries, beneficiaries.fatherName);
  await m.addColumn(beneficiaries, beneficiaries.familySize);
  await m.addColumn(beneficiaries, beneficiaries.maritalStatus);
  await m.addColumn(beneficiaries, beneficiaries.educationLevel);
  await m.addColumn(beneficiaries, beneficiaries.healthStatus);
  await m.addColumn(beneficiaries, beneficiaries.hasDisability);
}
```

### 3. UI Updates

#### أ. صفحة إضافة/تعديل المستفيد (`add_beneficiary_page.dart`)

تم إضافة 4 أقسام جديدة في النموذج:

1. **معلومات التواصل**
   - حقل رقم الهاتف مع التحقق
   - حقل القضاء
   - حقل العنوان الكامل (متعدد الأسطر)

2. **معلومات العائلة**
   - حقل اسم الأب
   - حقل اسم الأم
   - حقل عدد أفراد الأسرة (رقم)
   - قائمة منسدلة للحالة الاجتماعية

3. **المستوى التعليمي والصحي**
   - قائمة منسدلة للمستوى التعليمي
   - قائمة منسدلة للحالة الصحية

4. **الإعاقة**
   - مربع اختيار "لديه إعاقة"

#### ب. صفحة قائمة المستفيدين (`beneficiaries_list_page.dart`)

تم تحديث البطاقة لعرض:
- رقم الهاتف (إن وجد)
- القضاء (إن وجد)
- عدد أفراد الأسرة (إن وجد)

#### ج. صفحة تفاصيل المستفيد (`view_beneficiary_page.dart`)

تم إضافة 3 أقسام جديدة:

1. **معلومات التواصل**
   - رقم الهاتف
   - القضاء
   - العنوان الكامل

2. **معلومات العائلة**
   - اسم الأب
   - اسم الأم
   - عدد أفراد الأسرة
   - الحالة الاجتماعية

3. **التعليم والصحة**
   - المستوى التعليمي
   - الحالة الصحية
   - وجود إعاقة

---

## التوافق مع الإصدارات السابقة

- جميع الحقول الجديدة **nullable** - لا تؤثر على البيانات الموجودة
- يتم ترحيل البيانات تلقائياً عند فتح التطبيق
- البيانات القديمة ستحتوي على قيم `null` للحقول الجديدة
- يمكن تحديث البيانات القديمة لاحقاً من صفحة التعديل

---

## خطوات التنفيذ

### 1. تحديث الكود
```bash
# في مجلد C:\Dev\benaa_offline_app
dart run build_runner build --delete-conflicting-outputs
```

### 2. التحقق من النتائج
```bash
flutter analyze
```

### 3. الاختبار
- تشغيل التطبيق والتحقق من ترحيل قاعدة البيانات
- إضافة مستفيد جديد مع الحقول الجديدة
- تحديث مستفيد موجود
- عرض تفاصيل المستفيدين

---

## ملاحظات مهمة

### الأمان
- جميع البيانات الشخصية (رقم الهاتف، العنوان) مشفرة عبر SQLCipher
- يتم مزامنة البيانات الجديدة مع السيرفر تلقائياً

### الأداء
- إضافة الحقول لا تؤثر على الأداء
- الفهرسة الموجودة على `fullNameNorm` و `nationalId` مازالت فعالة

### المزامنة
- تم تحديث `SyncManager` ليدعم الحقول الجديدة
- يتم إرسال جميع الحقول عند المزامنة
- يجب تحديث API السيرفر لاستقبال الحقول الجديدة

---

## الخطوات التالية

1. ✅ تحديث قاعدة البيانات (مكتمل)
2. ✅ تحديث واجهات الإضافة والعرض (مكتمل)
3. ⏳ اختبار المزامنة مع السيرفر
4. ⏳ إضافة تقارير إحصائية عن الحقول الجديدة
5. ⏳ إضافة فلاتر بحث متقدمة (حسب الحالة الاجتماعية، المستوى التعليمي، إلخ)

---

## استعلامات SQL مفيدة

### عدد المستفيدين حسب الحالة الاجتماعية
```sql
SELECT maritalStatus, COUNT(*) as count 
FROM beneficiaries 
WHERE maritalStatus IS NOT NULL 
GROUP BY maritalStatus;
```

### عدد المستفيدين حسب المستوى التعليمي
```sql
SELECT educationLevel, COUNT(*) as count 
FROM beneficiaries 
WHERE educationLevel IS NOT NULL 
GROUP BY educationLevel;
```

### المستفيدون ذوو الإعاقة
```sql
SELECT * FROM beneficiaries 
WHERE hasDisability = 1;
```

### المستفيدون بحسب حجم الأسرة
```sql
SELECT 
  CASE 
    WHEN familySize <= 3 THEN 'صغيرة'
    WHEN familySize <= 6 THEN 'متوسطة'
    ELSE 'كبيرة'
  END as family_category,
  COUNT(*) as count
FROM beneficiaries 
WHERE familySize IS NOT NULL
GROUP BY family_category;
```

---

## الدعم الفني

للأسئلة أو المشاكل:
- راجع الكود في `lib/data/db/drift_database.dart`
- تحقق من ملفات التوليد في `.dart_tool/build/`
- راجع سجلات التطبيق عبر `flutter run -v`

---

## الخلاصة

تم تحديث قاعدة البيانات بنجاح لتشمل بيانات شاملة عن المستفيدين:
- ✅ 10 حقول جديدة
- ✅ واجهات إدخال كاملة
- ✅ واجهات عرض محدثة
- ✅ توافق تام مع البيانات القديمة
- ✅ جاهز للاختبار والاستخدام
