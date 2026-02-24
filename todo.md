4. Associations Synchronization (sponsors, employees)
   PLANNED (ANALYZED) ▼

## 1) Executive Status (الوضع الحالي الحقيقي)

### جاهزية حالية

- ✅ يوجد Feature محلي للجمعيات (`associations`) وفق Clean-ish layering (Domain/Data/Presentation).
- ✅ يوجد جداول محلية ودعم `sync_state` و `server_id` للجمعيات والمندوبين.
- ✅ توجد بنية مزامنة مركزية قوية (`MobileSyncService` + use cases + progress + counters).

### فجوات حرجة (تمنع ربط Associations API الحالي)

- ✅ تم إضافة endpoints الرسمية في `ApiConfig` لـ sponsors/employees (+ employees batch).
- ✅ تم دمج stage فعلي داخل `MobileSyncService` لمزامنة sponsors/employees (down + up).
- ✅ تم إضافة DTO/Mapper خاصين بعقد sponsors/employees.
- ✅ تم تفعيل Sync Metadata مستقل للـ associations/employees عبر `sync_metadata`.
- ✅ حذف associations/representatives أصبح يُسجّل tombstones مع دعم DELETE فعلي في sync-up.
- ✅ تم تغطية حقول sponsor الناقصة (`address`, `country_code`, `country_name`, `bank_name_id`) عبر جدول supplemental غير كاسر مع ربطه بـ down/up sync.

> الاستنتاج المحدث: البند **IMPLEMENTED فعليًا** على مستوى الربط الأساسي مع Backend API (down/up + metadata + tombstones + الحقول الناقصة)، مع بقاء تحسينات اختيارية لاحقة (UI polishing واختبارات أوسع).

---

## 2) Backend Contract (مصدر الحقيقة)

### Sponsors API

- GET `/api/mobile/associations/sponsors` (pagination + `updated_after` + `ids`)
- GET `/api/mobile/associations/sponsors/{id}`
- POST `/api/mobile/associations/sponsors`
- PUT `/api/mobile/associations/sponsors/{id}`
- DELETE `/api/mobile/associations/sponsors/{id}`

### Employees API

- GET `/api/mobile/associations/employees` (`sponsor_id`, `updated_after`)
- POST `/api/mobile/associations/employees`
- PUT `/api/mobile/associations/employees/{id}`
- DELETE `/api/mobile/associations/employees/{id}`
- POST `/api/mobile/associations/employees/batch`

---

## 3) Gap Matrix (Contract vs App)

### Data Model

- الحالي: `Associations` + `AssociationRepresentatives`.
- المطلوب: محاذاة `sponsors` + `employees` مع حقول backend القياسية.

### Sync Down

- الحالي: تنزيل beneficiaries + related entities فقط.
- المطلوب: stages منفصلة لتنزيل sponsors ثم employees مع `updated_after` + pagination.

### Sync Up

- الحالي: رفع beneficiaries/visits/attachments/family entities.
- المطلوب: رفع sponsors (CRUD) + employees (CRUD + batch) مع mapping ثابت للحالات.

### Delete Propagation

- الحالي: tombstones مفعلة لعدد من الكيانات (وليس associations/representatives).
- المطلوب: توحيد delete tracking للجمعيات والموظفين.

### UI/State

- الحالي: واجهة الجمعيات تعتمد local cache.
- المطلوب: counters/status واضحين لـ sponsors/employees داخل Sync Hub.

---

## 4) Clean Architecture Target Design

### Domain Layer

1. إضافة كيانات صريحة:
   - `Sponsor`
   - `AssociationEmployee`
2. إضافة عقود Repositories:
   - `SponsorSyncRepository`
   - `AssociationEmployeeSyncRepository`
3. إضافة Use Cases:
   - `SyncSponsorsDownUseCase`
   - `SyncSponsorsUpUseCase`
   - `SyncEmployeesDownUseCase`
   - `SyncEmployeesUpUseCase`
   - `SyncAssociationsModuleUseCase` (Facade)

### Data Layer

1. DTOs:
   - `SponsorDto`, `EmployeeDto`, `SponsorListResponseDto`, `EmployeeListResponseDto`
2. Mappers:
   - `SponsorMapper` (API ⇄ DB)
   - `EmployeeMapper` (API ⇄ DB)
3. Remote Data Sources:
   - sponsors endpoints client
   - employees endpoints client
4. Local Data Sources/DAOs:
   - upsert by `server_id`
   - pending rows queries
   - markSynced/markFailed

### Infrastructure / Sync Orchestration

1. دمج module جديد في `MobileSyncService`:
   - Stage Down: Sponsors → Employees
   - Stage Up: Sponsors → Employees (employees batch first when applicable)
2. إضافة metrics:
   - `sponsors_downloaded`, `employees_downloaded`
   - `sponsors_uploaded`, `employees_uploaded`
   - `sponsors_failed`, `employees_failed`
3. إضافة metadata keys:
   - `sponsors:last_sync_timestamp`
   - `employees:last_sync_timestamp`

### Presentation Layer

