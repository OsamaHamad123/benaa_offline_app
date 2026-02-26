# Mobile Sync Architecture Map

## الهدف

تثبيت حدود المسؤوليات داخل وحدة المزامنة، وتقليل تداخل الـ UI مع منطق الشبكة/التخزين.

## الطبقات الحالية

### 1) Orchestration

- الملف: `lib/core/sync/mobile_sync_service.dart`
- المسؤولية: تنسيق تدفقات `syncDown/syncUp` وإدارة الحالة والأخطاء.
- لا يحتوي على parsing معقد أو upsert تفصيلي للكيانات.

### 2) Response Parsing

- الملف: `lib/features/sync/data/parsers/mobile_sync_response_parser.dart`
- المسؤولية: تطبيع payloads المتغيرة من الـ backend (خصوصًا `deceased_parents`, `attachments`).

### 3) Beneficiary Persistence

- الملف: `lib/features/sync/data/repositories/mobile_sync_beneficiary_repository.dart`
- المسؤولية: upsert/delete/resolve لهوية المستفيد (`serverId`, `file_id`, `national_id`).

### 4) Related Entities Persistence

- الملف: `lib/features/sync/data/repositories/mobile_sync_related_entities_repository.dart`
- المسؤولية: upsert/delete-resolution لـ:
  - `attachments`
  - `family_members (re_people)`
  - `family_deceased (dead_people)`

## Hardening Pass (2026-02-25)

### Attachments (Offline-First)

- تم إيقاف أي جلب تلقائي/خلفي للمرفقات من روابط السيرفر (مثل prefetch).
- فتح/مشاركة المرفق يسمح بتنزيل عند الطلب فقط (بدون تحويل المتصفح إلى السيرفر).
- إذا فشل التنزيل عند الطلب، تظهر رسالة خطأ واضحة للمستخدم.

### Deceased Details Rendering

- تم تحصين تحويل بيانات المتوفين في controllers والـ V2 widgets لدعم:
  - `deceasedType` كرقم أو نص (`1/2`, `father/mother`, `أب/أم`).
  - مفاتيح اسم بديلة (`familyName`, `lastName`, `family_name`).
- الهدف: منع حالة ظهور العدد بدون تفاصيل.

## قاعدة تشغيلية

- أي تحميل من السيرفر يجب أن يكون صريحًا عبر زر/إجراء sync، وليس ضمن `open/preview`.
- أي widget يعرض أفراد متوفين يجب أن يستخدم type normalization قبل الفلترة.
