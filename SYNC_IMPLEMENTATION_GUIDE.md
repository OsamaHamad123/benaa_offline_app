# 🔄 دليل تطبيق المزامنة الكامل (Complete Sync Implementation Guide)

## 📋 الفهرس
1. [معمارية المزامنة](#معمارية-المزامنة)
2. [API Endpoints المطلوبة](#api-endpoints-المطلوبة)
3. [DTOs المطلوبة](#dtos-المطلوبة)
4. [استراتيجيات المزامنة](#استراتيجيات-المزامنة)
5. [حل التعارضات](#حل-التعارضات)
6. [التطبيق الكامل](#التطبيق-الكامل)

---

## 🏗️ معمارية المزامنة

### المكونات الحالية ✅
```
┌─────────────────────────────────────────────────────┐
│                   Mobile App                        │
├─────────────────────────────────────────────────────┤
│  ┌────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │ UI Layer   │→ │ SyncManager │→ │  ApiClient  │ │
│  └────────────┘  └─────────────┘  └─────────────┘ │
│         ↓               ↓                  ↓        │
│  ┌────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │ Drift DB   │  │ SyncQueue   │  │   Network   │ │
│  └────────────┘  └─────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────┘
                        ↕ HTTP/JSON
┌─────────────────────────────────────────────────────┐
│                 Backend Server                      │
├─────────────────────────────────────────────────────┤
│  ┌────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │ REST API   │→ │  Business   │→ │  Database   │ │
│  │ Endpoints  │  │   Logic     │  │   MySQL     │ │
│  └────────────┘  └─────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────┘
```

### أنواع المزامنة المطلوبة

#### 1️⃣ **Full Sync** (المزامنة الكاملة)
- **متى؟** أول مرة أو بعد فترة طويلة
- **البيانات:** كل شيء من السيرفر
- **الوقت:** 5-10 دقائق (حسب حجم البيانات)

```dart
// Example
await syncManager.fullSync(); // Downloads everything
```

#### 2️⃣ **Delta Sync** (التغييرات فقط) ⭐ الأهم
- **متى؟** كل 5 دقائق تلقائياً
- **البيانات:** التغييرات منذ آخر مزامنة فقط
- **الوقت:** 5-30 ثانية

```dart
// Example
await syncManager.deltaSync(
  lastSyncTime: DateTime(2025, 11, 15, 10, 30),
);
```

#### 3️⃣ **Push Sync** (رفع التغييرات المحلية)
- **متى؟** عند الاتصال بالإنترنت
- **البيانات:** التغييرات من الموبايل للسيرفر
- **الوقت:** 2-10 ثواني

```dart
// Example
await syncManager.pushLocalChanges();
```

---

## 🌐 API Endpoints المطلوبة

### ⚠️ **ملاحظة مهمة:**
هذه الـ Endpoints يجب أن يوفرها فريق الباك إند. إذا ما كان موجود، خليهم يطبقوها.

### 1. Authentication
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "username": "user123",
  "password": "password123"
}

Response:
{
  "access_token": "eyJhbGc...",
  "refresh_token": "dGhpc2lz...",
  "expires_in": 3600,
  "user_id": "123",
  "username": "user123"
}
```

```http
POST /api/v1/auth/refresh
Authorization: Bearer {refresh_token}

Response:
{
  "access_token": "eyJhbGc...",
  "refresh_token": "dGhpc2lz...",
  "expires_in": 3600
}
```

### 2. Beneficiaries Sync (المستفيدين)

#### 📥 Pull Changes (جلب التغييرات من السيرفر)
```http
GET /api/v1/beneficiaries/changes?since=2025-11-15T10:30:00Z&limit=100
Authorization: Bearer {access_token}

Response:
{
  "data": [
    {
      "id": 201,
      "file_id_number": "006066",
      "data_id_number": "400008207",
      "data_first_name": "انوار",
      "data_father_name": "سمير",
      // ... all fields from backend_schema.json
      "created_at": "2025-11-09T13:51:47Z",
      "updated_at": "2025-11-10T14:20:15Z",
      "_sync_action": "updated" // or "created", "deleted"
    }
  ],
  "pagination": {
    "total": 1500,
    "page": 1,
    "per_page": 100,
    "has_more": true
  },
  "sync_timestamp": "2025-11-18T12:00:00Z"
}
```

#### 📤 Push Changes (رفع التغييرات للسيرفر)
```http
POST /api/v1/beneficiaries/sync
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "changes": [
    {
      "client_id": "uuid-123",
      "action": "create", // or "update", "delete"
      "data": {
        "file_id_number": "006500",
        "data_id_number": "400999999",
        "data_first_name": "محمد",
        // ... all fields
      },
      "timestamp": "2025-11-18T11:45:00Z"
    }
  ]
}

Response:
{
  "success": [
    {
      "client_id": "uuid-123",
      "server_id": 502,
      "status": "created"
    }
  ],
  "conflicts": [
    {
      "client_id": "uuid-124",
      "reason": "version_conflict",
      "server_version": {
        "id": 503,
        "updated_at": "2025-11-18T11:50:00Z",
        "data": { /* server data */ }
      }
    }
  ],
  "errors": []
}
```

### 3. Visits Sync (الزيارات)
```http
GET /api/v1/visits/changes?since=2025-11-15T10:30:00Z
POST /api/v1/visits/sync
```
نفس البنية للمستفيدين

### 4. Taxonomies (التصنيفات)
```http
GET /api/v1/taxonomies?updated_after=2025-11-15T10:30:00Z

Response:
{
  "data": [
    {
      "id": "1",
      "group": "category",
      "code": "orphan",
      "label": "يتيم",
      "parent_id": null,
      "sort_order": 1,
      "is_active": true,
      "updated_at": "2025-11-01T00:00:00Z"
    }
  ]
}
```

### 5. Attachments (المرفقات)
```http
POST /api/v1/attachments/upload
Content-Type: multipart/form-data

{
  "file": <binary>,
  "beneficiary_id": "uuid-123",
  "visit_id": "uuid-456",
  "type": "photo"
}

Response:
{
  "id": "attachment-789",
  "file_name": "photo_2025.jpg",
  "file_size": 245678,
  "server_url": "https://cdn.example.com/files/photo_2025.jpg",
  "created_at": "2025-11-18T12:00:00Z"
}
```

---

## 📦 DTOs المطلوبة

### 1. Sync Request DTO
```dart
// lib/core/sync/models/sync_request.dart
class SyncRequest {
  final List<SyncChange> changes;
  final DateTime timestamp;

  SyncRequest({
    required this.changes,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'changes': changes.map((c) => c.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class SyncChange {
  final String clientId;
  final String action; // 'create', 'update', 'delete'
  final Map<String, dynamic> data;
  final DateTime timestamp;

  SyncChange({
    required this.clientId,
    required this.action,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'action': action,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
```

### 2. Sync Response DTO
```dart
// lib/core/sync/models/sync_response.dart
class SyncResponse {
  final List<SyncSuccess> success;
  final List<SyncConflict> conflicts;
  final List<SyncError> errors;

  SyncResponse({
    required this.success,
    required this.conflicts,
    required this.errors,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) {
    return SyncResponse(
      success: (json['success'] as List)
          .map((e) => SyncSuccess.fromJson(e))
          .toList(),
      conflicts: (json['conflicts'] as List)
          .map((e) => SyncConflict.fromJson(e))
          .toList(),
      errors: (json['errors'] as List)
          .map((e) => SyncError.fromJson(e))
          .toList(),
    );
  }
}

class SyncSuccess {
  final String clientId;
  final int serverId;
  final String status;

  SyncSuccess({
    required this.clientId,
    required this.serverId,
    required this.status,
  });

  factory SyncSuccess.fromJson(Map<String, dynamic> json) {
    return SyncSuccess(
      clientId: json['client_id'],
      serverId: json['server_id'],
      status: json['status'],
    );
  }
}

class SyncConflict {
  final String clientId;
  final String reason;
  final Map<String, dynamic> serverData;
  final DateTime serverUpdatedAt;

  SyncConflict({
    required this.clientId,
    required this.reason,
    required this.serverData,
    required this.serverUpdatedAt,
  });

  factory SyncConflict.fromJson(Map<String, dynamic> json) {
    return SyncConflict(
      clientId: json['client_id'],
      reason: json['reason'],
      serverData: json['server_version']['data'],
      serverUpdatedAt: DateTime.parse(
        json['server_version']['updated_at'],
      ),
    );
  }
}
```

### 3. Pull Changes DTO
```dart
// lib/core/sync/models/pull_changes_response.dart
class PullChangesResponse<T> {
  final List<ChangeItem<T>> data;
  final PaginationMeta pagination;
  final DateTime syncTimestamp;

  PullChangesResponse({
    required this.data,
    required this.pagination,
    required this.syncTimestamp,
  });

  factory PullChangesResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PullChangesResponse(
      data: (json['data'] as List)
          .map((e) => ChangeItem<T>.fromJson(e, fromJsonT))
          .toList(),
      pagination: PaginationMeta.fromJson(json['pagination']),
      syncTimestamp: DateTime.parse(json['sync_timestamp']),
    );
  }
}

class ChangeItem<T> {
  final T data;
  final String syncAction; // 'created', 'updated', 'deleted'

  ChangeItem({required this.data, required this.syncAction});

  factory ChangeItem.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ChangeItem(
      data: fromJsonT(json),
      syncAction: json['_sync_action'] ?? 'updated',
    );
  }
}
```

---

## 🔄 استراتيجيات المزامنة

### Strategy 1: Last-Write-Wins (الأخير يكسب) ⭐ الأبسط
```dart
// المنطق: آخر تعديل (based on timestamp) هو الصحيح
Future<void> resolveConflict_LastWriteWins(
  SyncConflict conflict,
) async {
  final localItem = await _db.beneficiariesDao.getById(conflict.clientId);
  
  if (localItem.updatedAt.isAfter(conflict.serverUpdatedAt)) {
    // Local is newer → Push to server
    await _apiClient.forcePush(localItem);
  } else {
    // Server is newer → Accept server version
    await _db.beneficiariesDao.update(
      BeneficiaryDataModel.fromJson(conflict.serverData),
    );
  }
}
```

### Strategy 2: Server-Wins (السيرفر دائماً يكسب)
```dart
// المنطق: دائماً نقبل نسخة السيرفر
Future<void> resolveConflict_ServerWins(
  SyncConflict conflict,
) async {
  await _db.beneficiariesDao.update(
    BeneficiaryDataModel.fromJson(conflict.serverData),
  );
}
```

### Strategy 3: Manual Resolution (المستخدم يقرر)
```dart
// المنطق: نعرض الخيارين للمستخدم ليختار
Future<void> resolveConflict_Manual(
  SyncConflict conflict,
) async {
  final choice = await _showConflictDialog(conflict);
  
  if (choice == ConflictChoice.keepLocal) {
    await _apiClient.forcePush(localItem);
  } else {
    await _db.beneficiariesDao.update(serverItem);
  }
}
```

---

## ⚔️ حل التعارضات (Conflict Resolution)

### سيناريوهات التعارضات الشائعة

#### 1. Edit-Edit Conflict
```
User A (Mobile): Updates beneficiary name at 10:30
User B (Web):    Updates same beneficiary phone at 10:35
Sync happens at 10:40 → CONFLICT!

Solution: Field-level merge
{
  "name": "من User A",      // أحدث تعديل للاسم
  "phone": "من User B"       // أحدث تعديل للهاتف
}
```

#### 2. Edit-Delete Conflict
```
User A: Edits beneficiary
User B: Deletes same beneficiary
Sync → CONFLICT!

Solution Options:
- Delete wins (السيرفر محذوف → نحذف محلياً)
- Edit wins (نعيد الإضافة للسيرفر)
- Ask user
```

#### 3. Offline Multi-Edit
```
User edits same record 5 times offline
Then syncs all at once

Solution: Batch changes into single update
```

---

## 💻 التطبيق الكامل

### خطوة 1: تحديث ApiClient

```dart
// lib/core/network/api_client.dart
class ApiClient {
  // ... existing code ...

  /// Pull changes from server (Delta Sync)
  Future<PullChangesResponse<BeneficiaryDataModel>> 
    pullBeneficiaryChanges({
    DateTime? since,
    int limit = 100,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/beneficiaries/changes',
        queryParameters: {
          if (since != null) 'since': since.toIso8601String(),
          'limit': limit,
          'page': page,
        },
      );

      return PullChangesResponse<BeneficiaryDataModel>.fromJson(
        response.data,
        (json) => BeneficiaryDataModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Push local changes to server
  Future<SyncResponse> pushBeneficiaryChanges(
    List<SyncChange> changes,
  ) async {
    try {
      final request = SyncRequest(
        changes: changes,
        timestamp: DateTime.now(),
      );

      final response = await _dio.post(
        '/beneficiaries/sync',
        data: request.toJson(),
      );

      return SyncResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
```

### خطوة 2: تحديث SyncManager

```dart
// lib/core/sync/sync_manager.dart

class SyncManager {
  // ... existing code ...

  /// ============================================
  /// DELTA SYNC - المزامنة الذكية ⭐
  /// ============================================
  Future<void> deltaSyncBeneficiaries() async {
    if (_apiClient == null) {
      throw Exception('API Client not available');
    }

    _updateStatus(_currentStatus.copyWith(
      isSyncing: true,
      currentEntity: 'Beneficiaries',
    ));

    try {
      // 1. Get last sync timestamp
      final lastSync = await _getLastSyncTimestamp('beneficiaries');
      
      // 2. Pull changes from server
      final pullResult = await _pullServerChanges(lastSync);
      
      // 3. Push local changes to server
      final pushResult = await _pushLocalChanges();
      
      // 4. Handle conflicts
      if (pushResult.conflicts.isNotEmpty) {
        await _handleConflicts(pushResult.conflicts);
      }
      
      // 5. Update last sync timestamp
      await _updateLastSyncTimestamp('beneficiaries');
      
      _updateStatus(_currentStatus.copyWith(
        isSyncing: false,
        lastError: null,
      ));
    } catch (e) {
      _updateStatus(_currentStatus.copyWith(
        isSyncing: false,
        lastError: e.toString(),
      ));
      rethrow;
    }
  }

  /// Pull changes from server and apply locally
  Future<void> _pullServerChanges(DateTime? since) async {
    int page = 1;
    bool hasMore = true;

    while (hasMore) {
      final response = await _apiClient!.pullBeneficiaryChanges(
        since: since,
        page: page,
      );

      for (final item in response.data) {
        switch (item.syncAction) {
          case 'created':
          case 'updated':
            await _db.beneficiariesDao.insertOrUpdate(item.data);
            break;
          case 'deleted':
            await _db.beneficiariesDao.delete(item.data.id!);
            break;
        }
      }

      hasMore = response.pagination.hasMore;
      page++;
      
      _updateStatus(_currentStatus.copyWith(
        completedItems: page * 100,
      ));
    }
  }

  /// Push local changes to server
  Future<SyncResponse> _pushLocalChanges() async {
    // Get pending changes from SyncQueue
    final pendingChanges = await _db.syncDao.getPendingSync(
      entity: 'beneficiary',
      limit: 50,
    );

    if (pendingChanges.isEmpty) {
      return SyncResponse(success: [], conflicts: [], errors: []);
    }

    // Convert to SyncChange format
    final syncChanges = pendingChanges.map((item) {
      return SyncChange(
        clientId: item.entityId,
        action: item.operation,
        data: jsonDecode(item.payload),
        timestamp: item.createdAt,
      );
    }).toList();

    // Push to server
    final response = await _apiClient!.pushBeneficiaryChanges(syncChanges);

    // Process successful syncs
    for (final success in response.success) {
      await _db.syncDao.markSynced(success.clientId);
      
      // Update serverId mapping
      await _db.beneficiariesDao.updateServerId(
        success.clientId,
        success.serverId,
      );
    }

    return response;
  }

  /// Handle sync conflicts
  Future<void> _handleConflicts(List<SyncConflict> conflicts) async {
    for (final conflict in conflicts) {
      // Strategy: Last-Write-Wins
      await resolveConflict_LastWriteWins(conflict);
    }
  }

  /// Get last sync timestamp for entity
  Future<DateTime?> _getLastSyncTimestamp(String entity) async {
    final metadata = await _db.customSelect(
      'SELECT last_sync FROM sync_metadata WHERE entity = ?',
      variables: [Variable.withString(entity)],
    ).getSingleOrNull();

    return metadata != null 
      ? DateTime.parse(metadata.data['last_sync'])
      : null;
  }

  /// Update last sync timestamp
  Future<void> _updateLastSyncTimestamp(String entity) async {
    await _db.customUpdate(
      '''
      INSERT INTO sync_metadata (entity, last_sync) 
      VALUES (?, ?)
      ON CONFLICT(entity) DO UPDATE SET last_sync = ?
      ''',
      variables: [
        Variable.withString(entity),
        Variable.withString(DateTime.now().toIso8601String()),
        Variable.withString(DateTime.now().toIso8601String()),
      ],
      updates: {},
    );
  }
}
```

### خطوة 3: إضافة Metadata Table

```dart
// lib/data/db/tables/sync_metadata_table.dart
import 'package:drift/drift.dart';

@DataClassName('SyncMetadata')
class SyncMetadataTable extends Table {
  TextColumn get entity => text()(); // 'beneficiaries', 'visits', etc.
  DateTimeColumn get lastSync => dateTime()();
  IntColumn get totalSynced => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {entity};
}
```

### خطوة 4: UI للمزامنة

```dart
// lib/features/sync/presentation/pages/sync_page.dart
class SyncPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: AppBar(title: Text('المزامنة')),
      body: syncStatus.when(
        data: (status) {
          return Column(
            children: [
              if (status.isSyncing)
                LinearProgressIndicator(value: status.progress),
              
              ListTile(
                title: Text('الحالة'),
                subtitle: Text(
                  status.isSyncing 
                    ? 'جاري المزامنة... ${status.currentEntity}'
                    : 'متزامن',
                ),
              ),

              if (status.lastError != null)
                Card(
                  color: Colors.red[50],
                  child: ListTile(
                    leading: Icon(Icons.error, color: Colors.red),
                    title: Text('خطأ'),
                    subtitle: Text(status.lastError!),
                  ),
                ),

              ElevatedButton(
                onPressed: status.isSyncing 
                  ? null 
                  : () => ref.read(syncManagerProvider).deltaSyncBeneficiaries(),
                child: Text('مزامنة الآن'),
              ),
            ],
          );
        },
        loading: () => CircularProgressIndicator(),
        error: (e, s) => Text('Error: $e'),
      ),
    );
  }
}
```

---

## 🎯 خطوات التنفيذ الموصى بها

### Phase 1: التحضير (يوم 1)
1. ✅ اتفق مع فريق الباك إند على الـ Endpoints
2. ✅ حدد استراتيجية حل التعارضات
3. ✅ أضف `sync_metadata` table

### Phase 2: DTOs (يوم 2)
4. ✅ أنشئ `SyncRequest`, `SyncResponse`
5. ✅ أنشئ `PullChangesResponse`
6. ✅ اختبر JSON serialization

### Phase 3: API Layer (يوم 3)
7. ✅ أضف `pullBeneficiaryChanges()` للـ ApiClient
8. ✅ أضف `pushBeneficiaryChanges()` للـ ApiClient
9. ✅ اختبر مع Mock Server

### Phase 4: Sync Logic (يوم 4-5)
10. ✅ طبّق `deltaSyncBeneficiaries()`
11. ✅ طبّق conflict resolution
12. ✅ اختبر offline → online scenarios

### Phase 5: UI & Testing (يوم 6)
13. ✅ أنشئ sync page
14. ✅ أضف progress indicators
15. ✅ اختبار شامل

---

## 📚 موارد إضافية

### أمثلة على استراتيجيات Sync ناجحة
- **Google Keep**: Last-write-wins + field-level merging
- **Evernote**: Server-wins with version history
- **Notion**: Operational Transform (معقد جداً)

### توصيات
1. ابدأ بـ Last-Write-Wins (الأبسط)
2. أضف logging شامل لكل عملية sync
3. احفظ sync history في جدول منفصل
4. استخدم exponential backoff للـ retries

---

## ❓ الأسئلة الشائعة

### س: إذا ما عندي باك إند؟
**ج:** استخدم Mock API Server:
```dart
// lib/core/network/mock_api_server.dart - already exists!
// طوّر عليه لإضافة sync endpoints
```

### س: كيف أختبر بدون إنترنت؟
**ج:** 
```dart
// في settings
bool enableSync = false; // Disable auto-sync
// ثم اختبر offline mode
```

### س: حجم البيانات كبير جداً؟
**ج:** استخدم pagination + compression:
```dart
await _dio.get('/beneficiaries/changes',
  options: Options(
    headers: {'Accept-Encoding': 'gzip'},
  ),
);
```

---

## ✅ Checklist قبل الإطلاق

- [ ] الـ Endpoints تشتغل مع الباك إند
- [ ] DTOs تتحول بدون أخطاء
- [ ] Conflict resolution مختبر
- [ ] Offline mode يشتغل 100%
- [ ] Auto-sync كل 5 دقائق
- [ ] Progress indicators واضحة
- [ ] Error handling شامل
- [ ] Logging للـ debugging

---

**تم بواسطة:** GitHub Copilot  
**التاريخ:** 18 نوفمبر 2025  
**الإصدار:** 1.0
