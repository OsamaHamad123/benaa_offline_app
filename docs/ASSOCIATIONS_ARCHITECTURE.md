# 🏢 Associations Management Architecture

## النظرة العامة (Overview)

نظام إدارة الجمعيات هو Feature مستقل بالكامل يتبع Clean Architecture Pattern مع فصل واضح بين الطبقات.

---

## 📊 Database Schema

### 1. جدول Associations (الجمعيات)

```sql
CREATE TABLE associations (
  id TEXT PRIMARY KEY,           -- UUID
  name TEXT NOT NULL,            -- اسم الجمعية
  short_name TEXT,               -- الاسم المختصر
  phone TEXT NOT NULL,           -- رقم هاتف الجمعية
  email TEXT,                    -- البريد الإلكتروني
  bank_name TEXT NOT NULL,       -- اسم البنك
  account_number TEXT NOT NULL,  -- رقم الحساب
  swift_code TEXT,               -- رمز السويفت
  bank_phone TEXT,               -- رقم هاتف البنك
  account_currency TEXT,         -- عملة الحساب (IQD, USD, EUR)
  representative_id TEXT,        -- مفتاح أجنبي لمندوب الجمعية
  is_active INTEGER DEFAULT 1,   -- نشط/معطل
  created_at TEXT NOT NULL,      -- تاريخ الإنشاء
  updated_at TEXT NOT NULL,      -- تاريخ التحديث
  sync_state TEXT DEFAULT 'pending', -- حالة المزامنة
  server_id INTEGER,             -- ID من السيرفر
  
  FOREIGN KEY (representative_id) REFERENCES association_representatives(id)
);

CREATE INDEX idx_associations_name ON associations(name);
CREATE INDEX idx_associations_active ON associations(is_active);
CREATE INDEX idx_associations_sync ON associations(sync_state);
```

### 2. جدول Association Representatives (مندوبي الجمعيات)

```sql
CREATE TABLE association_representatives (
  id TEXT PRIMARY KEY,           -- UUID
  name TEXT NOT NULL,            -- اسم المندوب فقط
  created_at TEXT NOT NULL,      -- تاريخ الإنشاء
  updated_at TEXT NOT NULL,      -- تاريخ التحديث
  sync_state TEXT DEFAULT 'pending'
);

CREATE INDEX idx_representatives_name ON association_representatives(name);
```

### 3. تحديث جدول Beneficiaries

```sql
ALTER TABLE beneficiaries 
  ADD COLUMN association_id TEXT,
  ADD FOREIGN KEY (association_id) REFERENCES associations(id);

-- إزالة الحقل القديم
-- ALTER TABLE beneficiaries DROP COLUMN association_name;
```

---

## 🏗️ Architecture Layers

### 1️⃣ Data Layer

```
lib/features/associations/
  ├── data/
  │   ├── models/
  │   │   ├── association_model.dart
  │   │   └── representative_model.dart
  │   ├── datasources/
  │   │   └── association_local_datasource.dart
  │   └── repositories/
  │       └── association_repository_impl.dart
```

### 2️⃣ Domain Layer

```
lib/features/associations/
  ├── domain/
  │   ├── entities/
  │   │   ├── association.dart
  │   │   └── representative.dart
  │   ├── repositories/
  │   │   └── association_repository.dart
  │   └── usecases/
  │       ├── get_all_associations.dart
  │       ├── get_association_by_id.dart
  │       ├── create_association.dart
  │       ├── update_association.dart
  │       ├── delete_association.dart
  │       ├── get_all_representatives.dart
  │       └── create_representative.dart
```

### 3️⃣ Presentation Layer

```
lib/features/associations/
  ├── presentation/
  │   ├── providers/
  │   │   └── associations_provider.dart
  │   ├── pages/
  │   │   ├── associations_list_page.dart
  │   │   └── association_form_page.dart
  │   └── widgets/
  │       ├── association_card.dart
  │       ├── association_form_fields.dart
  │       └── representative_dropdown.dart
```

---

## 🔗 Relationships (العلاقات)

```
Association (1) ──────> (1) Representative
     │
     │
     ↓
Beneficiary (Many) ──────> (1) Association
```

**شرح العلاقات:**
- كل جمعية لها مندوب واحد (One-to-One)
- المستفيد يمكن أن يكون مرتبط بجمعية واحدة (Many-to-One)
- المندوب مستقل تمامًا ويحتوي فقط على الاسم

---

## 🎨 UI/UX Design

### 1. صفحة قائمة الجمعيات (Associations List Page)

