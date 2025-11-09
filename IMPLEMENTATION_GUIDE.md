# دليل التنفيذ الكامل - Benaa Offline App

## نظرة عامة

هذا المشروع عبارة عن تطبيق Flutter كامل للعمل الميداني مع قدرات أوفلاين كاملة.

## الملفات المُنشأة

### Core (الأساسيات)

1. **lib/core/config/app_config.dart** - إعدادات التطبيق
2. **lib/core/errors/failure.dart** - معالجة الأخطاء
3. **lib/core/utils/result.dart** - نمط Result للتعامل مع النتائج
4. **lib/core/utils/text_normalizer.dart** - تطبيع النصوص العربية
5. **lib/core/storage/secure_store.dart** - تخزين آمن للمفاتيح
6. **lib/core/security/crypto_box.dart** - تشفير الملفات
7. **lib/core/network/api_client.dart** - عميل API مع Dio
8. **lib/core/sync/sync_queue.dart** - طابور المزامنة

### Data (البيانات)

9. **lib/data/db/drift_database.dart** - قاعدة البيانات الرئيسية
10. **lib/data/models/beneficiary.dart** - نموذج المستفيد
11. **lib/data/models/visit.dart** - نموذج الزيارة
12. **lib/data/models/attachment.dart** - نموذج المرفق
13. **lib/data/models/taxonomy.dart** - نموذج التصنيفات
14. **lib/data/models/auth_tokens.dart** - نموذج التوكنات
15. **lib/data/models/civil_record.dart** - نموذج السجل المدني

### Features (المميزات) - Placeholders

16. **lib/features/auth/login_page.dart** - صفحة تسجيل الدخول
17. **lib/features/beneficiaries/add_beneficiary_page.dart** - إضافة مستفيد
18. **lib/features/beneficiaries/view_beneficiary_page.dart** - عرض مستفيد
19. **lib/features/search/civil_search_page.dart** - البحث
20. **lib/features/attachments/attachments_page.dart** - المرفقات
21. **lib/features/reports/reports_page.dart** - التقارير
22. **lib/features/sync/sync_page.dart** - المزامنة

### App Structure

23. **lib/routing/app_router.dart** - التنقل
24. **lib/theme/app_theme.dart** - المظهر
25. **lib/app.dart** - التطبيق الرئيسي
26. **lib/main.dart** - نقطة الدخول

### Configuration

27. **assets/env.example.json** - مثال ملف البيئة
28. **assets/data/civil_registry/manifest.json** - ملف السجل المدني
29. **README.md** - التوثيق
30. **Makefile** - أوامر التشغيل

## الخطوات التالية للتنفيذ الكامل

### 1. تشغيل Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

هذا سيولد:
- `*.g.dart` للملفات مع `@JsonSerializable`
- `drift_database.g.dart` لـ Drift

### 2. تنفيذ Repositories

يجب إنشاء الملفات التالية في `lib/data/repos/`:

#### auth_repo.dart
```dart
class AuthRepository {
  final ApiClient apiClient;
  
  Future<Result<AuthTokens>> login(String username, String password);
  Future<Result<void>> logout();
  Future<Result<AuthTokens>> refreshToken();
}
```

#### beneficiary_repo.dart
```dart
class BeneficiaryRepository {
  final AppDatabase db;
  
  Future<Result<Beneficiary>> create(Beneficiary beneficiary);
  Future<Result<Beneficiary>> getById(String id);
  Future<Result<List<Beneficiary>>> getAll();
  Future<Result<Beneficiary>> update(Beneficiary beneficiary);
  Future<Result<void>> delete(String id);
  Future<Result<List<Beneficiary>>> search(String query);
}
```

#### visit_repo.dart
```dart
class VisitRepository {
  final AppDatabase db;
  
  Future<Result<Visit>> create(Visit visit);
  Future<Result<List<Visit>>> getByBeneficiary(String beneficiaryId);
}
```

#### attachment_repo.dart
```dart
class AttachmentRepository {
  final AppDatabase db;
  final CryptoBox cryptoBox;
  
  Future<Result<Attachment>> create(File file, String beneficiaryId);
  Future<Result<List<Attachment>>> getByBeneficiary(String beneficiaryId);
  Future<Result<File>> decrypt(Attachment attachment);
}
```

#### taxonomy_repo.dart
```dart
class TaxonomyRepository {
  final AppDatabase db;
  
  Future<Result<List<Taxonomy>>> getByGroup(String group);
  Future<void> sync(List<Taxonomy> taxonomies);
}
```

#### registry_repo.dart
```dart
class RegistryRepository {
  final AppDatabase db;
  
  Future<Result<void>> attachCivilRegistry(String dbPath);
  Future<Result<List<CivilRecord>>> searchByNationalId(String nationalId);
  Future<Result<List<CivilRecord>>> searchByFileNo(String fileNo);
  Future<Result<List<CivilRecord>>> searchByName(String name);
  Future<Result<bool>> verifyManifest();
}
```

### 3. تنفيذ Controllers (Riverpod)

