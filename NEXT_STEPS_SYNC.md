# 🚀 Next Steps - Taxonomy Sync Implementation

## ✅ ما تم إنجازه (Completed)

### 1. Clean Architecture - Complete ✅
- **Domain Layer**: Entities, Repository Interfaces, Use Cases (6 files)
- **Data Layer**: DAOs, DataSources, Repository Implementation (5 files)
- **Presentation Layer**: Riverpod Providers (1 file with 20+ providers)
- **DTOs**: TaxonomyDTO with json_serializable

### 2. Infrastructure Setup ✅
- `main.dart` updated with sync providers overrides
- Database: `TaxonomiesDao` + `SyncMetadataDao` ready
- Providers: All 10 taxonomy groups available as reactive streams

---

## 🔜 الخطوات التالية (Next Steps)

### Phase 1: API Integration (الأولوية!)
يحتاج الباك إند يجهز هذي الـ endpoints:

```dart
// في ApiClient - أضف هذي الـ methods:

// 1. جلب التصنيفات
Future<Map<String, dynamic>> getTaxonomies({
  String? group,
  DateTime? since,
}) async {
  final params = <String, dynamic>{};
  if (group != null) params['group'] = group;
  if (since != null) params['since'] = since.toIso8601String();
  
  final response = await dio.get('/api/v1/taxonomies', queryParameters: params);
  return response.data;
}

// 2. جلب تغييرات المستفيدين
Future<Map<String, dynamic>> getBeneficiaryChanges({
  DateTime? since,
  int limit = 100,
}) async {
  final response = await dio.get('/api/v1/beneficiaries/changes', queryParameters: {
    'since': since?.toIso8601String(),
    'limit': limit,
  });
  return response.data;
}

// 3. رفع تغييرات المستفيدين
Future<Map<String, dynamic>> syncBeneficiaries(List<Map<String, dynamic>> changes) async {
  final response = await dio.post('/api/v1/beneficiaries/sync', data: {'changes': changes});
  return response.data;
}
```

**مواصفات الـ Endpoints للباك إند:**

```
📥 GET /api/v1/taxonomies
Query: ?group=category&since=2025-11-18T10:00:00Z
Response: {
  "data": [
    {
      "id": "cat_orphan",
      "group": "category",
      "code": "orphan",
      "label": "يتيم",
      "parent_id": null,
      "sort_order": 1,
      "is_active": true,
      "updated_at": "2025-11-18T12:00:00Z"
    }
  ],
  "sync_timestamp": "2025-11-18T12:00:00Z",
  "total_count": 1
}
```

---

### Phase 2: First-Time Sync (أول مرة تشغيل)

**الملف:** `lib/core/sync/presentation/pages/first_time_sync_page.dart`

```dart
class FirstTimeSyncPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<FirstTimeSyncPage> createState() => _FirstTimeSyncPageState();
}

class _FirstTimeSyncPageState extends ConsumerState<FirstTimeSyncPage> {
  @override
  void initState() {
    super.initState();
    _performFirstSync();
  }

  Future<void> _performFirstSync() async {
    // 1. Sync Taxonomies FIRST (الأولوية!)
    final fullSyncUseCase = ref.read(fullSyncUseCaseProvider);
    
    await fullSyncUseCase.executeAll(entityTypes: [
      'taxonomies',      // الأهم - لازم ينجح
      'beneficiaries',
      'visits',
    ]);
    
    // 2. Navigate to home
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncControllerProvider);
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(syncState.message ?? 'جارٍ المزامنة...'),
          ],
        ),
      ),
    );
  }
}
```

**في `main.dart` - التحقق من أول مرة:**

```dart
// Add this check
final prefs = await SharedPreferences.getInstance();
final isFirstLaunch = prefs.getBool('first_launch') ?? true;

if (isFirstLaunch) {
  // Show FirstTimeSyncPage
  // After sync success: prefs.setBool('first_launch', false);
}
```

---

### Phase 3: Refactor Dropdowns (استبدال الـ Hardcoded)

**قبل (❌ Hardcoded):**
```dart
// في field_configs.dart
static const category = DropdownConfig<String>(
  items: [
    DropdownMenuItem(value: 'orphan', child: Text('يتيم')),
    DropdownMenuItem(value: 'widow', child: Text('أرملة')),
    // ... hardcoded
  ],
);
```

