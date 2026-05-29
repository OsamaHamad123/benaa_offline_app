# لوحة إدارة التصنيفات الهرمية — دليل التطوير

**التاريخ:** 2025  
**الحالة:** مكتمل ✅

---

## 1. ملخص التغييرات

### 1.1 المشكلات التي تم حلها

| المشكلة                                      | الحل                                                                    |
| -------------------------------------------- | ----------------------------------------------------------------------- |
| الصفحة لا تتحدث بعد الحذف                    | إضافة `ref.invalidate(taxonomiesByGroupProvider(group))` صريح بعد الحذف |
| ضعف الأداء عند التحديث                       | إضافة `skipLoadingOnRefresh: true` لتفادي وميض الـ loading              |
| حذف تصنيف أب يفشل بصمت                       | عرض Bottom Sheet بثلاثة خيارات بديلة                                    |
| القائمة المسطحة لا تعبّر عن العلاقات الهرمية | استبدالها بشجرة `ExpansionTile`                                         |

---

## 2. الملفات المُعدَّلة

### 2.1 ملفات Domain Layer

| الملف                                                            | التغيير                                        |
| ---------------------------------------------------------------- | ---------------------------------------------- |
| `lib/features/taxonomies/domain/entities/taxonomy.dart`          | أضيف `clearParentId` parameter لـ `copyWith()` |
| `lib/features/taxonomies/domain/usecases/taxonomy_usecases.dart` | أضيف 3 methods لـ `DeleteTaxonomyUseCase`      |

### 2.2 ملفات Presentation Layer

| الملف                                                                       | التغيير                                                                       |
| --------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| `lib/features/taxonomies/presentation/widgets/taxonomy_hierarchy_list.dart` | **جديد** — قائمة شجرية كاملة                                                  |
| `lib/features/taxonomies/presentation/widgets/taxonomy_widgets.dart`        | نقل `TaxonomyFormDialog` + `TaxonomyDetailsDialog` + إضافة `parentId` param   |
| `lib/features/taxonomies/presentation/pages/taxonomy_management_page.dart`  | استبدال `_TaxonomyGroupList` بـ `TaxonomyHierarchyList` + حذف dialogs القديمة |

---

## 3. Architecture

### 3.1 الشجرة الهرمية — TaxonomyHierarchyList

```
TaxonomyHierarchyList (ConsumerStatefulWidget)
├── Search bar + Filter chip (مع debounce 300ms)
├── [فارغ] → EmptyState + زر مزامنة
├── [بحث بدون نتائج] → NoResultsState
└── RefreshIndicator
    └── ListView.builder
        └── _TaxonomyTreeItem (لكل تصنيف جذري)
            ├── [له أبناء] → ExpansionTile
            │   ├── Leading: نقطة حالة (أخضر/رمادي)
            │   ├── Title: اسم التصنيف
            │   ├── Subtitle: الكود
            │   ├── Trailing: badge عدد الأبناء + PopupMenu
            │   └── Children: List<_ChildTile>
            └── [بدون أبناء] → ListTile عادي
```

### 3.2 خوارزمية بناء الشجرة

```dart
// يُشغَّل مرة واحدة في data: handler
final roots = all.where((t) => !t.hasParent).toList();
final childrenMap = <String?, List<Taxonomy>>{};
for (final t in all.where((t) => t.hasParent)) {
  (childrenMap[t.parentId!] ??= []).add(t);
}
```

**التعقيد:** O(n) مرة واحدة عند تغيير البيانات — لا عمليات بداخل build().

---

## 4. منطق الحذف الذكي

### 4.1 حالة تصنيف بلا أبناء

→ حوار تأكيد بسيط → `deleteTaxonomy(id)` (soft delete: `isActive = false`)

### 4.2 حالة تصنيف له أبناء

→ Bottom Sheet بثلاثة خيارات:

| الخيار                    | الإجراء                | Use Case Method                             |
| ------------------------- | ---------------------- | ------------------------------------------- |
| حذف مع كل الفرعيين        | حذف متتالي (cascade)   | `DeleteTaxonomyUseCase.cascade(id)`         |
| رفع الفرعيين لمستوى رئيسي | promote → حذف الأب     | `DeleteTaxonomyUseCase.promoteChildren(id)` |
| تعطيل بدلاً من الحذف      | `isActive = false` فقط | `DeleteTaxonomyUseCase.deactivate(id)`      |

