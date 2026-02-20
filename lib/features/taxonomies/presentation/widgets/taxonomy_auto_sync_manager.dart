import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/core/error_handling/result.dart';

import '../providers/taxonomy_providers.dart';

class TaxonomyAutoSyncManager extends ConsumerStatefulWidget {
  final Widget child;
  final Duration syncInterval;
  final Duration freshnessThreshold;
  final bool enabled;

  const TaxonomyAutoSyncManager({
    super.key,
    required this.child,
    required this.syncInterval,
    required this.freshnessThreshold,
    this.enabled = true,
  });

  @override
  ConsumerState<TaxonomyAutoSyncManager> createState() => _TaxonomyAutoSyncManagerState();
}

class _TaxonomyAutoSyncManagerState extends ConsumerState<TaxonomyAutoSyncManager> with WidgetsBindingObserver {
  static const Duration _startupDelay = Duration(seconds: 12);
  static const Duration _minAttemptGap = Duration(minutes: 2);
  static const Duration _maxBackoff = Duration(minutes: 30);

  final Random _random = Random();

  Timer? _timer;
  bool _syncInFlight = false;
  int _failureCount = 0;
  DateTime? _lastAttemptAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _publishState((state) => state.copyWith(enabled: widget.enabled));
    if (!widget.enabled) return;
    _scheduleNext(delay: _startupDelay);
  }

  @override
  void didUpdateWidget(covariant TaxonomyAutoSyncManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _publishState((state) => state.copyWith(enabled: widget.enabled));
      if (!widget.enabled) {
        _timer?.cancel();
        _publishState((state) => state.copyWith(nextAttemptAt: null));
        return;
      }
      _scheduleNext(delay: _withJitter(const Duration(seconds: 5)));
      return;
    }

    if (oldWidget.syncInterval != widget.syncInterval || oldWidget.freshnessThreshold != widget.freshnessThreshold) {
      _scheduleNext();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.enabled && state == AppLifecycleState.resumed) {
      unawaited(_attemptSync(reason: 'resume', force: true));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _attemptSync({
    required String reason,
    bool force = false,
  }) async {
    if (!mounted || _syncInFlight || !widget.enabled) return;

    final now = DateTime.now();
    final lastAttemptAt = _lastAttemptAt;
    if (!force && lastAttemptAt != null && now.difference(lastAttemptAt) < _minAttemptGap) {
      _scheduleNext();
      return;
    }

    _syncInFlight = true;
    _lastAttemptAt = now;
    _publishState((state) => state.copyWith(
          inFlight: true,
          lastAttemptAt: now,
          clearLastSkipReason: true,
        ));

    try {
      if (!force) {
        final lastSyncResult = await ref.read(taxonomyRepositoryProvider).getLastSyncTime();
        if (lastSyncResult is Success<DateTime?>) {
          final lastSyncAt = lastSyncResult.value;
          if (lastSyncAt != null && now.difference(lastSyncAt) < widget.freshnessThreshold) {
            _publishState((state) => state.copyWith(
                  inFlight: false,
                  lastSkipReason: 'fresh_cache',
                ));
            _scheduleNext();
            return;
          }
        }
      }

      final result = await ref.read(syncTaxonomiesUseCaseProvider).call();
      if (!mounted) return;

      if (result.isSuccess) {
        _failureCount = 0;
        _publishState((state) => state.copyWith(
              inFlight: false,
              lastSuccessAt: DateTime.now(),
              consecutiveFailures: 0,
              clearLastError: true,
            ));
        ref.invalidate(allTaxonomiesProvider);
        ref.invalidate(taxonomyStatisticsProvider);
        ref.invalidate(lastSyncTimeProvider);
      } else {
        _failureCount = (_failureCount + 1).clamp(1, 8);
        final failure = result as Failure;
        _publishState((state) => state.copyWith(
              inFlight: false,
              consecutiveFailures: _failureCount,
              lastError: failure.error.message,
            ));
        debugPrint('Taxonomy auto-sync failed ($reason): ${failure.error.message}');
      }
    } catch (e) {
      _failureCount = (_failureCount + 1).clamp(1, 8);
      _publishState((state) => state.copyWith(
            inFlight: false,
            consecutiveFailures: _failureCount,
            lastError: e.toString(),
          ));
      debugPrint('Taxonomy auto-sync exception ($reason): $e');
    } finally {
      _syncInFlight = false;
      if (mounted) {
        _scheduleNext(delay: _failureCount > 0 ? _computeBackoffDelay() : null);
      }
    }
  }

  void _scheduleNext({Duration? delay}) {
    if (!widget.enabled) {
      _timer?.cancel();
      _publishState((state) => state.copyWith(nextAttemptAt: null));
      return;
    }

    _timer?.cancel();
    final nextDelay = delay ?? _withJitter(widget.syncInterval);
    _publishState((state) => state.copyWith(nextAttemptAt: DateTime.now().add(nextDelay)));
    _timer = Timer(nextDelay, () {
      unawaited(_attemptSync(reason: 'periodic'));
    });
  }

  void _publishState(TaxonomyAutoSyncState Function(TaxonomyAutoSyncState) updater) {
    final notifier = ref.read(taxonomyAutoSyncStateProvider.notifier);
    notifier.state = updater(notifier.state);
  }

  Duration _computeBackoffDelay() {
    final powFactor = 1 << (_failureCount - 1);
    final seconds = min(15 * powFactor, _maxBackoff.inSeconds);
    return _withJitter(Duration(seconds: seconds));
  }

  Duration _withJitter(Duration base) {
    final baseMs = base.inMilliseconds;
    final spread = max(500, (baseMs * 0.12).round());
    final jitter = _random.nextInt(spread * 2 + 1) - spread;
    final withJitter = max(1000, baseMs + jitter);
    return Duration(milliseconds: withJitter);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
