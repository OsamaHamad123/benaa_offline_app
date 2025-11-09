# خطة تطوير تطبيق Benaa Offline
## نظرة عامة على المشروع

### الهدف الرئيسي
تطوير تطبيق موبايل/تابلت للعمل بدون انترنت لتسجيل بيانات المستفيدين (الأيتام) خلال الزيارات الميدانية، مع إمكانية المزامنة مع السيرفر عند توفر الانترنت.

### المتطلبات الأساسية
- ✅ العمل بشكل كامل بدون انترنت (Offline-First)
- ✅ تخزين السجل المدني محلياً (17GB)
- ✅ بحث سريع في السجل المدني
- ✅ مزامنة ذكية مع السيرفر
- ✅ التشفير والأمان
- ✅ دعم التابلت (1TB storage)

---

## 🏗️ الهيكلية المقترحة

### قواعد البيانات المحلية

#### 1. قاعدة البيانات الرئيسية (app.db)
**الجداول التي يتم التعديل عليها:**

```sql
-- المستفيدين (Beneficiaries)
CREATE TABLE beneficiaries (
  id TEXT PRIMARY KEY,
  full_name TEXT NOT NULL,
  full_name_norm TEXT NOT NULL, -- للبحث
  national_id TEXT NOT NULL UNIQUE,
  file_no TEXT NOT NULL UNIQUE,
  governorate TEXT NOT NULL,
  gender TEXT NOT NULL,
  category TEXT NOT NULL,
  birth_date DATETIME,
  notes TEXT,
  association_name TEXT,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  sync_state TEXT DEFAULT 'pending', -- pending/synced/failed
  server_id TEXT, -- ID من السيرفر بعد المزامنة
  last_synced_at DATETIME
);

-- الزيارات (Visits)
CREATE TABLE visits (
  id TEXT PRIMARY KEY,
  beneficiary_id TEXT NOT NULL,
  visit_date DATETIME NOT NULL,
  staff_name TEXT NOT NULL,
  notes TEXT,
  is_submitted BOOLEAN DEFAULT 0,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  sync_state TEXT DEFAULT 'pending',
  server_id TEXT,
  FOREIGN KEY (beneficiary_id) REFERENCES beneficiaries(id)
);

-- المرفقات (Attachments)
CREATE TABLE attachments (
  id TEXT PRIMARY KEY,
  beneficiary_id TEXT NOT NULL,
  visit_id TEXT,
  type TEXT NOT NULL, -- image/pdf/document
  path TEXT NOT NULL, -- مسار الملف المحلي
  hash TEXT NOT NULL, -- للتحقق من التكرار
  size INTEGER NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  sync_state TEXT DEFAULT 'pending',
  server_url TEXT, -- URL بعد الرفع
  FOREIGN KEY (beneficiary_id) REFERENCES beneficiaries(id)
);

-- طابور المزامنة (Sync Queue)
CREATE TABLE sync_queue (
  id TEXT PRIMARY KEY,
  entity TEXT NOT NULL, -- beneficiary/visit/attachment
  entity_id TEXT NOT NULL,
  operation TEXT NOT NULL, -- create/update/delete/upload
  payload TEXT NOT NULL, -- JSON
  priority INTEGER DEFAULT 0, -- أعلى رقم = أولوية أعلى
  attempts INTEGER DEFAULT 0,
  last_error TEXT,
  created_at DATETIME NOT NULL,
  scheduled_at DATETIME, -- للمزامنة المجدولة
  INDEX idx_priority (priority DESC, created_at ASC)
);
```

#### 2. قاعدة بيانات التصنيفات (taxonomies.db)
**للقوائم المنسدلة - تحدث من السيرفر:**

```sql
CREATE TABLE taxonomies (
  id TEXT PRIMARY KEY,
  group TEXT NOT NULL, -- governorate/category/gender/etc
  code TEXT NOT NULL,
  label TEXT NOT NULL,
  parent_id TEXT, -- للتصنيفات الهرمية
  is_active BOOLEAN DEFAULT 1,
  sort_order INTEGER DEFAULT 0,
  updated_at DATETIME NOT NULL,
  UNIQUE(group, code)
);

CREATE INDEX idx_taxonomy_group ON taxonomies(group, is_active);
```

#### 3. قاعدة السجل المدني (civil_registry.db) - 17GB
**للقراءة فقط - ملف منفصل:**

