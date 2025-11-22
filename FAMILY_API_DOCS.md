# Family API Documentation - للمبرمج Backend

## نظرة عامة (Overview)

تم تحديث نظام العائلة ليدعم تتبع الأيتام بشكل متخصص. الآن:
- **family_deceased**: تتبع الوالدين المتوفين فقط (الأب/الأم)
- **family_members**: تتبع الأيتام فقط مع مرفقاتهم الطبية والشخصية

---

## 1️⃣ جدول family_deceased

### البنية الجديدة (New Schema)

```sql
CREATE TABLE family_deceased (
    id INT AUTO_INCREMENT PRIMARY KEY,
    beneficiary_id INT NOT NULL,
    deceased_type VARCHAR(10) NOT NULL,        -- NEW: 'father' or 'mother'
    first_name VARCHAR(100) NOT NULL,          -- NEW
    second_name VARCHAR(100),                  -- NEW
    third_name VARCHAR(100),                   -- NEW
    family_name VARCHAR(100) NOT NULL,         -- NEW
    national_id VARCHAR(9) NOT NULL,           -- NEW (required, 9 digits)
    death_date DATETIME NOT NULL,              -- MODIFIED: now required
    death_cause VARCHAR(255) NOT NULL,         -- MODIFIED: now required
    document_type VARCHAR(50),                 -- NEW: 'شهادة وفاة' or 'إفادة شهيد'
    document_path VARCHAR(500),                -- NEW
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (beneficiary_id) REFERENCES beneficiaries(id),
    INDEX idx_deceased_type (deceased_type),
    INDEX idx_national_id (national_id)
);
```

### الحقول المحذوفة (Removed Fields)
- ❌ `full_name` → استبدل بـ `first_name`, `second_name`, `third_name`, `family_name`
- ❌ `relationship` → استبدل بـ `deceased_type` (father/mother فقط)
- ❌ `gender` → غير مطلوب (يُستنتج من `deceased_type`)
- ❌ `age_at_death` → غير مطلوب

### القيم المقبولة (Accepted Values)

#### deceased_type
- `father` (أب)
- `mother` (أم)

#### death_cause (أسباب الوفاة)
- `طبيعية`
- `مرض`
- `فجأة`
- `حادث`
- `أخرى`
- `انتحار`
- `مغدور`
- `غير معروف`

#### document_type
- `شهادة وفاة`
- `إفادة شهيد`
- `NULL` (اختياري)

### مثال JSON للإرسال (POST Example)

```json
{
  "beneficiary_id": 123,
  "deceased_type": "father",
  "first_name": "محمد",
  "second_name": "أحمد",
  "third_name": "علي",
  "family_name": "الفلسطيني",
  "national_id": "123456789",
  "death_date": "2023-10-07T00:00:00",
  "death_cause": "مغدور",
  "document_type": "إفادة شهيد",
  "document_path": "/uploads/documents/شهادة_شهيد_123.pdf",
  "notes": "استشهد في العدوان على غزة"
}
```

### مثال JSON للاستقبال (GET Response)

```json
{
  "id": 456,
  "beneficiary_id": 123,
  "deceased_type": "mother",
  "first_name": "فاطمة",
  "second_name": "محمود",
  "third_name": "خالد",
  "family_name": "الفلسطيني",
  "national_id": "987654321",
  "death_date": "2024-01-15T00:00:00",
  "death_cause": "مرض",
  "document_type": "شهادة وفاة",
  "document_path": "/uploads/documents/death_cert_456.pdf",
  "notes": "مرض السرطان",
  "created_at": "2024-01-20T10:30:00",
  "updated_at": "2024-01-20T10:30:00"
}
```

---

## 2️⃣ جدول family_members

### البنية الجديدة (New Schema)

