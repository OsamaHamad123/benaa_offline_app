# ملخص التحديثات - Database Schema v2 + Sync System

## التاريخ: ${DateTime.now().toString().split('.')[0]}

## التحديثات المنجزة ✅

### 1. تحديث Database Schema (v1 → v2)

#### الأعمدة الجديدة:

**Beneficiaries Table:**
- `server_id`: معرف السجل على السيرفر بعد المزامنة
- `last_synced_at`: آخر مرة تمت فيها المزامنة

**Visits Table:**
- `server_id`: معرف السجل على السيرفر
- `last_synced_at`: آخر مرة تمت فيها المزامنة

**Attachments Table:**
- `server_url`: رابط المرفق على السيرفر بعد الرفع
- `last_synced_at`: آخر مرة تمت فيها المزامنة

**Taxonomies Table:**
- `parent_id`: لدعم التصنيفات الهرمية
- `sort_order`: ترتيب عرض التصنيفات

**SyncQueue Table:**
- `priority`: أولوية المزامنة (10=Auth, 9=Beneficiary, 8=Visit, 7=Attachment)
- `scheduled_at`: موعد إعادة المحاولة (exponential backoff)

**CivilRegistry Table:**
- `district`: المنطقة/القضاء
- `birth_date`: تاريخ الميلاد
- `father_name`: اسم الأب
- `mother_name`: اسم الأم
- `address`: العنوان

#### Indexes للأداء:

```sql
-- Beneficiaries
idx_beneficiary_national    -- national_id
idx_beneficiary_file        -- file_no
idx_beneficiary_sync        -- sync_state
idx_beneficiary_server      -- server_id

-- Visits
idx_visit_beneficiary       -- beneficiary_id
idx_visit_sync              -- sync_state

-- Attachments
idx_attachment_beneficiary  -- beneficiary_id
idx_attachment_sync         -- sync_state

-- Taxonomies
idx_taxonomy_group          -- group, code
idx_taxonomy_active         -- group, is_active

-- Sync Queue
idx_sync_queue_priority     -- priority DESC, created_at ASC
idx_sync_queue_entity       -- entity, entity_id

-- Civil Registry (مهم جداً للبحث السريع)
idx_civil_national          -- national_id
idx_civil_file              -- file_no
idx_civil_name              -- full_name_norm
idx_civil_governorate       -- governorate
idx_civil_composite         -- governorate, full_name_norm
```

#### Helper Methods جديدة:

**Civil Registry:**
- `searchCivilByNationalId(String nationalId)`
- `searchCivilByFileNo(String fileNo)`
- `searchCivilByName(String name, {String? governorate, int limit})`

**Sync Queue:**
- `addToSyncQueue(SyncQueueCompanion item)`
- `getSyncQueue({int limit})`
- `removeFromSyncQueue(String id)`
- `updateSyncQueueError(String id, String error, int attempts)`

**Taxonomies:**
- `getTaxonomiesByGroup(String group)`
- `syncTaxonomies(List<TaxonomiesCompanion> items)`

**Utilities:**
- `_normalizeName(String name)`: تطبيع الأسماء العربية للبحث

### 2. نظام المزامنة (Sync System)

#### الملفات المنشأة:

1. **lib/core/sync/sync_manager.dart**
   - `SyncManager`: مدير المزامنة الرئيسي
   - `SyncStatus`: حالة المزامنة
   - `SyncPriority`: أولويات المزامنة
   - Providers: `syncManagerProvider`, `syncStatusProvider`

2. **lib/features/sync/sync_widgets.dart**
   - `SyncStatusBar`: شريط عرض حالة المزامنة
   - `SyncButton`: زر المزامنة اليدوية
   - `SyncDetailsPage`: شاشة تفاصيل المزامنة

3. **SYNC_SYSTEM.md**
   - توثيق كامل لنظام المزامنة
   - أمثلة الاستخدام
   - سيناريوهات العمل
   - Best practices

#### الميزات:

✅ **مزامنة تلقائية**: كل 5 دقائق عند توفر الإنترنت  
✅ **مزامنة يدوية**: زر في واجهة المستخدم  
✅ **أولويات ذكية**: Auth > Beneficiary > Visit > Attachment  
✅ **معالجة الأخطاء**: Exponential backoff  
✅ **مراقبة الحالة**: Real-time status updates  
✅ **UI Feedback**: Progress bars, error messages  

#### كيفية الاستخدام:

```dart
// 1. إضافة للطابور
await syncManager.queueBeneficiary(
  beneficiaryId,
  'create',
  beneficiary.toJson(),
);

// 2. مزامنة يدوية
await syncManager.syncAll();

// 3. مراقبة الحالة
final status = ref.watch(syncStatusProvider);

// 4. عرض في UI
SyncStatusBar()  // في أعلى الشاشة
SyncButton()     // في AppBar
```

