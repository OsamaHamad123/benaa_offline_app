# 📖 Widget Usage Examples

## 🎯 Validation Widgets

### ValidationIndicator

عرض حالة التحقق بصرياً:

```dart
import 'package:benaa_offline_app/core/widgets/validation_indicators.dart';

// Success state
ValidationIndicator(
  isValid: true,
  successMessage: 'الرقم الوطني صحيح ✓',
)

// Error state  
ValidationIndicator(
  isValid: false,
)

// Hidden state
ValidationIndicator(
  isValid: null, // Will not show anything
)
```

### FieldHelperText

نص مساعد مع أيقونة:

```dart
FieldHelperText(
  text: 'مثال: 0595735352',
  icon: Icons.info_outline,
  color: Colors.blue[600],
)
```

### RealTimeValidatedField

Wrapper للتحقق المباشر:

```dart
final controller = TextEditingController();

RealTimeValidatedField(
  controller: controller,
  validator: (value) {
    if (value == null || value.isEmpty) return 'الحقل مطلوب';
    if (value.length < 9) return 'يجب أن يكون 9 أرقام';
    return null;
  },
  successMessage: 'الرقم صحيح ✓',
  child: TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: 'الرقم الوطني'),
  ),
)
```

---

## ✨ Visual Enhancement Widgets

### ShimmerLoading

تأثير shimmer للـ loading:

```dart
ShimmerLoading(
  isLoading: _isLoading,
  child: Container(
    width: 200,
    height: 100,
    color: Colors.grey[300],
  ),
)
```

### FadeInWidget

دخول تدريجي للـ widget:

```dart
FadeInWidget(
  duration: Duration(milliseconds: 500),
  delay: Duration(milliseconds: 200),
  child: Card(
    child: Text('محتوى'),
  ),
)
```

### RippleCard

كارد مع تأثير ripple:

```dart
RippleCard(
  onTap: () => print('تم الضغط'),
  padding: EdgeInsets.all(16),
  borderRadius: BorderRadius.circular(12),
  child: Column(
    children: [
      Icon(Icons.person),
      Text('مستفيد'),
    ],
  ),
)
```

### GradientBackground

خلفية متدرجة:

```dart
GradientBackground(
  colors: [
    Colors.blue[700]!,
    Colors.blue[900]!,
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  child: Scaffold(
    backgroundColor: Colors.transparent,
    body: Center(child: Text('محتوى')),
  ),
)
```

### SuccessCheckmark

علامة صح متحركة:

```dart
// Show after successful operation
SuccessCheckmark(
  size: 100,
  color: Colors.green,
)

// In a dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SuccessCheckmark(),
        SizedBox(height: 16),
        Text('تم الحفظ بنجاح'),
      ],
    ),
  ),
);
```

### AnimatedProgressBar

شريط تقدم متحرك:

```dart
AnimatedProgressBar(
  progress: 0.65, // 0.0 to 1.0
  color: Colors.blue,
  backgroundColor: Colors.grey[200],
  height: 8,
  borderRadius: BorderRadius.circular(4),
)

// في نموذج متعدد الخطوات
AnimatedProgressBar(
  progress: _currentStep / _totalSteps,
  color: Theme.of(context).primaryColor,
)
```

---

## ♿ Accessibility Widgets

### AccessibleButton

زر مع حجم لمس مناسب (48x48 dp):

```dart
// Filled button
AccessibleButton(
  onPressed: () => _saveData(),
  child: Text('حفظ'),
)

// Outlined button
AccessibleButton(
  onPressed: () => _cancel(),
  outlined: true,
  child: Text('إلغاء'),
)

// Custom colors and size
AccessibleButton(
  onPressed: () {},
  backgroundColor: Colors.green,
  foregroundColor: Colors.white,
  minWidth: 100,
  minHeight: 56, // Larger touch target
  child: Text('إرسال'),
)
```

### AccessibleIconButton

زر أيقونة مع حجم مناسب:

```dart
AccessibleIconButton(
  icon: Icons.edit,
  onPressed: () => _edit(),
  tooltip: 'تعديل',
  color: Colors.blue,
)

// With background
AccessibleIconButton(
  icon: Icons.delete,
  onPressed: () => _delete(),
  tooltip: 'حذف',
  backgroundColor: Colors.red[50],
  color: Colors.red,
  size: 56, // Custom size
)
```

