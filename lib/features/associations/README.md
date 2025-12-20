# 🏢 نظام إدارة الجمعيات - دليل الاستخدام

## 📖 نظرة عامة

نظام إدارة الجمعيات هو feature مستقل بالكامل يتبع Clean Architecture مع فصل واضح بين الطبقات.

---

## 🚀 كيفية التشغيل

### 1. إضافة الجداول إلى Database

افتح ملف `lib/data/db/drift_database.dart` وأضف الجداول الجديدة:

```dart
import 'tables/associations_table.dart';

@DriftDatabase(
  tables: [
    // ... existing tables
    Associations,
    AssociationRepresentatives,
  ],
  daos: [
    // ... existing daos
    AssociationsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  // ...
}
```

### 2. تشغيل Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. إضافة الصفحة إلى Navigation

في ملف `lib/app.dart` أو حيث تدير التنقل:

```dart
import 'features/associations/associations.dart';

// في menu أو navigation
ListTile(
  leading: const Icon(Icons.business),
  title: const Text('إدارة الجمعيات'),
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

---

## 📋 استخدام الـ Providers

### في صفحة المستفيدين - عرض قائمة الجمعيات

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/associations/associations.dart';

class BeneficiaryFormPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final associationsState = ref.watch(associationsProvider);
    
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'الجمعية'),
      items: associationsState.associations.map((assoc) {
        return DropdownMenuItem(
          value: assoc.id,
          child: Text(assoc.displayName),
        );
      }).toList(),
      onChanged: (id) {
        // save association id to beneficiary
      },
    );
  }
}
```

### استخدام Use Cases مباشرة

```dart
final getAllAssociations = ref.read(getAllActiveAssociationsUseCaseProvider);
final result = await getAllAssociations.execute();

result.when(
  success: (associations) {
    // handle success
  },
  failure: (failure) {
    // handle error
  },
);
```

---

## 🔗 ربط الجمعيات بالمستفيدين

### تحديث جدول Beneficiaries

في `lib/data/db/tables/beneficiaries_table.dart`:

```dart
class Beneficiaries extends Table {
  // ... existing fields
  
  // إضافة حقل جديد
  TextColumn get associationId => 
    text().nullable().references(Associations, #id)();
    
  // حذف الحقل القديم (اختياري)
  // TextColumn get associationName => text().nullable()();
}
```

### في BeneficiaryFormPage

استبدال `associationName` بـ `associationId`:

```dart
// Old (Text Field)
TextFormField(
  controller: associationNameController,
  decoration: InputDecoration(labelText: 'اسم الجمعية'),
)

// New (Dropdown)
Consumer(
  builder: (context, ref, _) {
    final associations = ref.watch(associationsProvider).associations;
    
    return DropdownButtonFormField<String>(
      value: selectedAssociationId,
      decoration: InputDecoration(labelText: 'الجمعية'),
      items: associations.map((a) {
        return DropdownMenuItem(
          value: a.id,
          child: Text(a.displayName),
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

## 🎨 Customization

### تغيير الألوان

في ملفات الصفحات:

```dart
// Primary Color
const Color(0xFF2196F3) → يمكن تغييره حسب Theme التطبيق

// Accent Color (Green)
const Color(0xFF4CAF50) → للأزرار الأساسية
```

### إضافة حقول جديدة

1. أضف الحقل في `associations_table.dart`
2. أضف في `association.dart` Entity
3. أضف في `AssociationParams`
4. أضف في Form Page
5. Update Repository Implementation

---

## 🧪 Testing

### Unit Tests

```dart
test('Create association with valid data', () async {
  final params = AssociationParams(
    name: 'Test Association',
    phone: '07701234567',
    bankName: 'Test Bank',
    accountNumber: '123456',
  );
  
  final result = await createAssociationUseCase.execute(params);
  
  expect(result.isSuccess, true);
});
```

### Widget Tests

```dart
testWidgets('Association form validation', (tester) async {
  await tester.pumpWidget(AssociationFormPage());
  
  await tester.tap(find.text('حفظ'));
  await tester.pump();
  
  expect(find.text('اسم الجمعية مطلوب'), findsOneWidget);
});
```

---

## 📊 Database Schema Diagram

```
┌─────────────────────────┐
│   Associations          │
├─────────────────────────┤
│ id (PK)                 │
│ name                    │
│ short_name              │
│ phone                   │
│ email                   │
│ bank_name               │
│ account_number          │
│ swift_code              │
│ bank_phone              │
│ account_currency        │
│ representative_id (FK)  │──┐
│ is_active               │  │
│ created_at              │  │
│ updated_at              │  │
│ sync_state              │  │
└─────────────────────────┘  │
                              │
┌─────────────────────────┐  │
│ Representatives         │  │
├─────────────────────────┤  │
│ id (PK)                 │◄─┘
│ name                    │
│ created_at              │
│ updated_at              │
└─────────────────────────┘
         ▲
         │
         │ (Many-to-One)
         │
┌─────────────────────────┐
│   Beneficiaries         │
├─────────────────────────┤
│ id (PK)                 │
│ ...                     │
│ association_id (FK)     │──┘
│ ...                     │
└─────────────────────────┘
```

---

## 🔄 Migration Strategy

### خطوة 1: إضافة الجداول الجديدة
```sql
-- تم إنشاؤها تلقائياً من Drift
CREATE TABLE associations (...);
CREATE TABLE association_representatives (...);
```

### خطوة 2: نقل البيانات القديمة (اختياري)
```sql
-- إذا كان لديك بيانات في association_name
INSERT INTO associations (id, name, phone, bank_name, account_number, ...)
SELECT DISTINCT 
  uuid(),
  association_name,
  '07700000000', -- default phone
  'Unknown Bank',
  '000000',
  ...
FROM beneficiaries 
WHERE association_name IS NOT NULL;

-- ربط المستفيدين بالجمعيات الجديدة
UPDATE beneficiaries 
SET association_id = (
  SELECT id FROM associations 
  WHERE associations.name = beneficiaries.association_name
  LIMIT 1
);
```

### خطوة 3: حذف الحقل القديم
```sql
ALTER TABLE beneficiaries DROP COLUMN association_name;
```

---

## 🐛 Common Issues & Solutions

### Issue: Build Runner Error

```bash
# Solution
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Issue: Foreign Key Constraint Failed

```dart
// تأكد من وجود المندوب قبل ربطه بالجمعية
if (representativeId != null) {
  final rep = await getRepresentativeById(representativeId);
  if (rep == null) {
    // handle error
  }
}
```

### Issue: Dropdown shows no items

```dart
// تأكد من تحميل البيانات أولاً
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(associationsProvider.notifier).loadAssociations();
  });
}
```

---

## 📚 Additional Resources

- [Clean Architecture Guide](../CLEAN_ARCHITECTURE.md)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Riverpod Documentation](https://riverpod.dev/)

---

## ✅ Checklist

- [x] Database Schema Created
- [x] Tables & DAOs Implemented
- [x] Domain Entities Created
- [x] Use Cases Implemented
- [x] Repository Implemented
- [x] Providers Created
- [x] UI Pages Built
- [x] Widgets Created
- [ ] Tests Written
- [ ] Documentation Complete
- [ ] Migration Script Ready

---

**Created:** 2025-12-17  
**Version:** 1.0.0  
**Maintainer:** Development Team
