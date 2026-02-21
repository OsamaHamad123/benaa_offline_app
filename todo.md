الخطة الشاملة (مراحل تنفيذ)

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
