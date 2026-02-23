الخطة الشاملة (مراحل تنفيذ)

## خارطة طريق 2026-02-23 (إضافة مستفيد + التصنيفات)

### المرحلة 0 — إيقاف النزيف (Hotfix)

- [x] حماية تهيئة شاشة `BeneficiaryFormPageV3` بـ `try/catch` حتى لا ينهار التطبيق عند أي Exception.
- [x] إصلاح mapping `aid-statuses` ليُحفظ ضمن `assistance_type` بدل `beneficiary_status`.
- [x] تنظيف قاعدة البيانات من groups غير المدعومة في التطبيق بعد كل sync.

### المرحلة 1 — تثبيت الربط الإلزامي للفورم

- [x] ربط حقل `نوع المساعدة` (`assistance_type`) داخل نموذج إضافة مستفيد.
- [x] إضافة `assistance_type` في تحقق `missing taxonomy bindings` عند فتح النموذج.
- [x] حفظ/استرجاع قيمة `assistance_type` داخل المسودات (auto/manual draft).

### المرحلة 2 — تدقيق التغطية Server ↔ Forms

- [x] لوحة تشخيص تعرض: مجموعات السيرفر، المربوط محليًا، الناقص محليًا، وslugs غير المعروفة.
- [x] زر نسخ تقرير تشخيص جاهز للإرسال لفريق backend.
- [x] إضافة تقرير مطابقة نهائي: `group -> form fields` لكل شاشة (إضافة/تعديل/مراجعة).

### المرحلة 3 — تحليل الكراش عبر الطبقات

- [x] طبقة العرض: مراجعة كل `firstWhere`/`!`/async lifecycle في مسار فتح فورم إضافة مستفيد.
- [x] طبقة المنطق: مراجعة `mapper/data-handler/draft loader` لقيم taxonomy غير المتوقعة.
- [x] طبقة البيانات: مراجعة resolver للهوية المحلية/السيرفر (local/server id) لمسارات التحميل.
- [x] طبقة البنية: إضافة logging موحد عند فشل فتح الفورم مع `context + stack`.

### المرحلة 4 — استيعاب كل تصنيفات السيرفر (Dynamic Categories)

- [x] إنشاء طبقة `dynamic taxonomy groups` (مثل `fird`) لتتبع slugs غير المدرجة في enum الحالي.
- [x] حفظ جميع slugs القادمة من السيرفر (حتى غير المدعومة) محليًا دون كسر الفورم الحالي.
- [x] بناء شاشة إدارة/عرض لهذه المجموعات لتحديد مكان استخدامها في الفورمات.
- [x] تعريف policy واضحة: أي مجموعة جديدة من السيرفر تُصنّف تلقائيًا إلى:
  - `mapped-to-existing-field`
  - `new-field-required`
  - `ignored-not-used`

### المرحلة 5 — توسيع الفورمات بناءً على بيانات السيرفر

- [x] إضافة حقول taxonomy جديدة في `Add Beneficiary` حسب أولويات العمل (category/section/visit/disability/income...).
- [x] توحيد استخدام taxonomy في الفورمات الأخرى (تفاصيل مستفيد، زيارات، كفالات) بنفس الgroup source. (تم إنجاز مسار الزيارات في التصدير/العرض، وتحديث labels/خيارات تفاصيل المستفيد والكفالات مع fallback متوافق)
- [x] تحديث الحفظ/التحميل/المراجعة/التصدير لاحتواء الحقول الجديدة.

### المرحلة 6 — الاختبارات والحوكمة

- [x] Unit tests لسيناريوهات parser/mapping (خاصة slugs الجديدة).
- [x] Widget tests لفتح الفورم بدون crash حتى مع taxonomy ناقصة/غير متوقعة.
- [x] Integration smoke test: sync -> open add beneficiary -> save draft -> reopen.
- [x] Regression gate في CI يمنع دمج أي كود يخفض coverage الربط الإلزامي.

### المرحلة 7 — التنسيق مع Backend (رابط التوثيق الرسمي)

