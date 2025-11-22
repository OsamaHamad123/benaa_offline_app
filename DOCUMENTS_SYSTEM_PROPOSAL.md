# 📎 نظام إدارة الوثائق - مقترحات شاملة

## 🎯 المشكلة الحالية
- لا يوجد نظام موحد للوثائق
- كل قسم يحتاج وثائق مختلفة
- الوثائق مبعثرة بين الأقسام

---

## 💡 الحل المقترح: نظام وثائق موحد على مستوى الفورم

### الأقسام التي تحتاج وثائق:

#### 1️⃣ **قسم العائلة**
```
الوالدين المتوفيين:
- شهادة وفاة / إفادة شهيد (PDF, صورة)
- بطاقة هوية المتوفى (صورة)

الأيتام:
- شهادة ميلاد (PDF, صورة)
- بطاقة صحية (PDF, صورة)
- تقارير طبية (للحالات المرضية/الإعاقة)
```

#### 2️⃣ **قسم المعلومات الأساسية**
```
- صورة المستفيد (صورة شخصية)
- بطاقة الهوية (أمامية + خلفية)
- إثبات السكن (عقد إيجار، كهرباء، ماء)
```

#### 3️⃣ **قسم الحالة الصحية**
```
- تقارير طبية
- وصفات طبية
- نتائج تحاليل
- أشعات
```

#### 4️⃣ **قسم الحالة الاقتصادية**
```
- إثبات الدخل (كشف راتب، عقد عمل)
- فواتير الإيجار
- فواتير الكهرباء/الماء
- ديون (إن وجدت)
```

#### 5️⃣ **قسم السكن**
```
- صور المنزل (خارجي + داخلي)
- عقد الإيجار / ملكية
- مخططات (إن وجدت)
```

---

## 🏗️ التصميم المقترح

### Option 1: Tab مركزي للوثائق ⭐⭐⭐⭐⭐

**الأفضل للتابلت والموبايل**

```dart
Form Structure:
┌─────────────────────────────────┐
│ [معلومات] [عائلة] [صحة] [وثائق]│ ← Tabs
├─────────────────────────────────┤
│                                 │
│  📎 الوثائق والمرفقات           │
│                                 │
│  ┌──────────────────────────┐  │
│  │ 📋 الهوية الشخصية       │  │
│  │ • بطاقة الهوية (أمامية) │  │
│  │ • بطاقة الهوية (خلفية)   │  │
│  │ [+ إضافة]                │  │
│  └──────────────────────────┘  │
│                                 │
│  ┌──────────────────────────┐  │
│  │ 📋 الوالدين المتوفيين    │  │
│  │ • شهادة وفاة الأب        │  │
│  │ • إفادة شهيد الأم         │  │
│  │ [+ إضافة]                │  │
│  └──────────────────────────┘  │
│                                 │
│  ┌──────────────────────────┐  │
│  │ 📋 الأيتام               │  │
│  │ • شهادة ميلاد (أحمد)     │  │
│  │ • تقرير طبي (فاطمة)      │  │
│  │ [+ إضافة]                │  │
│  └──────────────────────────┘  │
│                                 │
└─────────────────────────────────┘
```

**المزايا:**
- ✅ منظم: كل الوثائق في مكان واحد
- ✅ سهل: المستخدم يعرف أين يضيف الوثائق
- ✅ Responsive: يعمل على موبايل وتابلت
- ✅ تجميع منطقي حسب القسم

**التطبيق:**
```dart
class DocumentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _buildDocumentSection(
          title: 'الهوية الشخصية',
          icon: Icons.badge,
          color: Colors.blue,
          children: [
            _buildDocumentItem('بطاقة الهوية (أمامية)', 'id_front'),
            _buildDocumentItem('بطاقة الهوية (خلفية)', 'id_back'),
          ],
        ),
        SizedBox(height: 16.h),
        _buildDocumentSection(
          title: 'الوالدين المتوفيين',
          icon: Icons.person_off,
          color: Colors.red,
          children: [
            _buildDocumentItem('شهادة وفاة الأب', 'father_death_cert'),
            _buildDocumentItem('شهادة وفاة الأم', 'mother_death_cert'),
          ],
        ),
        // ... باقي الأقسام
      ],
    );
  }
}
```

---

### Option 2: أزرار مرفقات في كل قسم ⭐⭐⭐⭐

**بديل جيد**

```dart
في قسم العائلة:
┌─────────────────────────────┐
│ أب متوفى: محمد أحمد         │
│ [عرض] [تعديل] [📎 وثائق]   │ ← زر الوثائق
└─────────────────────────────┘

عند الضغط على [📎 وثائق]:
┌─────────────────────────────┐
│ وثائق: محمد أحمد           │
├─────────────────────────────┤
│ • شهادة الوفاة              │
│ • بطاقة الهوية              │
│ [+ إضافة وثيقة جديدة]      │
└─────────────────────────────┘
```

**المزايا:**
- ✅ مباشر: الوثيقة قريبة من البيانات
- ✅ سياقي: كل شخص له وثائقه
- ✅ مرن: يمكن إضافة أي عدد من الوثائق

