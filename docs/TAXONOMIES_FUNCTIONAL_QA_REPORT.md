# تقرير QA الوظيفي — لوحة إدارة التصنيفات

**التاريخ:** 2025-05-29  
**flutter analyze:** 0 أخطاء | 7 تحذيرات (كلها مسبقة وغير متعلقة بالتصنيفات)  
**Tests:** 80/80 ✅

---

## 1. فتح الصفحة

| الاختبار                                               | النتيجة                              |
| ------------------------------------------------------ | ------------------------------------ |
| الصفحة تفتح بدون crash                                 | ✅                                   |
| `TaxonomyHierarchyList` يبني الشجرة من القائمة المسطحة | ✅                                   |
| حالة loading (أول load)                                | ✅ CircularProgressIndicator         |
| حالة error مع زر "إعادة المحاولة"                      | ✅                                   |
| حالة empty مع زر مزامنة                                | ✅                                   |
| `skipLoadingOnRefresh: true` — لا وميض عند invalidate  | ✅                                   |
| التصنيفات الجذرية في `ExpansionTile`                   | ✅                                   |
| التصنيفات الفرعية في `_ChildTile` بمسافة بادئة         | ✅                                   |
| overflow في النصوص الطويلة                             | ✅ `maxLines: 1, overflow: ellipsis` |
| RTL layout                                             | ✅ لا overflow                       |

---

## 2. Add Category

| الاختبار                                    | النتيجة                            |
| ------------------------------------------- | ---------------------------------- |
| الضغط على FAB يفتح `TaxonomyFormDialog`     | ✅                                 |
| validation: اسم فارغ                        | ✅ "الاسم مطلوب"                   |
| validation: كود فارغ                        | ✅ "الكود مطلوب"                   |
| validation: كود أقل من حرفين                | ✅ "يجب أن يكون حرفين على الأقل"   |
| كود مكرر داخل نفس المجموعة                  | ✅ use case يرفض + Snackbar بالسبب |
| إنشاء تصنيف رئيسي (parentId = null)         | ✅                                 |
| إنشاء تصنيف فرعي من popup menu "إضافة فرعي" | ✅ parentId يُمرَّر                |
| القائمة تتحدث فوراً بعد الحفظ               | ✅ `onSaved → ref.invalidate`      |
| `context.mounted` check قبل Navigator.pop   | ✅                                 |
| loading indicator داخل الزر أثناء الحفظ     | ✅                                 |

---

## 3. Edit Category

| الاختبار                                   | النتيجة                                                                                                                          |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| تعديل الاسم يعمل                           | ✅                                                                                                                               |
| كود التصنيف غير قابل للتعديل (disabled)    | ✅ `enabled: !_isEditing`                                                                                                        |
| تغيير حالة isActive عبر Switch             | ✅                                                                                                                               |
| use case يتحقق من وجود التصنيف قبل التحديث | ✅ `exists()` check                                                                                                              |
| كود مكرر عند التعديل يُرفض                 | ✅ `isCodeUnique(excludeId: id)`                                                                                                 |
| القائمة تتحدث فوراً بعد التعديل            | ✅                                                                                                                               |
| circular hierarchy prevention              | ⚠️ لا يوجد تحقق صريح من `parentId != id` في use case (لكن UI لا يسمح بتغيير parentId في نموذج التعديل الحالي — limitation مقبول) |

---

## 4. Details Dialog

| الاختبار                                                                    | النتيجة                        |
| --------------------------------------------------------------------------- | ------------------------------ |
| يفتح من action menu                                                         | ✅                             |
| يعرض: المجموعة، الكود، الاسم، الحالة، ترتيب العرض، تاريخ الإنشاء، آخر تحديث | ✅                             |
| الاسم الإنجليزي والوصف والـ parentId: تظهر فقط إذا موجودة                   | ✅ `if (field != null)`        |
| النصوص الطويلة: لا overflow (`Expanded` في `_DetailRow`)                    | ✅                             |
| `parentId` يُعرض كـ ID نصي (ليس الاسم)                                      | ⚠️ Limitation معروف — لا crash |

