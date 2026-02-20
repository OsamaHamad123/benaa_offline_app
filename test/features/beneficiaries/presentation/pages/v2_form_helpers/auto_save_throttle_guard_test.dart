import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/v2_form_helpers/auto_save_throttle_guard.dart';

void main() {
  group('AutoSaveThrottleGuard', () {
    test('blocks attempts while save is in flight', () {
      final guard = AutoSaveThrottleGuard();
      final now = DateTime(2026, 2, 20, 10, 0, 0);

      expect(guard.canAttempt(now), isTrue);
      guard.markStarted();
      expect(guard.canAttempt(now), isFalse);
      guard.markFinished(success: false, signature: 's1', now: now);
      expect(guard.canAttempt(now), isTrue);
    });

    test('enforces minimum interval after successful save', () {
      final guard = AutoSaveThrottleGuard(minInterval: const Duration(seconds: 10));
      final t0 = DateTime(2026, 2, 20, 10, 0, 0);

      guard.markStarted();
      guard.markFinished(success: true, signature: 'sig', now: t0);

      expect(guard.canAttempt(t0.add(const Duration(seconds: 5))), isFalse);
      expect(guard.canAttempt(t0.add(const Duration(seconds: 10))), isTrue);
    });

    test('skips unchanged signature within cooldown window', () {
      final guard = AutoSaveThrottleGuard(unchangedCooldown: const Duration(seconds: 30));
      final t0 = DateTime(2026, 2, 20, 10, 0, 0);

      guard.markStarted();
      guard.markFinished(success: true, signature: 'same', now: t0);

      expect(
        guard.shouldSkipUnchanged(signature: 'same', now: t0.add(const Duration(seconds: 20))),
        isTrue,
      );
      expect(
        guard.shouldSkipUnchanged(signature: 'same', now: t0.add(const Duration(seconds: 31))),
        isFalse,
      );
      expect(
        guard.shouldSkipUnchanged(signature: 'diff', now: t0.add(const Duration(seconds: 20))),
        isFalse,
      );
    });

    test('buildSignature changes when form data changes', () {
      final sig1 = AutoSaveThrottleGuard.buildSignature(
        formData: {'firstName': 'A', 'nationalId': '1'},
        currentTab: 0,
      );
      final sig2 = AutoSaveThrottleGuard.buildSignature(
        formData: {'firstName': 'B', 'nationalId': '1'},
        currentTab: 0,
      );

      expect(sig1, isNot(equals(sig2)));
    });
  });
}
