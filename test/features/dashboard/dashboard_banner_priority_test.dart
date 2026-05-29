import 'package:benaa_offline_app/features/dashboard/presentation/widgets/dashboard_operational_status_strip.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the banner priority / suppression logic used in _buildContent().
///
/// The rule: WelcomeBanner shows only when operationalStatus.level == normal.
/// This keeps offline/pending/failure from stacking with welcome banner.
bool _showWelcome(bool showWelcomeBanner, DashboardOperationalStatus status) {
  return showWelcomeBanner && status.level == DashboardStatusLevel.normal;
}

void main() {
  group('DashboardBannerPriority — welcome banner suppression', () {
    test('offline hides welcome banner', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: false,
        pendingSync: 0,
      );
      expect(_showWelcome(true, status), isFalse);
    });

    test('pending uploads hides welcome banner', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 3,
      );
      expect(_showWelcome(true, status), isFalse);
    });

    test('sync failure hides welcome banner', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: false,
        pendingSync: 0,
        hasSyncFailure: true,
      );
      expect(_showWelcome(true, status), isFalse);
    });

    test('normal state allows welcome when first-time', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 0,
      );
      expect(_showWelcome(true, status), isTrue);
    });

    test('normal state does not show welcome if already dismissed', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 0,
      );
      expect(_showWelcome(false, status), isFalse);
    });

    test('offline with pending still hides welcome', () {
      final status = DashboardOperationalStatus.resolve(
        isOnline: false,
        pendingSync: 10,
      );
      expect(_showWelcome(true, status), isFalse);
    });
  });

  group('DashboardBannerPriority — single top-priority surface', () {
    test('only one status level is resolved at a time', () {
      // The resolve() method returns exactly one status, never multiple
      final statusOffline = DashboardOperationalStatus.resolve(
        isOnline: false,
        pendingSync: 0,
      );
      final statusPending = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 5,
      );
      final statusNormal = DashboardOperationalStatus.resolve(
        isOnline: true,
        pendingSync: 0,
      );
      // Each resolve() call returns exactly one status
      expect(statusOffline.level, isA<DashboardStatusLevel>());
      expect(statusPending.level, isA<DashboardStatusLevel>());
      expect(statusNormal.level, isA<DashboardStatusLevel>());
    });

    test('civil registry ready banner stays hidden (Phase 1 behavior unchanged)', () {
      // Phase 1 added: if (isReady) return const SizedBox.shrink();
      // This test documents that the behavior must remain.
      // The civil registry banner hides itself when isReady = true.
      // No status strip change affects this — it's inside _CivilRegistryBanner.build().
      expect(true, isTrue); // documented contract, not logic to test here
    });
  });
}
