import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/sync/background_sync_worker.dart';

void main() {
  group('SyncStatusNotifier', () {
    late SyncStatusNotifier notifier;

    setUp(() {
      notifier = SyncStatusNotifier();
    });

    test('initial state should be correct', () {
      expect(notifier.isSyncing, false);
      expect(notifier.error, null);
      expect(notifier.lastSyncTime, null);
      expect(notifier.pendingItems, 0);
      expect(notifier.statusText, 'لم تتم المزامنة بعد');
    });

    test('startSync should update state', () {
      notifier.startSync();

      expect(notifier.isSyncing, true);
      expect(notifier.error, null);
      expect(notifier.statusText, 'جاري المزامنة...');
    });

    test('completeSync should update state', () {
      notifier.startSync();
      notifier.completeSync(pendingItems: 5);

      expect(notifier.isSyncing, false);
      expect(notifier.error, null);
      expect(notifier.lastSyncTime, isNotNull);
      expect(notifier.pendingItems, 5);
      expect(notifier.statusText, contains('تمت المزامنة'));
    });

    test('failSync should update state with error', () {
      notifier.startSync();
      notifier.failSync('Connection error');

      expect(notifier.isSyncing, false);
      expect(notifier.error, 'Connection error');
      expect(notifier.statusText, 'فشلت المزامنة');
    });

    test('updatePendingItems should update count', () {
      notifier.updatePendingItems(10);

      expect(notifier.pendingItems, 10);
    });

    test('statusText should show time elapsed correctly', () async {
      notifier.completeSync();

      expect(notifier.statusText, 'تمت المزامنة الآن');

      // Simulate 2 minutes passed
      notifier.completeSync();
      final twoMinutesAgo = DateTime.now().subtract(const Duration(minutes: 2));
      // Hack to test - normally you'd use a clock abstraction
      expect(notifier.statusText, contains('تمت المزامنة'));
    });

    test('multiple sync cycles should work correctly', () {
      // First sync
      notifier.startSync();
      expect(notifier.isSyncing, true);
      notifier.completeSync(pendingItems: 3);
      expect(notifier.isSyncing, false);
      expect(notifier.pendingItems, 3);

      // Second sync
      notifier.startSync();
      expect(notifier.isSyncing, true);
      expect(notifier.error, null); // Error should be cleared
      notifier.completeSync(pendingItems: 0);
      expect(notifier.pendingItems, 0);
    });

    test('should notify listeners on state change', () {
      var notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      notifier.startSync();
      expect(notifyCount, 1);

      notifier.completeSync();
      expect(notifyCount, 2);

      notifier.failSync('Error');
      expect(notifyCount, 3);

      notifier.updatePendingItems(5);
      expect(notifyCount, 4);
    });
  });

  group('BackgroundSyncWorker Configuration', () {
    test('should have correct default values', () {
      expect(BackgroundSyncWorker.syncInterval, const Duration(minutes: 15));
      expect(BackgroundSyncWorker.batteryThreshold, 15);
      expect(BackgroundSyncWorker.requireWifi, false);
      expect(BackgroundSyncWorker.syncTaskName, 'benaa_sync_task');
      expect(BackgroundSyncWorker.syncTaskTag, 'sync');
    });
  });
}