- [x] مراجعة دورية للـ contract وفق: https://palestine.benaadev.org/api-documentation.html
- [x] توحيد mapping `slug -> appGroup` كعقد رسمي مشترك مع backend.
- [x] اعتماد endpoint metadata لتعريف المجموعات الجديدة بدل hardcode داخل التطبيق.

### مخرجات مستهدفة (Definition of Done)

- [ ] شاشة إضافة مستفيد تفتح دائمًا بدون crash.
- [ ] كل الحقول المربوطة في الفورم لديها taxonomy محلية محمّلة.
- [ ] أي taxonomy من السيرفر إما مربوطة، أو مصنفة كـ dynamic، أو موثقة كغير مستخدمة.
- [ ] تقارير التشخيص قابلة للتصدير والإرسال وتكفي لتحديد المسؤولية (App vs Backend).

## حالة التنفيذ (محدث)

- ✅ المرحلة 1: Contract Lock **مكتملة**
- ✅ المرحلة 2: Identity Mapping **مكتملة**
- ✅ المرحلة 3: Persistence Integrity **مكتملة**
- ✅ المرحلة 4: UI Binding **مكتملة**
- ✅ المرحلة 5: File-ID Lifecycle **مكتملة**
- ✅ المرحلة 6: Observability + Safety **مكتملة**
- ✅ المرحلة 7: Cleanup **مكتملة**

### إنجازات المرحلة 3 (Persistence Integrity)

- تم تنفيذ الكتابة داخل `transaction` لكل صفحة أثناء sync-down.
- تم إضافة عدادات كتابة لكل كيان: `inserted / updated / skipped`.
- تم إضافة عرض عدادات الكتابة في شاشة المزامنة ضمن نتيجة آخر مزامنة.
- تم تقوية ربط الكيانات المرتبطة بالمستفيد عبر `server_id` ثم `file_id_number`.

### إنجازات المرحلة 4 (UI Binding)

- توحيد ربط قيم التصنيفات كـ codes في مسارات التحميل/الحفظ/المسودات.
- إضافة fallback عملي لتحميل بيانات العائلة عند وصول معرف غير محلي (محاولة عبر server_id).
- إضافة fallback مماثل لتحميل المرفقات بحيث يتم حل المعرف إلى local id قبل الاستعلام.

### إنجازات المرحلة 5 (File-ID Lifecycle)

- إكمال عقد `reserve/sync-used/reservations` بما يتوافق مع التوثيق الرسمي.
- إضافة تشخيص مباشر في شاشة المزامنة لعرض:
  - `available_count`
  - `used_unsynced_count`
  - `active_reservation_id`
  - `active_reservation_remaining`
  - `last_reserved_at`
  - `last_synced_at`
- إضافة استعلامات DAO لدعم reconciliation وقياس صحة مخزون أرقام الملفات.

### تقدم المرحلة 6 (Observability + Safety)

- إضافة `errorCategory` في نتيجة المزامنة (`auth/route/validation/server/network/parser/db/unknown`).
- إضافة `errorContext` يتضمن `path/status/body` مختصر لأخطاء الشبكة (Dio) في sync.
- عرض التصنيف والسياق مباشرة في بطاقة نتيجة المزامنة لتسهيل triage.

### إنجازات المرحلة 7 (Cleanup)

- إزالة probing/fallback لمسارات sync القديمة/غير الموثقة في تنزيل المستفيدين.
- تثبيت تنزيل المستفيدين على المسار الرسمي فقط: `/api/mobile/database/data`.
- تبسيط query params إلى القيم الرسمية المطلوبة للـ pagination والترتيب.
- الحفاظ على التوافق في parser للـ payload shape دون fallback route chaos.

### آخر تحقق (Validation)

- ✅ `flutter test test/features/sync/data/datasources/file_id_remote_datasource_test.dart` مرّ بنجاح.
- ✅ `flutter test test/core/sync/data/datasources/remote_sync_datasource_test.dart` مرّ بنجاح (2/2).
- ✅ `flutter analyze lib/core/sync` اكتمل بدون أي مشاكل (No issues found).
- ✅ فحص الأخطاء على ملفات `sync` و`file-id` و`mobile_sync_page` بدون أخطاء.