يجب إنشاء:

#### auth_controller.dart
```dart
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<AuthState> build() async {
    // Check if authenticated
  }
  
  Future<void> login(String username, String password);
  Future<void> logout();
}
```

#### beneficiaries_controller.dart
```dart
@riverpod
class BeneficiariesController extends _$BeneficiariesController {
  @override
  Future<List<Beneficiary>> build() async {
    // Load beneficiaries
  }
  
  Future<void> add(Beneficiary beneficiary);
  Future<void> update(Beneficiary beneficiary);
  Future<void> delete(String id);
}
```

#### search_controller.dart
```dart
@riverpod
class SearchController extends _$SearchController {
  @override
  FutureOr<List<CivilRecord>> build(String query) async {
    // Perform search
  }
}
```

### 4. تنفيذ Sync Manager

في `lib/core/sync/sync_manager.dart`:

```dart
class SyncManager {
  final ApiClient apiClient;
  final AppDatabase db;
  final SyncQueueService queueService;
  
  Future<SyncResult> syncAll();
  Future<SyncResult> syncBeneficiaries();
  Future<SyncResult> syncVisits();
  Future<SyncResult> syncAttachments();
  Future<void> pullTaxonomies();
}
```

### 5. تنفيذ Report Services

#### pdf_service.dart
```dart
class PdfService {
  Future<File> generateBeneficiariesReport(List<Beneficiary> data);
  Future<File> generateVisitsReport(List<Visit> data);
  Future<File> generateAttachmentsReport(List<Attachment> data);
}
```

#### excel_service.dart
```dart
class ExcelService {
  Future<File> generateBeneficiariesExcel(List<Beneficiary> data);
  Future<File> generateVisitsExcel(List<Visit> data);
}
```

### 6. تنفيذ UI كاملة

كل صفحة placeholder يجب أن تحتوي على:

- Form للإدخال
- Validation
- Integration مع Controllers
- Loading states
- Error handling
- Success feedback

### 7. تنفيذ Seed Data

في `lib/data/db/seed/seed_data.dart`:

```dart
class SeedData {
  static Future<void> seed(AppDatabase db) async {
    await seedTaxonomies(db);
    await seedBeneficiaries(db, count: 1000);
    await seedVisits(db, count: 3000);
    await seedCivilRegistry(db, count: 50000);
  }
}
```

### 8. الاختبارات

إنشاء اختبارات في `test/`:

- Unit tests للـ Repositories
- Unit tests للـ Controllers
- Integration tests للـ Sync
- Widget tests للصفحات

## نقاط مهمة

### التشفير

- قاعدة البيانات تستخدم SQLCipher مع مفتاح يُحفظ في Secure Storage
- الملفات تُشفر بـ AES-GCM
- كل ملف له IV عشوائي
- SHA-256 للتحقق من السلامة

### المزامنة

- دفعات بحجم 200
- Exponential backoff
- لا توقف الدفعة عند فشل عنصر
- Queue للعمليات الفاشلة

### البحث

- Indexes للرقم الوطني والملف
- FTS5 للأسماء
- تطبيع النص العربي قبل الحفظ

### الأداء

- استخدام Batch operations
- Indexes صحيحة
- Pagination للقوائم الطويلة
- Background Isolates للعمليات الثقيلة

## الملفات الناقصة للتنفيذ الكامل

1. `lib/data/repos/` - جميع الـ Repositories (6 ملفات)
2. `lib/features/*/controllers/` - جميع الـ Controllers
3. `lib/features/reports/pdf_service.dart` - خدمة PDF
4. `lib/features/reports/excel_service.dart` - خدمة Excel
5. `lib/core/sync/sync_manager.dart` - مدير المزامنة الكامل
6. `lib/core/sync/sync_policies.dart` - سياسات المزامنة
7. `lib/data/db/seed/seed_data.dart` - البيانات التجريبية
8. `lib/data/db/schema_migrations.dart` - Migrations للإصدارات القادمة

## حجم المشروع التقديري

- **الملفات الحالية**: ~30 ملف
- **الملفات المتبقية للتنفيذ الكامل**: ~25 ملف
- **إجمالي الملفات**: ~55 ملف
- **تقدير السطور**: 8,000 - 12,000 سطر

## الأولويات

1. ✅ البنية الأساسية (منتهية)
2. 🔄 Code Generation (تحتاج تشغيل)
3. ⏳ Repositories Implementation
4. ⏳ Controllers Implementation
5. ⏳ UI Implementation
6. ⏳ Sync Manager
7. ⏳ Reports Services
8. ⏳ Testing

## الخلاصة

المشروع تم إنشاء بنيته الأساسية بالكامل مع:
- ✅ جميع النماذج
- ✅ قاعدة البيانات
- ✅ التشفير
- ✅ API Client
- ✅ التنقل والمظهر
- ✅ Placeholders للصفحات

الخطوة التالية: تشغيل `dart run build_runner build` ثم تنفيذ الـ Repositories والـ Controllers.
