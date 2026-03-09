# الخطة الرئيسية A→Z لنظام المزامنة المركزي

تاريخ التقييم: 2026-03-09
النطاق: `data`, `re_people`, `dead_people`, `guardian_bank_accounts`, `attachments`, `file-ids`

## 1) النتيجة التنفيذية

- المشروع يملك بنية مزامنة قوية فعليا لـ `data + re_people + dead_people + attachments + file-ids`.
- يوجد نقص جوهري: `guardian_bank_accounts` غير مطبق كتدفق Sync كامل (DB + Domain + Data + API + UI + Tests).
- توجد فجوات توافق بين عقد API في `todo.md` وبين النماذج المحلية الحالية (خصوصا حقول full coverage والحقول النصية/المنطقية).
- المطلوب الآن ليس تحسينات تجميلية، بل برنامج تنفيذ طبقي موحد (Contract-First + Clean Architecture) مع هجرة آمنة للبيانات.

## 2) تدقيق مطابقـة `todo.md` مقابل التنفيذ الحالي

### 2.1 File ID Reservation

الحالة: **جزئيا مطابق + انحراف سياسة**

الموجود:

- Endpoints موجودة في الإعدادات: `reserve`, `reservations`, `sync-used`.
  - `lib/core/config/api_config.dart:28`
  - `lib/core/config/api_config.dart:29`
  - `lib/core/config/api_config.dart:30`
- Remote datasource يدعم المسارات الرسمية + fallback.
  - `lib/features/sync/data/datasources/file_id_remote_datasource.dart:113`
  - `lib/features/sync/data/datasources/file_id_remote_datasource.dart:249`
  - `lib/features/sync/data/datasources/file_id_remote_datasource.dart:268`

الفجوات:

- سياسة الدفعة/العتبة لا تطابق `todo.md`:
  - في الخدمة الحالية: `lowThreshold=100`, `reserveBatchSize=500`.
  - `todo.md` ينص: default batch = `5000`, تجديد عند `<1000`.
  - `lib/features/sync/services/file_id_service.dart:15`
  - `lib/features/sync/services/file_id_service.dart:16`
- الجدول المحلي legacy `file_id_reservations` فردي بالـ row لكل code، بينما العقد الحديث يعتمد أيضا مفهوم reservation batch metadata.
  - `lib/data/db/tables/file_id_reservation_table.dart:9`

### 2.2 Data (Main Family Records)

الحالة: **موجود وظيفيا لكن ليس 100% field parity**

الموجود:

- Pull/push endpoints موجودة (`/data`, `/data/batch`).
  - `lib/core/sync/data/datasources/remote_sync_datasource.dart:130`
  - `lib/core/sync/data/datasources/remote_sync_datasource.dart:155`
- Mapper موجود للرفع/التنزيل.
  - `lib/core/mappers/beneficiary_sync_mapper.dart:10`

الفجوات:

- عقد `todo.md` يذكر 45 حقل مع حقول \*\_normalized + label/name (مثل `data_city_name`, `data_request_status_name`).
- النموذج المحلي لا يحفظ هذه التغطية كاملة (خاصة normalized/name labels).
  - `lib/data/db/tables/beneficiaries_table.dart:1`
- بعض الأنواع المحلية مقيّدة كـ `int` بينما العقد يستقبل نصوص (مثال الهاتف/هوية في حالات متعددة)، ما يزيد مخاطر parse/fallback.

### 2.3 Re-People (Family Members)

الحالة: **مطبق جزئيا مع فجوات Schema**

الموجود:

- تنزيل ورفع من endpoints الرسمية.
  - `lib/core/sync/mobile_sync_service.dart:749`
  - `lib/features/sync/domain/usecases/sync_related_entities_up_usecase.dart:111`
- upsert/dedupe محلي جيد.
  - `lib/features/sync/data/repositories/mobile_sync_related_entities_repository.dart:103`

الفجوات:

- العقد يطلب 23 حقل ويشمل normalized names + label fields.
- الجدول المحلي لا يحتوي normalized name fields ولا label fields.
  - `lib/data/db/tables/family_members_table.dart:1`
- بعض الربط بين `person_type_of_guarantee` و `guarantee_type` يحتاج توحيد قاموسي نهائي.

### 2.4 Dead-People

الحالة: **مطبق functional مع فجوة تمثيل contract الكامل**

الموجود:

