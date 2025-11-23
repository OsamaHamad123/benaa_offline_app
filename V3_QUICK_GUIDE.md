# 🚀 دليل الاستخدام السريع - التحسينات الجديدة

## 📱 ResponsiveUtils - كيفية الاستخدام

### 1. استيراد الملف
```dart
import '../../../../../../core/utils/responsive_utils_v2.dart';
```

### 2. Device Detection
```dart
@override
Widget build(BuildContext context) {
  // التحقق من نوع الجهاز
  final isMobile = ResponsiveUtils.isMobile(context);      // < 600px
  final isTablet = ResponsiveUtils.isTablet(context);      // 600-1199px
  final isDesktop = ResponsiveUtils.isDesktop(context);    // >= 1200px
  final isLandscape = ResponsiveUtils.isLandscape(context);
  
  // استخدام مختصر
  final isTabletOrDesktop = ResponsiveUtils.isTablet(context) || 
                            ResponsiveUtils.isDesktop(context);
  
  return Container(/* ... */);
}
```

### 3. Responsive Padding
```dart
// Automatic padding based on device
padding: ResponsiveUtils.getResponsivePadding(context),
// Mobile: 16.r | Tablet: 24.r | Desktop: 32.r

// Horizontal only
padding: ResponsiveUtils.getHorizontalPadding(context),

// Vertical only
padding: ResponsiveUtils.getVerticalPadding(context),
```

### 4. Spacing Constants
```dart
// Pre-defined spacing
SizedBox(height: ResponsiveUtils.xSmallSpace),  // 4.h
SizedBox(height: ResponsiveUtils.smallSpace),   // 8.h
SizedBox(height: ResponsiveUtils.mediumSpace),  // 16.h
SizedBox(height: ResponsiveUtils.largeSpace),   // 24.h
SizedBox(height: ResponsiveUtils.xLargeSpace),  // 32.h

// Widgets
ResponsiveUtils.verticalSpace,    // SizedBox(height: 16.h)
ResponsiveUtils.horizontalSpace,  // SizedBox(width: 16.h)

// Custom spacing
ResponsiveUtils.verticalSpacing(20),   // Custom vertical
ResponsiveUtils.horizontalSpacing(30), // Custom horizontal
```

### 5. Responsive Sizes
```dart
// Font sizes
final titleSize = isTabletOrDesktop ? 18.sp : 16.sp;
final bodySize = isTabletOrDesktop ? 15.sp : 14.sp;

// Icon sizes
final iconSize = isTabletOrDesktop ? 28.0 : 24.0;

// Dimensions
final circleSize = isTabletOrDesktop ? 70.0 : 60.0;
final buttonHeight = isTabletOrDesktop ? 56.h : 48.h;
```

---

## 🎬 AnimatedTabTransition - الاستخدام

### 1. استيراد الملف
```dart
import 'v2_form_helpers/widgets/animated_tab_transition.dart';
```

### 2. استخدام AnimatedResponsiveTabView
```dart
// Replace normal TabBarView with AnimatedResponsiveTabView
AnimatedResponsiveTabView(
  controller: _tabController,
  transitionType: TransitionType.fadeSlide, // اختياري
  transitionDuration: const Duration(milliseconds: 300), // اختياري
  children: [
    Tab1Widget(),
    Tab2Widget(),
    Tab3Widget(),
    Tab4Widget(),
  ],
)
```

### 3. أنواع الانتقالات
```dart
// 1. Fade only
transitionType: TransitionType.fade,

// 2. Slide only
transitionType: TransitionType.slide,

// 3. Fade + Slide (الافتراضي - الأفضل)
transitionType: TransitionType.fadeSlide,

// 4. Scale
transitionType: TransitionType.scale,
```

### 4. مثال كامل
```dart
class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: [/* tabs */],
        ),
      ),
      body: AnimatedResponsiveTabView(
        controller: _tabController,
        children: [/* tab content */],
      ),
    );
  }
}
```

---

## 💾 DraftSaveDialog - الاستخدام

### 1. استيراد الملف
```dart
import 'v2_form_helpers/widgets/draft_save_dialog.dart';
```

### 2. عرض Dialog
```dart
// Simple usage
final result = await showDraftSaveDialog(context);

if (result != null) {
  final draftName = result['name'];
  final draftNotes = result['notes'];
  
  // حفظ المسودة
  await saveDraft(
    name: draftName,
    notes: draftNotes,
    data: formData,
  );
}
```

### 3. مع بيانات موجودة
```dart
// With existing draft data
final result = await showDraftSaveDialog(
  context,
  currentName: 'مسودة قديمة',
  currentNotes: 'ملاحظات سابقة',
);
```

### 4. مثال كامل في AppBar
```dart
AppBar(
  title: Text('نموذج المستفيد'),
  actions: [
    // زر حفظ كمسودة
    IconButton(
      icon: Icon(Icons.save_outlined),
      tooltip: 'حفظ كمسودة',
      onPressed: () async {
        final result = await showDraftSaveDialog(context);
        
        if (result != null) {
          setState(() => _isSaving = true);
          
          try {
            await saveDraft(
              name: result['name']!,
              notes: result['notes']!,
              data: collectFormData(),
            );
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم حفظ المسودة بنجاح')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('خطأ في حفظ المسودة: $e')),
              );
            }
          } finally {
            if (mounted) {
              setState(() => _isSaving = false);
            }
          }
        }
      },
    ),
  ],
)
```

