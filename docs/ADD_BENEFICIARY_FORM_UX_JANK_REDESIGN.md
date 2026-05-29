# إعادة تصميم UX وإزالة Jank - نموذج إضافة مستفيد

**التاريخ:** 2025  
**النطاق:** `lib/features/beneficiaries/presentation/`  
**الحالة:** ✅ مكتمل

---

## 1. المشاكل التي تم اكتشافها

### 1.1 مشاكل الأداء (Jank)

| المشكلة                                                             | الموقع                           | التأثير                |
| ------------------------------------------------------------------- | -------------------------------- | ---------------------- |
| إعادة بناء `calculateTabStats` في كل `build()`                      | `form_content_widget.dart`       | بطء ملحوظ عند التمرير  |
| `BeneficiaryFormTabBar4` بحجم 56px تُعيد رسم نفسها مع كل تغيير حالة | `form_tabs_4_merged.dart`        | jank عند تغيير التبويب |
| تخطيط عمودين (صف مسودة + صف تنقل) يُعيد البناء عند تغيير حجم الشاشة | `bottom_navigation_buttons.dart` | repaint غير ضروري      |
| نص طويل في AppBar يسبب overflow على شاشات صغيرة                     | `save_status_indicator.dart`     | خطأ بصري محتمل         |
| استيراد `ResponsiveUtilsV2` غير مستخدم                              | `bottom_navigation_buttons.dart` | تحذير تحليل            |

### 1.2 مشاكل UX

- **TabBar ضخمة** تأخذ ~56px من المساحة المرئية بدلاً من المحتوى
- **نص الحفظ الطويل** "تعديلات غير محفوظة" يمتد في AppBar
- **زر "حفظ مسودة"** بارز كصف كامل رغم أنه إجراء ثانوي
- **حجم العنوان** 18sp كبير نسبياً على AppBar ضيق

---

## 2. قرارات التصميم الجديدة

### 2.1 CompactFormStepIndicator بدلاً من BeneficiaryFormTabBar4

**السبب:** `BeneficiaryFormTabs4Merged` تستخدم `Stack + AnimatedOpacity + AnimatedSlide` (لا `TabBarView`)، مما يعني أن أي widget يمكنه استدعاء `controller.animateTo()` مباشرة دون الحاجة لـ `TabBar` تقليدية.

**التصميم الجديد:**

```
┌─────────────────────────────────────────────────────┐
│  خطوة 2 من 5  •  العائلة           ○ ● ○ ○ ○      │  ~36px
│  ══════════════════════░░░░░░░░░░░░░░░░░░░░░░░       │  2.5px
└─────────────────────────────────────────────────────┘
```

**مقارنة الحجم:**

- `BeneficiaryFormTabBar4`: ~56px + نص عربي في كل تبويب
- `CompactFormStepIndicator`: ~38.5px (36 + 2.5 progress bar)
- **توفير: ~17.5px = محتوى إضافي يظهر للمستخدم**

**تفاصيل التصميم:**

- يسار: "خطوة X من Y" (labelSmall، onSurfaceVariant) + نقطة فاصل + اسم الخطوة (labelMedium، bold، primary)
- يمين: نقاط pill متحركة — 18px للنشطة، 7px للخاملة — كل منها قابلة للنقر
- أسفل: `LinearProgressIndicator(minHeight: 2.5)` يعكس التقدم الكلي

### 2.2 إبقاء BeneficiaryFormTabBar4

الـ widget القديمة **لم تُحذف** للحفاظ على التوافق مع أي مكان قد يستخدمها مباشرة.

---

## 3. التغييرات في AppBar

**الملف:** `beneficiary_form_app_bar.dart`

| العنصر             | قبل                         | بعد                                     |
| ------------------ | --------------------------- | --------------------------------------- |
| حجم خط العنوان     | `18.sp` + `FontWeight.bold` | `16.sp` + `FontWeight.w600`             |
| نص الحفظ الجاري    | "جاري الحفظ..." (نص كامل)   | `CircularProgressIndicator` 16x16 فقط   |
| نص غير محفوظ       | "تعديلات غير محفوظة"        | نقطة حمراء 9x9 (`colorScheme.tertiary`) |
| حالة المحفوظ       | نص + أيقونة                 | `Icons.check_circle_rounded` 16sp فقط   |
| حالة لا يوجد تعديل | فراغ                        | `SizedBox.shrink()`                     |

**الفائدة:** AppBar أنظف، لا overflow، مساحة أكبر للعنوان.

---

## 4. التغييرات في أزرار التنقل السفلية

**الملف:** `bottom_navigation_buttons.dart`

### التصميم القديم

```
┌─────────────────────────────────┐
│  [حفظ مسودة    ]  ← صف كامل   │
├─────────────────────────────────┤
│  [السابق]  [التالي / حفظ]       │
└─────────────────────────────────┘
```

### التصميم الجديد