```sql
CREATE TABLE civil_registry (
  national_id TEXT PRIMARY KEY,
  file_no TEXT NOT NULL,
  full_name_norm TEXT NOT NULL, -- منسق للبحث
  full_name_raw TEXT NOT NULL, -- الاسم الأصلي
  governorate TEXT NOT NULL,
  district TEXT,
  birth_date TEXT,
  father_name TEXT,
  mother_name TEXT,
  address TEXT,
  -- إضافة أي حقول أخرى من السجل
  
  -- Indexes للبحث السريع
);

-- Indexes مهمة جداً للبحث السريع
CREATE INDEX idx_civil_national ON civil_registry(national_id);
CREATE INDEX idx_civil_file ON civil_registry(file_no);
CREATE INDEX idx_civil_name ON civil_registry(full_name_norm);
CREATE INDEX idx_civil_governorate ON civil_registry(governorate);
CREATE INDEX idx_civil_composite ON civil_registry(governorate, full_name_norm);

-- Full Text Search للبحث المتقدم
CREATE VIRTUAL TABLE civil_registry_fts USING fts5(
  full_name_norm,
  national_id,
  file_no,
  content=civil_registry
);
```

---

## 🔄 استراتيجية المزامنة

### نظام الأولويات (Priority System)

```
Priority 10: Authentication & User Data
Priority 9:  Beneficiaries (Create/Update)
Priority 8:  Visits Data
Priority 7:  Attachments Upload
Priority 6:  Taxonomies Sync (Download)
Priority 5:  Civil Registry Updates
```

### خوارزمية المزامنة الذكية

```dart
// 1. التحقق من الاتصال
if (!hasInternet) return;

// 2. مزامنة التصنيفات أولاً (إذا كانت قديمة)
if (taxonomiesNeedUpdate) {
  await syncTaxonomies();
}

// 3. مزامنة البيانات حسب الأولوية
final queue = await getSyncQueue(orderBy: 'priority DESC, created_at ASC');

for (final item in queue) {
  try {
    switch (item.entity) {
      case 'beneficiary':
        await syncBeneficiary(item);
      case 'visit':
        await syncVisit(item);
      case 'attachment':
        await uploadAttachment(item);
    }
    
    // تحديث حالة المزامنة
    await markAsSynced(item.id);
    
  } catch (e) {
    // تسجيل الخطأ وإعادة المحاولة لاحقاً
    await updateSyncError(item.id, e.toString());
    
    // إعادة الجدولة بعد فترة
    if (item.attempts < 3) {
      await rescheduleSync(item.id, delayMinutes: item.attempts * 5);
    }
  }
}

// 4. مزامنة التحديثات من السيرفر (Pull)
await pullServerUpdates();
```

### معالجة التعارضات (Conflict Resolution)

```dart
enum ConflictStrategy {
  serverWins,    // السيرفر يفوز دائماً
  clientWins,    // الجهاز يفوز دائماً
  lastWriteWins, // آخر تعديل يفوز (حسب timestamp)
  manual,        // يطلب من المستخدم الاختيار
}

// استراتيجية مقترحة
final strategy = {
  'beneficiary': ConflictStrategy.lastWriteWins,
  'visit': ConflictStrategy.clientWins, // البيانات الميدانية أهم
  'attachment': ConflictStrategy.clientWins,
  'taxonomy': ConflictStrategy.serverWins, // السيرفر مصدر الحقيقة
};
```

---

## 🔍 نظام البحث في السجل المدني

### استراتيجيات البحث

#### 1. البحث السريع (Fast Lookup)
```dart
// البحث بالرقم الوطني - O(1)
Future<CivilRecord?> searchByNationalId(String nationalId) async {
  return await (select(civilRegistry)
    ..where((r) => r.nationalId.equals(nationalId)))
    .getSingleOrNull();
}

// البحث برقم الملف - O(1)
Future<CivilRecord?> searchByFileNo(String fileNo) async {
  return await (select(civilRegistry)
    ..where((r) => r.fileNo.equals(fileNo)))
    .getSingleOrNull();
}
```

#### 2. البحث بالاسم (Name Search)
```dart
// البحث باستخدام LIKE مع index
Future<List<CivilRecord>> searchByName(String name, {
  String? governorate,
  int limit = 50,
}) async {
  final normalized = normalizeName(name);
  
  var query = select(civilRegistry)
    ..where((r) => r.fullNameNorm.like('%$normalized%'));
  
  if (governorate != null) {
    query = query..where((r) => r.governorate.equals(governorate));
  }
  
  return await (query
    ..limit(limit)
    ..orderBy([(r) => OrderingTerm.asc(r.fullNameNorm)]))
    .get();
}
```