**العيوب:**
- ⚠️ مبعثر: الوثائق موزعة على الأقسام
- ⚠️ صعب المراجعة: لا يوجد overview للكل

---

### Option 3: Floating Action Button للوثائق ⭐⭐⭐

**للموبايل فقط**

```dart
في أي tab:
                              [📎] ← FAB
عند الضغط:
┌─────────────────────────────┐
│ إضافة وثيقة                 │
├─────────────────────────────┤
│ • اختر القسم: [العائلة ▼]   │
│ • نوع الوثيقة: [شهادة ▼]    │
│ • [📷 كاميرا] [📁 ملف]      │
└─────────────────────────────┘
```

**المزايا:**
- ✅ سريع: وصول مباشر من أي مكان
- ✅ بسيط: لا tabs إضافية

**العيوب:**
- ⚠️ غير واضح: المستخدم قد لا يلاحظه
- ⚠️ لا يناسب التابلت

---

## 🎨 التصميم الموصى به

### **Tab مركزي للوثائق** (Option 1) ⭐⭐⭐⭐⭐

#### الكود الكامل:

```dart
// 1. إضافة Documents Tab للـ Form
class BeneficiaryFormTabs {
  static const List<Tab> tabs = [
    Tab(icon: Icon(Icons.info), text: 'معلومات'),
    Tab(icon: Icon(Icons.family_restroom), text: 'عائلة'),
    Tab(icon: Icon(Icons.health_and_safety), text: 'صحة'),
    Tab(icon: Icon(Icons.attach_file), text: 'وثائق'), // ← جديد
  ];
}

// 2. Documents Tab Widget
class DocumentsTab extends StatefulWidget {
  final BeneficiaryFormControllers formControllers;

  const DocumentsTab({super.key, required this.formControllers});

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // رأس الصفحة
        _buildHeader(),
        SizedBox(height: 16.h),

        // 1. وثائق الهوية
        _buildDocumentSection(
          title: 'الهوية الشخصية',
          icon: Icons.badge,
          color: Colors.blue,
          documents: widget.formControllers.identityDocuments,
          onAdd: () => _showAddDocumentDialog('identity'),
        ),
        SizedBox(height: 16.h),

        // 2. وثائق العائلة
        _buildDocumentSection(
          title: 'العائلة',
          icon: Icons.family_restroom,
          color: Colors.green,
          documents: widget.formControllers.familyDocuments,
          onAdd: () => _showAddDocumentDialog('family'),
        ),
        SizedBox(height: 16.h),

        // 3. وثائق صحية
        _buildDocumentSection(
          title: 'الحالة الصحية',
          icon: Icons.medical_services,
          color: Colors.red,
          documents: widget.formControllers.medicalDocuments,
          onAdd: () => _showAddDocumentDialog('medical'),
        ),
        SizedBox(height: 16.h),

        // 4. وثائق اقتصادية
        _buildDocumentSection(
          title: 'الحالة الاقتصادية',
          icon: Icons.account_balance_wallet,
          color: Colors.orange,
          documents: widget.formControllers.economicDocuments,
          onAdd: () => _showAddDocumentDialog('economic'),
        ),
        SizedBox(height: 16.h),

        // 5. وثائق السكن
        _buildDocumentSection(
          title: 'السكن',
          icon: Icons.home,
          color: Colors.purple,
          documents: widget.formControllers.housingDocuments,
          onAdd: () => _showAddDocumentDialog('housing'),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final totalDocs = widget.formControllers.identityDocuments.length +
        widget.formControllers.familyDocuments.length +
        widget.formControllers.medicalDocuments.length +
        widget.formControllers.economicDocuments.length +
        widget.formControllers.housingDocuments.length;

    return Card(
      color: Colors.blue.withValues(alpha: 0.1),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(Icons.folder_open, size: 40.sp, color: Colors.blue),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الوثائق والمرفقات',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'إجمالي الوثائق: $totalDocs',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> documents,
    required VoidCallback onAdd,
  }) {
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${documents.length} وثيقة'),
        children: [
          if (documents.isEmpty)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'لا توجد وثائق بعد',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
          ...documents.map((doc) => _buildDocumentItem(doc)),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('إضافة وثيقة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(Map<String, dynamic> doc) {
    final fileName = doc['name'] as String;
    final fileType = doc['type'] as String; // pdf, image, etc.
    final filePath = doc['path'] as String;
    final uploadDate = doc['uploadDate'] as DateTime?;

    IconData fileIcon;
    Color iconColor;

    switch (fileType.toLowerCase()) {
      case 'pdf':
        fileIcon = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
        fileIcon = Icons.image;
        iconColor = Colors.blue;
        break;
      default:
        fileIcon = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }

    return ListTile(
      leading: Icon(fileIcon, color: iconColor),
      title: Text(fileName),
      subtitle: uploadDate != null
          ? Text('${uploadDate.day}/${uploadDate.month}/${uploadDate.year}')
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility, color: Colors.blue),
            onPressed: () => _viewDocument(filePath),
            tooltip: 'عرض',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteDocument(doc),
            tooltip: 'حذف',
          ),
        ],
      ),
    );
  }

  void _showAddDocumentDialog(String category) {
    showDialog(
      context: context,
      builder: (context) => DocumentUploadDialog(
        category: category,
        onUpload: (documentData) {
          setState(() {
            switch (category) {
              case 'identity':
                widget.formControllers.identityDocuments.add(documentData);
                break;
              case 'family':
                widget.formControllers.familyDocuments.add(documentData);
                break;
              case 'medical':
                widget.formControllers.medicalDocuments.add(documentData);
                break;
              case 'economic':
                widget.formControllers.economicDocuments.add(documentData);
                break;
              case 'housing':
                widget.formControllers.housingDocuments.add(documentData);
                break;
            }
          });
        },
      ),
    );
  }

  void _viewDocument(String path) {
    // TODO: فتح الوثيقة
    // استخدم open_file أو url_launcher
  }

  void _deleteDocument(Map<String, dynamic> doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف "${doc['name']}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                // حذف من القائمة المناسبة
                widget.formControllers.identityDocuments.remove(doc);
                widget.formControllers.familyDocuments.remove(doc);
                widget.formControllers.medicalDocuments.remove(doc);
                widget.formControllers.economicDocuments.remove(doc);
                widget.formControllers.housingDocuments.remove(doc);
              });
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

// 3. Document Upload Dialog
class DocumentUploadDialog extends StatefulWidget {
  final String category;
  final Function(Map<String, dynamic>) onUpload;

  const DocumentUploadDialog({
    super.key,
    required this.category,
    required this.onUpload,
  });

  @override
  State<DocumentUploadDialog> createState() => _DocumentUploadDialogState();
}

class _DocumentUploadDialogState extends State<DocumentUploadDialog> {
  final _nameController = TextEditingController();
  String? _selectedType;
  String? _filePath;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة وثيقة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'اسم الوثيقة',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'نوع الوثيقة',
              border: OutlineInputBorder(),
            ),
            items: _getDocumentTypes(widget.category)
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => setState(() => _selectedType = value),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('كاميرا'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFromFiles,
                  icon: const Icon(Icons.folder),
                  label: const Text('ملف'),
                ),
              ),
            ],
          ),
          if (_filePath != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text('تم اختيار: ${_filePath!.split('/').last}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.green)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _filePath != null ? _upload : null,
          child: const Text('رفع'),
        ),
      ],
    );
  }

  List<String> _getDocumentTypes(String category) {
    switch (category) {
      case 'identity':
        return ['بطاقة هوية', 'جواز سفر', 'إثبات سكن'];
      case 'family':
        return ['شهادة وفاة', 'إفادة شهيد', 'شهادة ميلاد', 'تقرير طبي'];
      case 'medical':
        return ['تقرير طبي', 'وصفة طبية', 'نتائج تحليل', 'أشعة'];
      case 'economic':
        return ['كشف راتب', 'عقد عمل', 'فاتورة إيجار', 'فواتير'];
      case 'housing':
        return ['صورة المنزل', 'عقد إيجار', 'ملكية', 'مخطط'];
      default:
        return ['أخرى'];
    }
  }

  Future<void> _pickFromCamera() async {
    // TODO: استخدم image_picker
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.camera);
  }

  Future<void> _pickFromFiles() async {
    // TODO: استخدم file_picker
    // FilePickerResult? result = await FilePicker.platform.pickFiles();
  }

  void _upload() {
    final documentData = {
      'name': _nameController.text,
      'type': _selectedType,
      'path': _filePath!,
      'uploadDate': DateTime.now(),
    };
    widget.onUpload(documentData);
    Navigator.pop(context);
  }
}

// 4. إضافة للـ FormControllers
class BeneficiaryFormControllers extends ChangeNotifier {
  // ... الحقول الموجودة

  // وثائق جديدة
  final List<Map<String, dynamic>> identityDocuments = [];
  final List<Map<String, dynamic>> familyDocuments = [];
  final List<Map<String, dynamic>> medicalDocuments = [];
  final List<Map<String, dynamic>> economicDocuments = [];
  final List<Map<String, dynamic>> housingDocuments = [];
}
```

---

## 📱 Responsive Design

### للموبايل (< 600px):
```dart
- Dialog fullscreen
- حقول عمودية (Column)
- أزرار كبيرة
```

### للتابلت (> 600px):
```dart
- Dialog 600px width
- حقول في صفوف (Row)
- Layout أكثر كثافة
```

---

## ✅ خلاصة التوصيات

1. **حل اللاق:** ✅ استخدم `CompactFamilyMemberDialog` (تم)
2. **Responsive:** ✅ MediaQuery + ConstrainedBox (تم)
3. **الوثائق:** ⭐ **Tab مركزي** - أفضل حل للموبايل والتابلت

### الخطوات التالية:
1. ✅ تطبيق CompactDialog (تم)
2. 🔄 إنشاء DocumentsTab
3. 🔄 إضافة للـ FormControllers
4. 🔄 تكامل مع file_picker و image_picker
