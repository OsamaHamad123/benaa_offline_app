# إصلاح Overflow في Dropdown المؤسسة الكافلة

**التاريخ:** 2025  
**مستوى الخطورة:** متوسط — يظهر فقط مع بيانات فعلية وأسماء مؤسسات طويلة

---

## 1. الأماكن التي وُجد فيها Dropdown المؤسسة الكافلة

| الملف                                                                                       | السياق                  | نوع المشكلة                               |
| ------------------------------------------------------------------------------------------- | ----------------------- | ----------------------------------------- |
| `lib/features/kafalat/presentation/widgets/sponsorship_form_sheet.dart`                     | نموذج إضافة/تعديل كفالة | بدون `isExpanded`, `Text(a.name)` مجرد    |
| `lib/features/kafalat/presentation/widgets/tabs/unsponsored_tab.dart`                       | Bottom sheet تكفل جماعي | بدون `isExpanded`, بدون ellipsis          |
| `lib/features/kafalat/presentation/pages/kafalat_import_page.dart` → `_AssociationDropdown` | صفحة رفع Excel          | بدون `isExpanded`, `textAlign: right` فقط |
| `lib/features/kafalat/presentation/widgets/filters/quick_filters_bar.dart`                  | فلاتر الكفالات          | مُصلَح في جلسة سابقة                      |
| `lib/features/kafalat/presentation/widgets/tabs/sponsored_tab.dart` → `_openFiltersSheet`   | Bottom sheet الفلاتر    | مُصلَح في جلسة سابقة                      |

---

## 2. سبب المشكلة الأساسي

**السبب الجذري المشترك:**  
`DropdownButtonFormField` بدون `isExpanded: true` → الـ dropdown يحاول عرض الاسم كاملاً في الحقل مما يتجاوز عرضه.

أسباب فرعية:

- `Text(a.name)` بدون `overflow: TextOverflow.ellipsis` → النص يطغى على الحقل
- بدون `selectedItemBuilder` → نفس widget الـ dropdown item يُستخدم كـ selected display، وهو قد يكون أطول من الحقل
- أسماء المؤسسات تصل إلى 80+ حرف عربي أو إنجليزي

---

## 3. الحل: Widget مشترك `SponsorOrganizationDropdown`

**الملف المنشأ:**  
`lib/features/kafalat/presentation/widgets/common/sponsor_organization_dropdown.dart`

### المواصفات

| الخاصية          | التفاصيل                                                     |
| ---------------- | ------------------------------------------------------------ |
| النوع            | `ConsumerWidget` (Riverpod)                                  |
| المزود           | `kafalatActiveAssociationsProvider` — يُشاهَد داخلياً        |
| الـ overflow     | `isExpanded: true` + `TextOverflow.ellipsis` + `maxLines: 1` |
| الاختيار المعروض | `selectedItemBuilder` → نص مقطوع مناسب للحقل                 |
| بنود القائمة     | `Tooltip(message: a.name, child: Text(...))`                 |
| RTL              | مدعوم (Directionality يأتي من MaterialApp)                   |

### الحالات المُعالَجة

| الحالة | السلوك                                               |
| ------ | ---------------------------------------------------- |
| تحميل  | `InputDecorator` + `LinearProgressIndicator`         |
| خطأ    | `InputDecorator` + `errorText: 'فشل تحميل المؤسسات'` |
| فارغة  | `InputDecorator` + نص "لا توجد مؤسسات كافلة متاحة"   |
| بيانات | `DropdownButtonFormField` كامل المواصفات             |

### الـ parameters

```dart
SponsorOrganizationDropdown({
  required String? value,
  required ValueChanged<String?>? onChanged,
  String label = 'المؤسسة الكافلة',
  bool enabled = true,
  String? Function(String?)? validator,
  String? hintText,
})
```

---

## 4. كيفية التعامل مع الأسماء الطويلة

### داخل الحقل (selected display)

`selectedItemBuilder` يعرض `Text(a.name, overflow: TextOverflow.ellipsis, maxLines: 1)` — يُقطَع الاسم بنقاط عند نهاية الحقل.

### داخل القائمة المفتوحة

كل بند مُغلَّف بـ `Tooltip(message: a.name, ...)` — الاسم الكامل يظهر عند الضغط المطوّل.  
الاسم نفسه: `Text(a.name, overflow: TextOverflow.ellipsis, maxLines: 1)`.

### داخل الـ Filter Chip