### AccessibleListTile

List tile مع ارتفاع مناسب:

```dart
AccessibleListTile(
  leading: Icon(Icons.person),
  title: Text('اسم المستفيد'),
  subtitle: Text('معلومات إضافية'),
  trailing: Icon(Icons.arrow_forward_ios),
  onTap: () => _openDetails(),
  minHeight: 56, // Custom minimum height
)
```

### SemanticWrapper

إضافة semantic labels للـ screen readers:

```dart
SemanticWrapper(
  label: 'زر الحفظ',
  hint: 'اضغط للحفظ',
  child: IconButton(
    icon: Icon(Icons.save),
    onPressed: () => _save(),
  ),
)
```

### AccessibleSpacing

مسافات مناسبة:

```dart
Column(
  children: [
    AccessibleButton(...),
    AccessibleSpacing.recommendedVertical, // 16.h
    AccessibleButton(...),
    AccessibleSpacing.minVertical, // 8 dp minimum
    Text('نص'),
  ],
)

Row(
  children: [
    AccessibleButton(...),
    AccessibleSpacing.recommendedHorizontal,
    AccessibleButton(...),
  ],
)
```

---

## 🎨 Complete Form Example

مثال كامل لنموذج مع جميع التحسينات:

```dart
class EnhancedBeneficiaryForm extends StatefulWidget {
  @override
  State<EnhancedBeneficiaryForm> createState() => _EnhancedBeneficiaryFormState();
}

class _EnhancedBeneficiaryFormState extends State<EnhancedBeneficiaryForm> {
  final _nameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShimmerLoading(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Name field with real-time validation
              FadeInWidget(
                delay: Duration(milliseconds: 100),
                child: RealTimeValidatedField(
                  controller: _nameController,
                  validator: (v) => v?.isEmpty ?? true ? 'الاسم مطلوب' : null,
                  successMessage: 'صحيح ✓',
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'الاسم'),
                  ),
                ),
              ),

              AccessibleSpacing.recommendedVertical,

              // National ID field
              FadeInWidget(
                delay: Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nationalIdController,
                      decoration: InputDecoration(labelText: 'الرقم الوطني'),
                    ),
                    FieldHelperText(
                      text: 'مثال: 123456789',
                      icon: Icons.info_outline,
                    ),
                  ],
                ),
              ),

              AccessibleSpacing.recommendedVertical,

              // Progress indicator
              if (_isSaving) ...[
                AnimatedProgressBar(progress: 0.5),
                SizedBox(height: 16),
              ],

              // Action buttons with proper spacing
              Row(
                children: [
                  Expanded(
                    child: AccessibleButton(
                      onPressed: _isSaving ? null : () => _save(),
                      child: Text('حفظ'),
                    ),
                  ),
                  AccessibleSpacing.recommendedHorizontal,
                  Expanded(
                    child: AccessibleButton(
                      onPressed: () => Navigator.pop(context),
                      outlined: true,
                      child: Text('إلغاء'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    await Future.delayed(Duration(seconds: 2)); // Simulate save
    
    // Show success animation
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SuccessCheckmark(),
              SizedBox(height: 16),
              Text('تم الحفظ بنجاح'),
            ],
          ),
        ),
      ),
    );
    
    setState(() => _isSaving = false);
  }
}
```

---

## 💡 Best Practices

### 1. Accessibility
- استخدم `AccessibleButton` بدلاً من `ElevatedButton` أو `TextButton`
- تأكد من حجم اللمس 48x48 dp كحد أدنى
- أضف `tooltip` لجميع الأزرار الأيقونية

### 2. Visual Feedback
- أضف `HapticFeedback` للإجراءات المهمة
- استخدم `AnimatedContainer` للحالات المتغيرة
- أضف `FadeInWidget` للعناصر الجديدة

### 3. Validation
- استخدم `RealTimeValidatedField` للحقول المهمة
- أضف `FieldHelperText` مع أمثلة واضحة
- اعرض `ValidationIndicator` فقط عند النجاح

### 4. Performance
- استخدم `const` constructors حيثما أمكن
- تجنب rebuilds غير ضرورية
- استخدم `ShimmerLoading` للبيانات المحملة

---

**Last Updated:** December 20, 2024  
**Documentation Version:** 1.0
