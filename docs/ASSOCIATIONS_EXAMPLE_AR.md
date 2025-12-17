# 🎓 مثال عملي - نظام إدارة الجمعيات

## 📝 سيناريو كامل: إضافة جمعية جديدة

### المدخلات (User Input):

```yaml
اسم الجمعية: "جمعية بناء الخيرية"
الاسم المختصر: "بناء"
رقم الهاتف: "07701234567"
البريد الإلكتروني: "info@benaa.org"
البنك: "البنك التجاري العراقي"
رقم الحساب: "123456789"
رمز السويفت: "BKIQIQBA"
رقم هاتف البنك: "07901234567"
عملة الحساب: "IQD"
المندوب: "أحمد محمد" (جديد)
```

---

## 🔄 خطوات العملية

### 1. المستخدم يفتح الصفحة

```dart
// في Navigation Menu
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AssociationsListPage(),
    ),
  );
}
```

**ما يحدث في الخلفية:**
```dart
// initState() في AssociationsListPage
ref.read(associationsProvider.notifier).loadAssociations();
ref.read(associationsProvider.notifier).loadRepresentatives();

// يتم جلب البيانات من Database
SELECT * FROM associations WHERE is_active = true ORDER BY name;
SELECT * FROM association_representatives ORDER BY name;
```

---

### 2. المستخدم يضغط على زر "إضافة جمعية"

```dart
FloatingActionButton.extended(
  onPressed: () => _navigateToForm(),
  icon: Icon(Icons.add),
  label: Text('إضافة جمعية'),
)
```

**النتيجة:** فتح صفحة النموذج `AssociationFormPage`

---

### 3. المستخدم يملأ النموذج

#### أ. معلومات أساسية
```dart
TextField(
  controller: _nameController,
  decoration: InputDecoration(labelText: 'اسم الجمعية *'),
  validator: (v) => v?.trim().isEmpty == true ? 'اسم الجمعية مطلوب' : null,
)
// المدخل: "جمعية بناء الخيرية"
```

#### ب. المندوب (إضافة جديد)

المستخدم يضغط "إضافة مندوب جديد":

```dart
Future<void> _addNewRepresentative() async {
  // يظهر Dialog
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('إضافة مندوب جديد'),
      content: TextField(
        decoration: InputDecoration(labelText: 'اسم المندوب'),
      ),
    ),
  );
  
  // المدخل: "أحمد محمد"
  
  if (name != null) {
    final representative = await ref
        .read(associationsProvider.notifier)
        .createRepresentative(name);
    
    // يتم إضافة المندوب إلى Database
    // INSERT INTO association_representatives (id, name, ...) VALUES (?, ?, ...)
    
    if (representative != null) {
      widget.onChanged(representative.id);
      // يتم تحديث الـ Dropdown تلقائياً
    }
  }
}
```

**Database بعد إضافة المندوب:**
```sql
association_representatives
┌──────────────────────────────┬──────────────┬─────────────────────┐
│ id                           │ name         │ created_at          │
├──────────────────────────────┼──────────────┼─────────────────────┤
│ abc123-uuid                  │ أحمد محمد    │ 2025-12-17 10:30:00 │
└──────────────────────────────┴──────────────┴─────────────────────┘
```

---

### 4. المستخدم يضغط "حفظ"

```dart
Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  final params = AssociationParams(
    name: "جمعية بناء الخيرية",
    shortName: "بناء",
    phone: "07701234567",
    email: "info@benaa.org",
    bankName: "البنك التجاري العراقي",
    accountNumber: "123456789",
    swiftCode: "BKIQIQBA",
    bankPhone: "07901234567",
    accountCurrency: "IQD",
    representativeId: "abc123-uuid",
    isActive: true,
  );
  
  final success = await ref
      .read(associationsProvider.notifier)
      .createAssociation(params);
  
  if (success) {
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت إضافة الجمعية بنجاح ✅')),
    );
  }
}
```

---

## 🔍 تتبع العملية في الطبقات

### Layer 1: Presentation (UI)
```dart
// AssociationFormPage
_save() → calls Provider

// AssociationsNotifier
createAssociation(params) → calls Use Case
```

### Layer 2: Domain (Business Logic)
```dart
// CreateAssociationUseCase
Future<Result<Association>> execute(AssociationParams params) async {
  // 1. Validation
  if (!params.isValid) {
    return Failure(ValidationFailure(params.validationError));
  }
  
  // 2. Call Repository
  return await repository.createAssociation(params);
}
```

