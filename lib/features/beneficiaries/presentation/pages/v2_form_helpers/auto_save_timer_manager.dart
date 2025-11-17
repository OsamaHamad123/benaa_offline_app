import 'dart:async';
import 'package:flutter/material.dart';

/// ⏰ Auto-Save Timer Manager
///
/// Manages auto-save timer and last saved time display
class AutoSaveTimerManager {
  Timer? _autoSaveTimer;
  DateTime? _lastSavedTime;
  final VoidCallback onAutoSave;
  final Function(DateTime?) onLastSavedTimeChanged;

  AutoSaveTimerManager({
    required this.onAutoSave,
    required this.onLastSavedTimeChanged,
  });

  DateTime? get lastSavedTime => _lastSavedTime;

  /// Start auto-save timer (saves every 30 seconds)
  void startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => onAutoSave(),
    );
  }

  /// Stop auto-save timer
  void stopAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  /// Update last saved time
  void updateLastSavedTime() {
    _lastSavedTime = DateTime.now();
    onLastSavedTimeChanged(_lastSavedTime);
  }

  /// Get time ago text for last saved
  String getTimeAgoText() {
    if (_lastSavedTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(_lastSavedTime!);

    if (difference.inSeconds < 60) {
      return 'حُفظ منذ ${difference.inSeconds} ثانية';
    } else if (difference.inMinutes < 60) {
      return 'حُفظ منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'حُفظ منذ ${difference.inHours} ساعة';
    }
  }

  /// Dispose timer
  void dispose() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }
}