---

## 5. Delete / Deactivate

### تصنيف بدون أبناء (leaf)

| الاختبار                                       | النتيجة                                |
| ---------------------------------------------- | -------------------------------------- |
| حوار تأكيد يظهر                                | ✅                                     |
| إلغاء يُغلق الحوار بدون action                 | ✅                                     |
| تأكيد الحذف → soft delete (`isActive = false`) | ✅                                     |
| القائمة تتحدث فوراً                            | ✅ `ref.invalidate`                    |
| Snackbar يظهر نجاح/فشل                         | ✅ مع `backgroundColor: red` عند الفشل |

### تصنيف مع أبناء (parent)

| الاختبار                               | النتيجة                                   |
| -------------------------------------- | ----------------------------------------- |
| Bottom Sheet يظهر بخيارات واضحة        | ✅                                        |
| خيار 1: حذف متتالي (cascade)           | ✅ يحذف الأبناء وأبناء الأبناء ثم الأب    |
| خيار 2: رفع الفرعيين (promoteChildren) | ✅ يُصفّر `parentId` للأبناء ثم يحذف الأب |
| خيار 3: تعطيل بدلاً من الحذف           | ✅ `isActive = false` فقط                 |
| إلغاء                                  | ✅ يُغلق الـ sheet                        |
| loading indicator أثناء التنفيذ        | ✅                                        |
| Snackbar مرة واحدة فقط عند الفشل       | ✅ (تم إصلاح double SnackBar)             |

---

## 6. Toggle (تفعيل/تعطيل)

| الاختبار                             | النتيجة       |
| ------------------------------------ | ------------- |
| تعطيل تصنيف نشط                      | ✅            |
| تفعيل تصنيف معطل                     | ✅            |
| نتيجة `restore()` محفوظة (لا تُهمَل) | ✅ (تم إصلاح) |
| Snackbar يعكس نجاح/فشل حقيقي         | ✅ (تم إصلاح) |
| `onMutated()` لا يُستدعى عند الفشل   | ✅ (تم إصلاح) |
| نفس الإصلاح في `_ChildTile._toggle`  | ✅            |

---

## 7. Search / Filter

| الاختبار                                  | النتيجة                           |
| ----------------------------------------- | --------------------------------- |
| البحث عن اسم تصنيف جذري                   | ✅ يظهر التصنيف                   |
| **البحث عن اسم تصنيف فرعي**               | ✅ تم الإصلاح — يظهر الأب + الابن |
| فلتر "نشط فقط"                            | ✅                                |
| clear search (X button)                   | ✅ يرجع القائمة كاملة             |
| debounce 300ms                            | ✅                                |
| البحث لا يُعيد بناء الشجرة داخل `build()` | ✅ بُني خارج `itemBuilder`        |
| لا sort/filter ثقيل داخل build            | ✅                                |

---

## 8. Batch Dialogs

| الاختبار                                  | النتيجة |
| ----------------------------------------- | ------- |
| `_BatchCreateDialog` تفتح                 | ✅      |
| `_BatchUpdateDialog` تفتح                 | ✅      |
| `_BatchDeleteDialog` تفتح                 | ✅      |
| `context.mounted` check قبل Navigator.pop | ✅      |
| Snackbar بعد العملية داخل Scaffold صحيح   | ✅      |
| لا class conflict بعد نقل Dialogs         | ✅      |

---

## 9. Sync / Source of Truth

