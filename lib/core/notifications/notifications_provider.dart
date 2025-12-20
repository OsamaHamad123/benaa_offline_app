import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notifications_service.dart';

/// 🔔 Notifications Provider
/// Provider لخدمة الإشعارات

/// Provider للتهيئة الأولية
final notificationsInitializationProvider = FutureProvider<void>((ref) async {
  await NotificationsService.initialize();
});

/// Provider للتحقق من صلاحيات الإشعارات
final notificationsPermissionsProvider = FutureProvider<bool>((ref) async {
  return await NotificationsService.requestPermissions();
});

/// State Notifier لإدارة حالة الإشعارات
class NotificationsStateNotifier extends StateNotifier<NotificationsState> {
  NotificationsStateNotifier() : super(const NotificationsState());

  /// تهيئة الإشعارات
  Future<void> initialize() async {
    state = state.copyWith(isInitializing: true);
    try {
      await NotificationsService.initialize();
      state = state.copyWith(
        isInitialized: true,
        isInitializing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isInitializing: false,
        error: e.toString(),
      );
    }
  }

  /// طلب الصلاحيات
  Future<bool> requestPermissions() async {
    try {
      final granted = await NotificationsService.requestPermissions();
      state = state.copyWith(hasPermissions: granted);
      return granted;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// جدولة تذكير بزيارة
  Future<void> scheduleVisitReminder({
    required int beneficiaryId,
    required String beneficiaryName,
    required DateTime visitDate,
  }) async {
    try {
      await NotificationsService.scheduleVisitReminder(
        beneficiaryId: beneficiaryId,
        beneficiaryName: beneficiaryName,
        visitDate: visitDate,
      );

      state = state.copyWith(
        scheduledCount: state.scheduledCount + 1,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// جدولة تذكير بانتهاء مستند
  Future<void> scheduleDocumentExpiryReminder({
    required int beneficiaryId,
    required String beneficiaryName,
    required String documentType,
    required DateTime expiryDate,
  }) async {
    try {
      await NotificationsService.scheduleDocumentExpiryReminder(
        beneficiaryId: beneficiaryId,
        beneficiaryName: beneficiaryName,
        documentType: documentType,
        expiryDate: expiryDate,
      );

      state = state.copyWith(
        scheduledCount: state.scheduledCount + 1,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// جدولة تذكير بانتهاء كفالة
  Future<void> scheduleSponsorshipExpiryReminder({
    required int sponsorshipId,
    required String beneficiaryName,
    required DateTime endDate,
  }) async {
    try {
      await NotificationsService.scheduleSponsorshipExpiryReminder(
        sponsorshipId: sponsorshipId,
        beneficiaryName: beneficiaryName,
        endDate: endDate,
      );

      state = state.copyWith(
        scheduledCount: state.scheduledCount + 1,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// إلغاء إشعار
  Future<void> cancelNotification(int id) async {
    try {
      await NotificationsService.cancelNotification(id);
      state = state.copyWith(
        scheduledCount: state.scheduledCount > 0 ? state.scheduledCount - 1 : 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    try {
      await NotificationsService.cancelAllNotifications();
      state = state.copyWith(scheduledCount: 0);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// حالة الإشعارات
class NotificationsState {
  final bool isInitialized;
  final bool isInitializing;
  final bool hasPermissions;
  final int scheduledCount;
  final String? error;

  const NotificationsState({
    this.isInitialized = false,
    this.isInitializing = false,
    this.hasPermissions = false,
    this.scheduledCount = 0,
    this.error,
  });

  NotificationsState copyWith({
    bool? isInitialized,
    bool? isInitializing,
    bool? hasPermissions,
    int? scheduledCount,
    String? error,
  }) {
    return NotificationsState(
      isInitialized: isInitialized ?? this.isInitialized,
      isInitializing: isInitializing ?? this.isInitializing,
      hasPermissions: hasPermissions ?? this.hasPermissions,
      scheduledCount: scheduledCount ?? this.scheduledCount,
      error: error,
    );
  }
}

/// Provider للـ NotificationsStateNotifier
final notificationsStateProvider = StateNotifierProvider<NotificationsStateNotifier, NotificationsState>(
  (ref) => NotificationsStateNotifier(),
);