### تحسينات إضافية (دفعة واحدة) - مكتملة

- ✅ إضافة تصدير تقرير التشخيص من شاشة المزامنة إلى ملف JSON مع خيار المشاركة.
- ✅ إضافة تحذير تلقائي عند ارتفاع نسبة `skipped` بشكل غير طبيعي بعد المزامنة.
- ✅ إضافة Workflow مخصص للـ Regression على مسارات `sync/taxonomies/file-id`:
  - الملف: `.github/workflows/sync_regression.yml`
  - يشمل analyze موجّه + اختبارات file-id + اختبارات taxonomy.

---

## خطة شاملة لإصلاح ربط UI (أفراد العائلة + المرفقات) مع مراعاة الهيكل الحالي

### لماذا المشاكل موجودة أصلاً؟ (Root Cause)

1. **غياب هوية موحّدة للمستفيد داخل طبقة العرض**

- بعض المسارات تتعامل مع `beneficiaryId` كـ `local id` (رقم داخلي في Drift)،
- ومسارات أخرى تتعامل معه كـ `server id` أو string عام.
- النتيجة: الاستعلامات في UI قد تضرب على معرف مختلف عن المخزن فعليًا في جداول `attachments/family`.

2. **منطق fallback غير موحّد بين العائلة والمرفقات**

- المرفقات لديها `_resolveBeneficiaryIdForQuery` عند القراءة،
- العائلة تحل المعرف عند التحميل، لكن الحفظ يستخدم `int.parse` مباشرة.
- هذا يفتح فجوة في حالة وصول معرف غير محلي.

3. **واجهة النموذج تمرر `widget.beneficiaryId` مباشرة للتبويبات**

- بينما الهوية الأكيدة بعد التحميل يجب أن تكون من `beneficiaryFormProvider.beneficiary.id`.
- هذا قد يسبب فك ارتباط عند الحالات التي يأتي فيها route id غير مطابق للـ local id الفعلي.

4. **لا توجد طبقة تشخيص UI للربط**

- لا يوجد في شاشة المستفيد/النموذج مؤشر واضح يبيّن “تم حل الهوية إلى local id = X”.
- لذلك يصعب اكتشاف سبب الفراغ في التبويب رغم وجود بيانات في DB.

---

## مبدأ الحل (Re-Architecture بدون كسر الهيكل)

اعتماد **BeneficiaryIdentityResolver** موحّد في طبقة presentation/data-helper،
ويكون هو المصدر الوحيد لتحويل أي معرف وارد (route/server/local/file-id) إلى:

- `localBeneficiaryId` (int)
- `localBeneficiaryIdAsString`
- `serverBeneficiaryId` (إن وجد)

ثم إجبار جميع تبويبات UI (العائلة والمرفقات) على الاعتماد على هذا resolver بدل القراءة المباشرة للـ id الخام.

---

## خطة التنفيذ المرحلية

### المرحلة A — توحيد الهوية في واجهة المستفيد

**الملفات المستهدفة:**

- `lib/features/beneficiaries/presentation/pages/beneficiary_form_page_v3.dart`
- `lib/features/beneficiaries/presentation/pages/v2_form_helpers/widgets/form_tabs.dart`

**التنفيذ:**

- إنشاء `ValueNotifier<String?> resolvedBeneficiaryLocalId` داخل صفحة النموذج.
- بعد `loadBeneficiary`، تعيينه من `beneficiary.id` (المصدر الموثوق).
- تمرير `resolvedBeneficiaryLocalId` للتبويبات بدل `widget.beneficiaryId` الخام.

**الهدف:**

- تبويب العائلة والمرفقات يقرأ دائمًا نفس الهوية المحلية الفعلية.

### المرحلة B — توحيد حل المعرف على مستوى Helpers

**الملفات المستهدفة:**

- `lib/features/beneficiaries/presentation/pages/v2_form_helpers/family_save_helper.dart`
- `lib/features/attachments/data/datasources/attachment_datasource.dart`

