# ⚡ خطوات التفعيل السريعة - نظام إدارة الجمعيات

## 🎯 3 خطوات فقط للتشغيل!

---

## الخطوة 1️⃣: تحديث Database

افتح: `lib/data/db/drift_database.dart`

```dart
// أضف في الـ imports
import 'tables/associations_table.dart';
import 'daos/associations_dao.dart';

// أضف في @DriftDatabase
@DriftDatabase(
  tables: [
    // ... الجداول الموجودة
    Beneficiaries,
    FamilyMembersTable,
    // ... إلخ
    
    // ✅ أضف هذه الجداول الجديدة
    Associations,
    AssociationRepresentatives,
  ],
  daos: [
    // ... الـ DAOs الموجودة
    BeneficiariesDao,
    FamilyMembersDao,
    // ... إلخ
    
    // ✅ أضف هذا الـ DAO الجديد
    AssociationsDao,
  ],
  version: 1, // أو زد الرقم إذا كان موجود
)
class AppDatabase extends _$AppDatabase {
  // ... باقي الكود
}
```

---

## الخطوة 2️⃣: تشغيل Build Runner

في Terminal:

```bash
dart run build_runner build --delete-conflicting-outputs
```

⏱️ انتظر حتى ينتهي (حوالي 30 ثانية - دقيقة)

---

## الخطوة 3️⃣: إضافة إلى Navigation

### خيار أ: Dashboard Menu

افتح: `lib/features/dashboard/presentation/pages/dashboard_page.dart`

```dart
import 'package:benaa_offline_app/features/associations/associations.dart';

// في GridView أو القائمة
DashboardCard(
  icon: Icons.business,
  title: 'إدارة الجمعيات',
  color: Colors.blue,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AssociationsListPage(),
      ),
    );
  },
),
```

### خيار ب: Drawer Menu

افتح: `lib/features/dashboard/presentation/widgets/app_drawer.dart`

```dart
import 'package:benaa_offline_app/features/associations/associations.dart';

// في Drawer
ListTile(
  leading: const Icon(Icons.business),
  title: const Text('إدارة الجمعيات'),
  onTap: () {
    Navigator.pop(context); // أغلق الـ Drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AssociationsListPage(),
      ),
    );
  },
),
```

---

## ✅ تم! جرب الآن

1. شغل التطبيق: `flutter run`
2. افتح "إدارة الجمعيات" من القائمة
3. اضغط زر "إضافة جمعية"
4. املأ البيانات واحفظ

---

## 🔧 (اختياري) ربط بالمستفيدين

إذا كنت تريد ربط الجمعيات بالمستفيدين:

### 1. تحديث Beneficiaries Table

افتح: `lib/data/db/tables/beneficiaries_table.dart`

```dart
class Beneficiaries extends Table {
  // ... الحقول الموجودة
  
  // ✅ أضف هذا الحقل الجديد
  TextColumn get associationId => 
    text().nullable().references(Associations, #id)();
  
  // ❌ (اختياري) احذف الحقل القديم
  // TextColumn get associationName => text().nullable()();
}
```

### 2. شغل Build Runner مرة أخرى

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. استخدم في Beneficiary Form

افتح: `lib/features/beneficiaries/presentation/pages/beneficiary_form_page.dart`

```dart
import 'package:benaa_offline_app/features/associations/associations.dart';

// بدل TextField بـ Dropdown

// ❌ Old (قبل)
TextFormField(
  controller: associationNameController,
  decoration: InputDecoration(labelText: 'اسم الجمعية'),
)

// ✅ New (بعد)
Consumer(
  builder: (context, ref, _) {
    final associations = ref.watch(associationsProvider).associations;
    
    return DropdownButtonFormField<String>(
      value: selectedAssociationId,
      decoration: InputDecoration(
        labelText: 'الجمعية',
        prefixIcon: Icon(Icons.business),
      ),
      items: associations.map((assoc) {
        return DropdownMenuItem(
          value: assoc.id,
          child: Text(assoc.displayName),
        );
      }).toList(),
      onChanged: (id) {
        setState(() => selectedAssociationId = id);
      },
    );
  },
)
```

---

## 🐛 حل المشاكل الشائعة

### ❌ Build Runner Error

```bash
# الحل
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### ❌ Import Error

تأكد من import الصحيح:

```dart
// ✅ صحيح
import 'package:benaa_offline_app/features/associations/associations.dart';

// ❌ خطأ
import '../associations/associations.dart';
```

### ❌ Database Error: "no such table: associations"

الحل: زد رقم version في Database:

```dart
@DriftDatabase(
  // ...
  version: 2, // كان 1، اجعله 2
)
```

ثم:

```bash
flutter clean
flutter run
```

---

## 📚 ملفات التوثيق الكاملة

إذا كنت تحتاج تفاصيل أكثر:

1. **المعمارية الكاملة**: `docs/ASSOCIATIONS_ARCHITECTURE.md`
2. **دليل الاستخدام**: `lib/features/associations/README.md`
3. **ملخص تنفيذي**: `docs/ASSOCIATIONS_SUMMARY_AR.md`
4. **مثال عملي**: `docs/ASSOCIATIONS_EXAMPLE_AR.md`
5. **رسم معماري**: `docs/ASSOCIATIONS_ARCHITECTURE_DIAGRAM.md`

---

## ✅ Checklist

- [ ] تحديث `drift_database.dart`
- [ ] تشغيل Build Runner
- [ ] إضافة إلى Navigation Menu
- [ ] تجربة التطبيق
- [ ] (اختياري) ربط بالمستفيدين

---

**إذا واجهت أي مشكلة، راجع ملفات التوثيق أو اسأل في الفريق!**

---

**Created:** 17 ديسمبر 2025  
**Last Updated:** 17 ديسمبر 2025
