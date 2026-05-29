# Taxonomies Offline-First Architecture Fix

## المشكلة القديمة

كانت التصنيفات (taxonomies/categories) تعاني من عدة مشاكل أساسية تجعلها غير متوافقة مع مبدأ Offline-First:

### 1. `bridgeTaxonomiesIndexOnceProvider` يُدرج التصنيفات المحذوفة

```dart
// ❌ كان: يجلب getAllTaxonomies() بدون فلترة
final allItems = await db.taxonomiesDao.getAllTaxonomies();
for (final row in allItems) {
  final taxonomy = _convertFromDrift(row); // يُدرج المحذوف!
  index[taxonomy.group]!.add(taxonomy);
}
```

الـ `bridgeTaxonomiesByGroupOnceProvider` الذي تستخدمه كل الفورمز والدروب داون كان يعتمد على هذا الـ index، مما يعني أن التصنيفات المحذوفة كانت تظهر في الـ UI.

### 2. `_saveCanonicalDtos` يُحيي التصنيفات المحذوفة

```dart
// ❌ كان: insertOnConflictUpdate يُكتب فوق isActive=false بـ isActive=true
await local.upsertCompanions(companions); // → upsertBatch → insertOnConflictUpdate
```

أي sync من السيرفر كان يُعيد إحياء التصنيفات التي حذفها المستخدم محلياً.

### 3. `_syncFromFirestoreOrSkip` نفس المشكلة

```dart
// ❌ كان
await _localDataSource.saveTaxonomies(remoteItems); // يُكتب فوق المحذوف
```

### 4. `_enforceTaxonomyIntegrity` يُضيف fallbacks بعد الحذف

```dart
// ❌ كان: countByGroup يحسب النشط فقط → إذا count=0 بسبب حذف محلي، يُضيف fallbacks
final missingCriticalGroups = _integrityGuard.missingCriticalFallbackGroups(stats);
// يُدرج: 'فئة عامة' و 'ذكر/أنثى' حتى لو المستخدم حذفها عمداً
```

### 5. `_backfillMissingGroups` يجلب من السيرفر بعد الحذف

```dart
// ❌ كان: إذا group count=0، يُعيد الجلب من remote
if (entry.value <= 0) missingGroups.add(entry.key); // لا يميز الحذف من عدم الوجود
```

---

## Source of Truth الجديد

```
التطبيق يقرأ من LOCAL دائماً
         ↑
    Drift Database
         ↑
    TaxonomiesDao.watchByGroup(group, activeOnly: true)
         ↑
    sync_providers (categoriesProvider, governoratesProvider, ...)
         ↑
    taxonomy_bridge_providers (bridgeTaxonomiesByGroupProvider, ...)
         ↑
    UI: forms / dropdowns / filters
```

**السيرفر يُستخدم فقط عند:**

- ضغط المستخدم Sync/Refresh
- عند تشغيل التطبيق إذا sync مفعّل
- بشكل دوري (background sync)
- عند رجوع الاتصال بالإنترنت

---

## الإصلاحات المطبّقة

### Fix 1: `bridgeTaxonomiesIndexOnceProvider` — فلترة isActive

**الملف:** `lib/features/taxonomies/presentation/providers/taxonomy_bridge_providers.dart`

```dart
// ✅ الجديد: تخطي التصنيفات المحذوفة/غير النشطة
for (final row in allItems) {
  if (!row.isActive) continue; // ← هذا السطر أُضيف
  final taxonomy = _convertFromDrift(row);
  if (taxonomy == null) continue;
  index[taxonomy.group]!.add(taxonomy);
}
```

**الأثر:** كل dropdown/form يستخدم `bridgeTaxonomiesByGroupOnceProvider` لن يعرض التصنيفات المحذوفة أبداً.

---

### Fix 2: `syncSafeUpsertBatch` في DAO — احترام الحذف المحلي

**الملف:** `lib/data/db/daos/taxonomies_dao.dart`

```dart
Future<void> syncSafeUpsertBatch(List<TaxonomiesCompanion> companions) async {
  if (companions.isEmpty) return;

  // جلب IDs المحذوفة محلياً
  final deletedRows = await (select(taxonomies)..where((t) => t.isActive.equals(false))).get();
  final locallyDeletedIds = {for (final r in deletedRows) r.id};

  // تصفية — لا نُعيد إحياء المحذوف
  final safeCompanions = companions.where((c) {
    final id = c.id.present ? c.id.value : null;
    if (id == null) return true;
    return !locallyDeletedIds.contains(id);
  }).toList();

  if (safeCompanions.isEmpty) return;
  await upsertBatch(safeCompanions);
}
```