- تنزيل مخصص من endpoint dead-people.
  - `lib/core/sync/mobile_sync_service.dart:779`
- رفع grouped (father/mother) إلى نفس endpoint.
  - `lib/features/sync/domain/usecases/sync_related_entities_up_usecase.dart:208`
- معالجة nested father/mother في repository.
  - `lib/features/sync/data/repositories/mobile_sync_related_entities_repository.dart:164`

الفجوات:

- العقد يركز على `re_file_id` ونموذج nested كامل للأبوين.
- الجدول المحلي الحالي row-based (`deceasedType`) لا يحفظ snapshot حرفي لعقد nested، وهذا يفتح فجوات تحويل edge-cases.
  - `lib/data/db/tables/family_deceased_table.dart:1`

### 2.5 Attachments

الحالة: **مطبق بشكل جيد نسبيا**

الموجود:

- upload/delete endpoint موجودة.
  - `lib/core/sync/data/datasources/remote_sync_datasource.dart:256`
  - `lib/core/sync/data/datasources/remote_sync_datasource.dart:286`
- تنزيل dedicated endpoint ويتعامل مع key exception (`attachments` بدل `records`).
  - `lib/core/sync/mobile_sync_service.dart:718`
  - `lib/core/sync/mobile_sync_service.dart:719`
- توجد تغطية اختبار parsing لهذه الحالة.
  - `test/features/sync/data/parsers/mobile_sync_response_parser_test.dart:39`

الفجوات:

- العقد يميز metadata أوسع (`google_drive_*`, `download_url` كامل، ...).
- الجدول المحلي الحالي لا يخزن كل حقول metadata المذكورة في العقد.
  - `lib/data/db/tables/attachments_table.dart:1`

### 2.6 Guardian Bank Accounts

الحالة: **غير مطبق كتدفق مركزي**

الدليل:

- لا توجد endpoints/feature/table مخصصة لـ `bank-accounts` أو `guardian_bank_accounts` ضمن طبقة sync/beneficiary.
- نتائج البحث تظهر غياب فعلي، مع ظهور غير ذي صلة في associations فقط.
  - `lib/features/associations/data/models/associations_sync_dto.dart:85`

الاستنتاج:

- هذا هو أكبر gap حاليا، ويحتاج تنفيذ كامل Clean Architecture.

## 3) قرار معماري مطلوب (Architecture Decision)

اعتماد قرار موحد: **Contract-First Offline Sync**

- كل كيان له:
  - Remote DTO مطابق 1:1 لعقد API.
  - Local Entity/Table مهيأ للعمل Offline + Sync state.
  - Mapperين واضحين: `dto -> local`, `local -> payload`.
- أي field غير مستخدم UI حاليا يبقى محفوظا لضمان parity ومنع فقدان بيانات.
- اعتماد `sync_cursor` لكل endpoint بدل الاعتماد فقط على `updated_after` المتفرق.
- اعتماد Idempotency keys لعمليات الرفع batch عند الحاجة.

## 4) خطة التنفيذ A→Z (طبقات كاملة)

## المرحلة 0: تثبيت العقد والاختبارات المرجعية (2-3 أيام)

1. توثيق نسخة Contract نهائية في `docs/` (JSON schemas + examples).
2. توليد Contract tests (parser + mapper golden tests).
3. تعريف مصفوفة Field Parity إلزامية لكل كيان.

مخرجات إلزامية:

- `docs/contracts/central_sync/*.json`
- `test/contracts/*_contract_test.dart`

## المرحلة 1: Guardian Bank Accounts (Clean Architecture كامل) (4-6 أيام)

1. Domain:

- إنشاء `GuardianBankAccount` entity + repository interface + use cases:
  - `syncDown`, `syncUp`, `create`, `update`, `delete`, `getByGuardianFileId`.

2. Data:

- إنشاء Drift table جديدة `guardian_bank_accounts` (14+ fields حسب العقد).
- DAO كامل (CRUD + pending/unsynced + conflict markers).
- Remote datasource:
  - `GET /bank-accounts`
  - `GET /bank-accounts/{id}`
  - `POST /bank-accounts`
  - `PUT /bank-accounts/{id}`
  - `DELETE /bank-accounts/{id}`
- DTOs + mappers.

3. Sync Orchestration:

- إدراج Bank Accounts في `sync_down_flow` و `sync_up_flow` مع counters مستقلة.
- إدراجها في fallback/error categorization.