---

## ⌨️ KeyboardShortcutsHelp - الاستخدام

### 1. استيراد الملف
```dart
import 'v2_form_helpers/widgets/keyboard_shortcuts_help.dart';
```

### 2. عرض Help Sheet
```dart
// Simple usage
showKeyboardShortcutsHelp(context);
```

### 3. إضافة زر في AppBar
```dart
AppBar(
  title: Text('نموذج المستفيد'),
  actions: [
    // زر المساعدة
    IconButton(
      icon: Icon(Icons.help_outline),
      tooltip: 'اختصارات لوحة المفاتيح',
      onPressed: () => showKeyboardShortcutsHelp(context),
    ),
  ],
)
```

### 4. الاختصارات المتوفرة
| الاختصار | الوظيفة |
|----------|---------|
| `Ctrl + S` | حفظ النموذج |
| `Ctrl + Tab` | الانتقال للتبويب التالي |
| `Ctrl + Shift + Tab` | الانتقال للتبويب السابق |
| `Ctrl + Z` | التراجع |
| `Ctrl + Y` | إعادة |
| `F5` | تحديث البيانات |
| `Esc` | إلغاء/إغلاق |

---

## 📋 أمثلة عملية

### مثال 1: Widget متجاوب كامل
```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';

class MyResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isTabletOrDesktop = ResponsiveUtils.isTablet(context) ||
                              ResponsiveUtils.isDesktop(context);
    
    // Responsive values
    final titleSize = isTabletOrDesktop ? 20.sp : 18.sp;
    final iconSize = isTabletOrDesktop ? 28.0 : 24.0;
    final cardPadding = isTabletOrDesktop ? 20.0 : 16.0;
    
    return Card(
      margin: ResponsiveUtils.getHorizontalPadding(context),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.info, size: iconSize),
                SizedBox(width: ResponsiveUtils.smallSpace),
                Text(
                  'عنوان',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveUtils.mediumSpace),
            
            Text('محتوى...'),
          ],
        ),
      ),
    );
  }
}
```

### مثال 2: Form مع Draft Save و Animations
```dart
class BeneficiaryForm extends StatefulWidget {
  @override
  State<BeneficiaryForm> createState() => _BeneficiaryFormState();
}

class _BeneficiaryFormState extends State<BeneficiaryForm> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('نموذج المستفيد'),
        actions: [
          // Draft Save
          IconButton(
            icon: Icon(Icons.save_outlined),
            onPressed: () async {
              final result = await showDraftSaveDialog(context);
              if (result != null) {
                // حفظ المسودة
              }
            },
          ),
          
          // Keyboard Shortcuts Help
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => showKeyboardShortcutsHelp(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'البيانات الأساسية'),
            Tab(text: 'الأسرة'),
            Tab(text: 'المساعدات'),
            Tab(text: 'المراجعة'),
          ],
        ),
      ),
      
      body: AnimatedResponsiveTabView(
        controller: _tabController,
        transitionType: TransitionType.fadeSlide,
        children: [
          Tab1Content(),
          Tab2Content(),
          Tab3Content(),
          Tab4Content(),
        ],
      ),
    );
  }
}
```

---

## ✅ Checklist للتطبيق

عند إضافة widget جديد:

- [ ] استخدم ResponsiveUtils للـ padding
- [ ] استخدم device detection للأحجام المختلفة
- [ ] استخدم spacing constants بدل أرقام ثابتة
- [ ] أضف responsive font sizes
- [ ] أضف responsive icon sizes
- [ ] اختبر على mobile و tablet
- [ ] أضف const constructors حيث أمكن
- [ ] استخدم RepaintBoundary للويدجت المعقدة

---

## 🎯 Best Practices

### ✅ افعل:
```dart
// استخدم ResponsiveUtils
padding: ResponsiveUtils.getResponsivePadding(context),

// استخدم spacing constants
SizedBox(height: ResponsiveUtils.mediumSpace),

// استخدم device detection
final size = ResponsiveUtils.isTablet(context) ? 20.sp : 16.sp;
```

### ❌ لا تفعل:
```dart
// لا تستخدم أرقام ثابتة
padding: EdgeInsets.all(16.0),

// لا تستخدم magic numbers
SizedBox(height: 12),

// لا تتجاهل device types
fontSize: 16.sp, // نفس الحجم لجميع الأجهزة
```

---

## 📞 الدعم

للمزيد من المعلومات، راجع:
- 📄 `V3_RESPONSIVE_IMPROVEMENTS.md` - تقرير التحسينات الكامل
- 📄 `V3_PERFORMANCE_REPORT.md` - تقرير الأداء
- 📄 `responsive_utils_v2.dart` - الكود المصدري

---

**🎉 استمتع بالتطوير مع Responsive Design! 🚀**