عرض "الجمعية" ثابت (بدون اسم المؤسسة) — آمن من overflow لأن الاسم يمكن أن يكون طويلاً جداً.  
الـ chip داخل `SingleChildScrollView(scrollDirection: Axis.horizontal)` → لا overflow عرضي.

---

## 5. كيفية التعامل مع empty/loading/error

| الملف                         | الحالة السابقة                                                          | الحالة بعد الإصلاح                              |
| ----------------------------- | ----------------------------------------------------------------------- | ----------------------------------------------- |
| `sponsorship_form_sheet.dart` | `associationsState.when(loading: LinearProgressIndicator, error: Text)` | تُعالَج الآن داخل `SponsorOrganizationDropdown` |
| `kafalat_import_page.dart`    | `state.when(loading: LinearProgressIndicator, error: Text)`             | نفس المنطق + `isExpanded` + ellipsis            |
| `unsponsored_tab.dart`        | الجمعيات محمّلة مسبقاً (no async)                                       | `isExpanded` + `selectedItemBuilder` + ellipsis |

---

## 6. الملفات التي تم تعديلها

| الملف                                                                                 | التعديل                                                                                        |
| ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `lib/features/kafalat/presentation/widgets/common/sponsor_organization_dropdown.dart` | **جديد** — Widget مشترك                                                                        |
| `lib/features/kafalat/presentation/widgets/sponsorship_form_sheet.dart`               | استبدال `associationsState.when(...)` بـ `SponsorOrganizationDropdown`                         |
| `lib/features/kafalat/presentation/widgets/tabs/unsponsored_tab.dart`                 | `isExpanded: true` + `selectedItemBuilder` + `TextOverflow.ellipsis`                           |
| `lib/features/kafalat/presentation/pages/kafalat_import_page.dart`                    | `isExpanded: true` + `selectedItemBuilder` + `TextOverflow.ellipsis` في `_AssociationDropdown` |
| `lib/features/kafalat/presentation/widgets/filters/quick_filters_bar.dart`            | مُصلَح في جلسة سابقة                                                                           |
| `lib/features/kafalat/presentation/widgets/tabs/sponsored_tab.dart`                   | مُصلَح في جلسة سابقة                                                                           |

---

## 7. الاختبارات المضافة

**ملف:** `test/features/kafalat/widgets/sponsor_organization_dropdown_test.dart`

| الاختبار               | ما يتحقق منه                            |
| ---------------------- | --------------------------------------- |
| loading state          | يعرض LinearProgressIndicator            |
| loading في شاشة ضيقة   | لا overflow exception                   |
| error state            | يعرض نص الخطأ                           |
| empty state            | يعرض "لا توجد مؤسسات كافلة متاحة"       |
| اسم عربي قصير          | dropdown يعمل بدون exception            |
| اسم عربي طويل (76 حرف) | لا overflow في شاشة 300dp               |
| اسم إنجليزي طويل       | لا overflow                             |
| عدة مؤسسات متنوعة      | dropdown يعمل بدون exception            |
| RTL                    | `textDirection: rtl` مفعّل              |
| onChanged              | يُستدعى بـ id الصحيح                    |
| disabled               | لا يُستدعى onChanged عند enabled: false |
| container ضيق 280dp    | لا overflow exception                   |

---

## 8. نتيجة flutter analyze

```
Errors: 0
Warnings: 0 (من ملفات هذا التعديل)
```

الأخطاء الموجودة في المشروع (`bottom_navigation_buttons.dart` وغيرها) هي أخطاء موجودة مسبقاً وغير مرتبطة بهذا التعديل.

---

## 9. أسماء الاختبار المقترحة للتحقق اليدوي

```
"مؤسسة الكافلة للتنمية الاجتماعية والخدمات الإنسانية طويلة الاسم جداً"
"جمعية الرحمة العالمية لرعاية الأيتام والأسر المتعففة - فرع المدينة"
"Al-Kafala International Sponsorship Organization For Humanitarian Development"
```

### الصفحات للاختبار اليدوي

1. ✅ **نموذج إضافة كفالة** — `SponsorOrganizationDropdown` فعّال
2. ✅ **تعديل كفالة** — نفس النموذج
3. ✅ **فلاتر صفحة مكفول** — Bottom sheet مُصلَح
4. ✅ **تكفل جماعي** (غير مكفول) — `isExpanded` + ellipsis
5. ✅ **رفع Excel** — `_AssociationDropdown` مُصلَح
6. ✅ **فلاتر quick_filters_bar** — مُصلَح في جلسة سابقة