**التنفيذ:**

- استخراج Resolver مشترك (helper صغير) بدل تكرار منطق التحويل.
- تعديل `saveFamilyMembers` ليستخدم نفس `_resolveBeneficiaryLocalId` بدل `int.parse` المباشر.
- ضمان أن `addAttachment/getBeneficiaryAttachments/deleteBeneficiaryAttachments` كلها تمر بنفس resolver.

**الهدف:**

- منع اختلاف السلوك بين التحميل والحفظ.

### المرحلة C — ربط تبويبات UI بالهوية المحلولة فقط

**الملفات المستهدفة:**

- `lib/features/beneficiaries/presentation/widgets/v2/tabs/v2_unified_attachments_tab.dart`
- `lib/features/beneficiaries/presentation/widgets/v2/tabs/v2_family_members_tab_redesigned.dart`
- (إن لزم) `lib/features/beneficiaries/presentation/widgets/family_section.dart`

**التنفيذ:**

- إيقاف أي اعتماد على route id الخام داخل التبويب.
- تحميل المرفقات/العائلة باستخدام local id المحلول.
- عند عدم القدرة على الحل: عرض رسالة تشخيصية واضحة بدل قائمة فارغة صامتة.

**الهدف:**

- إظهار البيانات المستوردة فعليًا عند وجودها.

### المرحلة D — تشخيص UI قابل للدعم

**الملفات المستهدفة:**

- `lib/features/beneficiaries/presentation/pages/beneficiary_form_page_v3.dart`
- `lib/features/beneficiaries/presentation/pages/beneficiary_details_page_v2.dart`

**التنفيذ:**

- إضافة Debug panel (خلف flag أو debug mode) يعرض:
  - route id
  - resolved local id
  - server id
  - family count
  - attachments count
- توحيد رسائل الخطأ للمستخدم: “تعذر ربط بيانات المستفيد” بدل رسائل عامة.

**الهدف:**

- تسريع اكتشاف مشاكل الربط مستقبلًا بدون تخمين.

### المرحلة E — Regression Tests مركزة

**الملفات المستهدفة (اختبارات):**

- `test/features/beneficiaries/...` (جديد)
- `test/features/attachments/...` (جديد)

**سيناريوهات إلزامية:**

1. فتح نموذج بمُعرف محلي → تظهر العائلة + المرفقات.
2. فتح نموذج بمُعرف قابل للحل إلى server id → resolver يعيد local id وتظهر البيانات.
3. حفظ أفراد العائلة بمُعرف غير رقمي مباشر → لا crash ويتم التحويل والحفظ.
4. تبويب المرفقات يقرأ نفس ID الناتج من resolver دائمًا.

---

## معايير القبول (Definition of Done)

1. لا يوجد حالة “مستورد لكن غير ظاهر” عندما تكون البيانات موجودة فعليًا في جداول DB.
2. تبويب العائلة والمرفقات في `BeneficiaryFormPageV3` و`BeneficiaryDetailsPageV2` يستخدمان نفس local id المحلول.
3. `FamilySaveHelper` لا يحتوي `int.parse` مباشر على `beneficiaryId` الخام.
4. وجود tests تغطي مسارات local/server id للربط.
5. لا أخطاء analyze في الملفات المعدلة.

---

## ترتيب التنفيذ المقترح (آمن)

1. **A + B** أولًا (تثبيت الهوية).
2. **C** ثانيًا (ربط التبويبات).
3. **D** ثالثًا (تشخيص ودعم).
4. **E** أخيرًا (تثبيت ضد الرجوع Regression).

> ملاحظة: هذه الخطة تحافظ على الهيكل الحالي (Riverpod + Drift + helpers) ولا تتطلب إعادة بناء معمارية كاملة؛ فقط توحيد نقطة الحقيقة للهوية وربط كل UI بها.

---

## تقرير الفجوات النهائي مع API (2026-02-21)

### تم إغلاقه (متوافق الآن)

