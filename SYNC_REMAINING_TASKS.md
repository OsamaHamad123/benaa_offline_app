# 🚀 المهام المتبقية لإنهاء المزامنة

## ✅ تم إنجازه (90%):
- ✅ Clean Architecture الكامل
- ✅ Domain Layer (Entities, Repository, Use Cases)
- ✅ Data Layer (DAOs, DataSources, Repository Implementation)
- ✅ Presentation Layer (20+ Riverpod Providers)
- ✅ جميع الأخطاء مصلحة (0 compilation errors)
- ✅ TaxonomyDTO + json_serializable
- ✅ Main app integration

---

## 🔥 المتبقي (10%):

### Task 1: إضافة Taxonomy Endpoints في ApiClient ⏱️ 10 دقائق
**الملف:** `lib/core/network/api_client.dart`

**أضف هذه الـ methods:**

```dart
  /// Get taxonomies from server (Delta Sync Support)
  Future<Map<String, dynamic>> getTaxonomies({
    String? group,
    DateTime? since,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (group != null) params['group'] = group;
      if (since != null) params['since'] = since.toIso8601String();
      
      final response = await _dio.get(
        '/api/v1/taxonomies',
        queryParameters: params.isEmpty ? null : params,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get beneficiary changes for sync
  Future<Map<String, dynamic>> getBeneficiaryChanges({
    DateTime? since,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/beneficiaries/changes',
        queryParameters: {
          if (since != null) 'since': since.toIso8601String(),
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Push beneficiary changes to server
  Future<Map<String, dynamic>> syncBeneficiaries(
    List<Map<String, dynamic>> changes,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/beneficiaries/sync',
        data: {'changes': changes},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get visit changes for sync
  Future<Map<String, dynamic>> getVisitChanges({
    DateTime? since,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/visits/changes',
        queryParameters: {
          if (since != null) 'since': since.toIso8601String(),
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Push visit changes to server
  Future<Map<String, dynamic>> syncVisits(
    List<Map<String, dynamic>> changes,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/visits/sync',
        data: {'changes': changes},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
```

**المكان:** أضفهم قبل method `_handleDioError` (حوالي سطر 300)

---

### Task 2: اختبار First-Time Sync ⏱️ 5 دقائق

**بعد ما الباك إند يجهز endpoint واحد**، اختبر المزامنة:

**الملف:** أنشئ `lib/test_sync_page.dart` (مؤقت للاختبار)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/sync/presentation/providers/sync_providers.dart';

class TestSyncPage extends ConsumerWidget {
  const TestSyncPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Test Sync')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sync Status
            Text(
              'Status: ${syncState.status}',
              style: const TextStyle(fontSize: 20),
            ),
            
            if (syncState.message != null)
              Text(syncState.message!),
            
            if (syncState.itemsSynced != null)
              Text('Synced: ${syncState.itemsSynced} items'),
            
            if (syncState.error != null)
              Text('Error: ${syncState.error}', style: TextStyle(color: Colors.red)),
            
            const SizedBox(height: 40),
            
            // Test Buttons
            ElevatedButton(
              onPressed: () async {
                final controller = ref.read(syncControllerProvider.notifier);
                await controller.deltaSync('taxonomies');
              },
              child: const Text('Test Taxonomies Sync'),
            ),
            
            ElevatedButton(
              onPressed: () async {
                final controller = ref.read(syncControllerProvider.notifier);
                await controller.fullSyncAll();
              },
              child: const Text('Full Sync All'),
            ),
            
