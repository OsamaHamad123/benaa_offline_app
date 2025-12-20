import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// 📶 Offline Mode Service
/// خدمة الوضع غير المتصل المحسّن

class OfflineModeService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  final List<OfflineAction> _pendingActions = [];
  List<OfflineAction> get pendingActions => List.unmodifiable(_pendingActions);
  int get pendingActionsCount => _pendingActions.length;

  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// تهيئة خدمة الوضع غير المتصل
  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  /// تحديث حالة الاتصال
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );

    if (_isOnline != hasConnection) {
      _isOnline = hasConnection;
      notifyListeners();

      if (_isOnline) {
        // Connected to internet - sync pending actions
        _syncPendingActions();
      }
    }
  }

  /// إضافة إجراء معلق
  void addPendingAction(OfflineAction action) {
    _pendingActions.add(action);
    notifyListeners();
  }

  /// إزالة إجراء معلق
  void removePendingAction(String actionId) {
    _pendingActions.removeWhere((action) => action.id == actionId);
    notifyListeners();
  }

  /// مزامنة الإجراءات المعلقة
  Future<SyncResult> _syncPendingActions() async {
    if (_pendingActions.isEmpty) {
      return SyncResult(
        success: true,
        syncedCount: 0,
        failedCount: 0,
      );
    }

    int syncedCount = 0;
    int failedCount = 0;
    final failedActions = <OfflineAction>[];

    for (var action in List.from(_pendingActions)) {
      try {
        // Execute the action
        await action.execute();

        // Remove from pending if successful
        removePendingAction(action.id);
        syncedCount++;
      } catch (e) {
        failedCount++;
        failedActions.add(action);
      }
    }

    _lastSyncTime = DateTime.now();
    notifyListeners();

    return SyncResult(
      success: failedCount == 0,
      syncedCount: syncedCount,
      failedCount: failedCount,
      failedActions: failedActions,
    );
  }

  /// مزامنة يدوية
  Future<SyncResult> syncNow() async {
    if (!_isOnline) {
      return SyncResult(
        success: false,
        syncedCount: 0,
        failedCount: 0,
        error: 'لا يوجد اتصال بالإنترنت',
      );
    }

    return await _syncPendingActions();
  }

  /// مسح جميع الإجراءات المعلقة
  void clearPendingActions() {
    _pendingActions.clear();
    notifyListeners();
  }

  /// التخلص من الموارد
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// إجراء معلق
class OfflineAction {
  final String id;
  final String type;
  final String description;
  final Map<String, dynamic> data;
  final Future<void> Function() execute;
  final DateTime createdAt;

  OfflineAction({
    required this.id,
    required this.type,
    required this.description,
    required this.data,
    required this.execute,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// نتيجة المزامنة
class SyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final List<OfflineAction>? failedActions;
  final String? error;

  SyncResult({
    required this.success,
    required this.syncedCount,
    required this.failedCount,
    this.failedActions,
    this.error,
  });
}

/// 📶 Offline Mode Manager
/// إدارة الوضع غير المتصل للعمليات

class OfflineModeManager {
  final OfflineModeService _service;

  OfflineModeManager(this._service);

  /// تنفيذ عملية مع دعم الوضع غير المتصل
  Future<T> executeWithOfflineSupport<T>({
    required Future<T> Function() onlineAction,
    required Future<T> Function() offlineAction,
    required String actionId,
    required String actionType,
    required String description,
    required Map<String, dynamic> data,
  }) async {
    if (_service.isOnline) {
      try {
        return await onlineAction();
      } catch (e) {
        // If online action fails, queue for later
        _service.addPendingAction(
          OfflineAction(
            id: actionId,
            type: actionType,
            description: description,
            data: data,
            execute: () async {
              await onlineAction();
            },
          ),
        );

        // Execute offline fallback
        return await offlineAction();
      }
    } else {
      // Queue action for when online
      _service.addPendingAction(
        OfflineAction(
          id: actionId,
          type: actionType,
          description: description,
          data: data,
          execute: () async {
            await onlineAction();
          },
        ),
      );

      // Execute offline action
      return await offlineAction();
    }
  }

  /// حفظ بيانات محلياً في الوضع غير المتصل
  Future<void> saveLocallyIfOffline<T>({
    required T data,
    required Future<void> Function(T data) saveLocal,
    required Future<void> Function(T data) saveOnline,
    required String actionId,
    String? description,
  }) async {
    // Always save locally first
    await saveLocal(data);

    if (_service.isOnline) {
      try {
        await saveOnline(data);
      } catch (e) {
        // Queue for sync later
        _service.addPendingAction(
          OfflineAction(
            id: actionId,
            type: 'save',
            description: description ?? 'حفظ بيانات',
            data: {'data': data},
            execute: () => saveOnline(data),
          ),
        );
      }
    } else {
      // Queue for sync when online
      _service.addPendingAction(
        OfflineAction(
          id: actionId,
          type: 'save',
          description: description ?? 'حفظ بيانات',
          data: {'data': data},
          execute: () => saveOnline(data),
        ),
      );
    }
  }
}

/// 🔄 Conflict Resolution Strategy
/// استراتيجية حل التعارضات

enum ConflictResolutionStrategy {
  /// الاحتفاظ بالنسخة المحلية
  keepLocal,

  /// الاحتفاظ بالنسخة من السيرفر
  keepRemote,

  /// دمج التغييرات
  merge,

  /// سؤال المستخدم
  askUser,
}

/// حل التعارضات
class ConflictResolver<T> {
  final ConflictResolutionStrategy strategy;

  ConflictResolver({
    this.strategy = ConflictResolutionStrategy.askUser,
  });

  /// حل التعارض
  Future<T> resolve({
    required T localVersion,
    required T remoteVersion,
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
    Future<T> Function(T local, T remote)? mergeFunction,
    Future<T> Function(T local, T remote)? askUserFunction,
  }) async {
    switch (strategy) {
      case ConflictResolutionStrategy.keepLocal:
        return localVersion;

      case ConflictResolutionStrategy.keepRemote:
        return remoteVersion;

      case ConflictResolutionStrategy.merge:
        if (mergeFunction != null) {
          return await mergeFunction(localVersion, remoteVersion);
        }
        // Fallback to newest
        return localTimestamp.isAfter(remoteTimestamp)
            ? localVersion
            : remoteVersion;

      case ConflictResolutionStrategy.askUser:
        if (askUserFunction != null) {
          return await askUserFunction(localVersion, remoteVersion);
        }
        // Fallback to newest
        return localTimestamp.isAfter(remoteTimestamp)
            ? localVersion
            : remoteVersion;
    }
  }
}