### 4.3 Use Case Methods الجديدة

```dart
// في DeleteTaxonomyUseCase:

/// حذف متتالي (recursive - مستوى واحد من الأبناء + أبناء الأبناء)
Future<Result<void>> cascade(String id)

/// ترقية الأبناء لمستوى رئيسي ثم حذف الأب
Future<Result<void>> promoteChildren(String id)

/// تعطيل بدلاً من الحذف (setIsActive = false)
Future<Result<void>> deactivate(String id)
```

---

## 5. إدارة الحالة (State Management)

### 5.1 التدفق عند الحذف

```
User taps Delete
    ↓
_TaxonomyTreeItem._confirmDelete()
    ↓
[لا أبناء] → showDialog(simple)     [له أبناء] → showModalBottomSheet()
    ↓                                     ↓
AlertDialog.confirm                   _DeleteOptionsSheet.onSelected()
    ↓                                     ↓
useCase.call(id)              useCase.cascade/promoteChildren/deactivate(id)
    ↓                                     ↓
onMutated()                           onMutated()
= ref.invalidate(                    = ref.invalidate(
    taxonomiesByGroupProvider(group))     taxonomiesByGroupProvider(group))
    ↓                                     ↓
ListView يعيد البناء تلقائياً     ListView يعيد البناء تلقائياً
    (skipLoadingOnRefresh: true)          (skipLoadingOnRefresh: true)
```

### 5.2 لماذا نستدعي Use Case مباشرةً (لا عبر Notifier)?

- `_DeleteOptionsSheet` يدير loading state محلياً بـ `_loading` boolean
- `onMutated()` يُعيد invalidate المجموعة المحددة فقط (أكفأ من invalidate الكل)
- تفادي تغيير `AsyncValue.loading` الذي يسبب وميض الـ UI

---

## 6. TaxonomyFormDialog — التحديثات

### 6.1 الجديد

- انتقل من `taxonomy_management_page.dart` → `taxonomy_widgets.dart` (إزالة circular dependency)
- أضيف `parentId` parameter لإنشاء تصنيفات فرعية جديدة
- تحسين `_isEditing` logic: `widget.taxonomy != null && widget.taxonomy!.id.isNotEmpty`

### 6.2 استخدام parentId

```dart
// إضافة تصنيف فرعي جديد
TaxonomyFormDialog(
  group: group,
  parentId: parentTaxonomy.id,
  onSaved: onMutated,
);
```

---

## 7. الأداء

| Optimization                    | مكان التطبيق            | الأثر                  |
| ------------------------------- | ----------------------- | ---------------------- |
| `skipLoadingOnRefresh: true`    | `TaxonomyHierarchyList` | لا وميض عند invalidate |
| `addAutomaticKeepAlives: false` | `ListView.builder`      | تقليل الذاكرة          |
| `addRepaintBoundaries: false`   | `ListView.builder`      | تقليل layers           |
| بناء الشجرة خارج `itemBuilder`  | `data:` handler         | O(n) مرة واحدة فقط     |
| debounce 300ms                  | Search field            | تقليل عمليات الفلتر    |

---

## 8. Business Logic المحفوظة

- ✅ soft delete فقط (isActive = false) — لا حذف نهائي إلا عبر permanentlyDelete
- ✅ cascade يعمل على مستويين (أبناء + أبناء الأبناء)
- ✅ promoteChildren يستخدم `copyWith(clearParentId: true)` لتصفير parentId
- ✅ لا يمكن تعديل الكود (`code`) بعد الإنشاء
- ✅ Firestore sync يعمل عبر Repository layer (لا يتأثر بالتغييرات)

---

## 9. الملفات المتأثرة بصورة غير مباشرة

لا شيء — التغييرات محصورة في feature taxonomies فقط.

---

## 10. اختبارات مقترحة

```dart
// test/features/taxonomies/domain/usecases/delete_taxonomy_usecase_test.dart

test('cascade deletes children before parent', () async { ... });
test('promoteChildren sets parentId to null for all children', () async { ... });
test('deactivate sets isActive = false without deleting', () async { ... });
```

```dart
// test/features/taxonomies/presentation/widgets/taxonomy_hierarchy_list_test.dart

testWidgets('shows ExpansionTile for taxonomy with children', ...);
testWidgets('shows delete options sheet when parent has children', ...);
testWidgets('shows simple dialog when taxonomy has no children', ...);
```
