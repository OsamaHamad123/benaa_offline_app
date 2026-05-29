# إصلاح AppBar Overflow وخطأ Route - صفحة الزيارات

**الملف المُعدَّل:** `lib/features/visits/presentation/pages/visits_list_page_m3.dart`  
**التاريخ:** 2025

---

## 1. مشكلة AppBar Overflow

### السبب

كانت الـ AppBar تحتوي على ثلاثة عناصر في الـ `actions`:

1. `IconButton` لتبديل عرض التقويم
2. `PopupMenuButton` للفلتر (مع Badge)
3. `PopupMenuButton` لخيارات إضافية (تصدير/تحديث)

بالإضافة إلى `bottom: PreferredSize(height: 60h)` يحتوي على `Row` مع 3 `FilterChip`s — كل منها يحمل أيقونة + نص + عدد. على الشاشات الصغيرة هذا الـ `Row` يتجاوز العرض المتاح مما يسبب overflow.

عنوان AppBar كان بحجم `20.sp` و`centerTitle: true` مما يضغط على المساحة المتبقية للـ actions.

### الإصلاح

**1. AppBar title:**

- حجم الخط: `20.sp` → `16.sp`
- `centerTitle: true` → `centerTitle: false`
- أضيف `maxLines: 1` و`overflow: TextOverflow.ellipsis`

**2. دمج قائمتي الـ PopupMenu في قائمة واحدة:**

- قبل: IconButton + PopupMenu (فلتر) + PopupMenu (خيارات) = 3 عناصر
- بعد: IconButton + PopupMenu واحد يجمع الفلتر والخيارات = عنصران

**3. نقل FilterChips من AppBar إلى body:**

- حُذف `bottom: PreferredSize(...)` من AppBar
- أضيف `_buildFilterBar()` كأول عنصر في `Column` داخل `body`
- يستخدم `SingleChildScrollView(scrollDirection: Axis.horizontal)` لدعم الشاشات الصغيرة جداً

---

## 2. خطأ Route عند الضغط على "تسجيل أول زيارة"

### السبب

الكود القديم:

```dart
context.push('/visits/record');
// و في مكان آخر:
context.push('/visits/record');
```

**Route `/visits/record` غير موجود في `app_router.dart`** — الـ router يعرّف فقط:

- `/visits` → `VisitsListPageM3`

بالإضافة لذلك، صفحة تسجيل الزيارة (`RecordVisitPageEnhanced` و`RecordVisitPageClean`) تتطلب كائن `Beneficiary` كاملاً، وليس مجرد معرّف، لذا لا يمكن جعلها route مستقل بدون context للمستفيد.

### الإصلاح

أضيفت دالة `_navigateToRecordVisit()`:

```dart
void _navigateToRecordVisit() {
  if (widget.beneficiaryId != null) {
    // إذا فُتحت الصفحة من سياق مستفيد معين، انتقل لصفحته
    context.push('/beneficiaries/${widget.beneficiaryId}');
  } else {
    // لا يوجد مستفيد — وجّه المستخدم لاختيار مستفيد أولاً
    context.push('/beneficiaries');
  }
}
```

**Route الصحيح الآن:**

- عند فتح "جميع الزيارات" بدون مستفيد: `/beneficiaries` (ليختار المستخدم مستفيداً ثم يسجل الزيارة من صفحته)
- عند فتح "زيارات مستفيد" بمعرّف: `/beneficiaries/:id` (يعيد المستخدم لصفحة المستفيد)

**Empty State:**  
الزر في `_buildEmptyState()` تحوّل من:

```dart
onPressed: () => context.push('/visits/record'),
label: const Text('تسجيل زيارة'),
```

إلى:

```dart
onPressed: _navigateToRecordVisit,
label: const Text('تسجيل أول زيارة'),
```

---

## 3. نتيجة flutter analyze

```
Errors:   0 ❌
Warnings: 0 ⚠️
Info:     10 ℹ️ (جميعها مسبقة — withOpacity deprecated، unawaited_futures، use_build_context_synchronously)
```

لا أخطاء جديدة من التغييرات المُجراة.