            // Check Database
            ElevatedButton(
              onPressed: () async {
                final stats = await ref.read(taxonomyStatisticsProvider.future);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Taxonomy Statistics'),
                    content: Text(stats.toString()),
                  ),
                );
              },
              child: const Text('Check Database'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**للوصول للصفحة:** أضف في `main.dart` أو أي مكان:
```dart
Navigator.push(context, MaterialPageRoute(builder: (_) => TestSyncPage()));
```

---

### Task 3: استبدال Hardcoded Dropdowns ⏱️ 2-3 ساعات

#### 3.1 تحديد Dropdowns الموجودة

**ابحث في الكود:**
```bash
grep -r "DropdownButtonFormField" lib/features/beneficiaries/
grep -r "categories.*orphan" lib/
```

**القوائم المطلوب استبدالها (10 groups):**
1. ✅ `category` - يتيم، أرملة، فقير، معاق
2. ✅ `marital_status` - أعزب، متزوج، مطلق، أرمل
3. ✅ `education_level` - أمي، ابتدائي، ثانوي، جامعي
4. ✅ `health_status` - سليم، مريض، معاق
5. ✅ `gender` - ذكر، أنثى
6. ✅ `governorate` - دمشق، حلب، حمص، إلخ
7. ✅ `displacement_status` - نازح، مقيم
8. ✅ `employment_status` - عامل، عاطل، متقاعد
9. ✅ `housing_status` - ملك، إيجار، مؤقت
10. ✅ `housing_type` - بيت، شقة، خيمة

#### 3.2 مثال على التعديل

**الملف:** `lib/features/beneficiaries/presentation/pages/add_beneficiary_page.dart`

**قبل (❌ Hardcoded):**
```dart
DropdownButtonFormField<String>(
  items: const [
    DropdownMenuItem(value: 'orphan', child: Text('يتيم')),
    DropdownMenuItem(value: 'widow', child: Text('أرملة')),
    DropdownMenuItem(value: 'poor', child: Text('فقير')),
    DropdownMenuItem(value: 'disabled', child: Text('معاق')),
  ],
  decoration: const InputDecoration(labelText: 'الفئة'),
)
```

**بعد (✅ من السيرفر):**
```dart
Consumer(
  builder: (context, ref, _) {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return categoriesAsync.when(
      data: (taxonomies) {
        // Filter active only
        final activeCategories = taxonomies.where((t) => t.isActive).toList();
        
        return DropdownButtonFormField<String>(
          items: activeCategories.map((taxonomy) {
            return DropdownMenuItem(
              value: taxonomy.code,
              child: Text(taxonomy.label),
            );
          }).toList(),
          decoration: const InputDecoration(labelText: 'الفئة'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى اختيار الفئة';
            }
            return null;
          },
        );
      },
      loading: () => const DropdownButtonFormField<String>(
        items: [],
        decoration: InputDecoration(
          labelText: 'الفئة',
          suffixIcon: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, _) => DropdownButtonFormField<String>(
        items: const [],
        decoration: InputDecoration(
          labelText: 'الفئة',
          errorText: 'خطأ في تحميل الفئات',
        ),
      ),
    );
  },
)
```

#### 3.3 ملفات مطلوب تعديلها

**قائمة الملفات:**
1. ✅ `lib/features/beneficiaries/utils/field_configs.dart`
   - احذف أو عدّل DropdownConfig الثابتة
   
2. ✅ `lib/features/beneficiaries/constants/beneficiary_constants.dart`
   - احذف القوائم الثابتة (CATEGORIES, MARITAL_STATUSES, إلخ)
   
3. ✅ `lib/features/beneficiaries/presentation/pages/add_beneficiary_page.dart`
   - استبدل كل dropdown بـ Consumer + provider
   
4. ✅ `lib/features/beneficiaries/presentation/pages/edit_beneficiary_page.dart`
   - نفس التعديلات
   
5. ✅ `lib/features/beneficiaries/presentation/pages/beneficiaries_list_page.dart`
   - إذا فيه filters، استبدلهم

---

### Task 4: (Optional) Sync Settings Page ⏱️ 1-2 ساعات

**الملف:** `lib/features/settings/presentation/pages/sync_settings_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/sync/presentation/providers/sync_providers.dart';

class SyncSettingsPage extends ConsumerWidget {
  const SyncSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncControllerProvider);
    final taxonomyStats = ref.watch(taxonomyStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات المزامنة'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Last Sync Time
          _buildLastSyncCard(ref),
          
          const SizedBox(height: 16),
          
          // Taxonomy Statistics
          _buildStatisticsCard(taxonomyStats),
          
          const SizedBox(height: 16),
          
          // Manual Sync Button
          _buildSyncButton(context, ref, syncState),
          
          const SizedBox(height: 16),
          
          // Sync Status
          if (syncState.isSyncing)
            const LinearProgressIndicator(),
          
          if (syncState.isSuccess)
            _buildSuccessCard(syncState),
          
          if (syncState.isError)
            _buildErrorCard(syncState),
        ],
      ),
    );
  }

  Widget _buildLastSyncCard(WidgetRef ref) {
    final lastSyncAsync = ref.watch(lastSyncTimeProvider('taxonomies'));
    
    return Card(
      child: ListTile(
        leading: const Icon(Icons.access_time),
        title: const Text('آخر مزامنة'),
        subtitle: lastSyncAsync.when(
          data: (time) => time != null 
              ? Text(DateFormat('yyyy-MM-dd HH:mm').format(time))
              : const Text('لم تتم المزامنة بعد'),
          loading: () => const Text('جارٍ التحميل...'),
          error: (_, __) => const Text('خطأ'),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(AsyncValue<Map<String, int>> statsAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات التصنيفات المحلية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            statsAsync.when(
              data: (stats) {
                if (stats.isEmpty) {
                  return const Text('لا توجد بيانات محلية');
                }
                return Column(
                  children: stats.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_getGroupLabel(entry.key)),
                          Chip(label: Text('${entry.value}')),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('خطأ: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context, WidgetRef ref, SyncState syncState) {
    return ElevatedButton.icon(
      onPressed: syncState.isSyncing
          ? null
          : () async {
              final controller = ref.read(syncControllerProvider.notifier);
              await controller.fullSyncAll();
              
              if (context.mounted && syncState.isSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت المزامنة بنجاح')),
                );
              }
            },
      icon: const Icon(Icons.sync),
      label: Text(syncState.isSyncing ? 'جارٍ المزامنة...' : 'مزامنة الآن'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildSuccessCard(SyncState state) {
    return Card(
      color: Colors.green.shade50,
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: const Text('تمت المزامنة بنجاح'),
        subtitle: Text('${state.itemsSynced} عنصر'),
      ),
    );
  }

  Widget _buildErrorCard(SyncState state) {
    return Card(
      color: Colors.red.shade50,
      child: ListTile(
        leading: const Icon(Icons.error, color: Colors.red),
        title: const Text('فشلت المزامنة'),
        subtitle: Text(state.error ?? 'خطأ غير معروف'),
      ),
    );
  }

  String _getGroupLabel(String group) {
    const labels = {
      'category': 'الفئات',
      'marital_status': 'الحالة الاجتماعية',
      'education_level': 'المستوى التعليمي',
      'health_status': 'الحالة الصحية',
      'gender': 'الجنس',
      'governorate': 'المحافظات',
      'displacement_status': 'حالة النزوح',
      'employment_status': 'حالة العمل',
      'housing_status': 'حالة السكن',
      'housing_type': 'نوع السكن',
    };
    return labels[group] ?? group;
  }
}
```

---

## 📊 جدول الأولويات:

| المهمة | الوقت | الأولوية | الحالة |
|-------|------|---------|--------|
| 1. تحديث ApiClient | 10 دقائق | 🔥 عالية | ⏳ جاهز للتنفيذ |
| 2. اختبار Sync | 5 دقائق | 🔥 عالية | ⏸️ ينتظر الباك إند |
| 3. استبدال Dropdowns | 2-3 ساعات | 🔥 عالية | ⏸️ ينتظر اختبار |
| 4. Sync Settings Page | 1-2 ساعات | 🟡 متوسطة | ⏸️ اختياري |

---

## 🎯 ابدأ الآن:

### الخطوة 1 (اليوم): تحديث ApiClient ✅
افتح `lib/core/network/api_client.dart` وأضف الـ 5 methods أعلاه.

### الخطوة 2 (غداً): تنسيق مع الباك إند 📞
اطلب منهم تجهيز endpoint واحد فقط:
```
GET /api/v1/taxonomies?group=category
```

Response مثال:
```json
{
  "data": [
    {
      "id": "cat_orphan",
      "group": "category",
      "code": "orphan",
      "label": "يتيم",
      "parent_id": null,
      "sort_order": 1,
      "is_active": true,
      "updated_at": "2025-11-18T10:00:00Z"
    }
  ],
  "sync_timestamp": "2025-11-18T12:00:00Z"
}
```

### الخطوة 3: اختبر المزامنة 🧪
استخدم `TestSyncPage` للاختبار.

### الخطوة 4: استبدل Dropdowns تدريجياً 🔄
dropdown واحد كل يوم.

---

## ✅ Success Criteria:

عشان تعرف إن المزامنة شغالة 100%:

1. ✅ التصنيفات تتحمل من السيرفر تلقائياً
2. ✅ كل الـ Dropdowns تعرض بيانات من Database (لا hardcoded)
3. ✅ Delta sync يجيب التغييرات الجديدة فقط (لا يعيد كل شي)
4. ✅ UI تتحدث تلقائياً عند إضافة/تعديل taxonomy من الباك إند
5. ✅ Sync يشتغل بدون أخطاء (0 errors)

---

**بالتوفيق! 🚀**