---

### Fix 3: `saveTaxonomiesFromSync` في DataSource — الطبقة المجردة

**الملف:** `lib/features/taxonomies/data/datasources/taxonomy_local_datasource.dart`

أُضيفت دالة `saveTaxonomiesFromSync` في abstract interface بتطبيق افتراضي آمن، مع override حقيقي في كل implementation:

- `TaxonomyLocalDriftDataSource` → يستخدم `syncSafeUpsertBatch`
- `TaxonomyLocalDataSourceImpl` (SharedPreferences) → يفلتر بـ `isDeleted`

---

### Fix 4: `_saveCanonicalDtos` في Repository — استخدام sync-safe upsert

**الملف:** `lib/features/taxonomies/data/repositories/taxonomy_repository_impl.dart`

```dart
// ✅ الجديد: sync-safe — لا يُعيد إحياء المحذوف محلياً
await local.upsertCompanionsFromSync(companions);
// بدلاً من:
// await local.upsertCompanions(companions); ← كان unsafe
```

---

### Fix 5: `_syncFromFirestoreOrSkip` — sync-safe

```dart
// ✅ الجديد
await _localDataSource.saveTaxonomiesFromSync(remoteItems);
// بدلاً من:
// await _localDataSource.saveTaxonomies(remoteItems); ← كان unsafe
```

---

### Fix 6: `TaxonomyStatistics` — إضافة `deletedCountByGroup`

**الملف:** `lib/features/taxonomies/domain/entities/taxonomy.dart`

```dart
class TaxonomyStatistics extends Equatable {
  // ... الحقول الموجودة

  /// عدد التصنيفات المحذوفة محلياً لكل مجموعة
  final Map<TaxonomyGroup, int> deletedCountByGroup;

  /// هل المجموعة تحتوي على تصنيفات حذفها المستخدم عمداً؟
  bool hasLocallyDeletedItems(TaxonomyGroup group) {
    return (deletedCountByGroup[group] ?? 0) > 0;
  }
}
```

---

### Fix 7: `_enforceTaxonomyIntegrity` — تخطي المجموعات المحذوفة

```dart
// ✅ الجديد: لا fallbacks للمجموعات التي حذف منها المستخدم عمداً
final groupsEligibleForFallback = missingCriticalGroups.where((group) {
  return !stats.hasLocallyDeletedItems(group);
}).toList();
```

---

### Fix 8: `_backfillMissingGroups` — تخطي المجموعات المحذوفة

```dart
// ✅ الجديد: لا إعادة جلب من remote للمجموعات التي حذف منها المستخدم
if (entry.value <= 0 && !stats.hasLocallyDeletedItems(entry.key)) entry.key,
// بدلاً من:
// if (entry.value <= 0) entry.key, ← لا يميز الحذف من عدم الوجود
```

---

## Delete/Tombstone Strategy

التطبيق يستخدم **Soft Delete** عبر `isActive = false`:

| العملية                       | السلوك                                           |
| ----------------------------- | ------------------------------------------------ |
| `deleteTaxonomy(id)`          | يضع `isActive = false` (لا حذف فيزيائي)          |
| `watchByGroup(group)`         | يُرجع `isActive = true` فقط (افتراضي)            |
| `getAllTaxonomies()`          | يُرجع الكل بما في ذلك المحذوف (للإدارة الداخلية) |
| `syncSafeUpsertBatch()`       | يتجاهل الـ companions التي IDs-ها محذوفة محلياً  |
| `_enforceTaxonomyIntegrity()` | لا يُضيف fallbacks إذا بالمجموعة حذف محلي        |
| `_backfillMissingGroups()`    | لا يجلب من remote إذا بالمجموعة حذف محلي         |

---

## Conflict Policy

| الحالة                         | القرار                                                             |
| ------------------------------ | ------------------------------------------------------------------ |
| Local deleted + Remote active  | **Local يفوز** — لا إحياء                                          |
| Local active + Remote deleted  | يُحدَّث محلياً (يُطبق الحذف من السيرفر)                            |
| Local pending + Remote updated | Local pending يُحفظ حتى sync ناجح                                  |
| Remote غير متاح                | Local يعمل بشكل مستقل تام                                          |
| disabled-api.example.com       | `legacyTaxonomyRestSyncEnabledProvider = false` → لا network calls |