```sql
CREATE TABLE family_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    beneficiary_id INT NOT NULL,
    orphan_national_id VARCHAR(9) NOT NULL,    -- NEW (required, 9 digits)
    first_name VARCHAR(100) NOT NULL,          -- NEW
    second_name VARCHAR(100),                  -- NEW
    third_name VARCHAR(100),                   -- NEW
    family_name VARCHAR(100) NOT NULL,         -- NEW
    birth_date DATE NOT NULL,                  -- MODIFIED: now required
    age INT,                                   -- AUTO-CALCULATED from birth_date
    gender VARCHAR(10) NOT NULL,               -- male/female
    health_status VARCHAR(50) NOT NULL,        -- NEW: enum values
    attachments TEXT,                          -- NEW: comma-separated file paths
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (beneficiary_id) REFERENCES beneficiaries(id),
    INDEX idx_orphan_national_id (orphan_national_id),
    INDEX idx_health_status (health_status)
);
```

### الحقول المحذوفة (Removed Fields - 12 حقل)
- ❌ `full_name` → استبدل بـ 4 حقول منفصلة
- ❌ `relationship` → غير مطلوب (كلهم أيتام)
- ❌ `national_id` → استبدل بـ `orphan_national_id`
- ❌ `marital_status` → غير مطلوب
- ❌ `education_level` → غير مطلوب
- ❌ `occupation` → غير مطلوب
- ❌ `has_disability` → استبدل بـ `health_status`
- ❌ `disability_type` → استبدل بـ `health_status`
- ❌ `has_chronic_disease` → استبدل بـ `health_status`
- ❌ `chronic_disease_type` → استبدل بـ `health_status`
- ❌ `lives_with_beneficiary` → غير مطلوب
- ❌ `phone` → غير مطلوب

### القيم المقبولة (Accepted Values)

#### gender
- `male` (ذكر)
- `female` (أنثى)

#### health_status (الحالة الصحية)
- `سليم` - صحة جيدة
- `مريض` - مريض حالياً
- `مريض مزمن` - مرض مزمن
- `معاق` - إعاقة
- `غير معروف` - غير معروف

#### attachments (المرفقات المطلوبة - 6 ملفات)
مسارات مفصولة بفواصل:
1. صورة هوية (national_id_image)
2. تقرير طبي (medical_report)
3. شهادة الميلاد (birth_certificate)
4. آخر شهادة (last_certificate)
5. صورة شخصية (personal_photo)
6. صورة طولية (full_photo)

**مثال:**
```
/uploads/orphans/123/national_id.jpg,/uploads/orphans/123/medical.pdf,/uploads/orphans/123/birth_cert.jpg,/uploads/orphans/123/school_cert.jpg,/uploads/orphans/123/personal.jpg,/uploads/orphans/123/full_body.jpg
```

### مثال JSON للإرسال (POST Example)

```json
{
  "beneficiary_id": 123,
  "orphan_national_id": "123456789",
  "first_name": "عمر",
  "second_name": "محمد",
  "third_name": "أحمد",
  "family_name": "الفلسطيني",
  "birth_date": "2015-05-10",
  "age": 9,
  "gender": "male",
  "health_status": "سليم",
  "attachments": "/uploads/orphans/123/id.jpg,/uploads/orphans/123/medical.pdf,/uploads/orphans/123/birth.jpg,/uploads/orphans/123/cert.jpg,/uploads/orphans/123/personal.jpg,/uploads/orphans/123/full.jpg",
  "notes": "طفل يتيم الأب، بحاجة لدعم تعليمي"
}
```

### مثال JSON للاستقبال (GET Response)

```json
{
  "id": 789,
  "beneficiary_id": 123,
  "orphan_national_id": "123456789",
  "first_name": "عمر",
  "second_name": "محمد",
  "third_name": "أحمد",
  "family_name": "الفلسطيني",
  "birth_date": "2015-05-10",
  "age": 9,
  "gender": "male",
  "health_status": "سليم",
  "attachments": "/uploads/orphans/123/id.jpg,/uploads/orphans/123/medical.pdf,/uploads/orphans/123/birth.jpg,/uploads/orphans/123/cert.jpg,/uploads/orphans/123/personal.jpg,/uploads/orphans/123/full.jpg",
  "notes": "طفل يتيم الأب، بحاجة لدعم تعليمي",
  "created_at": "2024-01-20T10:30:00",
  "updated_at": "2024-01-20T10:30:00"
}
```

