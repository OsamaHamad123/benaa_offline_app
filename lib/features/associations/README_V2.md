# 🏢 Associations Feature - نظام إدارة الجمعيات

نظام كامل ومحسّن لإدارة الجمعيات الخارجية مع تطبيق Clean Architecture الكامل.

## 📋 المحتويات

- [المميزات](#-المميزات)
- [البنية المعمارية](#-البنية-المعمارية)
- [التثبيت والإعداد](#-التثبيت-والإعداد)
- [الاستخدام](#-الاستخدام)
- [الملفات الرئيسية](#-الملفات-الرئيسية)
- [التوثيق الكامل](#-التوثيق-الكامل)

## ✨ المميزات

### 🎨 تصميم احترافي
- ✅ **ResponsiveUtils** - دعم كامل للموبايل والتابلت
- ✅ **Theme موحد** - استخدام Theme.of(context) في كل مكان
- ✅ **Gradient AppBar** - تصميم أنيق مع تدرجات لونية
- ✅ **Material 3** - تصميم عصري

### ⚡ تجربة مستخدم ممتازة
- ✅ **Skeleton Loader** - تحميل احترافي بدون أخطاء أحجام
- ✅ **Empty State مع Animation** - حالة فارغة جميلة
- ✅ **بحث متقدم** - مع فلاتر (نشط/معطل، حسب المندوب)
- ✅ **ResponsiveBottomSheet** - لكل النماذج (إضافة، تعديل، المندوب)

### 🏗️ بنية نظيفة
- ✅ **Clean Architecture** - فصل كامل بين الطبقات
- ✅ **8 Use Cases** - لكل عملية Use Case منفصل
- ✅ **Result Pattern** - معالجة أخطاء احترافية
- ✅ **Riverpod** - إدارة حالة قوية

## 🏗️ البنية المعمارية

```
lib/features/associations/
├── 📂 domain/
│   ├── entities/
│   │   ├── association.dart
│   │   └── representative.dart
│   ├── repositories/
│   │   └── association_repository.dart
│   └── usecases/
│       ├── get_all_active_associations.dart
│       ├── get_association_by_id.dart
│       ├── create_association.dart
│       ├── update_association.dart
│       ├── delete_association.dart
│       ├── get_all_representatives.dart
│       ├── create_representative.dart
│       └── search_associations.dart
│
├── 📂 data/
│   └── repositories/
│       └── association_repository_impl.dart
│
├── 📂 presentation/
│   ├── providers/
│   │   └── associations_provider.dart
│   ├── pages/
│   │   ├── associations_list_page_v2.dart ✨ (محسّن)
│   │   └── association_form_bottom_sheet.dart ✨
│   └── widgets/
│       ├── association_card_v2.dart ✨
│       ├── representative_dropdown_v2.dart ✨
│       └── associations_skeleton_loader.dart ✨
│
└── associations_v2.dart (Barrel Export)
```

## 🚀 التثبيت والإعداد

### 1. إضافة الجداول إلى drift_database.dart

الجداول مضافة تلقائياً:
- ✅ `Associations`
- ✅ `AssociationRepresentatives`
- ✅ `AssociationsDao`

### 2. تشغيل Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. إضافة المسار في Router

```dart
GoRoute(
  path: '/associations',
  name: 'associations',
  builder: (context, state) => const AssociationsListPageV2(),
),
```

## 📖 الاستخدام

### فتح صفحة الجمعيات

```dart
// باستخدام GoRouter
context.go('/associations');

// أو باستخدام Navigator
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AssociationsListPageV2(),
  ),
);
```

### الوصول إلى State

```dart
// في Widget
final state = ref.watch(associationsProvider);

// تحميل البيانات
ref.read(associationsProvider.notifier).loadAssociations();

// إضافة جمعية
final params = AssociationParams(
  name: 'جمعية الخير',
  phone: '07701234567',
  bankName: 'البنك المركزي',
  accountNumber: '123456789',
  accountCurrency: 'IQD',
  representativeId: 'rep-id',
);
await ref.read(associationsProvider.notifier).createAssociation(params);
```

## 📁 الملفات الرئيسية

### V2 - الإصدار المحسّن ✨

#### 1. associations_list_page_v2.dart
صفحة القائمة الرئيسية مع:
- ResponsiveUtils
- Skeleton Loader
- بحث متقدم مع فلاتر
- Empty State مع Animation
- AlertDialog لتأكيد الحذف
- ResponsiveBottomSheet للإضافة والتعديل

#### 2. association_form_bottom_sheet.dart
نموذج الإضافة/التعديل:
- ResponsiveBottomSheet
- ResponsiveUtils
- جميع الحقول المطلوبة
- Validation كامل
- Theme موحد

#### 3. representative_dropdown_v2.dart
Dropdown مع إضافة مندوب:
- ResponsiveBottomSheet لإضافة مندوب
- ResponsiveUtils
- Theme موحد

#### 4. association_card_v2.dart
كرت الجمعية:
- ResponsiveUtils
- عرض كل التفاصيل
- أيقونات ملونة
- زر الحذف

#### 5. associations_skeleton_loader.dart
Skeleton Loader:
- تأثير shimmer
- بدون أخطاء أحجام
- ResponsiveUtils

### الملفات القديمة (V1)

الملفات التالية قديمة ولا يُنصح باستخدامها:
- ❌ `associations_list_page.dart` (استبدلت بـ V2)
- ❌ `association_form_page.dart` (استبدلت بـ bottom sheet)
- ❌ `association_card.dart` (استبدلت بـ V2)
- ❌ `representative_dropdown.dart` (استبدلت بـ V2)

## 📚 التوثيق الكامل

للتوثيق الكامل، راجع:
- [`docs/ASSOCIATIONS_INDEX.md`](../../docs/ASSOCIATIONS_INDEX.md) - الفهرس الرئيسي
- [`docs/ASSOCIATIONS_ARCHITECTURE.md`](../../docs/ASSOCIATIONS_ARCHITECTURE.md) - التوثيق المعماري
- [`docs/ASSOCIATIONS_QUICK_START.md`](../../docs/ASSOCIATIONS_QUICK_START.md) - دليل البداية السريع

## 🔄 التحديثات

### V2 (ديسمبر 2024) ✨
- ✅ ResponsiveUtils كامل
- ✅ ResponsiveBottomSheet للنماذج
- ✅ Skeleton Loader احترافي
- ✅ بحث متقدم مع فلاتر
- ✅ Empty State مع Animation
- ✅ Theme موحد 100%

### V1 (أولي)
- ✅ Clean Architecture
- ✅ Database Schema
- ✅ CRUD Operations
- ❌ بدون ResponsiveUtils
- ❌ بدون Bottom Sheets

## 🎯 المهام المستقبلية

- [ ] ربط الجمعيات بقسم الكفالات (سيتم لاحقاً)
- [ ] ربط الجمعيات بالمستفيدين (اختياري)
- [ ] تقارير الجمعيات
- [ ] مزامنة مع السيرفر

## 📝 ملاحظات

1. **ResponsiveUtils**: تم تطبيقه في كل مكان مع `.w`, `.h`, `.sp`
2. **Theme**: استخدام `Theme.of(context).colorScheme` في كل مكان
3. **AlertDialog للحذف**: حسب الطلب، بدل ResponsiveBottomSheet
4. **بحث متقدم**: مع فلاتر نشط/معطل ومندوب
5. **Skeleton Loader**: بدون أخطاء أحجام

---

Made with ❤️ for Benaa Offline App
