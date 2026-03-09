# Sync Parity Architecture Decision (2026-03-10)

## القرار

اعتماد نمط `sidecar-first parity` كقرار إغلاق مرحلي للإصدار الحالي.

## لماذا هذا القرار الآن

- يقلل مخاطر كسر schema الأساسية أثناء الإغلاق النهائي.
- يسمح بحفظ الحقول التعاقدية التفصيلية دون انتظار migrations كبيرة.
- يدعم backfill سريع وقابل للتشغيل من واجهة Sync التشخيصية.

## نطاق القرار

- الجداول الجانبية المعتمدة:
  - `re_people_contract_fields`
  - `dead_people_contract_fields`
  - `attachments_contract_fields`
- حفظ مباشر أثناء upsert + backfill عند الحاجة.

## معايير قبول القرار

- لا يوجد فقدان حقول contract-critical في مسارات sync الأساسية.
- backfill قابل للتكرار (idempotent) ولا يسبب تضاربًا.
- وجود عدادات parity واضحة في dashboard diagnostics.
- وجود اختبارات failure-path تغطي malformed payloads و no-op behavior.

## متى ننتقل إلى Core-Table-Native

يتم فتح مرحلة migration للحقول الأساسية فقط عند تحقق الشروط التالية:

1. استقرار parity sidecar على الأقل دورة إصدار كاملة بدون regressions.
2. وجود قائمة حقول ذات قيمة تشغيلية مثبتة للاستهلاك المباشر في UI/domain.
3. جاهزية migrations مع خطة rollback واضحة وتغطية tests قبل/بعد الترحيل.

## القرار التنفيذي الحالي

- `sidecar-first` = النهج الرسمي للإغلاق الحالي.
- `core-table-native` = ترقية لاحقة مخططة وليست شرطًا لإغلاق هذا الإصدار.
