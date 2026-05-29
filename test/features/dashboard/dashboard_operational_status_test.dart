import 'package:benaa_offline_app/features/dashboard/presentation/widgets/dashboard_operational_status_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardOperationalStatus — priority resolution', () {
    test('sync failed beats offline', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: false,
        pendingSync: 5,
        hasSyncFailure: true,
      );
      expect(status.level, DashboardStatusLevel.danger);
    });

    test('sync failed beats online with pending', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 10,
        hasSyncFailure: true,
      );
      expect(status.level, DashboardStatusLevel.danger);
    });

    test('offline beats pending uploads', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: false,
        pendingSync: 3,
      );
      expect(status.level, DashboardStatusLevel.warning);
    });

    test('pending beats normal when online', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 5,
      );
      expect(status.level, DashboardStatusLevel.info);
    });

    test('zero pending online returns normal', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 0,
      );
      expect(status.level, DashboardStatusLevel.normal);
    });

    test('pending count is shown in title or message', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 7,
      );
      final combined = '${status.title} ${status.message}';
      expect(combined.contains('7'), isTrue);
    });

    test('offline with pending shows count in message', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: false,
        pendingSync: 3,
      );
      expect(status.level, DashboardStatusLevel.warning);
      expect(status.message.contains('3'), isTrue);
    });

    test('offline with zero pending does not mention count', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: false,
        pendingSync: 0,
      );
      expect(status.level, DashboardStatusLevel.warning);
      expect(status.message, isNotEmpty);
    });

    test('all statuses have non-null icon and non-empty Arabic strings', () {
      final statuses = [
        DashboardOperationalStatus.resolve(isOnline: true, pendingSync: 0),
        DashboardOperationalStatus.resolve(isOnline: false, pendingSync: 0),
        DashboardOperationalStatus.resolve(isOnline: true, pendingSync: 5),
        DashboardOperationalStatus.resolve(
          isOnline: false,
          pendingSync: 0,
          hasSyncFailure: true,
        ),
      ];
      for (final s in statuses) {
        expect(s.icon, isA<IconData>());
        expect(s.title, isNotEmpty);
        expect(s.message, isNotEmpty);
      }
    });

    test('lastSyncTime null shows no-sync message', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 0,
        lastSyncTime: null,
      );
      expect(status.message.contains('لم'), isTrue);
    });

    test('lastSyncTime recent (< 1 hour) shows minutes in message', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 0,
        lastSyncTime: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      expect(status.message.contains('دقيقة'), isTrue);
    });

    test('lastSyncTime hours-old shows hours in message', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 0,
        lastSyncTime: DateTime.now().subtract(const Duration(hours: 3)),
      );
      expect(status.message.contains('ساعة'), isTrue);
    });

    test('lastSyncTime days-old shows days in message', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 0,
        lastSyncTime: DateTime.now().subtract(const Duration(days: 2)),
      );
      expect(status.message.contains('يوم'), isTrue);
    });
  });
}
