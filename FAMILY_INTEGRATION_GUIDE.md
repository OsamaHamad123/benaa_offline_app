# دليل استخدام أقسام العائلة

## 🎯 الملفات المُنشأة

### 1. نماذج الإدخال
- **family_deceased_form.dart**: نموذج إضافة/تعديل بيانات المتوفين
  - الحقول: الاسم، صلة القرابة، الجنس، تاريخ الوفاة، السبب، العمر، ملاحظات
  
- **family_members_form.dart**: نموذج إضافة/تعديل بيانات الأحياء
  - المعلومات الأساسية: الاسم، القرابة، الجنس، الرقم الوطني، تاريخ الميلاد، الهاتف
  - المعلومات الاجتماعية: الحالة الاجتماعية، التعليم، المهنة
  - المعلومات الصحية: الحالة الصحية، الإعاقة، الأمراض المزمنة
  - معلومات السكن: هل يعيش مع المستفيد

### 2. ويدجتات العرض
- **family_list_widget.dart**: قوائم عرض أفراد العائلة بتبويبات
  - تبويب "أفراد العائلة": عرض الأحياء مع معلومات الصحة
  - تبويب "الأموات": عرض المتوفين مع تواريخ وأسباب الوفاة
  - إمكانية التعديل والحذف مباشرة

- **family_statistics_widget.dart**: إحصائيات شاملة
  - الإحصائيات الإجمالية: العدد الكلي، الذكور، الإناث، الأطفال، من يعيشون معاً
  - الحالة الصحية: عدد ذوي الإعاقة، عدد من لديهم أمراض مزمنة
  - التوزيع حسب القرابة: Chips تفاعلية
  - عدد الأموات المسجلين

- **family_section.dart**: قسم متكامل يجمع الإحصائيات والقوائم

## 🔧 كيفية الدمج في صفحة تفاصيل المستفيد

### الخطوة 1: إضافة الـ Provider
في ملف التطبيق الرئيسي أو في الصفحة:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase(); // أو الـ instance الحالي
});
```

### الخطوة 2: إضافة القسم في beneficiary_detail_page.dart

```dart
import 'widgets/family_section.dart';

// داخل build method
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('تفاصيل المستفيد')),
    body: SingleChildScrollView(
      child: Column(
        children: [
          // البيانات الأساسية للمستفيد
          BeneficiaryBasicInfo(beneficiary: beneficiary),
          
          // قسم العائلة الجديد
          FamilySection(beneficiaryId: beneficiary.id),
          
          // باقي الأقسام (الزيارات، المرفقات، إلخ)
        ],
      ),
    ),
  );
}
```

### الخطوة 3 (اختياري): استخدام ExpansionPanel

إذا كنت تفضل أن يكون القسم قابل للطي:

```dart
ExpansionPanelList(
  elevation: 2,
  expandedHeaderPadding: EdgeInsets.zero,
  children: [
    ExpansionPanel(
      headerBuilder: (context, isExpanded) => ListTile(
        leading: Icon(Icons.family_restroom),
        title: Text('بيانات العائلة'),
      ),
      body: FamilySection(beneficiaryId: beneficiary.id),
      isExpanded: _isFamilySectionExpanded,
    ),
  ],
  expansionCallback: (index, isExpanded) {
    setState(() => _isFamilySectionExpanded = !isExpanded);
  },
)
```

## 🔄 المزامنة

تم تحديث:
1. **backend_php/sync.php**: أضيف دعم `family_deceased` و `family_member`
   - دوال: `processFamilyDeceasedChange()` و `processFamilyMemberChange()`
   - جلب التحديثات من السيرفر تلقائياً

2. **lib/core/sync/new_sync_manager.dart**: أضيف معالجات
   - `_updateFamilyDeceased()`: تحديث بيانات المتوفين من السيرفر
   - `_updateFamilyMember()`: تحديث بيانات الأحياء من السيرفر

### تفعيل المزامنة التلقائية
البيانات تُحفظ بحالة `syncState = 'pending'` وتُزامن تلقائياً مع:
- المزامنة اليدوية من الواجهة
- المزامنة الخلفية كل 15 دقيقة

## 📊 قاعدة البيانات

### جدول family_deceased
```sql
- id (primary key)
- beneficiary_id (foreign key)
- full_name
- relationship
- gender
- death_date
- death_cause
- age_at_death
- notes
- sync fields (sync_state, server_id, last_synced_at)
```

### جدول family_members
```sql
- id (primary key)
- beneficiary_id (foreign key)
- full_name, relationship, gender
- national_id, birth_date, age, phone
- marital_status, education_level, occupation
- health_status, has_disability, disability_type
- has_chronic_disease, chronic_disease_type
- lives_with_beneficiary
- sync fields
```

## 🎨 التخصيص

### تغيير الألوان
في family_statistics_widget.dart:

```dart
_buildStatCard(
  'إجمالي الأفراد',
  stats.totalMembers.toString(),
  Icons.people,
  Colors.blue, // غير هذا اللون
)
```

### إضافة حقول جديدة
1. أضف العمود في الجدول بـ database_setup.sql
2. أضف الحقل في family_members_table.dart أو family_deceased_table.dart
3. شغّل `dart run build_runner build --delete-conflicting-outputs`
4. أضف حقل الإدخال في النموذج المناسب
5. حدّث دالة المزامنة في sync.php

## ✅ الاختبار

1. افتح صفحة تفاصيل مستفيد
2. انتقل لقسم العائلة
3. أضف فرد عائلة حي
4. أضف متوفى
5. تحقق من الإحصائيات
6. جرب التعديل والحذف
7. تحقق من المزامنة

## 🐛 استكشاف الأخطاء

### خطأ: "Database provider must be overridden"
**الحل**: أضف الـ Provider في التطبيق:
```dart
ProviderScope(
  overrides: [
    databaseProvider.overrideWithValue(database),
  ],
  child: MyApp(),
)
```

### خطأ: "Failed to load family data"
**الحل**: تأكد من تشغيل build_runner:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### البيانات لا تُزامن
**الحل**: 
1. تأكد من رفع backend_php/ للسيرفر
2. تحقق من ApiConfig.defaultBaseUrl
3. راجع السجلات في DebugLogger