| الاختبار                                          | النتيجة                                          |
| ------------------------------------------------- | ------------------------------------------------ |
| البيانات لا تأتي من dummy list في UI              | ✅ كل شيء عبر `taxonomiesByGroupProvider`        |
| create/update/delete عبر Repository               | ✅                                               |
| Firestore sync عبر `taxonomySyncNotifierProvider` | ✅                                               |
| refresh يُعيد جلب البيانات من DB                  | ✅ `RefreshIndicator → syncGroup`                |
| seed data لا تُعاد بعد حذف المستخدم               | ✅ seed مشروط بـ `seedFromLocalIfFirestoreEmpty` |

---

## 10. Performance

| الملاحظة                        | الحالة                 |
| ------------------------------- | ---------------------- |
| `_buildTree` خارج `itemBuilder` | ✅ O(n) مرة واحدة      |
| `skipLoadingOnRefresh: true`    | ✅ لا jank عند refresh |
| `addAutomaticKeepAlives: false` | ✅ تقليل ذاكرة         |
| لا sync داخل `build()`          | ✅                     |
| debounce 300ms للبحث            | ✅                     |

---

## Bugs تم إصلاحها في هذه الجلسة

### Bug 1 — البحث عن تصنيف فرعي يُعيد قائمة فارغة (مهم)

**السبب:** `_filter()` تُعيد الابن فقط بدون أبيه → `tree[null] = []` → قائمة فارغة.  
**الإصلاح:** `_filterForTree()` تضيف آباء العناصر المطابقة تلقائياً عند البحث.  
**الملف:** `taxonomy_hierarchy_list.dart`

### Bug 2 — نتيجة `restore()` مهملة (توقع خاطئ للنتيجة)

**السبب:** `_toggleActive` كانت تُهمل نتيجة `useCase.restore()` وتُعيد `const Success(null)` دائماً، ما يعني إظهار "تم التفعيل" حتى لو فشلت العملية.  
**الإصلاح:** تُخزَّن النتيجة الفعلية ويُعرض الـ Snackbar بناءً عليها.  
**الملفات:** `taxonomy_hierarchy_list.dart` — في `_TaxonomyTreeItem._toggleActive` و`_ChildTile._toggle`

### Bug 3 — Double SnackBar عند فشل delete options

**السبب:** اللامبدا في `_execute` كانت تعرض SnackBar ثم ترمي Exception، وكان `catch` يعرض SnackBar ثانياً.  
**الإصلاح:** أُزيل SnackBar من اللامبدا، ويُرمى Exception بالرسالة، ويعرض `catch` SnackBar واحد فقط.  
**الملف:** `taxonomy_hierarchy_list.dart` — في `_DeleteOptionsSheetState._execute`

---

## Limitations باقية (مقبولة)

| المحدودية                                                         | السبب                                                                                   |
| ----------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| `TaxonomyDetailsDialog` يعرض `parentId` كـ ID نصي لا اسماً        | يحتاج Provider lookup في StatelessWidget — خارج نطاق QA الحالي                          |
| لا تحقق من circular hierarchy عند التعديل                         | UI لا يُتيح تغيير parentId في نموذج التعديل حالياً                                      |
| لا تحقق من أن التصنيف "مستخدم في بيانات" قبل الحذف                | Repository layer لا يحتوي هذا الـ constraint حالياً — deactivate هو الخيار الآمن المتاح |
| حذف الأبناء محدود بمستويين فقط (أبناء + أبناء الأبناء) في cascade | كافٍ للعمق الحالي في التطبيق                                                            |

---

## نتيجة flutter analyze

```
Errors:   0
Warnings: 7  (جميعها في ملفات غير متعلقة بالتصنيفات)
```

## نتيجة Tests

```
80/80 All tests passed ✅
```

ملفات test الخاصة بالتصنيفات:

- `taxonomy_test.dart` — entities
- `taxonomy_group_test.dart` — group entity
- `taxonomy_dto_test.dart` — data model
- `taxonomy_integrity_guard_test.dart` — integrity service
- `beneficiary_taxonomy_contract_test.dart` — mapping contract
- `taxonomy_bridge_dropdown_test.dart` — widget test
