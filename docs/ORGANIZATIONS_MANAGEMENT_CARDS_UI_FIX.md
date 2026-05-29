# إصلاح UI/UX صفحة إدارة الجمعيات — كروت Compact

**التاريخ:** 2026-05-29  
**الملفات المعدّلة:** `professional_association_card.dart`, `associations_list_page_v2.dart`  
**الملف الجديد:** `test/.../professional_association_card_test.dart`

---

## 1. سبب المسافات الكبيرة

**السبب الجذري:** الصفحة كانت تستخدم `SliverGrid` مع `childAspectRatio: 1.1` للموبايل (عمود واحد).

على شاشة 360dp عرض:

- عرض متاح بعد الـ padding: ~336dp
- ارتفاع الكارد = 336 / 1.1 ≈ **305dp**

هذا يعني كل كارد يحجز 305dp حتى لو محتواه 120dp فقط → **فراغ ~185dp** في أسفل كل كارد.

أسباب إضافية:

- `CardGradientHeader` به padding: `12.h` علوي + سفلي → أضاف 24dp+ فراغ رأسي غير ضروري
- `SliverPadding` كان يستخدم `ResponsiveUtils.mediumSpace` (~16dp) على كل الجهات
- `const Spacer()` قبل أزرار الأفعال → فراغ أفقي كبير

---

## 2. كيف تم تقليل حجم الكارد

| البُعد                    | قبل                                                 | بعد                                      |
| ------------------------- | --------------------------------------------------- | ---------------------------------------- |
| ارتفاع الكارد (mobile)    | مقيّد بـ aspect ratio = ~305dp                      | **auto** يحدده المحتوى (~110-140dp)      |
| padding داخلي             | gradient header 12.h + content 8.h × 2              | `fromLTRB(12.w, 8.h, 4.w, 8.h)` موحد     |
| border radius             | 16.r                                                | 10.r                                     |
| elevation / shadow        | `blurRadius: 8, elevation:0 + container decoration` | `elevation: 1, shadowColor` خفيف         |
| مسافة بين الكروت          | `mainAxisSpacing: 2.h` (غير مؤثر في Grid)           | `Card.margin: 3.h` (فعّال في SliverList) |
| padding الـ SliverPadding | `mediumSpace (~16dp)` كل الجهات                     | `fromLTRB(12.w, 4.h, 12.w, 16.h)`        |

**التغيير الأهم:** تحويل mobile من `SliverGrid` → `SliverList` → الكارد يحدد حجمه من محتواه الفعلي.

---

## 3. ما المعلومات التي أصبحت تظهر داخل الكارد

| المعلومة          | قبل                          | بعد                              |
| ----------------- | ---------------------------- | -------------------------------- |
| اسم الجمعية       | ✅ في header gradient        | ✅ في السطر الأول                |
| الاسم المختصر     | ✅ سطر منفصل                 | ✅ يحل محل الاسم الكامل إذا توفر |
| حالة نشط/معطل     | ✅ badge في header           | ✅ badge في نفس السطر مع الاسم   |
| رقم الهاتف        | ✅                           | ✅                               |
| البريد الإلكتروني | ✅ (كان مخفياً أحياناً)      | ✅ في نفس سطر الهاتف إذا توفر    |
| البنك             | ✅                           | ✅                               |
| العملة            | ✅ chip منفصل                | ✅ في نفس سطر البنك              |
| المندوب           | ✅                           | ✅ (صف 4 اختياري)                |
| نوع الجمعية       | ✅                           | ✅ (صف 4 اختياري مع المندوب)     |
| أزرار تعديل / حذف | ✅ زرّان ظاهران يأخذان مساحة | ✅ مخفيان داخل PopupMenuButton   |
| زر التفاصيل       | ❌ لم يكن ظاهراً             | ✅ في القائمة المنبثقة           |

---

## 4. كيف تم التعامل مع البيانات الناقصة

