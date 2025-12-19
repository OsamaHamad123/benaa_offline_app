# 🚀 دليل التطبيق السريع - حقول النماذج الحديثة

## 📋 كيفية استخدام `modern_form_fields.dart`

### 1️⃣ ModernTextField - حقل نصي فاخر

#### الاستخدام الأساسي:
```dart
ModernTextField(
  controller: _nameController,
  focusNode: _nameFocus,
  labelText: 'اسم الجمعية *',
  hintText: 'أدخل اسم الجمعية',
  icon: Icons.business,
  iconColor: Colors.blue,
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال اسم الجمعية';
    }
    return null;
  },
  textInputAction: TextInputAction.next,
  onFieldSubmitted: () => _shortNameFocus.requestFocus(),
)
```

#### مع أنواع لوحة المفاتيح:
```dart
// هاتف
ModernTextField(
  controller: _phoneController,
  labelText: 'رقم الهاتف',
  icon: Icons.phone,
  iconColor: Colors.green,
  keyboardType: TextInputType.phone,
)

// بريد إلكتروني
ModernTextField(
  controller: _emailController,
  labelText: 'البريد الإلكتروني',
  icon: Icons.email,
  iconColor: Colors.purple,
  keyboardType: TextInputType.emailAddress,
)

// رقم
ModernTextField(
  controller: _accountController,
  labelText: 'رقم الحساب',
  icon: Icons.account_balance,
  iconColor: Colors.teal,
  keyboardType: TextInputType.number,
)
```

#### حقل متعدد الأسطر:
```dart
ModernTextField(
  controller: _notesController,
  labelText: 'ملاحظات',
  hintText: 'أدخل الملاحظات',
  icon: Icons.notes,
  iconColor: Colors.orange,
  maxLines: 4,
)
```

---

### 2️⃣ ModernDropdownField - قائمة منسدلة فاخرة

#### الاستخدام مع String:
```dart
ModernDropdownField<String>(
  labelText: 'العملة',
  hintText: 'اختر العملة',
  icon: Icons.monetization_on,
  iconColor: Colors.amber,
  value: _selectedCurrency,
  items: [
    DropdownMenuItem(value: 'IQD', child: Text('دينار عراقي')),
    DropdownMenuItem(value: 'USD', child: Text('دولار أمريكي')),
    DropdownMenuItem(value: 'EUR', child: Text('يورو')),
  ],
  onChanged: (value) {
    setState(() => _selectedCurrency = value);
  },
  validator: (value) {
    if (value == null) return 'الرجاء اختيار العملة';
    return null;
  },
)
```

#### مع كائنات مخصصة:
```dart
// مثال: قائمة المناديب
ModernDropdownField<Representative>(
  labelText: 'المندوب',
  hintText: 'اختر المندوب',
  icon: Icons.person,
  iconColor: Colors.deepPurple,
  value: _selectedRepresentative,
  items: representatives.map((rep) {
    return DropdownMenuItem(
      value: rep,
      child: Text(rep.name),
    );
  }).toList(),
  onChanged: (value) {
    setState(() => _selectedRepresentative = value);
  },
)
```

---

### 3️⃣ ModernSwitchTile - مفتاح تبديل فاخر

```dart
ModernSwitchTile(
  title: 'الحالة النشطة',
  subtitle: 'قم بتفعيل أو تعطيل الجمعية',
  icon: Icons.toggle_on,
  iconColor: Colors.green,
  value: _isActive,
  onChanged: (value) {
    setState(() => _isActive = value);
  },
)
```

---

### 4️⃣ ModernSectionHeader - عنوان قسم

```dart
ModernSectionHeader(
  title: 'المعلومات الأساسية',
  subtitle: 'بيانات الجمعية الرئيسية',
  icon: Icons.info_outline,
  iconColor: Colors.blue,
)
```

---

## 🎨 دليل الألوان (Color Guide)

### الألوان الموصى بها لكل نوع حقل:

```dart
// معلومات أساسية
Icons.business → Colors.blue
Icons.short_text → Colors.indigo

// معلومات اتصال
Icons.phone → Colors.green
Icons.email → Colors.purple
Icons.location_on → Colors.red

// معلومات بنكية
Icons.account_balance → Colors.teal
Icons.credit_card → Colors.cyan
Icons.account_balance_wallet → Colors.lightBlue

// عملات وأموال
Icons.monetization_on → Colors.amber
Icons.payments → Colors.orange
Icons.attach_money → Colors.yellow

// أشخاص
Icons.person → Colors.deepPurple
Icons.group → Colors.indigo
Icons.supervisor_account → Colors.purple

// حالة وإعدادات
Icons.toggle_on → Colors.green
Icons.settings → Colors.blueGrey
Icons.info → Colors.blue
```

---

## 📱 مثال كامل: نموذج جمعية