---

## 3️⃣ API Endpoints المطلوبة

### Family Deceased Endpoints

#### GET /api/family_deceased
**Parameters:**
- `beneficiary_id` (optional) - filter by beneficiary
- `deceased_type` (optional) - filter by father/mother
- `limit` (optional) - default 100
- `offset` (optional) - for pagination

**Response:**
```json
{
  "success": true,
  "data": [/* array of deceased records */],
  "total": 50,
  "limit": 100,
  "offset": 0
}
```

#### POST /api/family_deceased
**Body:** JSON object (see example above)

**Response:**
```json
{
  "success": true,
  "id": 456,
  "message": "Family deceased record created successfully"
}
```

#### PUT /api/family_deceased/{id}
**Body:** JSON object with fields to update

**Response:**
```json
{
  "success": true,
  "message": "Family deceased record updated successfully"
}
```

#### DELETE /api/family_deceased/{id}
**Response:**
```json
{
  "success": true,
  "message": "Family deceased record deleted successfully"
}
```

### Family Members Endpoints

#### GET /api/family_members
**Parameters:**
- `beneficiary_id` (optional) - filter by beneficiary
- `health_status` (optional) - filter by health status
- `limit` (optional) - default 100
- `offset` (optional) - for pagination

**Response:**
```json
{
  "success": true,
  "data": [/* array of member records */],
  "total": 120,
  "limit": 100,
  "offset": 0
}
```

#### POST /api/family_members
**Body:** JSON object (see example above)

**Response:**
```json
{
  "success": true,
  "id": 789,
  "message": "Family member created successfully"
}
```

#### PUT /api/family_members/{id}
**Body:** JSON object with fields to update

**Response:**
```json
{
  "success": true,
  "message": "Family member updated successfully"
}
```

#### DELETE /api/family_members/{id}
**Response:**
```json
{
  "success": true,
  "message": "Family member deleted successfully"
}
```

---

## 4️⃣ Sync API (للمزامنة)

### Push Changes (من التطبيق للسيرفر)

#### POST /api/sync/push
**Body:**
```json
{
  "changes": [
    {
      "entity_type": "family_deceased",
      "operation": "insert",
      "entity_id": 456,
      "data": {/* family_deceased object */}
    },
    {
      "entity_type": "family_members",
      "operation": "update",
      "entity_id": 789,
      "data": {/* family_members object */}
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "results": [
    {
      "entity_type": "family_deceased",
      "entity_id": 456,
      "server_id": 456,
      "status": "success"
    },
    {
      "entity_type": "family_members",
      "entity_id": 789,
      "server_id": 789,
      "status": "success"
    }
  ]
}
```

### Pull Changes (من السيرفر للتطبيق)

#### GET /api/sync/pull
**Parameters:**
- `last_sync_time` - timestamp of last sync (format: Y-m-d H:i:s)
- `entity_types[]` - array of entity types (optional)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "entity_type": "family_deceased",
      "id": 456,
      "data": {/* full record */}
    },
    {
      "entity_type": "family_members",
      "id": 789,
      "data": {/* full record */}
    }
  ],
  "server_time": "2024-11-21 12:30:00"
}
```

---

## 5️⃣ Validation Rules

### family_deceased
- `deceased_type`: REQUIRED, ENUM('father', 'mother')
- `first_name`: REQUIRED, MAX 100 chars
- `family_name`: REQUIRED, MAX 100 chars
- `national_id`: REQUIRED, EXACTLY 9 digits, UNIQUE per beneficiary
- `death_date`: REQUIRED, DATETIME
- `death_cause`: REQUIRED, MAX 255 chars
- `document_type`: OPTIONAL, ENUM('شهادة وفاة', 'إفادة شهيد')
- `document_path`: OPTIONAL, MAX 500 chars

### family_members
- `orphan_national_id`: REQUIRED, EXACTLY 9 digits, UNIQUE
- `first_name`: REQUIRED, MAX 100 chars
- `family_name`: REQUIRED, MAX 100 chars
- `birth_date`: REQUIRED, DATE
- `gender`: REQUIRED, ENUM('male', 'female')
- `health_status`: REQUIRED, ENUM('سليم', 'مريض', 'مريض مزمن', 'معاق', 'غير معروف')
- `attachments`: OPTIONAL, TEXT (comma-separated)

---

## 6️⃣ Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "error": "Invalid deceased_type. Must be father or mother",
  "field": "deceased_type"
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": "Family deceased record not found",
  "id": 456
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": "Database connection failed",
  "message": "Could not connect to database server"
}
```

