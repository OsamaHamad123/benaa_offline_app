# 🔄 تحديث قاعدة البيانات - جداول العائلة

## ✅ التغييرات المطبقة

### 1️⃣ جدول `family_deceased` (الأب/الأم المتوفى)

**الحقول الجديدة:**
- ✅ `deceasedType` - نوع المتوفى (father/mother)
- ✅ `firstName` - الاسم الأول *
- ✅ `secondName` - الاسم الثاني (اختياري)
- ✅ `thirdName` - الاسم الثالث (اختياري)
- ✅ `familyName` - اسم العائلة *
- ✅ `nationalId` - رقم الهوية *
- ✅ `deathDate` - تاريخ الوفاة * (datetime)
- ✅ `deathCause` - سبب الوفاة * (dropdown)
  - طبيعية
  - مرض
  - فجأة
  - حادث
  - أخرى
  - انتحار
  - مغدور
  - غير معروف
- ✅ `documentType` - نوع الوثيقة (شهادة وفاة / إفادة شهيد)
- ✅ `documentPath` - مسار الوثيقة المرفقة

**الحقول المحذوفة:**
- ❌ `fullName` → تم استبداله بالاسم الرباعي
- ❌ `relationship` → استبدل بـ `deceasedType`
- ❌ `gender` → يتم استنتاجه من `deceasedType`
- ❌ `ageAtDeath` → غير مطلوب

---

### 2️⃣ جدول `family_members` (أفراد الأسرة - الأيتام)

**الحقول الجديدة:**
- ✅ `orphanNationalId` - رقم هوية اليتيم *
- ✅ `firstName` - الاسم الأول *
- ✅ `secondName` - الاسم الثاني (اختياري)
- ✅ `thirdName` - الاسم الثالث (اختياري)
- ✅ `familyName` - اسم العائلة *
- ✅ `birthDate` - تاريخ الميلاد * (datetime)
- ✅ `age` - العمر (يُحسب تلقائياً)
- ✅ `gender` - الجنس * (male/female)
- ✅ `healthStatus` - الحالة الصحية * (dropdown)
  - سليم
  - مريض
  - مريض مزمن
  - معاق
  - غير معروف
- ✅ `notes` - ملاحظات (اختياري)
- ✅ `attachments` - الملفات المرفقة * (مفصولة بفاصلة)
  - صورة هوية
  - تقرير طبي
  - شهادة الميلاد
  - آخر شهادة
  - صورة شخصية
  - صورة طولية

**الحقول المحذوفة:**
- ❌ `fullName` → تم استبداله بالاسم الرباعي
- ❌ `relationship` → غير مطلوب (كلهم أيتام)
- ❌ `nationalId` → استبدل بـ `orphanNationalId`
- ❌ `maritalStatus` → غير مطلوب
- ❌ `educationLevel` → غير مطلوب
- ❌ `occupation` → غير مطلوب
- ❌ `hasDisability` → يُستنتج من `healthStatus`
- ❌ `disabilityType` → يُستنتج من `healthStatus`
- ❌ `hasChronicDisease` → يُستنتج من `healthStatus`
- ❌ `chronicDiseaseType` → يُستنتج من `healthStatus`
- ❌ `livesWithBeneficiary` → غير مطلوب
- ❌ `phone` → غير مطلوب

---

## 📋 الخطوات التالية المطلوبة

### 1. ✅ تم: تحديث جداول Drift
### 2. ✅ تم: تشغيل build_runner
### 3. ⏳ مطلوب: تحديث DAOs
### 4. ⏳ مطلوب: تحديث Forms
### 5. ⏳ مطلوب: تحديث Backend (MySQL + PHP)
### 6. ⏳ مطلوب: تحديث المزامنة

---

## 🎯 الملفات التي تحتاج تحديث

1. `lib/data/db/daos/family_deceased_dao.dart` - تعديل queries
2. `lib/data/db/daos/family_members_dao.dart` - تعديل queries
3. `lib/features/beneficiaries/presentation/widgets/family_deceased_form.dart` - نموذج جديد
4. `lib/features/beneficiaries/presentation/widgets/family_members_form.dart` - نموذج جديد
5. `backend_php/database_setup.sql` - تحديث schema
6. `backend_php/sync.php` - تحديث معالجة البيانات

---

## 💡 ملاحظات مهمة

1. **رقم الهوية** في family_deceased هو رقم هوية المتوفى (الأب/الأم)
2. **orphanNationalId** في family_members هو رقم هوية اليتيم
3. **الملفات المرفقة** ستُحفظ في جدول `attachments` منفصل
4. **الحالة الصحية** مهمة لتحديد الحالات الخاصة (إعاقة، مرض مزمن)
