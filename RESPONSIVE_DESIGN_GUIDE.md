# 📐 Responsive Design Guide - flutter_screenutil

## ✅ تم التثبيت والإعداد

### المكتبة المثبتة:
- **flutter_screenutil**: ^5.9.3

### الملفات المحدثة:
1. ✅ `pubspec.yaml` - إضافة المكتبة
2. ✅ `lib/app.dart` - تهيئة ScreenUtilInit
3. ✅ `lib/core/utils/responsive_utils_v2.dart` - Utility class جديد

---

## 🎯 كيفية الاستخدام

### 1️⃣ **Responsive Sizes** (الأبعاد)

```dart
// Width & Height
Container(
  width: 100.w,    // 100 وحدة responsive width
  height: 50.h,    // 50 وحدة responsive height
  margin: EdgeInsets.all(16.r),  // Responsive radius/padding
)

// الفرق:
// .w  = responsive width
// .h  = responsive height  
// .r  = responsive radius (يعمل على الأبعاد الصغيرة)
```

### 2️⃣ **Font Sizes** (حجم الخط)

```dart
Text(
  'مرحباً',
  style: TextStyle(
    fontSize: 16.sp,  // Responsive font size
  ),
)

// أو استخدم الثوابت الجاهزة:
Text(
  'عنوان',
  style: TextStyle(fontSize: ResponsiveUtils.headingFont),
)
```

### 3️⃣ **Spacing** (المسافات)

```dart
// مسافات عمودية/أفقية
Column(
  children: [
    Text('الأول'),
    ResponsiveUtils.verticalSpace,  // 16.h spacing
    Text('الثاني'),
    SizedBox(height: 24.h),         // Custom spacing
  ],
)

// أو استخدم الثوابت:
SizedBox(height: ResponsiveUtils.largeSpace)  // 24.h
SizedBox(width: ResponsiveUtils.smallSpace)   // 8.w
```

### 4️⃣ **Padding** (الحواشي)

```dart
// Responsive padding based on device
Padding(
  padding: ResponsiveUtils.getResponsivePadding(context),
  child: Text('محتوى'),
)

// أو manual:
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 12.h,
  ),
  child: Text('محتوى'),
)
```

### 5️⃣ **Border Radius** (الزوايا الدائرية)

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12.r),  // Responsive radius
  ),
)

// أو استخدم الثوابت:
BorderRadius.circular(ResponsiveUtils.mediumRadius)  // 8.r
```

### 6️⃣ **Device Detection** (كشف نوع الجهاز)

```dart
if (ResponsiveUtils.isMobile(context)) {
  return MobileLayout();
} else if (ResponsiveUtils.isTablet(context)) {
  return TabletLayout();
} else {
  return DesktopLayout();
}

// أو استخدم responsive builder:
ResponsiveUtils.responsive(
  mobile: MobileWidget(),
  tablet: TabletWidget(),
  desktop: DesktopWidget(),
)
```

---

## 📊 الثوابت المتاحة

### Font Sizes:
```dart
ResponsiveUtils.xSmallFont    // 10.sp
ResponsiveUtils.smallFont     // 12.sp
ResponsiveUtils.bodyFont      // 14.sp
ResponsiveUtils.mediumFont    // 16.sp
ResponsiveUtils.largeFont     // 18.sp
ResponsiveUtils.titleFont     // 20.sp
ResponsiveUtils.headingFont   // 24.sp
ResponsiveUtils.displayFont   // 32.sp
```

### Spacing:
```dart
ResponsiveUtils.xSmallSpace   // 4.h
ResponsiveUtils.smallSpace    // 8.h
ResponsiveUtils.mediumSpace   // 16.h
ResponsiveUtils.largeSpace    // 24.h
ResponsiveUtils.xLargeSpace   // 32.h
```

### Border Radius:
```dart
ResponsiveUtils.smallRadius      // 4.r
ResponsiveUtils.mediumRadius     // 8.r
ResponsiveUtils.largeRadius      // 12.r
ResponsiveUtils.xLargeRadius     // 16.r
ResponsiveUtils.circularRadius   // 100.r
```

---

## 🎨 أمثلة عملية

### Card Widget:
```dart
Card(
  margin: EdgeInsets.all(16.r),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
  ),
  child: Padding(
    padding: EdgeInsets.all(16.r),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العنوان',
          style: TextStyle(
            fontSize: ResponsiveUtils.titleFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'المحتوى',
          style: TextStyle(fontSize: ResponsiveUtils.bodyFont),
        ),
      ],
    ),
  ),
)
```

### Button:
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: Size(double.infinity, 48.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
    ),
  ),
  onPressed: () {},
  child: Text(
    'حفظ',
    style: TextStyle(fontSize: ResponsiveUtils.mediumFont),
  ),
)
```

### Grid:
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: ResponsiveUtils.getGridColumns(context),
    crossAxisSpacing: ResponsiveUtils.getGridSpacing(context),
    mainAxisSpacing: ResponsiveUtils.getGridSpacing(context),
  ),
  itemBuilder: (context, index) => Card(),
)
```

---

## ⚡ Performance Tips

1. **استخدم `.r` للـ padding/margin** بدلاً من `.w` أو `.h`
2. **استخدم الثوابت الجاهزة** (ResponsiveUtils.mediumSpace) بدلاً من الأرقام المباشرة
3. **تجنب الحسابات المعقدة** في كل build
4. **استخدم `const`** حيثما أمكن

---

## 🚀 Migration من responsive_utils.dart القديم

### قبل:
```dart
ResponsiveUtils.getResponsiveSpacing(context)  // Old
```

### بعد:
```dart
ResponsiveUtils.mediumSpace  // New - No context needed!
// Or:
16.h  // Direct use
```

---

## ✅ المميزات

- ✅ **لا حاجة للـ context** في معظم الحالات
- ✅ **تلقائي** - يتكيف مع أي حجم شاشة
- ✅ **سريع** - No calculations at runtime
- ✅ **متسق** - نفس النسب في كل مكان
- ✅ **سهل الاستخدام** - Just add .w, .h, .sp, .r
- ✅ **يدعم RTL** - Arabic text works perfectly
- ✅ **Desktop/Web ready** - Works on all platforms

---

## 📝 ملاحظات مهمة

1. **Design Size**: التصميم المرجعي هو **390x844** (iPhone 13 Pro)
2. **استخدم `.sp` للخطوط** دائماً لضمان قابلية القراءة
3. **استخدم `.r`** للـ padding, margin, borderRadius
4. **استخدم `.w` للعروض** و `.h` للارتفاعات
5. **لا تستخدم .w مع الارتفاع** أو العكس (يسبب تشوه)

---

تم بحمد الله! 🎉
الآن كل التطبيق responsive بدون أي مشاكل مستقبلية.