---

## Providers المحلية فقط (Local-Only)

| Provider                              | المصدر                                                     |
| ------------------------------------- | ---------------------------------------------------------- |
| `categoriesProvider`                  | `taxonomiesDao.watchByGroup('category')` — Drift stream    |
| `governoratesProvider`                | `taxonomiesDao.watchByGroup('governorate')` — Drift stream |
| `bridgeTaxonomiesByGroupProvider`     | `taxonomiesDao.watchByGroup(group.value)` — Drift stream   |
| `bridgeTaxonomiesIndexOnceProvider`   | `taxonomiesDao.getAllTaxonomies()` + فلتر `isActive`       |
| `bridgeTaxonomiesByGroupOnceProvider` | يعتمد على `bridgeTaxonomiesIndexOnceProvider`              |
| `allTaxonomiesProvider`               | `localDataSource.getAllTaxonomies()`                       |
| `taxonomiesByGroupProvider`           | `localDataSource.getTaxonomiesByGroup(group)`              |

**لا يوجد provider يستدعي remote مباشرة عند القراءة للـ UI.**

---

## Sync فقط

الـ Remote يُستخدم فقط عبر:

- `syncTaxonomiesUseCaseProvider` → `TaxonomyRepository.syncFromServer()`
- `TaxonomyAutoSyncManager` (background/foreground)
- زر Sync/Refresh يدوي
- **ليس** عند فتح forms/dropdowns/pages

---

## Remote Disabled Guard

في `legacyTaxonomyRestSyncEnabledProvider`:

```dart
// لا sync إذا:
// 1. لم يُفعَّل صراحةً بـ --dart-define
// 2. flavor = firebase
// 3. baseUrl يحتوي 'disabled-api.example.com'
final isDisabledPlaceholder = baseUrl.contains('disabled-api.example.com');
if (isDisabledPlaceholder) return false;
```

عند `legacyRestSyncEnabled = false`:

- كل CRUD operations تعمل محلياً فقط
- لا SocketException متكرر
- لا retry للشبكة
- UI يعمل بالكامل من local

---

## Tests المضافة

**الملف:** `test/features/taxonomies/data/datasources/taxonomy_offline_first_test.dart`

| Test                                             | الهدف                             |
| ------------------------------------------------ | --------------------------------- |
| `hasLocallyDeletedItems returns false`           | TaxonomyStatistics صحيحة بدون حذف |
| `hasLocallyDeletedItems returns true`            | TaxonomyStatistics صحيحة مع حذف   |
| `empty() has zero deleted counts`                | empty factory صحيح                |
| `saveTaxonomiesFromSync does not resurrect`      | الـ sync لا يُعيد إحياء المحذوف   |
| `saves new taxonomy from sync`                   | التصنيف الجديد يُحفظ              |
| `updates existing active taxonomy from sync`     | التحديث يعمل للنشط                |
| `getTaxonomiesByGroup excludes inactive`         | الـ query يُرجع النشط فقط         |
| `soft-deletes taxonomy and hides it`             | الحذف المرن يُخفي التصنيف         |
| `deleted taxonomy does not return after restart` | الحذف مستمر عبر إعادة التشغيل     |
| `tombstone survival across sync rounds`          | الـ tombstone يبقى عبر جولات sync |

**النتيجة:** 10/10 ✅

---

## نتيجة flutter analyze

الأخطاء المتعلقة بالتصنيفات: **0 errors**.

الـ warnings الموجودة قبل هذه التغييرات (غير ذات صلة بالتصنيفات):

- `_firstIncompleteTabIndex` في `beneficiary_form_page_v3.dart`
- `_applySavedPreset` و `_deleteSavedPreset` في `sponsored_tab.dart`

---

## التحقق اليدوي المقترح

```
1. شغّل التطبيق offline
2. افتح form يستخدم تصنيفات (مثل إضافة مستفيد)
3. تأكد أن التصنيفات تظهر من local بدون loading
4. احذف تصنيف من لوحة التصنيفات
5. افتح نفس الفورم → يجب أن لا يظهر التصنيف المحذوف
6. أعد تشغيل التطبيق → التصنيف لا يرجع
7. فعّل sync مع remote disabled → لا SocketException
8. فعّل sync مع disabled-api.example.com → يُتخطى بهدوء
```
