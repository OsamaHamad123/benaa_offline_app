# 📱 Mobile Sync Implementation - تطبيق المزامنة مع Mobile API

## ✅ What Was Implemented (ما تم تنفيذه)

تم تطبيق نظام مزامنة **مؤقت** للبيانات مع Mobile Sync API الموجود على السيرفر.

### 📦 الملفات الجديدة:

1. **`lib/core/sync/mobile_sync_service.dart`** (459 lines)
   - Service للمزامنة مع Mobile Sync API
   - يدعم Sync Down (تنزيل البيانات)
   - يدعم Sync Up (رفع التغييرات)
   - Pagination support (100 records/page)
   - Progress tracking with Stream
   - Error handling and retry logic

2. **`lib/core/mappers/beneficiary_sync_mapper.dart`** (132 lines)
   - تحويل بين Drift model والـ backend JSON
   - `fromBackend()` - تحويل من JSON إلى Companion
   - `toBackend()` - تحويل من Beneficiary إلى JSON
   - Helper methods للـ normalization و parsing

3. **`lib/features/sync/mobile_sync_page.dart`** (380 lines)
   - واجهة مستخدم كاملة للمزامنة
   - زر Sync Down + زر Sync Up
   - Progress indicator
   - Status display
   - Result card with success/failure
   - Warning card للقيود الموجودة

### 🔧 الملفات المعدلة:

1. **`lib/routing/app_router.dart`**
   - أضفنا route جديد: `/mobile-sync`
   - Route accessible من أي مكان في التطبيق

2. **`lib/features/dashboard/presentation/pages/dashboard_page.dart`**
   - استبدال SyncPage بـ MobileSyncPage في bottom navigation
   - الآن تاب "المزامنة" يفتح الصفحة الجديدة

---

## 🚀 How to Use (كيفية الاستخدام)

### 1. فتح صفحة المزامنة

**من Bottom Navigation:**
- اضغط على "المزامنة" (ثاني تاب)

**من أي مكان:**
```dart
context.push('/mobile-sync');
```

### 2. تنزيل البيانات (Sync Down)

1. اضغط على زر "تنزيل البيانات من السيرفر" (الأزرق)
2. انتظر حتى ينتهي التحميل
3. سترى progress bar مع النسبة المئوية
4. عند الانتهاء: رسالة "تم تنزيل X مستفيد بنجاح"

**ماذا يحدث:**
- يجلب البيانات من `sy_benaa_application` table
- Pagination automatic (100 records/page)
- يحفظها في قاعدة البيانات المحلية
- إذا السجل موجود → يتم التحديث
- إذا جديد → يتم الإضافة

### 3. رفع التغييرات (Sync Up)

1. اضغط على زر "رفع التغييرات للسيرفر" (الأخضر)
2. انتظر حتى ينتهي الرفع
3. سترى progress bar
4. عند الانتهاء: رسالة "تم رفع X سجل"

**ماذا يحدث:**
- يجلب كل السجلات بحالة `pending` أو `modified`
- للسجلات الموجودة: يستخدم PUT (update)
- للسجلات الجديدة: يستخدم POST (create)
- عند النجاح: يتم تحديث الحالة إلى `synced`
- يحفظ serverId المستلم من الـ API

---

## ⚠️ Limitations (القيود المؤقتة)

### 🔴 Critical Limitations:

1. **No Authentication**
   - API بدون Bearer Token
   - أي شخص يمكنه الوصول للبيانات
   - **حل مؤقت:** استخدمه فقط للتطوير/اختبار

2. **No File Upload**
   - المرفقات (PDF, images) لا تتزامن
   - فقط البيانات النصية
   - **حل مؤقت:** رفع الملفات يدوياً أو انتظار endpoint جديد

3. **Server-Wins Conflict Resolution**
   - في حالة التعارض، بيانات السيرفر تفوز
   - لا يوجد merge أو user choice
   - **حل مؤقت:** تأكد من المزامنة المنتظمة

4. **No Soft Delete Tracking**
   - السجلات المحذوفة لا تتزامن
   - **حل مؤقت:** لا تحذف سجلات مهمة قبل المزامنة

### 🟡 Other Limitations:

- `fullName` is auto-computed field (لا يمكن إدخاله مباشرة)
- `idNumber`, `phoneNumber`, `altPhoneNumber` يجب أن تكون integers
- Taxonomy IDs (province, gender, relationship) must match server values
- No retry mechanism for failed uploads (manual retry required)

---

## 🔌 API Integration Details

### Base URL:
```
https://palestine.benaadev.org
```

### Database:
```
u983550065_sy_test
```

### Table:
```
sy_benaa_application
```

### Endpoints Used:

#### 1. Database Info
```http
GET /api/mobile-sync/database/info?database=u983550065_sy_test
```

#### 2. Table List
```http
GET /api/mobile-sync/database/tables?database=u983550065_sy_test
```

#### 3. Fetch Data (with Pagination)
```http
GET /api/mobile-sync/fetch?table=sy_benaa_application&database=u983550065_sy_test&page=1&per_page=100
```

**Response:**
```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "current_page": 1,
    "last_page": 5,
    "total": 500
  }
}
```