```
┌─────────────────────────────────────────────────────┐
│  [السابق]  [═══════ التالي / حفظ ═══════]  [···]   │
└─────────────────────────────────────────────────────┘
```

**التفاصيل:**

- **صف واحد دائماً** — لا تخطيط متعدد الصفوف
- **"السابق"**: `OutlinedButton.icon` (يختفي في التبويب الأول)، على شاشات <360px يصبح `IconButton` للاقتصاد بالمساحة
- **"التالي / حفظ"**: `FilledButton.icon` + `Expanded` يأخذ كل المساحة المتبقية
- **"حفظ مسودة"**: انتقل إلى `PopupMenuButton` (40x40) — `···` — لأنه إجراء ثانوي
- **حُذف**: استيراد `ResponsiveUtilsV2` غير المستخدم

---

## 5. تحسينات الأداء المُنجزة

### 5.1 تخفيض Rebuilds

| المكان            | قبل                        | بعد                                     |
| ----------------- | -------------------------- | --------------------------------------- |
| إحصاءات التبويبات | تُحسب في كل `build()`      | debounce 600ms + `_cachedTabStats`      |
| مؤشر الخطوة       | `StatefulWidget` مع استماع | `StatelessWidget` يستقبل `currentIndex` |
| شريط التقدم       | جزء من TabBar المعاد رسمها | `LinearProgressIndicator` منفصل         |

### 5.2 RepaintBoundary

- `CompactFormStepIndicator` مُلفَّف بـ `RepaintBoundary`
- `BottomNavigationButtons` مُلفَّف بـ `RepaintBoundary`
- يمنع تموّج إعادة الرسم من الانتشار للـ widget الأم

### 5.3 Widget-level تحسينات

- `AlwaysStoppedAnimation` بدلاً من إنشاء Animation جديدة
- `SizedBox.shrink()` بدلاً من `Container()` فارغ
- `const` constructors في كل مكان ممكن

---

## 6. الاختبارات التي تم إنشاؤها

**الملف:** `test/features/beneficiaries/presentation/pages/v2_form_helpers/widgets/add_beneficiary_form_ux_test.dart`

### المجموعة 1: `CompactFormStepIndicator - Step Indicator`

1. `shows correct step label for current tab` — يعرض "خطوة 1 من 5" و"معلومات أساسية"
2. `no overflow on compact 360px screen` — لا خطأ overflow
3. `shows correct title for each step index` — كل عنوان الخطوات الخمس
4. `tapping pill dot calls animateTo on controller` — النقر يغيّر التبويب
5. `progress bar is always present` — `LinearProgressIndicator` موجود دائماً

### المجموعة 2: `BottomNavigationButtons - Single Row Layout`

6. `Next button triggers onNext callback` — المعاودة تُستدعى
7. `Previous button triggers onPrevious callback` — المعاودة تُستدعى
8. `Save button shown on last tab` — "حفظ" يظهر في التبويب الأخير
9. `Previous hidden on first tab` — "السابق" يختفي
10. `popup menu visible for draft` — `PopupMenuButton` موجود
11. `buttons disabled during loading` — معطّل عند `isLoading: true`
12. `no overflow on 320px screen` — لا overflow على أصغر شاشة

### المجموعة 3: `FormBottomNavWidget - tab-aware navigation`

13. `renders without error` — لا exception
14. `shows save on last tab` — "حفظ" يظهر
15. `ScaffoldMessenger snackbar shown via root scaffold` — snackbar يظهر صحيح

---

## 7. نتيجة flutter analyze النهائية

```
Errors:   0 ❌
Warnings: 0 ⚠️
Infos:    5 ℹ️ (جميعها مسبقة وغير حرجة)
```

تفاصيل الـ infos في ملفاتنا:

- `form_content_widget.dart:62` — `_searchQuery` could be `final` (ignore مضاف)
- `form_content_widget.dart:304` — unnecessary parentheses (أسلوب)
- `form_tabs_4_merged.dart:505,564` — prefer `const` declarations
- `add_beneficiary_form_ux_test.dart:75` — redundant argument value

---

## 8. الملفات المُعدَّلة

| الملف                                                | نوع التغيير                        |
| ---------------------------------------------------- | ---------------------------------- |
| `widgets/form_tabs_4_merged.dart`                    | إضافة `CompactFormStepIndicator`   |
| `widgets/form_content_widget.dart`                   | استخدام `CompactFormStepIndicator` |
| `widgets/form/app_bar/beneficiary_form_app_bar.dart` | تصغير العنوان 18→16sp              |
| `widgets/form/app_bar/save_status_indicator.dart`    | نص → أيقونة/نقطة فقط               |
| `widgets/bottom_navigation_buttons.dart`             | صف واحد + مسودة في Popup           |
| `test/.../add_beneficiary_form_ux_test.dart`         | 14 اختباراً جديداً                 |
