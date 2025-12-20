import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ⏱️ Session Manager
///
/// إدارة جلسات المستخدم مع انتهاء تلقائي

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static const String _lastActivityKey = 'last_activity_timestamp';
  static const String _sessionTimeoutKey = 'session_timeout_minutes';
  static const int _defaultTimeoutMinutes = 15;

  Timer? _sessionTimer;
  DateTime? _lastActivity;
  VoidCallback? _onSessionExpired;

  int _timeoutMinutes = _defaultTimeoutMinutes;

  /// تهيئة Session Manager
  Future<void> initialize({VoidCallback? onSessionExpired}) async {
    _onSessionExpired = onSessionExpired;

    final prefs = await SharedPreferences.getInstance();
    _timeoutMinutes =
        prefs.getInt(_sessionTimeoutKey) ?? _defaultTimeoutMinutes;

    final lastActivityTimestamp = prefs.getInt(_lastActivityKey);
    if (lastActivityTimestamp != null) {
      _lastActivity =
          DateTime.fromMillisecondsSinceEpoch(lastActivityTimestamp);
      _checkSession();
    }

    startSessionMonitoring();
  }

  /// بدء مراقبة الجلسة
  void startSessionMonitoring() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkSession();
    });
  }

  /// إيقاف مراقبة الجلسة
  void stopSessionMonitoring() {
    _sessionTimer?.cancel();
  }

  /// تحديث آخر نشاط
  Future<void> updateActivity() async {
    _lastActivity = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActivityKey, _lastActivity!.millisecondsSinceEpoch);
  }

  /// التحقق من الجلسة
  void _checkSession() {
    if (_lastActivity == null) return;

    final now = DateTime.now();
    final inactiveDuration = now.difference(_lastActivity!);

    if (inactiveDuration.inMinutes >= _timeoutMinutes) {
      expireSession();
    }
  }

  /// إنهاء الجلسة
  void expireSession() {
    _sessionTimer?.cancel();
    _lastActivity = null;
    _onSessionExpired?.call();
  }

  /// بدء جلسة جديدة
  Future<void> startNewSession() async {
    await updateActivity();
    startSessionMonitoring();
  }

  /// إنهاء الجلسة وتسجيل الخروج
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastActivityKey);

    expireSession();
  }

  /// تعيين مهلة الجلسة
  Future<void> setSessionTimeout(int minutes) async {
    _timeoutMinutes = minutes;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionTimeoutKey, minutes);
  }

  /// الحصول على مهلة الجلسة الحالية
  int get sessionTimeoutMinutes => _timeoutMinutes;

  /// الحصول على الوقت المتبقي للجلسة
  Duration? get remainingTime {
    if (_lastActivity == null) return null;

    final now = DateTime.now();
    final inactiveDuration = now.difference(_lastActivity!);
    final timeoutDuration = Duration(minutes: _timeoutMinutes);

    final remaining = timeoutDuration - inactiveDuration;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// هل الجلسة نشطة؟
  bool get isSessionActive {
    if (_lastActivity == null) return false;

    final now = DateTime.now();
    final inactiveDuration = now.difference(_lastActivity!);

    return inactiveDuration.inMinutes < _timeoutMinutes;
  }

  /// الحصول على الإحصائيات
  SessionStats getStats() {
    return SessionStats(
      lastActivity: _lastActivity,
      timeoutMinutes: _timeoutMinutes,
      remainingTime: remainingTime,
      isActive: isSessionActive,
    );
  }

  /// تحرير الموارد
  void dispose() {
    _sessionTimer?.cancel();
  }
}

/// إحصائيات الجلسة
class SessionStats {
  final DateTime? lastActivity;
  final int timeoutMinutes;
  final Duration? remainingTime;
  final bool isActive;

  SessionStats({
    required this.lastActivity,
    required this.timeoutMinutes,
    required this.remainingTime,
    required this.isActive,
  });

  String get remainingTimeFormatted {
    if (remainingTime == null) return 'غير نشط';

    final minutes = remainingTime!.inMinutes;
    final seconds = remainingTime!.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'SessionStats(active: $isActive, remaining: $remainingTimeFormatted, timeout: ${timeoutMinutes}m)';
  }
}