### 3. Migration Strategy

#### onCreate:
- إنشاء جميع الجداول
- إنشاء جميع الـ indexes
- إنشاء FTS5 table للبحث
- إنشاء Triggers لتحديث FTS

#### onUpgrade (v1 → v2):
- إضافة الأعمدة الجديدة لجميع الجداول
- إعادة إنشاء الـ indexes

### 4. الملفات المعدلة

```
lib/data/db/drift_database.dart          ✅ محدث
lib/core/sync/sync_manager.dart          ✅ جديد
lib/features/sync/sync_widgets.dart      ✅ جديد
SYNC_SYSTEM.md                           ✅ جديد
```

## الخطوات التالية 📋

### 1. إكمال API Integration (عالية الأولوية)

```dart
// في sync_manager.dart
Future<void> _syncBeneficiary(...) async {
  final response = await apiClient.post('/beneficiaries', data);
  final serverId = response.data['id'];
  
  // Update local record
  await db.customStatement(
    'UPDATE beneficiaries SET server_id = ?, last_synced_at = ?, sync_state = ? WHERE id = ?',
    [serverId, DateTime.now(), 'synced', id],
  );
}
```

### 2. تحديث UI لاستخدام Sync System

**Dashboard:**
```dart
// إضافة SyncStatusBar
Column(
  children: [
    SyncStatusBar(),
    // ... existing content
  ],
)
```

**AppBar:**
```dart
actions: [
  SyncButton(),
  // ... existing actions
],
```

### 3. Conflict Resolution

```dart
// عند تعارض البيانات
enum ConflictStrategy {
  serverWins,    // السيرفر يفوز
  clientWins,    // الجهاز يفوز
  lastWriteWins, // آخر تعديل يفوز
  manual,        // يدوي (يسأل المستخدم)
}
```

### 4. Background Sync

```dart
// Android: WorkManager
// iOS: Background Fetch
// Web: Service Workers
```

### 5. Civil Registry Integration

```dart
// تحميل قاعدة السجل المدني (17GB)
// استخدام attached database
await db.customStatement(
  "ATTACH DATABASE ? AS civil_registry",
  [civilRegistryDbPath],
);
```

### 6. FTS5 for Civil Registry

```sql
CREATE VIRTUAL TABLE civil_registry_fts USING fts5(
  full_name_norm,
  national_id,
  file_no,
  content='civil_registry',
  tokenize='unicode61'
);
```

### 7. Testing

```dart
// Unit Tests
test('sync queue priority order', () {...});
test('exponential backoff', () {...});

// Integration Tests
testWidgets('sync progress shown', () {...});

// E2E Tests
scenario('offline to online sync', () {...});
```

## الأداء المتوقع 🚀

### Database:
- Schema version: **2**
- Tables: **6**
- Indexes: **16**
- FTS5 tables: **1** (+ civil registry later)

### Sync:
- Auto sync interval: **5 minutes**
- Batch size: **100 items**
- Max retry attempts: **3**
- Backoff multiplier: **5 minutes × attempts**

### Search Performance:
- Beneficiaries search: **< 50ms** (with indexes)
- Civil registry search: **< 200ms** (17GB, with FTS5)
- Composite search: **< 100ms** (governorate + name)

## ملاحظات مهمة ⚠️

1. **Database Migration**: التطبيق سيقوم تلقائياً بترقية قاعدة البيانات من v1 إلى v2 عند أول تشغيل
2. **Existing Data**: البيانات الموجودة ستبقى، فقط ستضاف الأعمدة الجديدة
3. **Sync State**: جميع السجلات الحالية ستكون بحالة `pending` للمزامنة
4. **Network Required**: المزامنة تتطلب اتصال إنترنت نشط
5. **Auto Sync**: يمكن تعطيلها إذا لزم الأمر

## الأخطاء المحتملة وحلولها 🔧

### خطأ: "Database schema mismatch"
**الحل**: حذف قاعدة البيانات القديمة وإعادة التثبيت (للتطوير فقط)

### خطأ: "Sync queue overflow"
**الحل**: زيادة batch size أو تقليل auto sync interval

### خطأ: "Civil registry not found"
**الحل**: التأكد من وجود ملف السجل المدني وصلاحيات القراءة

## الخلاصة 🎯

تم بنجاح:
- ✅ تحديث Database Schema إلى v2
- ✅ إضافة نظام مزامنة كامل
- ✅ دعم العمل offline-first
- ✅ Priority-based sync queue
- ✅ UI components للمزامنة
- ✅ توثيق شامل

الخطوة التالية: **ربط نظام المزامنة مع Backend API**