---

## 7️⃣ ملفات التنفيذ المرفقة

1. **`backend_php/migrations/update_family_tables.sql`**
   - Migration script لتحديث قاعدة البيانات
   - يحتوي على:
     - CREATE backup tables
     - ALTER tables to add new columns
     - UPDATE statements to migrate data
     - DROP old columns
     - CREATE indexes

2. **`backend_php/sync_family_updated.php`**
   - PHP functions جاهزة للاستخدام
   - يحتوي على:
     - `processFamilyDeceasedChange()` - معالجة تغييرات الأموات
     - `processFamilyMemberChange()` - معالجة تغييرات الأيتام
     - `fetchFamilyDeceased()` - جلب الأموات
     - `fetchFamilyMembers()` - جلب الأيتام
     - Validation logic كامل

---

## 8️⃣ خطوات التنفيذ للمبرمج

### المرحلة 1: قاعدة البيانات
1. ✅ عمل backup كامل للقاعدة
2. ✅ تشغيل `update_family_tables.sql`
3. ✅ التحقق من نجاح الـ migration
4. ✅ اختبار البيانات المهاجرة

### المرحلة 2: Backend Code
1. ✅ نسخ الدوال من `sync_family_updated.php`
2. ✅ دمجها في `sync.php` الموجود
3. ✅ تحديث الـ switch cases للـ entity types
4. ✅ اختبار الـ push/pull sync

### المرحلة 3: API Endpoints
1. ✅ إنشاء/تحديث endpoints للـ CRUD operations
2. ✅ تطبيق validation rules
3. ✅ إضافة error handling
4. ✅ اختبار كل endpoint بـ Postman

### المرحلة 4: Testing
1. ✅ اختبار إضافة أب متوفى
2. ✅ اختبار إضافة أم متوفاة
3. ✅ اختبار إضافة يتيم مع 6 مرفقات
4. ✅ اختبار المزامنة الكاملة
5. ✅ اختبار التحديث والحذف

---

## 9️⃣ أسئلة شائعة (FAQ)

**Q: هل يمكن إضافة أكثر من أب/أم لنفس المستفيد؟**
A: نعم، ولكن يُفضل واحد من كل نوع. يمكن التحقق في الكود.

**Q: ماذا لو لم يكن لليتيم كل المرفقات الستة؟**
A: في التطبيق، كل المرفقات مطلوبة. في الـ API، يمكن قبول attachments فارغ.

**Q: كيف يتم حساب العمر؟**
A: تلقائياً من `birth_date` عند الحفظ/التحديث.

**Q: هل `national_id` و `orphan_national_id` مختلفان؟**
A: نعم، `orphan_national_id` للأيتام، `national_id` للأموات.

---

**الدعم الفني:**
إذا واجهت أي مشكلة، راجع:
- `FAMILY_SCHEMA_UPDATE.md` - توثيق التغييرات
- `FAMILY_UPDATE_STATUS.md` - حالة التنفيذ
- أو تواصل مع فريق التطوير

**تاريخ آخر تحديث:** 2024-11-21
**الإصدار:** 2.0
