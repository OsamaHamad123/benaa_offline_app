# 📊 تحديث قاعدة البيانات - Beneficiary Form Improvements

## ✅ التحديثات المُنجزة

### 1. 📋 الحقول الجديدة المضافة

#### Beneficiary Entity
```dart
- relationship (int?) // صلة القرابة (2=أرملة، 3=أرمل، 4=يتيم، etc)
- sectionId (int?) // القسم/الشعبة  
- createdByUser (String?) // المستخدم المدخل للبيانات
```

#### Attachments Table
```dart
- documentType (String?) // نوع الوثيقة (17+ نوع)
- personType (String?) // الشخص المرتبط (صاحب الملف، أفراد الأسرة، etc)
- personId (String?) // ID الشخص إذا كان فرد من العائلة
- notes (String?) // ملاحظات على المرفق
```

#### Family Members Table
```dart
- sponsorshipStatus (int?) // حالة الكفالة (1=مكفول، 2=غير مكفول، 3=قيد الانتظار)
- sponsorshipType (int?) // نوع الكفالة (1=كاملة، 2=جزئية، 3=موسمية)
- sponsorName (String?) // اسم الكفيل
- sponsorshipStartDate (DateTime?) // تاريخ بدء الكفالة
```

#### Form Controllers
```dart
- selectedSection (String?) // القسم المختار
```

---

### 2. 📚 Enums الجديدة

#### 📄 DocumentType - أنواع الوثائق (17 نوع)
```dart
- idCard: صورة هوية
- medicalReport: تقرير طبي
- birthCertificate: شهادة الميلاد
- lastCertificate: آخر شهادة
- personalPhoto: صورة شخصية
- fullPhoto: صورة طولية
- inheritanceDeed: حضر إرث
- orphanCareDeed: حجة أعالة يتيم
- testDocument: test
- otherDocuments: أوراق ثبوتية أخرى
- agencyDeed: وكالة في شؤون الولاية
- widowhoodDeed: حجة ترمل
- parenthoodDeed: حجة والدة
- walletAccountPhoto: صورة حساب المحفظة
- deathCertificate: شهادة الوفاة
- guardianDeed: حجة الوصاية
- other: أخرى
```

#### 👤 AttachmentPersonType - أنواع الأشخاص
```dart
- fileOwner: صاحب الملف
- familyMember: أفراد الأسرة
- deceasedMember: الأفراد المتوفيين
- deceasedFather: الأب المتوفي
- deceasedMother: الأم المتوفية
```

#### 🏢 Department - الأقسام
```dart
- section1: القسم الأول (1)
- section2: القسم الثاني (2)
- section3: القسم الثالث (3)
- section4: القسم الرابع (4)
- section5: القسم الخامس (5)
```

#### 👨‍👩‍👧‍👦 Relationship - صلة القرابة
```dart
- widow: أرملة (2)
- widower: أرمل (3)
- orphan: يتيم (4)
- orphanGirl: يتيمة (5)
- guardian: ولي أمر (6)
- other: أخرى (99)
```

#### 🤝 SponsorshipStatus - حالة الكفالة
```dart
- sponsored: مكفول (1)
- notSponsored: غير مكفول (2)
- pending: قيد الانتظار (3)
```

#### 💰 SponsorshipType - نوع الكفالة
```dart
- full: كفالة كاملة (1)
- partial: كفالة جزئية (2)
- seasonal: كفالة موسمية (3)
```

---

### 3. 🔄 تحديثات Mapper

#### mapControllersToBeneficiary
- ✅ بناء fullName من 4 أجزاء (firstName + fatherName + grandfatherName + lastName)
- ✅ تحويل Strings إلى Enums (Gender, Category, MaritalStatus, etc.)
- ✅ تحويل String تاريخ إلى DateTime
- ✅ معالجة relationship و sectionId كـ integers
- ✅ ربط phoneNumber/altPhoneNumber بشكل صحيح

#### mapBeneficiaryToControllers
- ✅ تقسيم fullName إلى 4 أجزاء
- ✅ تحويل Enums إلى Arabic strings
- ✅ تنسيق DateTime إلى string
- ✅ معالجة جميع الحقول الجديدة

#### Helper Methods المضافة
```dart
_parseGender, _parseCategory, _parseMaritalStatus
_parseEducationLevel, _parseHealthStatus
_parseDisplacementStatus, _parseEmploymentStatus
_parseHousingStatus, _parseHousingType
_parseRelationship, _parseSection
_parseDateString, _formatDate, _parseInt
```

---

### 4. 📁 الملفات المُنشأة

