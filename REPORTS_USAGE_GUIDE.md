# 📊 دليل استخدام نظام التقارير المحسّن

## 🚀 البدء السريع

### 1. إنشاء تقرير مخصص

```dart
// في صفحة التقارير، انقر على أيقونة "+" في الأعلى
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const CustomReportsPage(),
  ),
);
```

**الخطوات:**
1. أدخل عنوان التقرير
2. اختر الفترة الزمنية (اختياري)
3. حدد الحقول المطلوبة
4. اختر التقارير المطلوبة
5. حدد خيارات العرض
6. اختر صيغة التصدير
7. انقر "إنشاء وتصدير التقرير"

---

### 2. استخدام الفلاتر السريعة

```dart
QuickDateFilters(
  startDate: _startDate,
  endDate: _endDate,
  onFilterSelected: (start, end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    _refreshData();
  },
  onClearFilter: _clearDateFilter,
)
```

**الفلاتر المتاحة:**
- ⏰ اليوم
- 📅 هذا الأسبوع
- 📆 هذا الشهر
- 📊 هذه السنة
- 🗑️ مسح الفلتر

---

### 3. البحث في التقارير

```dart
ReportSearchField(
  hint: 'ابحث عن محافظة...',
  onSearch: (query) {
    setState(() => _searchQuery = query);
  },
)
```

**مطبّق في:**
- ✅ تقرير المحافظات
- يمكن إضافته لأي تقرير

---

### 4. تصدير جميع التقارير

```dart
// انقر على زر PDF أو Excel في البطاقة البنفسجية
_exportAllReports('pdf') // أو 'excel'
```

**ما يتم تصديره:**
- ملخص الإحصائيات
- تقرير الجنس
- تقرير المحافظات
- تقرير الفئات
- تقرير الأعمار
- تقرير المزامنة

---

## 🎨 الـ Widgets الجديدة

### EmptyStateWidget
```dart
EmptyStateWidget(
  icon: Icons.assessment_outlined,
  title: 'لا توجد بيانات',
  subtitle: 'ابدأ بإضافة مستفيدين لعرض الإحصائيات',
  onActionPressed: () => Navigator.pushNamed(context, '/add-beneficiary'),
  actionLabel: 'إضافة مستفيد',
)
```

### StatisticComparisonCard
```dart
StatisticComparisonCard(
  label: 'إجمالي المستفيدين',
  currentValue: 1500,
  previousValue: 1200,
  icon: Icons.people,
  color: Colors.blue,
)
```

---

## 🔧 الدوال الجديدة

### PDF Export Service

```dart
// تصدير تقرير مخصص
final pdfBytes = await PdfExportService.exportCustomReport(
  title: 'تقرير شامل',
  startDate: startDate,
  endDate: endDate,
  selectedReports: ['summary', 'gender'],
  selectedFields: ['total', 'orphans'],
  includeCharts: true,
  includeDetails: true,
  data: reportData,
);

// حفظ PDF
final path = await PdfExportService.savePdfToFile(pdfBytes, 'report.pdf');
```

### Excel Export Service

```dart
// تصدير تقرير مخصص
final excelPath = await ExcelExportService.exportCustomReport(
  title: 'تقرير شامل',
  startDate: startDate,
  endDate: endDate,
  selectedReports: ['summary', 'gender'],
  selectedFields: ['total', 'orphans'],
  data: reportData,
);
```

---

## 💡 أمثلة عملية

### مثال 1: تقرير يومي
```dart
// استخدم فلتر "اليوم"
QuickDateFilters -> انقر "اليوم"

// أو
final now = DateTime.now();
final start = DateTime(now.year, now.month, now.day);
final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
_setQuickFilter(start, end);
```

### مثال 2: تقرير شهري مخصص
```dart
// افتح Custom Reports Page
Navigator.push(context, MaterialPageRoute(
  builder: (context) => const CustomReportsPage(),
));

// اختر:
// - الفترة: 2025/11/01 إلى 2025/11/30
// - الحقول: total, orphans, poor
// - التقارير: summary, category
// - الصيغة: Excel
```

### مثال 3: البحث عن محافظة
```dart
// في تقرير المحافظات
// اكتب في حقل البحث: "بغداد"
// النتائج تُفلتر تلقائياً
```

---

## ⚠️ ملاحظات مهمة

### الأمان
- ⚠️ التقارير تحتوي على بيانات حساسة
- ⚠️ تظهر رسالة تأكيد قبل التصدير
- ⚠️ استخدم قنوات آمنة للمشاركة

### الأداء
- ✅ استخدم الفلاتر لتقليل حجم البيانات
- ✅ التصدير يعمل في background
- ✅ مؤشر تقدم واضح

### التوافقية
- ✅ يعمل على Android & iOS
- ✅ دعم RTL كامل
- ✅ Responsive design

---

## 🐛 استكشاف الأخطاء

### مشكلة: لا تظهر البيانات
**الحل:**
1. تأكد من وجود بيانات في قاعدة البيانات
2. تحقق من الفلاتر المطبقة
3. امسح الفلتر وحاول مرة أخرى

### مشكلة: فشل التصدير
**الحل:**
1. تأكد من وجود مساحة تخزين كافية
2. تحقق من الأذونات
3. حاول تصدير تقرير أصغر

### مشكلة: البحث لا يعمل
**الحل:**
1. تأكد من كتابة الاسم بشكل صحيح
2. جرّب البحث بجزء من الاسم
3. امسح البحث وحاول مرة أخرى

---

## 📝 قائمة التحقق

قبل استخدام النظام، تأكد من:

- [ ] تم إصلاح مشكلة null safety
- [ ] جميع الـ imports موجودة
- [ ] لا توجد أخطاء compile
- [ ] تم اختبار الفلاتر السريعة
- [ ] تم اختبار البحث
- [ ] تم اختبار التصدير
- [ ] تم اختبار Custom Reports

---

## 🎯 الخطوات التالية

### للمطورين:
1. إضافة البحث لباقي التقارير
2. إضافة مقارنة الفترات في الواجهة
3. إضافة Charts تفاعلية
4. إضافة Scheduled Reports

### للمستخدمين:
1. جرّب جميع الميزات
2. أنشئ تقارير مخصصة حسب احتياجك
3. استخدم الفلاتر السريعة للاستخدام اليومي
4. صدّر التقارير بالصيغة المناسبة

---

## 📞 الدعم

للمساعدة أو الأسئلة:
- راجع الملف: `REPORTS_ENHANCEMENTS_COMPLETE.md`
- تحقق من الأمثلة في الكود
- جرّب الميزات المختلفة

**Happy Reporting! 📊✨**