```dart
class AssociationForm extends StatefulWidget {
  @override
  _AssociationFormState createState() => _AssociationFormState();
}

class _AssociationFormState extends State<AssociationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountController = TextEditingController();
  
  String? _selectedCurrency = 'IQD';
  bool _isActive = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // 📋 قسم المعلومات الأساسية
          ModernSectionHeader(
            title: 'المعلومات الأساسية',
            subtitle: 'بيانات الجمعية الرئيسية',
            icon: Icons.info_outline,
            iconColor: Colors.blue,
          ),
          
          SizedBox(height: 16.h),
          
          // اسم الجمعية
          ModernTextField(
            controller: _nameController,
            labelText: 'اسم الجمعية *',
            hintText: 'أدخل اسم الجمعية',
            icon: Icons.business,
            iconColor: Colors.blue,
            validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
          ),
          
          SizedBox(height: 16.h),
          
          // الهاتف
          ModernTextField(
            controller: _phoneController,
            labelText: 'رقم الهاتف *',
            hintText: '07xxxxxxxxx',
            icon: Icons.phone,
            iconColor: Colors.green,
            keyboardType: TextInputType.phone,
            validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
          ),
          
          SizedBox(height: 16.h),
          
          // البريد
          ModernTextField(
            controller: _emailController,
            labelText: 'البريد الإلكتروني',
            hintText: 'example@email.com',
            icon: Icons.email,
            iconColor: Colors.purple,
            keyboardType: TextInputType.emailAddress,
          ),
          
          SizedBox(height: 32.h),
          
          // 🏦 قسم المعلومات البنكية
          ModernSectionHeader(
            title: 'المعلومات البنكية',
            subtitle: 'تفاصيل الحساب البنكي',
            icon: Icons.account_balance,
            iconColor: Colors.teal,
          ),
          
          SizedBox(height: 16.h),
          
          // اسم البنك
          ModernTextField(
            controller: _bankNameController,
            labelText: 'اسم البنك *',
            hintText: 'أدخل اسم البنك',
            icon: Icons.account_balance,
            iconColor: Colors.teal,
            validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
          ),
          
          SizedBox(height: 16.h),
          
          // رقم الحساب
          ModernTextField(
            controller: _accountController,
            labelText: 'رقم الحساب *',
            hintText: 'أدخل رقم الحساب',
            icon: Icons.credit_card,
            iconColor: Colors.cyan,
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
          ),
          
          SizedBox(height: 16.h),
          
          // العملة
          ModernDropdownField<String>(
            labelText: 'العملة',
            hintText: 'اختر العملة',
            icon: Icons.monetization_on,
            iconColor: Colors.amber,
            value: _selectedCurrency,
            items: [
              DropdownMenuItem(value: 'IQD', child: Text('دينار عراقي')),
              DropdownMenuItem(value: 'USD', child: Text('دولار أمريكي')),
              DropdownMenuItem(value: 'EUR', child: Text('يورو')),
            ],
            onChanged: (value) {
              setState(() => _selectedCurrency = value);
            },
          ),
          
          SizedBox(height: 32.h),
          
          // الحالة النشطة
          ModernSwitchTile(
            title: 'الحالة النشطة',
            subtitle: 'قم بتفعيل أو تعطيل الجمعية',
            icon: Icons.toggle_on,
            iconColor: Colors.green,
            value: _isActive,
            onChanged: (value) {
              setState(() => _isActive = value);
            },
          ),
          
          SizedBox(height: 32.h),
          
          // زر الحفظ
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // حفظ البيانات
              }
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
```

---

## 💡 نصائح الاستخدام

### 1. Focus Management:
```dart
// إنشاء FocusNodes
final _nameFocus = FocusNode();
final _phoneFocus = FocusNode();

// استخدام textInputAction
ModernTextField(
  focusNode: _nameFocus,
  textInputAction: TextInputAction.next,
  onFieldSubmitted: () => _phoneFocus.requestFocus(),
)

// التنظيف
@override
void dispose() {
  _nameFocus.dispose();
  _phoneFocus.dispose();
  super.dispose();
}
```

### 2. Validation:
```dart
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'هذا الحقل مطلوب';
  }
  if (value.length < 3) {
    return 'يجب أن يكون 3 أحرف على الأقل';
  }
  return null; // valid
}
```

### 3. State Management:
```dart
// مع setState
setState(() => _selectedCurrency = value);

// مع ValueNotifier
final _currencyNotifier = ValueNotifier<String?>('IQD');

ValueListenableBuilder(
  valueListenable: _currencyNotifier,
  builder: (context, value, child) {
    return ModernDropdownField(...);
  },
)
```

---

## ⚡ Performance Tips

1. **استخدم const constructors حيث أمكن**
2. **FocusNode reuse** - لا تنشئ FocusNode جديدة في build
3. **ValueListenableBuilder** - للتحديثات الجزئية
4. **Dispose controllers** - دائماً نظف الـ controllers

---

## 🎉 جاهز للاستخدام!

الآن يمكنك استبدال الحقول القديمة بالحقول الجديدة الفاخرة! 🚀