### Layer 3: Data (Data Management)
```dart
// AssociationRepositoryImpl
Future<Result<Association>> createAssociation(AssociationParams params) async {
  try {
    final id = _uuid.v4(); // xyz789-uuid
    final now = DateTime.now();
    
    // 1. Map to Drift Companion
    final companion = AssociationsCompanion(
      id: Value(id),
      name: Value(params.name.trim()),
      shortName: Value(params.shortName?.trim()),
      phone: Value(params.phone.trim()),
      email: Value(params.email?.trim()),
      bankName: Value(params.bankName.trim()),
      accountNumber: Value(params.accountNumber.trim()),
      swiftCode: Value(params.swiftCode?.trim()),
      bankPhone: Value(params.bankPhone?.trim()),
      accountCurrency: Value(params.accountCurrency),
      representativeId: Value(params.representativeId),
      isActive: Value(params.isActive),
      createdAt: Value(now),
      updatedAt: Value(now),
      syncState: Value('pending'),
    );
    
    // 2. Call DAO
    await database.associationsDao.addAssociation(companion);
    
    // 3. Get created association
    final result = await database.associationsDao.getAssociationById(id);
    
    // 4. Map to Domain Entity
    return Success(_mapToDomain(result!));
    
  } catch (e, stackTrace) {
    return Failure(DatabaseFailure('فشل إضافة الجمعية: $e', stackTrace));
  }
}
```

### Layer 4: Database
```sql
INSERT INTO associations (
  id, 
  name, 
  short_name, 
  phone, 
  email, 
  bank_name, 
  account_number, 
  swift_code, 
  bank_phone, 
  account_currency, 
  representative_id, 
  is_active, 
  created_at, 
  updated_at, 
  sync_state
) VALUES (
  'xyz789-uuid',
  'جمعية بناء الخيرية',
  'بناء',
  '07701234567',
  'info@benaa.org',
  'البنك التجاري العراقي',
  '123456789',
  'BKIQIQBA',
  '07901234567',
  'IQD',
  'abc123-uuid',
  1,
  '2025-12-17 10:35:00',
  '2025-12-17 10:35:00',
  'pending'
);
```

---

## 📊 حالة Database بعد الإضافة

### جدول `associations`
```sql
┌──────────────┬─────────────────────────┬────────┬─────────────┬──────────────────┬────────────────────────┬───────────────┬──────────┬─────────────┬──────────────────┬──────────────────┬──────────┬─────────────────────┬─────────────────────┬──────────────┐
│ id           │ name                    │ short  │ phone       │ email            │ bank_name              │ account_no    │ swift    │ bank_phone  │ account_currency │ representative_id│ is_active│ created_at          │ updated_at          │ sync_state   │
├──────────────┼─────────────────────────┼────────┼─────────────┼──────────────────┼────────────────────────┼───────────────┼──────────┼─────────────┼──────────────────┼──────────────────┼──────────┼─────────────────────┼─────────────────────┼──────────────┤
│ xyz789-uuid  │ جمعية بناء الخيرية      │ بناء   │ 07701234567 │ info@benaa.org   │ البنك التجاري العراقي │ 123456789     │ BKIQIQBA │ 07901234567 │ IQD              │ abc123-uuid      │ 1        │ 2025-12-17 10:35:00 │ 2025-12-17 10:35:00 │ pending      │
└──────────────┴─────────────────────────┴────────┴─────────────┴──────────────────┴────────────────────────┴───────────────┴──────────┴─────────────┴──────────────────┴──────────────────┴──────────┴─────────────────────┴─────────────────────┴──────────────┘
```

### جدول `association_representatives`
```sql
┌──────────────┬──────────────┬─────────────────────┬─────────────────────┬──────────────┐
│ id           │ name         │ created_at          │ updated_at          │ sync_state   │
├──────────────┼──────────────┼─────────────────────┼─────────────────────┼──────────────┤
│ abc123-uuid  │ أحمد محمد    │ 2025-12-17 10:30:00 │ 2025-12-17 10:30:00 │ pending      │
└──────────────┴──────────────┴─────────────────────┴─────────────────────┴──────────────┘
```

---

## 📱 الواجهة بعد الإضافة

### قائمة الجمعيات