4. Presentation:

- تبويب حساب بنكي داخل beneficiary form/view.
- حالات offline-first + pending badge + conflict UI.

5. Tests:

- Unit tests للـ mapper/usecase.
- Integration tests DAO + sync scenarios.
- Failure-path tests (401/404/422/conflict).

## المرحلة 2: رفع parity لـ data/re_people/dead_people (5-8 أيام)

1. Beneficiaries parity:

- إضافة الحقول الناقصة ذات القيمة التعاقدية (normalized + names labels + optional contract fields).
- ترقية mapper لعدم إسقاط أي field مهم.

2. Re-people parity:

- إضافة normalized name fields + label fields (health/sponsorship/guarantee labels) محليا.
- إصلاح mapping الصارم للـ gender والقيم النصية/العددية.

3. Dead-people parity:

- اعتماد تمثيل محلي يدعم nested الأب/الأم بدون فقدان معلومات.
- خياران:
  - إما جدولين father/mother per registration.
  - أو table واحدة مع أعمدة father*\* و mother*\* (يفضل للعقد).

4. Backward compatibility:

- Migration scripts + one-time backfill من الجداول القديمة.

## المرحلة 3: Attachments metadata parity + download robustness (3-4 أيام)

1. توسيع جدول المرفقات لحقول metadata الناقصة (`mime_type`, `file_type`, `download_url`, `google_drive_*`).
2. طبقة download manager مع retry/resume/checksum.
3. تحسين مسار `download_url` كمسار أساسي بدل البناء اليدوي.
4. اختبارات تحميل binary + mime validation + file not found.

## المرحلة 4: File IDs alignment مع العقد النهائي (2-3 أيام)

1. جعل الإعدادات قابلة للضبط عبر env/remote config:

- `batch_size` الافتراضي 5000
- `renew_threshold` الافتراضي 1000

2. توحيد local storage model بين `local_codes` و reservation batches.
3. تحسين telemetry لقياس الاستهلاك والانقطاعات.

## المرحلة 5: الموثوقية التشغيلية والمراقبة (2-3 أيام)

1. Structured logs لكل endpoint + correlation id لكل sync run.
2. Metrics:

- success rate per entity
- latency p95
- conflict count
- retry count

3. لوحات تشغيل (sync dashboard) مع drill-down أخطاء.

## المرحلة 6: الإطلاق الآمن (2 أيام)

1. Feature flags لكل كيان جديد.
2. Rollout مرحلي:

- 5% -> 25% -> 50% -> 100%

3. خطة rollback واضحة على مستوى schema + feature flags.

## 5) خطة المايغريشن (DB + Data)

1. إضافة جداول جديدة بدون حذف القديم.
2. Backfill تدريجي داخل transaction chunks.
3. التحقق عبر checksums/count parity.
4. بعد الاستقرار: deprecate الأعمدة/الجداول legacy.

## 6) تعريف النجاح (Definition of Done)

- Field parity >= 99% مع عقد `todo.md` لكل كيان.
- Zero data-loss في سيناريوهات offline/online transitions.
- Passing tests:
  - Contract tests
  - Integration sync tests
  - Regression tests
- bank accounts تعمل end-to-end (CRUD + sync + UI + conflict handling).

## 7) ترتيب الأولويات الفوري (الأسبوع القادم)

1. تنفيذ `guardian_bank_accounts` بالكامل (Phase 1).
2. ترقية parity لـ `data/re_people/dead_people` (Phase 2).
3. تعديل سياسة `file_ids` إلى 5000/1000 configurable.
4. تثبيت contract tests كـ gate في CI.

## 8) مخاطر رئيسية يجب إدارتها

- انكسار backward compatibility في migrations.
- تضارب IDs/أنواع الحقول بين local و server.
- أخطاء parsing بسبب optional fields وresponse shape variance.
- تضخم حجم الـ payload مع full coverage fields.

## 9) توصية تنفيذية

ابدأ بـ **Guardian Bank Accounts** كحزمة مستقلة (feature branch) مع Contract tests من اليوم الأول.
بعدها مباشرة نفذ parity upgrade لباقي الكيانات قبل أي توسعة UI إضافية.

هذا يعطيك نظام مزامنة مركزي متماسك على كل الطبقات، ويحول `todo.md` من وثيقة API إلى تنفيذ production-ready فعلي.
