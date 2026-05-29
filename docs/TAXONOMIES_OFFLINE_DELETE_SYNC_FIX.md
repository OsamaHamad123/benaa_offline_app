# إصلاح الحذف والمزامنة في وضع Offline للتصنيفات

**التاريخ:** 2025  
**النطاق:** `taxonomy_repository_impl.dart` · `taxonomy_remote_datasource.dart`

---

## المشكلة

عند تنفيذ حذف تصنيف (أو إنشاء/تحديث)، كانت العملية تفشل بخطأ:

```
SocketException: Failed host lookup: 'disabled-api.example.com'
```

وكانت تكرّر المحاولة **3 مرات** بسبب منطق retry في `_withRetry`، مما يسبب:

- تأخيراً ملحوظاً في واجهة المستخدم
- رسائل خطأ مخيفة للمستخدم لا علاقة لها بما فعله
- فشل cascade delete كاملاً رغم أن البيانات محلية فقط
- عودة بيانات seed بعد الحذف عند Refresh (لأن الحذف لم يُنفَّذ محلياً أصلاً)

---

## السبب الجذري

### 1. Repository: Remote-first بدلاً من Local-first

جميع write operations كانت تستدعي الـ remote datasource **أولاً** قبل الحذف/الحفظ محلياً:

```dart
// قبل الإصلاح — deleteTaxonomy
await _remoteDataSource.deleteTaxonomy(id); // ← يفشل بـ SocketException
await _localDataSource.deleteTaxonomy(id);  // ← لا يُنفَّذ أبداً
```

### 2. `_isRetryableDioError`: يُعيد المحاولة عند DNS lookup failure

`DioExceptionType.connectionError` كان مُدرجاً كـ "قابل للإعادة"، وهذا يشمل `SocketException: Failed host lookup` — فكانت كل عملية تُجري **3 اتصالات فاشلة** بدلاً من واحدة.

### 3. `_legacyRestSyncEnabled = false` بشكل افتراضي

المعامل `legacyRestSyncEnabled` كان يُستخدم فقط في `syncFromServer()` وليس في عمليات الكتابة، رغم أن التوقع الصحيح هو تخطي كل الاتصالات بالـ API عندما يكون `false`.

---

## الإصلاح

### `taxonomy_remote_datasource.dart` — لا تعيد المحاولة عند DNS failure

```dart
bool _isRetryableDioError(DioException e) {
  // ...
  // DNS lookup failures are not transient — never retry them.
  if (e.type == DioExceptionType.connectionError) {
    final msg = e.error?.toString() ?? '';
    if (msg.contains('Failed host lookup') || msg.contains('SocketException')) {
      return false;
    }
  }
  // ...
}
```

### `taxonomy_repository_impl.dart` — Local-first لجميع عمليات الكتابة

| العملية                 | قبل                  | بعد                                   |
| ----------------------- | -------------------- | ------------------------------------- |
| `createTaxonomy`        | Remote أولاً → Local | Local أولاً → Remote (إن كان مفعّلاً) |
| `updateTaxonomy`        | Remote أولاً → Local | Local أولاً → Remote (إن كان مفعّلاً) |
| `deleteTaxonomy`        | Remote أولاً → Local | Local أولاً → Remote (إن كان مفعّلاً) |
| `createTaxonomiesBatch` | Remote فقط           | Local fallback إن كان Remote معطّلاً  |
| `updateTaxonomiesBatch` | Remote فقط           | Local fallback إن كان Remote معطّلاً  |
| `deleteTaxonomiesBatch` | Remote فقط           | Local fallback إن كان Remote معطّلاً  |

```dart
// مثال — deleteTaxonomy بعد الإصلاح
await _localDataSource.deleteTaxonomy(id);   // ← يُنفَّذ دائماً أولاً

if (!_legacyRestSyncEnabled) {
  developer.log('Taxonomy remote sync skipped: API disabled', name: 'TaxonomyRepo');
  return const Success(null);  // ← ينتهي هنا إذا كان API معطّلاً
}

try {
  await _remoteDataSource.deleteTaxonomy(id, group: ...);
} catch (e) {
  developer.log('remote delete error — local delete retained');
}

return const Success(null);  // ← دائماً نجاح إذا نجح الحذف المحلي
```

---

## سلوك النظام بعد الإصلاح

### عندما `legacyRestSyncEnabled = false` (الحالة الافتراضية):

- الحذف المحلي يُنفَّذ فوراً ✅
- لا اتصال شبكي ✅
- لا `SocketException` ✅
- البيانات لا تعود بعد Refresh ✅
- log: `Taxonomy remote sync skipped: API disabled`

### عندما `legacyRestSyncEnabled = true` (API حقيقي):

- الحذف المحلي يُنفَّذ أولاً ✅
- يُحاول المزامنة مع الـ API ✅
- إذا فشل الـ API: الحذف المحلي محفوظ، log تحذيري ✅
- إذا نجح: مزامنة كاملة ✅

### تقليل retry من 3 إلى 1 لـ DNS failures:

- قبل: كل حذف يُجري 3 اتصالات بـ `disabled-api.example.com`
- بعد: صفر اتصالات (إذا `legacyRestSyncEnabled = false`), أو اتصال واحد يفشل فوراً

---

## بيانات Seed

مشكلة عودة بيانات Seed بعد الحذف كانت ناتجة عن:

1. الحذف المحلي لم يُنفَّذ (Remote-first يفشل → يستثنى الكود المحلي)
2. الحل الجذري: Local-first يضمن حذف البيانات محلياً دائماً

---

## تفعيل REST Sync (للتطوير أو الإنتاج)

```bash
flutter run --dart-define=ENABLE_LEGACY_TAXONOMY_REST_SYNC=true
```

لن يُفعَّل حتى مع هذا العلم إذا كان `baseUrl` يحتوي `disabled-api.example.com` أو إذا كان `BackendFlavor.firebase`.