**بعد (✅ من السيرفر):**
```dart
// في add_beneficiary_page.dart
final categories = ref.watch(categoriesProvider);

categories.when(
  data: (taxonomies) => DropdownButtonFormField<String>(
    items: taxonomies.map((t) => DropdownMenuItem(
      value: t.code,
      child: Text(t.label),
    )).toList(),
    // ...
  ),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('خطأ: $e'),
);
```

**الملفات المطلوب تعديلها:**
1. ✅ `lib/features/beneficiaries/utils/field_configs.dart` - احذف hardcoded dropdowns
2. ✅ `lib/features/beneficiaries/constants/beneficiary_constants.dart` - احذف hardcoded lists
3. ✅ `lib/features/beneficiaries/presentation/pages/add_beneficiary_page.dart` - استخدم providers

---

### Phase 4: Sync Settings Page (صفحة إعدادات المزامنة)

**الملف:** `lib/features/settings/presentation/pages/sync_settings_page.dart`

```dart
class SyncSettingsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncControllerProvider);
    final lastSyncTime = ref.watch(lastSyncTimeProvider('taxonomies'));
    
    return Scaffold(
      appBar: AppBar(title: Text('إعدادات المزامنة')),
      body: ListView(
        children: [
          // Last Sync Time
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text('آخر مزامنة'),
            subtitle: lastSyncTime.when(
              data: (time) => time != null 
                  ? Text(DateFormat('yyyy-MM-dd HH:mm').format(time))
                  : Text('لم تتم المزامنة بعد'),
              loading: () => Text('...'),
              error: (_, __) => Text('خطأ'),
            ),
          ),
          
          // Manual Sync Button
          ListTile(
            leading: Icon(Icons.sync),
            title: Text('مزامنة يدوية'),
            trailing: syncState.isSyncing
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      ref.read(syncControllerProvider.notifier).fullSyncAll();
                    },
                    child: Text('مزامنة الآن'),
                  ),
          ),
          
          // Sync Status
          if (syncState.isSuccess)
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('تمت المزامنة بنجاح'),
              subtitle: Text('${syncState.itemsSynced} عنصر'),
            ),
          
          if (syncState.isError)
            ListTile(
              leading: Icon(Icons.error, color: Colors.red),
              title: Text('فشلت المزامنة'),
              subtitle: Text(syncState.error ?? ''),
            ),
        ],
      ),
    );
  }
}
```

---

### Phase 5: Testing (الاختبارات)

**1. Unit Tests للـ Use Cases:**

```dart
// test/core/sync/domain/usecases/delta_sync_usecase_test.dart
void main() {
  late DeltaSyncUseCase useCase;
  late MockSyncRepository mockRepo;
  
  setUp(() {
    mockRepo = MockSyncRepository();
    useCase = DeltaSyncUseCase(mockRepo);
  });
  
  test('should sync taxonomies successfully', () async {
    // Arrange
    when(mockRepo.getLastSyncTime('taxonomies'))
        .thenAnswer((_) async => null);
    when(mockRepo.deltaSync('taxonomies', lastSyncTime: null))
        .thenAnswer((_) async => SyncSuccess(...));
    
    // Act
    final result = await useCase.execute('taxonomies');
    
    // Assert
    expect(result, isA<SyncSuccess>());
  });
}
```

**2. Integration Tests للـ Sync Flow:**

```dart
// integration_test/sync_flow_test.dart
void main() {
  testWidgets('Full sync flow', (tester) async {
    await tester.pumpWidget(MyApp());
    
    // Trigger sync
    await tester.tap(find.byIcon(Icons.sync));
    await tester.pumpAndSettle();
    
    // Verify taxonomies loaded
    final categories = await database.taxonomiesDao.getByGroup('category');
    expect(categories, isNotEmpty);
  });
}
```

---

## 📋 Checklist - الخطوات بالترتيب

### Week 1: API + First Sync
- [ ] **Day 1-2**: الباك إند يجهز endpoints (taxonomies, beneficiaries)
- [ ] **Day 3**: تحديث `ApiClient` بالـ methods الجديدة
- [ ] **Day 4**: بناء `FirstTimeSyncPage`
- [ ] **Day 5**: اختبار first-time sync مع الباك إند

