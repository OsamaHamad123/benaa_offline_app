# 🏷️ Taxonomy System - نظام التصنيفات الجديد

## 📋 الملخص

تم إنشاء نظام تصنيفات جديد باستخدام **Clean Architecture** مع **Riverpod** لإدارة الحالة.
مع **Bridge Providers** للتوافق مع Drift Database الموجود.

## 🏗️ الهيكل

```
lib/features/taxonomies/
├── taxonomies.dart                    # Barrel exports
├── domain/
│   ├── entities/
│   │   ├── taxonomy.dart              # Entity + Statistics + SyncResult
│   │   └── taxonomy_group.dart        # 15 TaxonomyGroup enum
│   ├── repositories/
│   │   └── taxonomy_repository.dart   # Repository Interface
│   └── usecases/
│       └── taxonomy_usecases.dart     # 6 Use Cases
├── data/
│   ├── models/
│   │   └── taxonomy_dto.dart          # DTOs (hand-written)
│   ├── datasources/
│   │   ├── taxonomy_remote_datasource.dart
│   │   └── taxonomy_local_datasource.dart
│   └── repositories/
│       └── taxonomy_repository_impl.dart
└── presentation/
    ├── providers/
    │   ├── taxonomy_providers.dart          # Clean Architecture Providers
    │   └── taxonomy_bridge_providers.dart   # 🌉 Bridge to Drift DB
    ├── pages/
    │   └── taxonomy_management_page.dart
    └── widgets/
        ├── taxonomy_widgets.dart
        └── taxonomy_bridge_widgets.dart     # 🌉 Bridge Widgets
```

## 📦 15 مجموعة تصنيفات

| Enum                | Value              | العربية           |
| ------------------- | ------------------ | ----------------- |
| `governorate`       | governorate        | المحافظات         |
| `category`          | category           | الفئات            |
| `maritalStatus`     | marital_status     | الحالة الاجتماعية |
| `educationLevel`    | education_level    | المستوى التعليمي  |
| `healthStatus`      | health_status      | الحالة الصحية     |
| `housingType`       | housing_type       | نوع السكن         |
| `housingStatus`     | housing_status     | حالة السكن        |
| `disabilityType`    | disability_type    | نوع الإعاقة       |
| `incomeSource`      | income_source      | مصدر الدخل        |
| `associationType`   | association_type   | نوع الجمعية       |
| `sponsorshipType`   | sponsorship_type   | نوع الكفالة       |
| `gender`            | gender             | الجنس             |
| `visitType`         | visit_type         | نوع الزيارة       |
| `assistanceType`    | assistance_type    | نوع المساعدة      |
| `beneficiaryStatus` | beneficiary_status | حالة المستفيد     |

## 🔧 الاستخدام

### 🌉 استخدام Bridge Widgets (موصى به - متوافق مع Drift)

```dart
import 'package:benaa_offline_app/features/taxonomies/taxonomies.dart';

// Dropdown للفئات
TaxonomyBridgeDropdown(
  group: TaxonomyGroup.category,
  selectedCode: selectedCategoryCode,
  onCodeChanged: (code) => setState(() => selectedCategoryCode = code),
  isRequired: true,
)

// Dropdown للجنس
TaxonomyBridgeDropdown(
  group: TaxonomyGroup.gender,
  selectedCode: selectedGender,
  onCodeChanged: (code) => setState(() => selectedGender = code),
)

// عرض اسم التصنيف
TaxonomyLabel(
  group: TaxonomyGroup.category,
  code: 'orphan',
)

// Chip
TaxonomyBridgeChip(
  group: TaxonomyGroup.governorate,
  code: 'BGD',
)
```

### جلب التصنيفات (Bridge Providers)

```dart
// جلب حسب المجموعة (Stream من Drift)
final categories = ref.watch(bridgeTaxonomiesByGroupProvider(TaxonomyGroup.category));

// جلب تصنيف بالكود
final taxonomy = ref.watch(
  bridgeTaxonomyByCodeProvider((group: TaxonomyGroup.category, code: 'orphan'))
);
```

### جلب التصنيفات (Clean Architecture - SharedPreferences)

```dart
// جلب حسب المجموعة
final governorates = ref.watch(taxonomiesByGroupProvider(TaxonomyGroup.governorate));

// جلب كل التصنيفات
final allTaxonomies = ref.watch(allTaxonomiesProvider);
```

### المزامنة

```dart
// بدء المزامنة
await ref.read(taxonomySyncNotifierProvider.notifier).sync();

// التحقق من حالة المزامنة
final isSyncing = ref.watch(taxonomySyncNotifierProvider);
final lastResult = ref.watch(lastSyncResultProvider);
```

### Widgets جاهزة

```dart
// Dropdown
TaxonomyDropdown(
  group: TaxonomyGroup.governorate,
  selectedId: selectedGovernorateId,
  onChanged: (id) => setState(() => selectedGovernorateId = id),
)

// Chip
TaxonomyChip(
  taxonomyId: 'gov_BGD',
  group: TaxonomyGroup.governorate,
)

// ListTile
TaxonomyListTile(
  taxonomy: taxonomy,
  onTap: () => navigateToDetails(taxonomy),
)
```

## 🔄 API Endpoints

| Method   | Endpoint              | الوصف             |
| -------- | --------------------- | ----------------- |
| `GET`    | `/taxonomies`         | جميع التصنيفات    |
| `GET`    | `/taxonomies/groups`  | المجموعات المتاحة |
| `GET`    | `/taxonomies/{group}` | حسب مجموعة        |
| `POST`   | `/taxonomies/sync`    | مزامنة تلقائية    |
| `POST`   | `/taxonomies`         | إنشاء جديد        |
| `PUT`    | `/taxonomies/{id}`    | تحديث             |
| `DELETE` | `/taxonomies/{id}`    | حذف               |

## ✅ الاختبارات

- **52 اختبار** تم اجتيازها
- اختبارات Entity
- اختبارات TaxonomyGroup
- اختبارات DTOs

## � الربط بالتطبيق

### صفحة الإدارة

- **Route**: `/taxonomies`
- **الوصول**: الإعدادات → البيانات → إدارة التصنيفات

### في فورم المستفيد (للاستخدام المستقبلي)

```dart
// بدلاً من الـ dropdown القديم:
V2DropdownField<String>(
  value: widget.selectedCategory,
  items: const [
    DropdownMenuItem(value: 'orphan', child: Text('يتيم')),
    // ...
  ],
)

// استخدم:
TaxonomyBridgeDropdown(
  group: TaxonomyGroup.category,
  selectedCode: widget.selectedCategory,
  onCodeChanged: widget.onCategoryChanged,
  isRequired: true,
)
```

## �📁 ملفات التوافق

للترحيل التدريجي من النظام القديم:

```dart
// بدلاً من:
import '../../core/services/taxonomy_service.dart';

// استخدم:
import 'package:benaa_offline_app/features/taxonomies/taxonomies.dart';
```

أو استخدم طبقة التوافق:

```dart
import '../../core/services/taxonomy_compatibility.dart';
```

## 🗑️ ملفات للحذف لاحقاً

بعد الترحيل الكامل، يمكن حذف:

- `lib/core/services/taxonomy_service.dart`
- `lib/data/models/taxonomy.dart` + `.g.dart`
- `lib/data/models/taxonomy_dto.dart` + `.g.dart`
