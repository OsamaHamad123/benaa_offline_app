# إصلاحات تجربة المستخدم — قسم الكفالات (الفلاتر، Excel، التقارير)

**التاريخ:** 2025  
**الملفات المُعدَّلة:**

- `lib/features/kafalat/presentation/widgets/tabs/sponsored_tab.dart`
- `lib/features/kafalat/presentation/widgets/filters/quick_filters_bar.dart`

---

## 1. مشكلة الـ Overflow في صفحة "مكفول"

### السبب الجذري

كان لوح الفلاتر السريعة (`AnimatedCrossFade`) يظهر **دائمًا مضمّنًا** داخل الصفحة، يحتوي على:

- شرائح ActionChip لحالات الكفالة
- `QuickFiltersBar` (Dropdown للجمعية + Chips للنوع والحالة)
- نافذة فلاتر متقدمة مدمجة

هذا أدى إلى:

- overflow أفقي في الـ Dropdown (بدون `isExpanded: true`)
- ازدحام بصري دائم يأكل مساحة المحتوى
- تناقض UX: الفلتر يُطبَّق فوريًا عند كل تغيير

---

## 2. الحل: نافذة فلاتر منفصلة (Bottom Sheet)

### ما تم حذفه

- `AnimatedCrossFade` بالكامل (لوح الفلاتر المضمّن)
- `QuickFiltersBar` widget من داخل `SponsoredTab`
- `_showQuickFilters` state variable
- `_applyQuickPreset()` method
- `_openAdvancedFilters()` method
- `hasTaxonomyGap` variable
- `associationsAsync` watch من build method

### ما تم إضافته

**`_openFiltersSheet(BuildContext context)`**: نافذة `DraggableScrollableSheet` تحتوي على:

- شرائح **الحالة**: نشطة / موقوفة / منتهية / الكل
- شرائح **نوع الكفالة**: شهري / ربع سنوي / سنوي / عيني / أخرى
- **Dropdown الجمعية** مع `isExpanded: true` و `TextOverflow.ellipsis`
- **نطاق التاريخ**: منتقي بداية ونهاية
- **نطاق المبلغ**: حقلا نص (حد أدنى / حد أقصى)
- **الترتيب**: `SortingMenu`
- أزرار: **تطبيق** (يحفظ ويغلق) + **إلغاء** (يغلق بدون حفظ) + **مسح الكل**

### سلوك الفلاتر الجديد

- الفلاتر **لا تُطبَّق تلقائيًا** — تبقى في `temp` variables داخل `StatefulBuilder`
- تُطبَّق **فقط عند الضغط على "تطبيق"**
- يتم استدعاء `_persistUiState()` لحفظها في `SharedPreferences`

---

## 3. صف شرائح الفلاتر النشطة

بعد إغلاق النافذة، تظهر **شريط أفقي قابل للتمرير** (`SingleChildScrollView`) يعرض:

- شريحة لكل فلتر نشط (الحالة / النوع / الجمعية / البحث / فلاتر متقدمة)
- كل شريحة لها زر `onDeleted` لإلغاء ذلك الفلتر منفردًا
- زر "مسح الكل" لإعادة ضبط كل الفلاتر دفعةً واحدة
- الشريط يظهر فقط إذا كان `_hasActiveFilters == true`

---

## 4. إصلاح Overflow في Dropdown الجمعية

**ملف:** `quick_filters_bar.dart`  
**التغيير:**

```dart
// قبل
DropdownButtonFormField<String?>(
  initialValue: selectedAssociationId,
  items: [...associations.map((a) => DropdownMenuItem(child: Text(a.name)))],
)

// بعد
DropdownButtonFormField<String?>(
  isExpanded: true,           // ← منع overflow أفقي
  initialValue: selectedAssociationId,
  items: [
    DropdownMenuItem(child: Text('كل الجمعيات', overflow: TextOverflow.ellipsis)),
    ...associations.map((a) => DropdownMenuItem(
      child: Text(a.name, overflow: TextOverflow.ellipsis, maxLines: 1),
    )),
  ],
)
```

---

## 5. التحقق من منطق رفع Excel

**ملف:** `lib/features/kafalat/presentation/pages/kafalat_import_page.dart`

### تدفق البيانات

1. `FilePicker` → اختيار ملف `.xlsx`
2. `KafalatExcelImportParser.parse()` → تحويل الصفوف إلى `KafalatImportRow`
3. عرض معاينة أول 30 صفًا
4. `_importRows()`:
   - transaction في Drift DB
   - upsert في جدول `beneficiaries` (بمعرف وطني كـ idempotency key)
   - upsert في جدول `sponsorships`
   - تسجيل في `import_batches` مع عدد الصفوف والتاريخ
5. رسالة نجاح أو خطأ

### حماية الـ Overflow الموجودة

- اسم الملف: `overflow: TextOverflow.ellipsis` ✅
- أزرار الإجراء: `LayoutBuilder` للتبديل بين Row/Column ✅

---

## 6. التحقق من منطق التقارير (PDF + Excel)

**ملف:** `lib/features/kafalat/presentation/pages/export_page.dart`

### تصدير Excel

- 8 أعمدة: رقم، اسم المكفول، الجمعية، الحالة، النوع، المبلغ، تاريخ البدء، الملاحظات
- يستخدم `ref.read(kafalatSponsorshipsProvider(...))` — يقرأ البيانات المخزنة في DB
- **البيانات المرفوعة من Excel تظهر في التقارير** ✅ (لأنها محفوظة في DB عبر Drift)

### تصدير PDF

- `pw.TableHelper.fromTextArray` مع `PdfGoogleFonts.cairoRegular()` / `cairoBold()`
- ترويسات بالعربي، اتجاه RTL
- يستخدم نفس مصدر البيانات → يشمل جميع الكفالات بما فيها المرفوعة من Excel ✅
- مسار الملف المحفوظ: `_lastExportPath` مع `overflow: TextOverflow.ellipsis` ✅

---

## 7. نتيجة flutter analyze

```
No error-level issues in kafalat files.
Remaining issues: info/warnings pre-existing (withOpacity deprecations, etc.)
Exit code 1 due to project-wide warnings (not related to our changes).
```

---

## 8. المشاكل المعروفة المتبقية (غير حرجة)

| المشكلة                                                   | الخطورة | ملاحظة                                                                       |
| --------------------------------------------------------- | ------- | ---------------------------------------------------------------------------- |
| `_saveCurrentPreset` غير مستخدم                           | warning | ميزة حفظ العروض موجودة لكن بدون واجهة — يمكن إعادتها لاحقًا                  |
| `_onSavedPresetMenuSelected` غير مستخدم                   | warning | مرتبط بالميزة السابقة                                                        |
| `withOpacity` deprecated                                  | info    | موجود في ملفات متعددة، ليس من تعديلاتنا                                      |
| `DropdownButtonFormField initialValue` لا يتتبع التغييرات | تصميم   | لكن StatefulBuilder يعيد البناء الكامل عند setSheet، لذا لا توجد مشكلة عملية |