**Layout:**
```
┌─────────────────────────────────────┐
│  🏢 إدارة الجمعيات                 │
│                         [+ إضافة]   │
├─────────────────────────────────────┤
│  🔍 بحث...                          │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │ 🏢 جمعية بناء الخيرية        │   │
│  │ 📞 07701234567              │   │
│  │ 👤 أحمد محمد (المندوب)      │   │
│  │              [تعديل] [حذف]  │   │
│  └─────────────────────────────┘   │
│                                      │
│  ┌─────────────────────────────┐   │
│  │ 🏢 جمعية الأمل الخيرية       │   │
│  │ ...                          │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### 2. نموذج إضافة/تعديل جمعية (Association Form)

**Layout:**
```
┌─────────────────────────────────────┐
│  إضافة جمعية جديدة                  │
│  ← رجوع                             │
├─────────────────────────────────────┤
│                                      │
│  📝 معلومات أساسية                  │
│  ┌─────────────────────────────┐   │
│  │ اسم الجمعية *               │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ الاسم المختصر               │   │
│  └─────────────────────────────┘   │
│                                      │
│  📞 معلومات الاتصال                 │
│  ┌─────────────────────────────┐   │
│  │ رقم الهاتف *                │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ البريد الإلكتروني           │   │
│  └─────────────────────────────┘   │
│                                      │
│  🏦 المعلومات المصرفية              │
│  ┌─────────────────────────────┐   │
│  │ اسم البنك *                 │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ رقم الحساب *                │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ رمز السويفت                 │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ رقم هاتف البنك              │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ عملة الحساب ▼              │   │
│  │ IQD / USD / EUR            │   │
│  └─────────────────────────────┘   │
│                                      │
│  👤 مندوب الجمعية                   │
│  ┌─────────────────────────────┐   │
│  │ اسم المندوب ▼              │   │
│  │ (أو إضافة مندوب جديد)       │   │
│  └─────────────────────────────┘   │
│                                      │
│      [إلغاء]     [حفظ]              │
└─────────────────────────────────────┘
```

**Form Validation:**
- اسم الجمعية: مطلوب
- رقم الهاتف: مطلوب (تنسيق عراقي)
- اسم البنك: مطلوب
- رقم الحساب: مطلوب
- مندوب الجمعية: اختياري

---

## 🎯 Core Features

### 1. إدارة الجمعيات (CRUD)
- ✅ عرض جميع الجمعيات
- ✅ إضافة جمعية جديدة
- ✅ تعديل بيانات جمعية
- ✅ حذف جمعية (Soft Delete)
- ✅ البحث عن جمعية

### 2. إدارة المندوبين
- ✅ عرض جميع المندوبين
- ✅ إضافة مندوب جديد (اسم فقط)
- ✅ اختيار مندوب من قائمة

### 3. الربط مع المستفيدين
- ✅ اختيار جمعية عند إضافة مستفيد
- ✅ عرض جمعية المستفيد في صفحة التفاصيل
- ✅ تقارير حسب الجمعية

---

## 📱 Color Scheme

```dart
// Material Colors
primaryColor: Color(0xFF2196F3),    // Blue
accentColor: Color(0xFF4CAF50),     // Green
cardColor: Colors.white,
backgroundColor: Color(0xFFF5F5F5),
```

---

## 🔄 Sync Strategy

```dart
// Associations Sync Priority
enum SyncPriority {
  associations = 90,      // أولوية عالية
  representatives = 85,    // أولوية عالية
  beneficiaries = 80,
}
```

---

## ✅ Best Practices

1. **Clean Architecture**: فصل كامل بين الطبقات
2. **Single Responsibility**: كل Entity له مسؤولية واحدة
3. **Immutability**: استخدام `final` و `const` حيثما أمكن
4. **Null Safety**: التعامل الصحيح مع القيم الاختيارية
5. **Error Handling**: استخدام `Result<T>` pattern
6. **Validation**: التحقق من المدخلات قبل الحفظ
7. **Indexing**: Indexes على الحقول المستخدمة في البحث

---

## 📝 Example Code

### Entity Example

```dart
class Association {
  final String id;
  final String name;
  final String? shortName;
  final String phone;
  final String? email;
  final String bankName;
  final String accountNumber;
  final String? swiftCode;
  final String? bankPhone;
  final String? accountCurrency;
  final String? representativeId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Association({
    required this.id,
    required this.name,
    this.shortName,
    required this.phone,
    this.email,
    required this.bankName,
    required this.accountNumber,
    this.swiftCode,
    this.bankPhone,
    this.accountCurrency,
    this.representativeId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

### Use Case Example

```dart
class CreateAssociationUseCase {
  final AssociationRepository repository;

  CreateAssociationUseCase(this.repository);

  Future<Result<Association>> execute(AssociationParams params) async {
    // Validation
    if (params.name.trim().isEmpty) {
      return Failure(ValidationFailure('اسم الجمعية مطلوب'));
    }

    if (params.phone.trim().isEmpty) {
      return Failure(ValidationFailure('رقم الهاتف مطلوب'));
    }

    // Create
    return await repository.createAssociation(params);
  }
}
```

---

## 🚀 Implementation Steps

1. ✅ إنشاء جداول Database
2. ✅ إنشاء Data Models & Tables (Drift)
3. ✅ إنشاء DAOs
4. ✅ إنشاء Domain Entities
5. ✅ إنشاء Repositories
6. ✅ إنشاء Use Cases
7. ✅ إنشاء Providers (Riverpod)
8. ✅ إنشاء UI Pages & Widgets
9. ✅ Testing & Validation
10. ✅ Documentation

---

## 📚 Related Files

- `lib/data/db/tables/associations_table.dart`
- `lib/data/db/tables/representatives_table.dart`
- `lib/data/db/daos/associations_dao.dart`
- `lib/features/associations/`

---

**Created:** 2025-12-17
**Version:** 1.0.0
**Status:** ✅ Ready for Implementation