```
┌────────────────────────────────────────┐
│ 🏢 إدارة الجمعيات              [+ إضافة] │
├────────────────────────────────────────┤
│ 🔍 بحث...                             │
├────────────────────────────────────────┤
│ ┌────────────────────────────────────┐ │
│ │ 🏢  جمعية بناء الخيرية      [نشط] │ │
│ │                                    │ │
│ │ 📞 الهاتف: 07701234567             │ │
│ │ 📧 البريد: info@benaa.org          │ │
│ │ 🏦 البنك: البنك التجاري العراقي    │ │
│ │ 👤 المندوب: أحمد محمد              │ │
│ │                                    │ │
│ │              [تعديل]  [حذف]        │ │
│ └────────────────────────────────────┘ │
└────────────────────────────────────────┘

✅ SnackBar: "تمت إضافة الجمعية بنجاح"
```

---

## 🔗 استخدام في صفحة المستفيدين

### قبل التحديث (Old)
```dart
// حقل نصي بسيط
TextFormField(
  controller: associationNameController,
  decoration: InputDecoration(
    labelText: 'اسم الجمعية',
  ),
)

// في Beneficiary Entity
class Beneficiary {
  final String? associationName; // نص فقط
}
```

### بعد التحديث (New)
```dart
// قائمة منسدلة مع ربط
Consumer(
  builder: (context, ref, _) {
    final associations = ref.watch(associationsProvider).associations;
    
    return DropdownButtonFormField<String>(
      value: selectedAssociationId,
      decoration: InputDecoration(labelText: 'الجمعية'),
      items: associations.map((assoc) {
        return DropdownMenuItem(
          value: assoc.id,
          child: Row(
            children: [
              Icon(Icons.business, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text(assoc.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: (id) {
        setState(() => selectedAssociationId = id);
      },
    );
  },
)

// في Beneficiary Entity
class Beneficiary {
  final String? associationId; // ID مع Foreign Key
}
```

---

## 📊 Query Examples (أمثلة الاستعلامات)

### 1. جلب جميع المستفيدين في جمعية معينة

```dart
// في BeneficiariesDao
Future<List<Beneficiary>> getBeneficiariesByAssociation(String associationId) {
  return (select(beneficiaries)
        ..where((b) => b.associationId.equals(associationId))
        ..orderBy([(b) => OrderingTerm.asc(b.fullName)]))
      .get();
}
```

SQL المق��بل:
```sql
SELECT * FROM beneficiaries 
WHERE association_id = 'xyz789-uuid'
ORDER BY full_name ASC;
```

### 2. إحصائيات الجمعية

```dart
// عدد المستفيدين لكل جمعية
Future<Map<String, int>> getBeneficiariesCountByAssociation() async {
  final query = select(beneficiaries).join([
    innerJoin(associations, associations.id.equalsExp(beneficiaries.associationId))
  ]);
  
  final results = await query.get();
  
  // Group by association and count
  // ...
}
```

SQL المقابل:
```sql
SELECT 
  a.id,
  a.name,
  COUNT(b.id) as beneficiary_count
FROM associations a
LEFT JOIN beneficiaries b ON b.association_id = a.id
GROUP BY a.id, a.name
ORDER BY beneficiary_count DESC;
```

### 3. تقرير شامل

```sql
-- جمعية مع مندوبها وعدد المستفيدين
SELECT 
  a.id,
  a.name as association_name,
  a.short_name,
  a.phone,
  r.name as representative_name,
  COUNT(b.id) as total_beneficiaries,
  SUM(CASE WHEN b.request_status = 1 THEN 1 ELSE 0 END) as active_beneficiaries
FROM associations a
LEFT JOIN association_representatives r ON a.representative_id = r.id
LEFT JOIN beneficiaries b ON b.association_id = a.id
WHERE a.is_active = true
GROUP BY a.id, a.name, a.short_name, a.phone, r.name
ORDER BY total_beneficiaries DESC;
```

---

## 🎯 الخلاصة

### ✅ ما تم إنجازه:

1. **نظام كامل ومستقل** - يعمل بشكل مستقل عن باقي التطبيق
2. **Clean Architecture** - فصل واضح بين الطبقات
3. **UI احترافي** - واجهة مستخدم بسيطة وجميلة
4. **Validation** - التحقق من جميع المدخلات
5. **Error Handling** - معالجة الأخطاء بشكل صحيح
6. **Database Relations** - علاقات واضحة ومنطقية

### 🚀 الخطوات التالية:

1. تشغيل `dart run build_runner build`
2. إضافة الصفحة إلى Navigation Menu
3. (اختياري) تحديث جدول Beneficiaries لإضافة `association_id`
4. (اختياري) نقل البيانات القديمة من `association_name` إلى النظام الجديد

---

**Created:** 17 ديسمبر 2025  
**Purpose:** مثال عملي كامل للاستخدام
