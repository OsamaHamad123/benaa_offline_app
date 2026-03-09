# Central Sync Field Parity Matrix

تاريخ التحديث: 2026-03-10

## نطاق المصفوفة

- `data`
- `re_people`
- `dead_people`
- `attachments`
- `guardian_bank_accounts`
- `file_ids`

## تعريف الحالة

- `Green`: مطبق ومغطى اختباريًا بشكل مقبول.
- `Yellow`: مطبق جزئيًا أو يحتاج توسيع parity.
- `Red`: غير مطبق أو فجوة جوهرية.

## مصفوفة الحالة الحالية

| Entity                   | Contract Endpoint(s)                                      | Local Schema                                   | Sync Down | Sync Up | Tests                          | Status   |
| ------------------------ | --------------------------------------------------------- | ---------------------------------------------- | --------- | ------- | ------------------------------ | -------- |
| `data`                   | `/api/mobile/database/data`, `/data/batch`                | موجود (beneficiaries)                          | موجود     | موجود   | موجود (Parser + Mapper + Repo) | `Yellow` |
| `re_people`              | `/api/mobile/database/re-people`                          | موجود (family_members)                         | موجود     | موجود   | موجود (Parser + Repo جزئي)     | `Yellow` |
| `dead_people`            | `/api/mobile/database/dead-people`                        | موجود (family_deceased)                        | موجود     | موجود   | موجود (Parser + Repo جزئي)     | `Yellow` |
| `attachments`            | `/api/mobile/database/attachments`                        | موجود (attachments)                            | موجود     | موجود   | موجود (Parser + Repo)          | `Yellow` |
| `guardian_bank_accounts` | `/api/mobile/database/bank-accounts`                      | موجود (custom table)                           | موجود     | موجود   | موجود (Repository + Widget)    | `Yellow` |
| `file_ids`               | `/api/mobile/database/file-ids/*` + `/api/mobile/codes/*` | موجود (`file_id_reservations` + `local_codes`) | موجود     | موجود   | موجود                          | `Yellow` |

## ملخص ما اكتمل فعليًا في `guardian_bank_accounts`

- إضافة endpoint config: `guardianBankAccountsEndpoint`.
- إضافة جدول محلي `guardian_bank_accounts` في migration v31 مع indexes.
- إضافة handlers في sync-down:
  - `upsertGuardianBankAccount(...)`
  - `deleteGuardianBankAccountFromServerRow(...)`
- إضافة stage في sync-up:
  - `syncGuardianBankAccounts(deviceId)` مع `POST/PUT/DELETE`.
- إضافة اختبار تكاملي Repository:
  - `test/features/sync/data/repositories/mobile_sync_related_entities_repository_test.dart`
- إضافة طبقة ميزة كاملة (Domain + Repository + UseCases) للحساب البنكي.
- دمج واجهة الحساب البنكي داخل نموذج المستفيد مع تحميل/حفظ.
- تحويل اختيار البنك إلى `TaxonomyBridgeDropdown` (group: `bankName`) مع تعبئة `bank_name_id` واسم البنك تلقائيًا.
- إضافة اختبار Widget لمسار الإدخال وربط بيانات البنك بالـ draft map:
  - `test/features/beneficiaries/presentation/widgets/v2/tabs/v2_contact_notes_merged_tab_test.dart`

## الفجوات المتبقية (المرحلة التالية)

1. Field Coverage Parity

- تمت إضافة طبقة حفظ محلية جانبية (sidecar tables) لحقول contract التفصيلية دون كسر Drift schema الحالية:
  - `re_people_contract_fields`
  - `dead_people_contract_fields`
  - `attachments_contract_fields`
- تم ربط الكتابة إليها مباشرة داخل repository upsert flows لـ `re_people/dead_people/attachments`.
- تمت إضافة backfill فعلي لسد فجوات parity من البيانات المحلية الحالية عبر:
  - `MobileSyncDashboardLoader.backfillContractParity(...)`
  - زر تشغيلي في شاشة Sync: `تشغيل backfill parity`
- تمت إضافة عدادات parity في Dashboard diagnostics export و`recommended_actions`.
- المتبقي: تقرير جاهزية التحول من sidecar إلى أعمدة أساسية مستقبلًا (إذا تقرر ذلك).

2. Contract Tests

- تمت إضافة اختبارات repository متخصصة لـ `re_people` و `dead_people` في:
  - `test/features/sync/data/repositories/mobile_sync_related_entities_repository_test.dart`
- تمت إضافة تغطية اختبارية لـ `attachments` contract-sidecar metadata في نفس الملف.
- تمت إضافة Contract tests لـ `data/attachments/dead_people` (parser) و `data` (mapper) وربطها مع اختبارات repository في `release_gate_sync.yml`.

## ملاحظات تشغيلية

- الحالة الحالية `Yellow` متعمدة: الأساس الوظيفي موجود، لكن parity الكامل وواجهة المستخدم لم تكتمل بعد.
- أي انتقال إلى `Green` يتطلب تحققًا من:
  - اكتمال الحقول التعاقدية المطلوبة.
  - اختبارات contract + integration + failure paths.

## معايير Green المعتمدة (Closure Gate)

1. التغطية التعاقدية

- كل كيان يجب أن يثبت عدم إسقاط الحقول الحرجة من عقد API في مسارات `sync-down` و`sync-up`.
- أي key استثنائي في العقد (مثل `data.attachments[]`) يجب أن يملك اختبار parser صريح.

2. الصلابة التشغيلية

- وجود اختبارات `failure-path` لكل كيان (payload malformed, missing ids, empty parent branches, no-op deletes).
- أي backfill parity يجب أن يكون idempotent وقابلًا للتنفيذ من الواجهة التشخيصية.

3. البوابة الآلية

- نجاح مسار `release_gate_sync.yml` كاملًا:
  - focused contract tests
  - smoke script
  - e2e diagnostics sanity

4. قرار معماري موثق

- توثيق قرار المعمارية الحالي بوضوح (`sidecar-first` في هذه المرحلة) مع شروط الترقية إلى `core-table-native`.

## Snapshot الإقفال (2026-03-10)

- تم اعتماد `sidecar-first` كقرار الإقفال للإصدار الحالي (انظر: `docs/SYNC_PARITY_ARCHITECTURE_DECISION_2026-03-10.md`).
- تمت إضافة failure-path tests إضافية في:
  - `test/features/sync/data/parsers/mobile_sync_response_parser_test.dart`
  - `test/features/sync/data/repositories/mobile_sync_related_entities_repository_test.dart`
- الـ gate الحالي يغطي ملفات الاختبارات العقدية الأساسية، بما فيها الملفات المحدثة أعلاه.
- الحالة العامة تبقى `Yellow` إلى حين اكتمال field-coverage النهائي لكل الكيانات وإثباته اختباريًا بنطاق أوسع.