```dart
// لا يُعرض الإيميل إذا كان null أو فارغاً
if (email != null && email!.trim().isNotEmpty) ...

// لا يُعرض صف المندوب + النوع إذا كلاهما null
final hasSecondary = representativeName != null ||
    (associationTypeLabel != null && associationTypeLabel!.trim().isNotEmpty);
if (hasSecondary) ...

// لا تُعرض العملة إذا لم تتوفر
if (currency != null && currency!.trim().isNotEmpty) ...
```

**القاعدة:** كل سطر اختياري يظهر فقط إذا كانت بياناته متوفرة وغير فارغة.  
**لا يوجد** نص "غير متوفر" داخل الكارد — السطر يختفي كلياً.

---

## 5. كيف تم منع overflow

| الأسلوب                          | التفاصيل                                              |
| -------------------------------- | ----------------------------------------------------- |
| `maxLines: 1`                    | على جميع النصوص                                       |
| `TextOverflow.ellipsis`          | على جميع النصوص                                       |
| `Flexible`                       | حول النصوص في الـ Row (يسمح بضغط النص)                |
| `Expanded`                       | حول النصوص في السطر الأساسي                           |
| `SliverList`                     | يزيل قيد الـ aspect ratio (الأهم لمنع overflow عمودي) |
| `mainAxisSize: MainAxisSize.min` | في Column الكارد — لا تمدد غير ضروري                  |
| `PopupMenuButton`                | بديل الأزرار — لا يتمدد خارج حدود الكارد              |

---

## 6. بنية الكارد الجديدة

```
┌──────────────────────────────────────────┐
│ [🏦]  اسم الجمعية / الاسم المختصر  [نشط] [⋮] │  ← 30r أيقونة + اسم + badge + menu
│ ☎ 07901234567     ✉ info@org.iq         │  ← هاتف + إيميل (اختياري في نفس السطر)
│ 💳 البنك الأهلي العراقي          [IQD]   │  ← بنك + عملة chip
│ 👤 أحمد محمود   🏷️ جمعية خيرية         │  ← مندوب + نوع (صف اختياري)
└──────────────────────────────────────────┘
  padding: 12.w | 8.h | 4.w | 8.h
  Card.margin: vertical 3.h
  elevation: 1 (light) / 0+border (dark)
```

---

## 7. الملفات المعدّلة

| الملف                                              | التغيير                                                      |
| -------------------------------------------------- | ------------------------------------------------------------ |
| `lib/.../professional_association_card.dart`       | إعادة كتابة كاملة — بلا gradient، PopupMenu، auto-height     |
| `lib/.../associations_list_page_v2.dart`           | تحويل mobile من `SliverGrid` إلى `SliverList`، تقليل padding |
| `test/.../professional_association_card_test.dart` | **جديد** — 17 اختباراً                                       |

**ملفات غير معدّلة (تحتفظ بها المشاريع الأخرى):**

- `card_gradient_header.dart` — لا تزال مستخدمة في kafalat feature
- `card_info_section.dart` — نفسه
- `card_action_buttons.dart` — نفسه

---

## 8. الاختبارات المضافة

**ملف:** `test/features/associations/presentation/widgets/professional_association_card_test.dart`  
**عدد الاختبارات:** 17

| المجموعة            | الاختبارات                                                         |
| ------------------- | ------------------------------------------------------------------ |
| بيانات أساسية       | اسم، اسم مختصر، badge نشط/معطل، هاتف، بنك                          |
| حقول اختيارية       | إيميل، عملة، مندوب، نوع، غياب الحقول                               |
| overflow وشاشة ضيقة | اسم عربي 80+ حرف، اسم إنجليزي طويل، شاشة 280dp، جميع الحقول ممتلئة |
| PopupMenu والأفعال  | وجود more_vert، onTap يُستدعى                                      |
| RTL                 | لا overflow في RTL                                                 |

---

## 9. نتيجة flutter analyze

```
Errors: 0
Warnings: 0  (في الملفات المعدّلة)
```