- ✅ رفع المرفقات في مسار المزامنة الأساسي صار متوافقًا مع:
  - `POST /api/mobile/database/attachments`
  - الحقول: `person_identity_number` + `file_type` (مع fallback محسّن)
- ✅ حذف المرفقات صار على:
  - `DELETE /api/mobile/database/attachments/{id}`
- ✅ Taxonomy CRUD في مصدر taxonomy الحديث أصبح مبنيًا على مسارات categories الديناميكية حسب الوثائق.

### الفجوات المتبقية (مرتبة بالأولوية)

#### P0 (حرجة قبل الإطلاق)

1. **وجود مسار مزامنة قديم يعتمد `/api/v1`** في:

- `lib/core/sync/data/datasources/remote_sync_datasource.dart`
- أمثلة حالية: taxonomies/beneficiaries/visits/sync-status/timestamp
- **الخطر:** سلوك مختلف بين مسارين للمزامنة، واحتمال استدعاء endpoints غير موثقة في `api-doc.html`.

2. **تعارض معماري محتمل بين محركي sync** (المسار الحديث مقابل المسار القديم).

- **الخطر:** جزء من التطبيق يرسل على contract مختلف عن المسار المعتمد.

#### P1 (عالية)

3. **TODOs غير مكتملة في قلب المزامنة** (update/delete/push mapping) في:

- `lib/core/sync/new_sync_manager.dart`
- `lib/core/sync/data/repositories/sync_repository_impl.dart`
- `lib/core/sync/sync_manager.dart`
- **الخطر:** تغطية ناقصة لحالات التحديث/الحذف أو push لبعض الكيانات.

4. **local queue handling غير مكتمل بالكامل** في:

- `lib/core/sync/data/datasources/local_sync_datasource.dart`
- **الخطر:** عناصر معلقة قد لا تُدار بدقة في كل المسارات.

#### P2 (متوسطة)

5. **تحسينات observability إضافية** (ربط كل خطأ endpoint+payload بشكل موحد عبر كل managers).

6. **زيادة اختبارات الانحدار** لتغطية المسار القديم وإثبات إيقافه/توحيده نهائيًا.

---

## خطة تنفيذ عملية مختصرة (Action Checklist)

### المرحلة A — توحيد مسار المزامنة (P0)

- [x] حصر كل استدعاءات `/api/v1` داخل `lib/core/sync/**`.
- [x] نقلها إلى `/api/mobile/**` حسب العقد الرسمي (في `remote_sync_datasource`).
- [x] إيقاف أي fallback route قديم غير موثق في datasource المستهدف.

### المرحلة B — حسم مصدر الحقيقة للمزامنة (P0)

- [x] اعتماد محرك sync الرسمي في واجهات sync (`sync_widgets` و`test_sync_page`) عبر `MobileSyncService`.
- [x] عزل ربط المسار القديم من واجهات المستخدم الأساسية مع إبقاء التوافق الخلفي لباقي المسارات الداخلية.

### المرحلة C — إغلاق TODOs الحرجة (P1)

- [x] تنفيذ update/delete الناقصة الأساسية في `new_sync_manager.dart` (visit/attachment/taxonomy + deletion parser).
- [x] إكمال push mapping في `sync_repository_impl.dart` بدل success placeholder.
- [x] توحيد queue handling في `local_sync_datasource.dart` (aliases + remove + clear + saveBeneficiary).

### المرحلة D — التحقق النهائي (P1/P2)

- [x] تشغيل اختبارات sync المستهدفة + إضافة حالتين regression للمسارات التي كانت `/api/v1`.
- [x] تشغيل analyze موجّه على `lib/core/sync/**` والتأكد من عدم وجود أخطاء مرتبطة بالتعديلات (lint/info فقط).

---

## القرار التنفيذي الحالي

- الحالة الآن: **جاهزة للاعتماد التشغيلي** لمسار sync المستهدف بعد إغلاق A/B/C/D.
- المتبقي غير الحرج: **تحسينات lint/observability اختيارية** بدون تأثير وظيفي مباشر على العقد الحالي.
