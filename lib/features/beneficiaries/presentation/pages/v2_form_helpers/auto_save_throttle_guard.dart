class AutoSaveThrottleGuard {
  final Duration minInterval;
  final Duration unchangedCooldown;

  DateTime? _lastSavedAt;
  String? _lastSignature;
  bool _inFlight = false;

  AutoSaveThrottleGuard({
    this.minInterval = const Duration(seconds: 12),
    this.unchangedCooldown = const Duration(seconds: 45),
  });

  bool get inFlight => _inFlight;

  bool canAttempt(DateTime now) {
    if (_inFlight) return false;
    final lastSavedAt = _lastSavedAt;
    if (lastSavedAt == null) return true;
    return now.difference(lastSavedAt) >= minInterval;
  }

  bool shouldSkipUnchanged({
    required String signature,
    required DateTime now,
  }) {
    final lastSavedAt = _lastSavedAt;
    if (_lastSignature != signature || lastSavedAt == null) {
      return false;
    }
    return now.difference(lastSavedAt) < unchangedCooldown;
  }

  void markStarted() {
    _inFlight = true;
  }

  void markFinished({
    required bool success,
    required String signature,
    required DateTime now,
  }) {
    _inFlight = false;
    if (!success) return;
    _lastSavedAt = now;
    _lastSignature = signature;
  }

  static String buildSignature({
    required Map<String, dynamic> formData,
    required int currentTab,
  }) {
    final keys = formData.keys.toList()..sort();
    final buffer = StringBuffer()..write('t=$currentTab;');
    for (final key in keys) {
      final value = formData[key];
      buffer
        ..write(key)
        ..write('=')
        ..write(value?.toString() ?? '')
        ..write(';');
    }
    return buffer.toString().hashCode.toString();
  }
}