#### 4. Create Record
```http
POST /api/mobile-sync/create
Content-Type: application/json

{
  "table": "sy_benaa_application",
  "database": "u983550065_sy_test",
  "data": { ... }
}
```

**Response:**
```json
{
  "success": true,
  "id": 123
}
```

#### 5. Update Record
```http
PUT /api/mobile-sync/update
Content-Type: application/json

{
  "table": "sy_benaa_application",
  "database": "u983550065_sy_test",
  "id": 123,
  "data": { ... }
}
```

---

## 📊 Data Mapping (Backend ↔ Local)

### Backend JSON Fields → Local Drift Fields:

```dart
// IDs
'id' → serverId (int)
'file_id_number' → fileIdNumber (String)
'data_id_number' → idNumber (int)

// Name Parts
'data_first_name' → firstName (String)
'data_father_name' → fatherName (String)
'data_grand_father_name' → grandFatherName (String)
'data_family_name' → familyName (String)
// Note: fullName is auto-computed from above 4 fields

// Contact
'data_phone_number' → phoneNumber (int)
'data_alt_phone_number' → altPhoneNumber (int)

// Location
'data_governorate' → province (int) // Taxonomy ID

// Demographics
'data_gender' → gender (int) // Taxonomy ID
'data_family_type' → relationship (int) // Taxonomy ID

// Metadata
'created_at' → createdAt (DateTime)
'updated_at' → updatedAt (DateTime)
```

---

## 🧪 Testing

### Manual Testing Steps:

1. **Test Sync Down:**
   ```
   1. Open Mobile Sync Page
   2. Press "تنزيل البيانات من السيرفر"
   3. Wait for completion
   4. Check database for new records
   5. Verify serverId is populated
   ```

2. **Test Sync Up:**
   ```
   1. Create a new beneficiary locally
   2. Set syncState to 'pending'
   3. Open Mobile Sync Page
   4. Press "رفع التغييرات للسيرفر"
   5. Check if serverId is updated
   6. Check if syncState changed to 'synced'
   ```

3. **Test Update:**
   ```
   1. Modify existing beneficiary with serverId
   2. Set syncState to 'modified'
   3. Sync Up
   4. Verify update on server
   ```

### Error Scenarios:

- ❌ **No Internet:** Shows error toast
- ❌ **Server Error:** Shows error in status card
- ❌ **Invalid Data:** Skips record, continues with next

---

## 🎯 Next Steps (للتحسين لاحقاً)

### High Priority:

1. **Add Authentication**
   - Implement Bearer Token in headers
   - Store token securely
   - Handle token refresh

2. **File Upload Support**
   - Create endpoint for file upload
   - Implement chunked upload for large files
   - Store file URLs in beneficiary record

3. **Conflict Resolution**
   - Add `last_modified_timestamp` to records
   - Implement 3-way merge
   - Show conflict resolution UI to user

4. **Soft Delete Tracking**
   - Add `deleted_at` column
   - Sync deleted records
   - Handle deleted records on server

### Medium Priority:

5. **Retry Mechanism**
   - Auto-retry failed uploads (exponential backoff)
   - Queue failed records
   - Resume sync after network error

6. **Selective Sync**
   - Allow user to choose what to sync
   - Filter by date range, category, etc.

7. **Background Sync**
   - Use WorkManager for periodic sync
   - Sync when connected to WiFi
   - Show notification on completion

### Low Priority:

8. **Sync Analytics**
   - Track sync success/failure rate
   - Monitor sync duration
   - Send to analytics dashboard

9. **Sync History**
   - Store sync sessions in database
   - Show history to user
   - Allow rollback to previous sync

---

## 📝 Code Structure

```
lib/
├── core/
│   ├── sync/
│   │   └── mobile_sync_service.dart      ← Main sync logic
│   └── mappers/
│       └── beneficiary_sync_mapper.dart   ← Data conversion
│
├── features/
│   ├── sync/
│   │   └── mobile_sync_page.dart          ← UI for sync
│   └── dashboard/
│       └── presentation/
│           └── pages/
│               └── dashboard_page.dart     ← Updated with MobileSyncPage
│
└── routing/
    └── app_router.dart                     ← Added /mobile-sync route
```

---

## ✅ Summary (الملخص)

**تم بنجاح:**
- ✅ نظام مزامنة كامل (Sync Down + Sync Up)
- ✅ واجهة مستخدم سهلة وواضحة
- ✅ Pagination للبيانات الكبيرة
- ✅ Progress tracking real-time
- ✅ Error handling شامل
- ✅ Data mapping صحيح

**القيود الحالية:**
- ⚠️ No authentication (use for dev/test only)
- ⚠️ No file upload
- ⚠️ Server-wins conflicts
- ⚠️ No soft delete tracking

**الاستخدام:**
- 📱 من Dashboard → تاب "المزامنة"
- 📱 من أي مكان → `context.push('/mobile-sync')`

**الخطوة التالية:**
- 🔐 إضافة Authentication
- 📁 دعم رفع الملفات
- ⚔️ حل التعارضات بشكل أفضل

---

**Status:** ✅ **Ready for Testing**

يمكنك الآن تجربة المزامنة مع السيرفر الموجود! 🎉
