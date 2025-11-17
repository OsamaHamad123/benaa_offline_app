# 📎 Attachments Feature - Clean Architecture

## البنية المعمارية

تم تنظيم ميزة المرفقات باستخدام Clean Architecture مع ثلاث طبقات منفصلة:

```
features/attachments/
├── domain/                 # Domain Layer - قلب المنطق
│   ├── entities/
│   │   └── attachment.dart          # Attachment Entity + AttachmentType enum
│   ├── repositories/
│   │   └── attachment_repository.dart    # Repository Interface
│   └── usecases/
│       ├── get_beneficiary_attachments_usecase.dart
│       ├── add_attachment_usecase.dart
│       └── delete_attachment_usecase.dart
├── data/                   # Data Layer - تفاصيل التنفيذ
│   ├── models/
│   │   └── attachment_model.dart    # AttachmentModel extends Attachment
│   ├── datasources/
│   │   └── attachment_datasource.dart    # File operations + DB access
│   └── repositories/
│       └── attachment_repository_impl.dart
└── presentation/           # Presentation Layer - UI
    ├── providers/
    │   └── attachments_provider.dart     # Riverpod state management
    └── widgets/
        └── attachments_section_clean.dart # UI widget
```

## الكيانات (Entities)

### Attachment
```dart
class Attachment {
  final String id;
  final String beneficiaryId;
  final String? visitId;
  final String fileName;
  final String filePath;
  final AttachmentType type;
  final int fileSize;
  final String? thumbnailPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync;
  final String? serverUrl;
  final DateTime? lastSyncedAt;
}
```

### AttachmentType
```dart
enum AttachmentType {
  image,   // صورة
  pdf,     // PDF
  other;   // ملف آخر
}
```

## Use Cases

### 1. GetBeneficiaryAttachmentsUseCase
احصل على جميع مرفقات مستفيد معين.

```dart
final attachments = await getBeneficiaryAttachmentsUseCase.execute(beneficiaryId);
```

### 2. AddAttachmentUseCase
إضافة مرفق جديد (صورة أو PDF).

```dart
final attachment = await addAttachmentUseCase.execute(
  beneficiaryId: beneficiaryId,
  sourceFile: file,
);
```

### 3. DeleteAttachmentUseCase
حذف مرفق محدد.

```dart
final success = await deleteAttachmentUseCase.execute(attachmentId);
```

## Data Source

### AttachmentDataSource
يتعامل مع:
- ✅ حفظ الملفات في مجلد التطبيق
- ✅ ضغط الصور تلقائياً (max 1920px)
- ✅ إنشاء thumbnails للصور (200px)
- ✅ الحفظ في قاعدة البيانات Drift
- ✅ التحقق من حجم الملف (max 10 MB)
- ✅ دعم أنواع مختلفة (jpg, png, pdf, etc.)

### مسارات الملفات
```
/data/data/com.example.app/files/
├── beneficiary_attachments/
│   └── {beneficiaryId}/
│       └── {timestamp}.{ext}
└── thumbnails/
    └── {beneficiaryId}/
        └── thumb_{timestamp}.{ext}
```

## Presentation Layer

### AttachmentsProvider
State management باستخدام Riverpod:

```dart
// Load attachments
ref.read(attachmentsProvider(beneficiaryId).notifier).loadAttachments(beneficiaryId);

// Add attachment
await ref.read(attachmentsProvider(beneficiaryId).notifier).addAttachment(
  beneficiaryId: beneficiaryId,
  sourceFile: file,
);

// Delete attachment
await ref.read(attachmentsProvider(beneficiaryId).notifier).deleteAttachment(id);
```

### AttachmentsSectionClean Widget
Widget جاهز للاستخدام مع:
- ✅ عرض المرفقات في Grid
- ✅ إضافة مرفقات (كاميرا، معرض، PDF)
- ✅ حذف مرفقات
- ✅ فتح الملفات
- ✅ عرض thumbnails للصور
- ✅ عرض حجم ونوع الملف
- ✅ وضع Read-only

## الاستخدام

### في صفحة التفاصيل
```dart
AttachmentsSectionClean(
  beneficiaryId: beneficiaryId,
  readOnly: false, // أو true لعدم السماح بالتعديل
)
```

### في صفحة الإضافة/التعديل
```dart
AttachmentsSectionClean(
  beneficiaryId: beneficiaryId,
  readOnly: false,
)
```

## المميزات

### ✅ Clean Architecture
- فصل كامل بين الطبقات
- سهولة الاختبار
- سهولة الصيانة والتوسع

### ✅ تحسين الأداء
- ضغط الصور تلقائياً
- Thumbnails للعرض السريع
- Caching في الـ state

### ✅ تجربة مستخدم محسنة
- عرض Grid جميل
- إضافة من مصادر متعددة
- تأكيد قبل الحذف
- رسائل واضحة للنجاح/الفشل

### ✅ حفظ آمن
- تخزين في قاعدة البيانات
- تتبع حالة المزامنة
- حذف آمن (ملفات + قاعدة بيانات)

## الترقية من النظام القديم

الكود القديم:
```dart
AttachmentsSection(
  beneficiaryId: beneficiaryId,
  loadFromDatabase: true,
)
```

الكود الجديد:
```dart
AttachmentsSectionClean(
  beneficiaryId: beneficiaryId,
  readOnly: false,
)
```

## ملاحظات مهمة

1. **Auto-loading**: المرفقات تُحمّل تلقائياً عند إنشاء Provider
2. **File Management**: الملفات تُحفظ في مجلد التطبيق (لا يتم المسح عند إلغاء التثبيت)
3. **Sync State**: يتم تتبع حالة المزامنة لكل مرفق
4. **Error Handling**: جميع العمليات محمية بـ try-catch مع رسائل واضحة

## TODO - تحسينات مستقبلية

- [ ] دعم أنواع ملفات إضافية (Word, Excel)
- [ ] مزامنة مع السيرفر
- [ ] معاينة PDF داخل التطبيق
- [ ] تعديل/تدوير الصور
- [ ] تحميل batch للمرفقات
- [ ] دعم مرفقات الزيارات