#### 3. البحث المتقدم (Full-Text Search)
```dart
// استخدام FTS5 للبحث المتقدم
Future<List<CivilRecord>> advancedSearch(String searchTerm) async {
  return await customSelect(
    '''
    SELECT c.* FROM civil_registry c
    JOIN civil_registry_fts fts ON c.national_id = fts.national_id
    WHERE fts MATCH ?
    ORDER BY rank
    LIMIT 50
    ''',
    variables: [Variable.withString(searchTerm)],
  ).map((row) => civilRegistry.map(row.data)).get();
}
```

#### 4. تطبيع النصوص للبحث
```dart
String normalizeName(String name) {
  return name
    .toLowerCase()
    .trim()
    // إزالة الحركات
    .replaceAll(RegExp(r'[\u064B-\u065F]'), '')
    // توحيد الهمزات
    .replaceAll(RegExp(r'[إأآ]'), 'ا')
    .replaceAll('ة', 'ه')
    // إزالة المسافات الزائدة
    .replaceAll(RegExp(r'\s+'), ' ');
}
```

---

## 📱 واجهة البحث في السجل المدني

### ميزات مقترحة:

1. **بحث ذكي متعدد المعايير:**
   - الرقم الوطني
   - رقم الملف
   - الاسم الكامل
   - المحافظة
   - مدينة/منطقة

2. **نتائج فورية (Live Search)**
   - نتائج أثناء الكتابة
   - تحديد عدد النتائج (50 بشكل افتراضي)

3. **تصفية متقدمة:**
   - حسب المحافظة
   - حسب نطاق تاريخ الميلاد
   - ترتيب النتائج

4. **ربط سريع:**
   - زر "استخدام البيانات" لنسخ المعلومات إلى نموذج إضافة مستفيد

---

## 🔐 الأمان والتشفير

### البيانات المشفرة:
- ✅ قاعدة البيانات الرئيسية (app.db) - SQLCipher
- ✅ المرفقات المحلية
- ✅ Tokens في SecureStorage

### البيانات غير المشفرة:
- Civil Registry (للسرعة - 17GB)
- Taxonomies (بيانات عامة)

---

## 📊 MVP - النسخة الأولية

### الميزات الأساسية:

#### ✅ Phase 1 - الأساسيات
1. **Auth:**
   - تسجيل الدخول
   - حفظ Token
   - Auto-login

2. **إضافة مستفيد:**
   - النموذج الكامل
   - التحقق من البيانات
   - الحفظ المحلي

3. **البحث في السجل المدني:**
   - بحث بالرقم الوطني
   - بحث بالاسم
   - عرض النتائج

4. **التصنيفات:**
   - تحميل من السيرفر
   - التخزين المحلي
   - التحديث التلقائي

#### ⏳ Phase 2 - التحسينات
5. **المزامنة:**
   - رفع المستفيدين
   - نظام الطابور
   - معالجة الأخطاء

6. **الزيارات:**
   - إضافة زيارة
   - ربطها بالمستفيد
   - ملاحظات الزيارة

7. **المرفقات:**
   - التقاط الصور
   - رفع الملفات
   - الضغط والتحسين

---

## 🛠️ التعديلات المطلوبة على الكود الحالي

### 1. إعادة هيكلة قاعدة البيانات
### 2. إضافة نظام المزامنة المتقدم
### 3. تحسين البحث في السجل المدني
### 4. إضافة إدارة التصنيفات
### 5. تحسين UI/UX للعمل الميداني

---

## 📝 ملاحظات مهمة

1. **حجم السجل المدني (17GB):**
   - يجب ضغطه قبل التوزيع
   - استخدام indexes بذكاء
   - عدم نسخه في backup التلقائي

2. **سرعة البحث:**
   - استخدام FTS5 للبحث النصي
   - Indexes مركبة للاستعلامات الشائعة
   - Caching للنتائج المكررة

3. **إدارة المساحة:**
   - حذف الصور القديمة بعد المزامنة (اختياري)
   - ضغط الصور قبل الحفظ
   - مراقبة المساحة المتاحة

4. **تجربة المستخدم:**
   - العمل السريع بدون انتظار
   - مؤشرات واضحة للمزامنة
   - معالجة الأخطاء برسائل مفهومة

هل نبدأ بتطبيق هذه التعديلات؟