### Week 2: Dropdowns Refactoring
- [ ] **Day 1**: حذف hardcoded values من `field_configs.dart`
- [ ] **Day 2**: تحديث `add_beneficiary_page.dart` لاستخدام providers
- [ ] **Day 3**: تحديث باقي الصفحات (edit, filter, etc.)
- [ ] **Day 4**: اختبار كل الـ dropdowns
- [ ] **Day 5**: Fix any UI issues

### Week 3: Settings + Polish
- [ ] **Day 1-2**: بناء `SyncSettingsPage`
- [ ] **Day 3**: Background sync scheduler (optional)
- [ ] **Day 4**: Error handling + retry logic
- [ ] **Day 5**: Testing + Documentation

---

## 🎯 الأولويات الحالية

### 🔥 High Priority (هذا الأسبوع):
1. ✅ **الباك إند** - جهز endpoint واحد على الأقل (`/api/v1/taxonomies`)
2. ✅ **تحديث ApiClient** - أضف `getTaxonomies()` method
3. ✅ **First Sync** - اعمل basic first-time sync للـ taxonomies

### 🟡 Medium Priority (الأسبوع القادم):
4. Refactor dropdowns (واحد واحد)
5. Sync Settings Page
6. Testing

### 🟢 Low Priority (لاحقاً):
7. Background sync
8. Conflict resolution UI
9. Advanced features

---

## 💡 نصائح مهمة

### 1. **ابدأ بـ Taxonomies فقط**
لا تحاول تعمل sync لكل شيء مرة واحدة. ابدأ بالتصنيفات:
```dart
// First iteration - Taxonomies only
final result = await fullSyncUseCase.execute('taxonomies');
```

### 2. **اختبر مع بيانات قليلة**
الباك إند يبدأ ب 10-20 taxonomy فقط للاختبار.

### 3. **Error Handling في كل مكان**
```dart
try {
  final result = await syncUseCase.execute('taxonomies');
  if (result is SyncFailure) {
    showErrorDialog(result.error);
  }
} catch (e) {
  showErrorDialog('خطأ غير متوقع: $e');
}
```

### 4. **استخدم Logs**
```dart
debugPrint('🔄 Starting sync for: $entityType');
debugPrint('✅ Sync success: ${result.itemsSynced} items');
```

---

## 🚨 Common Issues & Solutions

### Issue 1: "No internet connection"
**Solution:** تحقق من `ConnectivityPlus` قبل المزامنة:
```dart
final connectivity = await Connectivity().checkConnectivity();
if (connectivity == ConnectivityResult.none) {
  return SyncFailure(error: 'لا يوجد اتصال بالإنترنت');
}
```

### Issue 2: "Taxonomies not showing in dropdown"
**Solution:** تأكد من:
1. Sync نجحت: `ref.read(lastSyncTimeProvider('taxonomies'))`
2. Database فيها بيانات: `db.taxonomiesDao.getByGroup('category')`
3. Provider مربوط صح: `ref.watch(categoriesProvider)`

### Issue 3: "Build runner errors"
**Solution:**
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

## 📚 Resources

- **TAXONOMY_SYNC_IMPLEMENTATION.md** - التوثيق الكامل
- **SYNC_IMPLEMENTATION_GUIDE.md** - دليل المزامنة التفصيلي
- **SYNC_QUICK_START.md** - البداية السريعة

---

## ✅ Success Criteria

المشروع جاهز للإنتاج عندما:

1. ✅ الـ Taxonomies تتحمل من السيرفر تلقائياً
2. ✅ كل الـ Dropdowns تستخدم Taxonomies (لا hardcoded values)
3. ✅ First-time sync يشتغل بدون أخطاء
4. ✅ Manual sync من Settings يشتغل
5. ✅ Delta sync يجيب التغييرات الجديدة فقط
6. ✅ UI تتحدث تلقائياً عند تحديث Taxonomies

---

**الخلاصة:** البنية الأساسية جاهزة 100%! ✅  
الآن نحتاج فقط:
1. الباك إند يجهز endpoint واحد
2. نختبر first-time sync
3. نبدأ نستبدل الـ hardcoded dropdowns واحد واحد

🚀 **Let's do this!**
