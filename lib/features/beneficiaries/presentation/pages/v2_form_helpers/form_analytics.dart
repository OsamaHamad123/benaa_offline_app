import 'dart:async';

/// 📊 Analytics Tracker for Form Behavior
///
/// Tracks user interactions and form completion metrics
class FormAnalytics {
  final Map<int, DateTime> _tabStartTimes = {};
  final Map<int, Duration> _tabDurations = {};
  final Set<String> _skippedFields = {};
  final List<String> _errorLog = [];
  final DateTime _formStartTime = DateTime.now();

  /// Start tracking a tab
  void startTabTracking(int tabIndex) {
    _tabStartTimes[tabIndex] = DateTime.now();
  }

  /// End tracking a tab
  void endTabTracking(int tabIndex) {
    if (_tabStartTimes.containsKey(tabIndex)) {
      final duration = DateTime.now().difference(_tabStartTimes[tabIndex]!);
      _tabDurations[tabIndex] =
          (_tabDurations[tabIndex] ?? Duration.zero) + duration;
      _tabStartTimes.remove(tabIndex);
    }
  }

  /// Log field skip
  void logFieldSkip(String fieldName) {
    _skippedFields.add(fieldName);
  }

  /// Log validation error
  void logError(String fieldName, String error) {
    _errorLog.add('[$fieldName]: $error');
  }

  /// Get total time spent on form
  Duration getTotalTime() {
    return DateTime.now().difference(_formStartTime);
  }

  /// Get time spent per tab
  Map<int, Duration> getTabDurations() {
    return Map.from(_tabDurations);
  }

  /// Get completion rate (0-100)
  double getCompletionRate(int totalFields, int filledFields) {
    if (totalFields == 0) return 0;
    return (filledFields / totalFields) * 100;
  }

  /// Get analytics summary
  Map<String, dynamic> getSummary({
    required int totalFields,
    required int filledFields,
  }) {
    return {
      'totalTime': getTotalTime().inSeconds,
      'tabDurations': _tabDurations.map(
        (k, v) => MapEntry(k.toString(), v.inSeconds),
      ),
      'skippedFields': _skippedFields.toList(),
      'errorCount': _errorLog.length,
      'errors': _errorLog,
      'completionRate': getCompletionRate(totalFields, filledFields),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Reset analytics
  void reset() {
    _tabStartTimes.clear();
    _tabDurations.clear();
    _skippedFields.clear();
    _errorLog.clear();
  }
}
