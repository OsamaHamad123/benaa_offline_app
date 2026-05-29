# تنفيذ Calendar Filter لصفحة الزيارات

**الملف المُعدَّل:** `lib/features/visits/presentation/pages/visits_list_page_m3.dart`  
**التاريخ:** 2025

---

## 1. أين كان Calendar غير منفذ

كانت `_buildCalendarView()` ترجع فقط:

```dart
return const Center(child: Text('Calendar View - Coming Soon'));
```

وكان الزر في AppBar يفعل:

```dart
setState(() => _showCalendar = !_showCalendar);
```

أي يُبدّل بين عرض القائمة وعرض "Coming Soon".

---

## 2. الحل المُختار: DatePicker

**بدلاً من Calendar View مستقل** (يأخذ مساحة دائمة ويتطلب widget خارجية)، اخترنا **DatePicker**:

- `showDatePicker()` المدمج في Flutter
- يدعم RTL والـ locale العربي تلقائياً
- متناسق مع الـ Theme الحالي بدون أي تعديل
- سريع، لا overhead

**طريقة الفتح:**

- زر `📅` في AppBar يفتح DatePicker مباشرة
- يظهر `Badge` صغير على الأيقونة عند وجود تاريخ محدد

```dart
Future<void> _pickDate() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    locale: const Locale('ar'),
    helpText: 'اختر تاريخاً لتصفية الزيارات',
    cancelText: 'إلغاء',
    confirmText: 'تأكيد',
  );
  if (picked != null && mounted) {
    setState(() => _selectedDate = picked);
  }
}
```

---

## 3. كيف يتم فلترة الزيارات حسب التاريخ

```dart
List<VisitEntity> get _filteredVisits {
  return state.visits.where((visit) {
    // فلتر المزامنة (موجود سابقاً)
    if (_selectedFilter == 'pending' && visit.syncState != 'pending') { return false; }
    if (_selectedFilter == 'synced' && visit.syncState != 'synced') { return false; }
    // فلتر التاريخ — مقارنة year/month/day فقط، بدون وقت
    if (_selectedDate != null) {
      final vd = visit.visitDate;
      if (vd.year != _selectedDate!.year ||
          vd.month != _selectedDate!.month ||
          vd.day != _selectedDate!.day) { return false; }
    }
    return true;
  }).toList()
    ..sort((a, b) => b.visitDate.compareTo(a.visitDate));
}
```

**مزايا الطريقة:**

- لا تعتمد على String comparison
- لا تتأثر بالـ timezone (DateTime local)
- تتكامل مع فلتر المزامنة (يمكن تفعيل الاثنين معاً)
- لا تُعيد تحميل البيانات من الـ API — تفلتر محلياً

---

## 4. عرض حالة الفلتر + زر المسح

```
┌─────────────────────────────────────────────┐
│  [الكل (3)] [قيد المزامنة] [مكتمل]          │  ← filter bar (موجود سابقاً)
│  📅 التاريخ: 2026/05/29  [✕]                │  ← chip يظهر فقط عند اختيار تاريخ
└─────────────────────────────────────────────┘
```

- `_buildDateFilterChip()` يظهر فقط عند `_selectedDate != null`
- زر `✕` يستدعي `_clearDateFilter()` → `setState(() => _selectedDate = null)`

---

## 5. كيف تم التعامل مع Empty State

حالتان:

**أ. تاريخ محدد بدون زيارات:**

```
📅 لا توجد زيارات في 2026/05/29
لم يتم تسجيل أي زيارة في هذا اليوم
[ مسح التاريخ ]  [ تسجيل زيارة ]
```

**ب. عدم وجود زيارات عاماً:**

```
📋 لا توجد زيارات
ابدأ بتسجيل زيارة جديدة
[ تسجيل أول زيارة ]
```

زر "تسجيل زيارة" يستخدم `_navigateToRecordVisit()` الصحيح (لا `/visits/record` المكسور).

---

## 6. تغييرات State Management

| قبل                                    | بعد                       |
| -------------------------------------- | ------------------------- |
| `bool _showCalendar`                   | `DateTime? _selectedDate` |
| `TabController _tabController` (مهجور) | محذوف                     |
| `SingleTickerProviderStateMixin`       | محذوف                     |
| `_buildCalendarView()` Coming Soon     | محذوفة                    |

---

## 7. نتيجة flutter analyze

```
Errors:   0 ❌
Warnings: 0 ⚠️
Info:     12 ℹ️ (جميعها مسبقة — withOpacity deprecated، unawaited_futures)
```
