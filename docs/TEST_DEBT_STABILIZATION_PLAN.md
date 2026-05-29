# خطة تثبيت الديون الاختبارية (Test Debt Stabilization Plan)

**تاريخ الإنشاء:** 2026-05-28  
**المرحلة:** الجلسة الثالثة — ما بعد تجميد Dashboard الإنتاجي  
**الهدف:** إصلاح 19 اختبارًا فاشلًا موجودة مسبقًا دون المساس بأي من 100 اختبار Phase 1 + Phase 2

---

## قواعد ثابتة (DO NOT VIOLATE)

- ❌ لا تحذف اختبارات فاشلة للوصول للأخضر
- ❌ لا تضف `skip` دون سبب خارجي موثق
- ❌ لا تضف `Firebase.initializeApp()` لاختبارات الوحدات
- ❌ لا تعدّل Dashboard/Home أو Quick Actions أو منطق صلاحيات Admin
- ✅ فقط: إصلاح mockات مفقودة، إصلاح feature flags، إصلاح بنية wrapper

---

## جرد الاختبارات الفاشلة (قبل الإصلاح)

| #   | الملف                                      | عدد الإخفاقات | نوع الخطأ                         | سبب الجذر                                                                                                                                                    | الإصلاح المقترح                                                                    | الخطورة       | الحالة  |
| --- | ------------------------------------------ | ------------- | --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- | ------------- | ------- |
| 1   | `bank_account_validator_test.dart`         | 2             | منطق وحدات                        | `ibanValidationEnabled = false` بشكل افتراضي؛ الاختبارات تتوقع التحقق الكامل                                                                                 | تفعيل الـ feature flag في `setUp`/`tearDown`                                       | منخفضة        | ⏳ معلق |
| 2   | `dashboard_charts_test.dart`               | 1             | ConsumerWidget بدون ProviderScope | `CategoryDistributionChart extends ConsumerWidget` — الاختبار لا يلف بـ `ProviderScope`                                                                      | إضافة `ProviderScope` wrapping + override لـ `bridgeTaxonomiesByGroupOnceProvider` | منخفضة        | ⏳ معلق |
| 3   | `taxonomy_bridge_dropdown_test.dart`       | 4             | مزود Firebase غير محاكى           | `_scheduleRealtimeGroupSync` يستدعي `taxonomyFirestoreHydratorProvider` → `isAuthenticatedProvider` → `appConfigProvider.requireValue` → يرمي `AsyncLoading` | إضافة override لـ `isAuthenticatedProvider` = false في helper `_host()`            | متوسطة        | ⏳ معلق |
| 4   | `form_data_handler_test.dart`              | 1             | منطق وحدات مفقود                  | `populateControllers` لا يستنتج `hasDisability = true` عندما `specialNeedsCount > 0`                                                                         | إضافة الاستنتاج في `populateControllers` بـ production code                        | منخفضة        | ⏳ معلق |
| 5   | `beneficiary_form_page_test.dart`          | 5             | Firebase / AppConfig              | `apiClientProvider` يصل إلى `appConfigProvider.requireValue` غير محاكٍ                                                                                       | تحقيق مفصل — إضافة override لـ `appConfigProvider` و auth providers                | متوسطة        | ⏳ معلق |
| 6   | `v2_personal_info_merged_tab_test.dart`    | 2             | Firebase dependency               | نفس جذر المشكلة — providers تصل Firebase                                                                                                                     | تحقيق مفصل — overrides مفقودة                                                      | متوسطة        | ⏳ معلق |
| 7   | `v2_contact_notes_merged_tab_test.dart`    | 1             | Firebase dependency               | TBD بعد التحقيق                                                                                                                                              | TBD                                                                                | متوسطة        | ⏳ معلق |
| 8   | `form_tabs_4_merged_integration_test.dart` | 1             | Integration test infra            | TBD بعد التحقيق                                                                                                                                              | TBD                                                                                | متوسطة        | ⏳ معلق |
| 9   | `beneficiary_form_open_ci_guard_test.dart` | 1             | CI threshold                      | عتبة أداء في بيئة CI                                                                                                                                         | TBD — احتمال تأجيل                                                                 | منخفضة–متوسطة | ⏳ معلق |

**الإجمالي:** 19 إخفاقًا قبل الإصلاح

---

## ترتيب الأولويات

### المرحلة D — إصلاحات سهلة (منخفضة الخطورة)

1. **`bank_account_validator_test.dart`** — تفعيل IBAN feature flag في setUp
2. **`form_data_handler_test.dart`** — إضافة استنتاج `hasDisability` في `populateControllers`
3. **`dashboard_charts_test.dart`** — إضافة `ProviderScope` wrapper

### المرحلة F — إصلاح Firebase mock

4. **`taxonomy_bridge_dropdown_test.dart`** — override لـ `isAuthenticatedProvider`
5. **`beneficiary_form_page_test.dart`** — تحقيق وإضافة overrides مفقودة
6. **`v2_personal_info_merged_tab_test.dart`** — تحقيق وإضافة overrides مفقودة
7. **`v2_contact_notes_merged_tab_test.dart`** — تحقيق وإصلاح
8. **`form_tabs_4_merged_integration_test.dart`** — تحقيق وإصلاح

### المرحلة G — CI threshold

9. **`beneficiary_form_open_ci_guard_test.dart`** — مراجعة العتبة

---

## التحقق النهائي

بعد الإصلاح يجب أن يكون:

- `flutter test` → `+910 ~0 -0` (بدون إخفاقات)
- `flutter analyze` → 0 errors, 0 warnings
- Dashboard/Home لم يُعدَّل
- 100 اختبار Phase 1 + Phase 2 لا تزال تعمل
- `DASHBOARD_BASELINE_2026_05_28.md` محدثة بملاحظة الإصلاح

---

## سجل التقدم

| التاريخ    | الخطوة                                  | النتيجة                                   |
| ---------- | --------------------------------------- | ----------------------------------------- |
| 2026-05-28 | Part A — التحقق من خط الأساس            | `flutter analyze` ✅ 0 errors, 0 warnings |
| 2026-05-28 | Part B — إنشاء هذا المستند              | ✅ مكتمل                                  |
| 2026-05-28 | Part D — إصلاح bank_account_validator   | ⏳ معلق                                   |
| 2026-05-28 | Part D — إصلاح form_data_handler        | ⏳ معلق                                   |
| 2026-05-28 | Part G — إصلاح dashboard_charts         | ⏳ معلق                                   |
| 2026-05-28 | Part F — إصلاح taxonomy_bridge_dropdown | ⏳ معلق                                   |
| 2026-05-28 | Part E — إصلاح beneficiary form tests   | ⏳ معلق                                   |
| 2026-05-28 | Part H — التشغيل الكامل + التوثيق       | ⏳ معلق                                   |