```
lib/
├── core/
│   └── enums/
│       ├── attachment_enums.dart (NEW) ✨
│       ├── beneficiary_enums.dart (NEW) ✨
│       └── sponsorship_enums.dart (NEW) ✨
├── features/
│   └── beneficiaries/
│       ├── domain/
│       │   └── entities/
│       │       └── beneficiary.dart (UPDATED) ♻️
│       └── presentation/
│           └── pages/
│               ├── form/
│               │   ├── state/
│               │   │   ├── beneficiary_form_state.dart (NEW) ✨
│               │   │   ├── beneficiary_form_notifier.dart (NEW) ✨
│               │   │   └── beneficiary_form_providers.dart (NEW) ✨
│               │   └── logic/
│               │       ├── beneficiary_form_validator.dart (NEW) ✨
│               │       ├── beneficiary_form_mapper.dart (NEW) ✨
│               │       └── beneficiary_draft_handler.dart (NEW) ✨
│               └── v2_form_helpers/
│                   └── form_controllers.dart (UPDATED) ♻️
└── data/
    └── db/
        └── tables/
            ├── beneficiaries_table.dart (EXISTS) ✓
            ├── attachments_table.dart (UPDATED) ♻️
            └── family_members_table.dart (UPDATED) ♻️
```

---

### 5. 🎯 التوافق مع Backend

#### ✅ الحقول المتطابقة بالكامل
- ✅ القسم (sectionId / data_section_id)
- ✅ صلة القرابة (relationship / data_relationship)
- ✅ المستخدم المدخل (createdByUser / data_user_insert_data)
- ✅ أنواع الوثائق (17+ document types)
- ✅ الأشخاص المرتبطين بالمرفقات
- ✅ حقول الكفالة للأفراد

#### ⚠️ ملاحظات
1. **رقم الملف (fileNo)**: يتم توليده تلقائياً من النظام
2. **RequestStatus**: يتم تحديده من النظام (pending by default)
3. **Family Members**: يتم حفظها في جدول منفصل (family_members)
4. **Attachments**: جدول منفصل مع دعم كامل لجميع أنواع الوثائق

---

### 6. 🔍 الاختلافات المعالجة

| Backend Field | Frontend Field | Solution |
|--------------|----------------|----------|
| `file_id_number` | `fileNo` | Auto-generated |
| `data_id_number` | `nationalId` | ✅ Mapped |
| `data_first_name, data_father_name, data_grand_father_name, data_family_name` | `fullName` (calculated) | ✅ Split/Join in mapper |
| `data_phone_number` | `phoneNumber` | ✅ Mapped |
| `data_alt_phone_number` | `altPhoneNumber` | ✅ Mapped |
| `data_relationship` | `relationship` | ✅ Added |
| `data_section_id` | `sectionId` | ✅ Added |
| `data_user_insert_data` | `createdByUser` | ✅ Added |

---

### 7. 📊 إحصائيات التحديث

- ✅ **3 New Enum Files** created
- ✅ **6 New Form Logic Files** created
- ✅ **3 Database Tables** updated
- ✅ **1 Entity** updated with 3 new fields
- ✅ **1 Controller** updated with selectedSection
- ✅ **252 lines** added to mapper
- ✅ **17+ Document Types** supported
- ✅ **0 Critical Errors** (only 4 info warnings)

---

### 8. 🚀 الخطوات التالية

#### Phase 1.3: Split UI Components ✅ COMPLETED
- ✅ فصل AppBar widget
- ✅ فصل Tabs widget  
- ✅ فصل Actions widget
- ✅ فصل Statistics widget
- ✅ تطبيق الويدجيتات في الملف الرئيسي

#### Phase 1.4: Reduce Main File Size ✅ IN PROGRESS
- ✅ استخدام الويدجيتات المنفصلة
- ⏸️ تقليل 1750 → هدف: 300 سطر (قد يتطلب refactoring إضافي)

---

### 9. 💾 Migration Notes

⚠️ **قبل تطبيق التحديثات على قاعدة البيانات:**

1. **Backup Database**: عمل نسخة احتياطية من قاعدة البيانات
2. **Run Migrations**: تشغيل migration scripts لإضافة الحقول الجديدة
3. **Test Thoroughly**: اختبار شامل لجميع الحقول
4. **Sync Backend**: التأكد من مزامنة Backend بنفس التحديثات

```bash
# Generate Drift files
dart run build_runner build --delete-conflicting-outputs

# Test database migrations
flutter test test/database/
```

---

### 10. 📚 Resources

#### Files Location
- **Enums**: `lib/core/enums/`
- **State Management**: `lib/features/beneficiaries/presentation/pages/form/state/`
- **Business Logic**: `lib/features/beneficiaries/presentation/pages/form/logic/`
- **Database Tables**: `lib/data/db/tables/`

#### Key Commits
- `feat(database): Add missing fields to match backend structure` - 7f89418
- `refactor(mapper): Update form mapper to match Beneficiary entity` - 0f07c0b

---

## 🎉 Summary

**تم بنجاح:**
- ✅ إضافة جميع الحقول الناقصة
- ✅ محاذاة قاعدة البيانات مع Backend
- ✅ إنشاء State Management محترف
- ✅ فصل Business Logic بشكل كامل
- ✅ دعم جميع أنواع الوثائق (17+)
- ✅ دعم حقول الكفالة
- ✅ توثيق شامل

**الجاهزية:**
- ✅ Ready for UI integration
- ✅ Ready for database migration
- ✅ Ready for backend sync
- ✅ Ready for Phase 1.3 (UI Component Splitting)