1. تحديث `mobile_sync_page` لإظهار قسم فرعي واضح للـ Associations Sync.
2. توفير refresh provider invalidation بعد نجاح sync.
3. حالات فشل واضحة برسائل عملية (auth/network/validation/conflict).

---

## 5) Database Migration Plan

## المرحلة 1 (غير كاسرة)

- إضافة أعمدة مفقودة في `associations` لملاءمة العقد:
  - `address`
  - `country_code`
  - `country_name`
  - `bank_name_id`
- إضافة جدول `association_employees` (أو إعادة تسمية `AssociationRepresentatives` منطقيًا مع compatibility).

## المرحلة 2 (توحيد الأسماء)

- اعتماد naming واضح:
  - Internal: associations/employees
  - API: sponsors/employees
- إضافة indexes:
  - `server_id`
  - `(sync_state, updated_at)`
  - `sponsor_id` في employees

## المرحلة 3 (تتبع الحذف)

- تفعيل tombstone recording للجمعيات والموظفين.

---

## 6) Sync Flows (تفصيلي)

### A) Down Sync (Incremental)

1. قراءة `last_sync_timestamp` لكل module.
2. GET sponsors بـ `updated_after` + pagination.
3. Upsert sponsors محليًا (idempotent).
4. GET employees بـ `updated_after` + pagination.
5. Upsert employees محليًا مع ربط sponsor.
6. حفظ `sync_timestamp` بعد نجاح المرحلة كاملة.

### B) Up Sync (Pending)

1. رفع sponsors pending/modified (POST/PUT).
2. رفع employees pending/modified:
   - استخدام `/batch` إذا العدد أكبر من threshold.
3. تطبيق mapping للـ server IDs محليًا.
4. مزامنة deletes عبر tombstones (DELETE endpoints).
5. تحديث `sync_state` و `last_synced_at`.

### C) Conflict Policy

- القاعدة الافتراضية: **Server wins** في down-sync، مع local retry في pending-up.
- في `409`: حفظ payload الفاشل + reason في diagnostics وإبقاء السجل `failed`.

---

## 7) Implementation Roadmap (من الألف للياء)

### Sprint 0 — Contract Freeze

- تثبيت contract النهائي مع backend (خصوصًا employee payload shape و batch response shape).
- توثيق response parsers المعتمدة (records/data/meta/pagination).

### Sprint 1 — Data Foundations

- Migration + DAO + DTO + Mapper.
- Unit tests للـ mapping والتحويلات.

### Sprint 2 — Down Sync Integration

- تنفيذ Sync Down للسponsors/employees.
- حفظ metadata timestamps + counters.
- ربط providers بعملية refresh بعد sync.

### Sprint 3 — Up Sync Integration

- تنفيذ رفع sponsors/employees + batch + delete tombstones.
- تنفيذ retry/backoff + classification للأخطاء.

### Sprint 4 — UI, Diagnostics, Hardening

- إضافة بطاقات حالة associations داخل Sync Hub.
- تصدير diagnostics يتضمن module associations.
- تحسين رسائل الخطأ وتجربة الاسترجاع.

### Sprint 5 — Verification & Rollout

- Integration tests + smoke tests.
- تجريب بيانات حقيقية staging.
- إطلاق تدريجي مع مراقبة metrics.

---

## 8) Test Strategy

### Unit

- DTO parsing لكل أشكال payload المعروفة.
- Mapper correctness (nullability + type conversion).

### Integration

- Down sync paginated sponsors/employees.
- Up sync CRUD + batch + delete.
- إعادة المحاولة عند timeout/5xx.

### End-to-End

- إنشاء Sponsor وEmployee أوفلاين ثم Sync Up.
- تنزيل تحديث من السيرفر ثم ظهور فوري في UI.
- حذف Sponsor مع موظفيه والتحقق من consistency.

---

## 9) Definition of Done (DoD)

- لا يوجد hardcoded associations data في الواجهات.
- كل dropdown/lookup يعتمد cache محلي متزامن.
- Sync Hub يعرض counters دقيقة لـ sponsors/employees.
- جميع عمليات CRUD (create/update/delete) متزامنة ثنائيًا (down/up).
- فشل الشبكة لا يؤدي لفقدان البيانات، وتوجد إعادة محاولة آمنة.

---

## 10) Immediate Next Execution Tasks (Ready to Start)

1. ✅ تحديث `ApiConfig` بإندبوينتس associations الرسمية.
2. ✅ إنشاء migration غير كاسرة + تغطية حقول sponsor الناقصة (supplemental profile).
3. ✅ بناء DTO/Mapper/RemoteDataSource للـ sponsors/employees.
4. ✅ إضافة stages في `MobileSyncService` (down ثم up).
5. ✅ ربط counters + sync metadata + diagnostics.
6. ✅ إضافة اختبارات integration مخصصة للموديول.

---

## 11) قرار إداري للحالة

- الحالة السابقة: `IMPLEMENTED`
- الحالة المصححة: `IMPLEMENTED (CORE INTEGRATION COMPLETE)`
- السبب: تم تنفيذ الربط الفعلي end-to-end للمزامنة الأساسية (sponsors/employees) مع إغلاق الفجوات الحرجة.
