# نظام Responsive في التطبيق

تم تطبيق نظام شامل للـ responsive design في التطبيق لضمان تجربة مستخدم مثالية على جميع أحجام الشاشات.

## الملفات الرئيسية

### 1. `core/utils/responsive_utils.dart`
يحتوي على الأدوات المساعدة للتعامل مع الأحجام المختلفة:

#### Breakpoints المستخدمة:
- **Mobile**: أقل من 600px
- **Tablet**: من 600px إلى 1200px
- **Desktop**: أكبر من 1200px

#### الدوال الرئيسية:

```dart
// التحقق من نوع الشاشة
ResponsiveUtils.isMobile(context)
ResponsiveUtils.isTablet(context)
ResponsiveUtils.isDesktop(context)

// الحصول على قيمة بناءً على حجم الشاشة
ResponsiveUtils.getResponsiveValue<T>(
  context,
  mobile: value1,
  tablet: value2,
  desktop: value3,
)

// الحصول على عدد الأعمدة للـ Grid
ResponsiveUtils.getCrossAxisCount(
  context,
  mobile: 2,
  tablet: 3,
  desktop: 4,
)

// الحصول على Padding تلقائي
ResponsiveUtils.getResponsivePadding(context)

// الحصول على المسافات
ResponsiveUtils.getResponsiveSpacing(context)

// الحصول على مقياس الخط
ResponsiveUtils.getFontScale(context)
```

### 2. `core/widgets/responsive_widgets.dart`
مجموعة من الـ Widgets الجاهزة للاستخدام:

#### ResponsiveCard
```dart
ResponsiveCard(
  child: Text('محتوى البطاقة'),
)
```

#### ResponsiveGridView
```dart
ResponsiveGridView(
  mobileColumns: 2,
  tabletColumns: 3,
  desktopColumns: 4,
  children: [
    // العناصر
  ],
)
```

#### ResponsiveContainer
```dart
ResponsiveContainer(
  child: Text('محتوى'),
)
```

#### ResponsiveText
```dart
ResponsiveText(
  'نص متجاوب',
  useScale: true,
  style: TextStyle(fontSize: 16),
)
```

#### ResponsiveSizedBox
```dart
// للارتفاع
ResponsiveSizedBox.height(
  mobile: 16,
  tablet: 20,
  desktop: 24,
)

// للعرض
ResponsiveSizedBox.width(
  mobile: 100,
  tablet: 150,
  desktop: 200,
)
```

#### ResponsivePadding
```dart
ResponsivePadding(
  child: Text('محتوى'),
)
```

#### ResponsiveBuilder
```dart
ResponsiveBuilder(
  mobile: (context, constraints) => MobileLayout(),
  tablet: (context, constraints) => TabletLayout(),
  desktop: (context, constraints) => DesktopLayout(),
)
```

## أمثلة الاستخدام

### مثال 1: Grid متجاوب
```dart
final crossAxisCount = ResponsiveUtils.getCrossAxisCount(
  context,
  mobile: 2,
  tablet: 3,
  desktop: 4,
);

GridView.count(
  crossAxisCount: crossAxisCount,
  children: items,
)
```

### مثال 2: Padding متجاوب
```dart
Padding(
  padding: ResponsiveUtils.getResponsivePadding(context),
  child: Column(
    children: [...],
  ),
)
```

### مثال 3: تخطيطات مختلفة حسب الحجم
```dart
ResponsiveBuilder(
  mobile: (context, constraints) => ListView(
    children: items,
  ),
  desktop: (context, constraints) => GridView(
    children: items,
  ),
)
```

### مثال 4: أحجام نصوص متجاوبة
```dart
Text(
  'عنوان',
  style: TextStyle(
    fontSize: ResponsiveUtils.isMobile(context) ? 18 : 24,
  ),
)
```

## التطبيقات في المشروع

### Dashboard Page
- Grid متجاوب للإحصائيات (2 أعمدة في Mobile، 4 في Tablet/Desktop)
- Grid متجاوب للإجراءات السريعة (2 في Mobile، 3 في Tablet، 6 في Desktop)
- Padding وSpacing متجاوب في جميع العناصر

### Beneficiaries List Page
- Padding متجاوب للبحث والفلاتر
- تخطيط متجاوب لقائمة المستفيدين

## نصائح للاستخدام

1. **استخدم الأدوات المساعدة**: استخدم `ResponsiveUtils` بدلاً من القيم الثابتة
2. **اختبر على أحجام مختلفة**: تأكد من اختبار التطبيق على هواتف وأجهزة لوحية
3. **استخدم الـ Widgets الجاهزة**: استخدم `ResponsiveCard`, `ResponsiveGridView`, إلخ للحصول على نتائج أسرع
4. **تجنب القيم الثابتة**: تجنب استخدام `const EdgeInsets.all(16)` واستخدم `ResponsiveUtils.getResponsivePadding(context)` بدلاً منها
5. **فكر في التجربة**: فكر في كيفية ظهور العناصر على الشاشات الكبيرة والصغيرة

## الصفحات المحدثة

✅ Dashboard Page - محدثة بالكامل
✅ Beneficiaries List Page - محدثة جزئياً
⏳ Add Beneficiary Page - قيد التحديث
⏳ View Beneficiary Page - قيد التحديث
⏳ Search Page - قيد التحديث
⏳ Reports Page - قيد التحديث
⏳ Sync Page - قيد التحديث

## المستقبل

سيتم تطبيق نظام الـ responsive على جميع صفحات التطبيق تدريجياً لضمان تجربة متسقة على جميع الأجهزة.
