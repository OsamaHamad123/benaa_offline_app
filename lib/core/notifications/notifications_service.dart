import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 🔔 Notifications Service
/// خدمة الإشعارات الذكية

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static const int _civilDbDownloadNotificationId = 45001;
  static const int _syncOperationNotificationId = 45002;
  static const int _codesInventoryAlertNotificationId = 45003;

  /// تهيئة الإشعارات
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await initialize();
  }

  /// معالجة الضغط على الإشعار
  static void _onNotificationTap(NotificationResponse response) {
    // TODO: Handle notification tap - navigate to relevant screen
    final payload = response.payload;
    if (payload != null) {
      // Navigate based on payload
      // Example: router.push('/beneficiary/$id')
    }
  }

  /// طلب صلاحيات الإشعارات
  static Future<bool> requestPermissions() async {
    await _ensureInitialized();

    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// إظهار إشعار فوري
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'general_channel',
      'إشعارات عامة',
      channelDescription: 'إشعارات تطبيق بناء',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// جدولة إشعار
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'إشعارات مجدولة',
      channelDescription: 'تذكيرات وإشعارات مجدولة',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// إلغاء إشعار
  static Future<void> cancelNotification(int id) async {
    await _ensureInitialized();
    await _notifications.cancel(id);
  }

  /// إلغاء جميع الإشعارات
  static Future<void> cancelAllNotifications() async {
    await _ensureInitialized();
    await _notifications.cancelAll();
  }

  static Future<void> showCivilDbDownloadProgress({
    required double percentage,
    required String subtitle,
  }) async {
    await _ensureInitialized();

    final bounded = percentage.clamp(0, 100).round();

    final androidDetails = AndroidNotificationDetails(
      'civil_db_download_channel',
      'تنزيل السجل المدني',
      channelDescription: 'متابعة تقدم تنزيل قاعدة بيانات السجل المدني',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: bounded,
      category: AndroidNotificationCategory.progress,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _civilDbDownloadNotificationId,
      'جاري تنزيل السجل المدني ($bounded%)',
      subtitle,
      details,
      payload: 'civil_db_download:progress',
    );
  }

  static Future<void> showCivilDbDownloadCompleted() async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'civil_db_download_channel',
      'تنزيل السجل المدني',
      channelDescription: 'متابعة تقدم تنزيل قاعدة بيانات السجل المدني',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      category: AndroidNotificationCategory.status,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _civilDbDownloadNotificationId,
      'اكتمل تنزيل السجل المدني',
      'قاعدة البيانات أصبحت جاهزة للاستخدام.',
      details,
      payload: 'civil_db_download:completed',
    );
  }

  static Future<void> showCivilDbDownloadFailed(String message) async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'civil_db_download_channel',
      'تنزيل السجل المدني',
      channelDescription: 'متابعة تقدم تنزيل قاعدة بيانات السجل المدني',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      category: AndroidNotificationCategory.error,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _civilDbDownloadNotificationId,
      'فشل تنزيل السجل المدني',
      message,
      details,
      payload: 'civil_db_download:failed',
    );
  }

  static Future<void> showCivilDbDownloadCancelled() async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'civil_db_download_channel',
      'تنزيل السجل المدني',
      channelDescription: 'متابعة تقدم تنزيل قاعدة بيانات السجل المدني',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: false,
      category: AndroidNotificationCategory.status,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _civilDbDownloadNotificationId,
      'تم إلغاء تنزيل السجل المدني',
      'يمكنك استكمال التنزيل لاحقًا من نفس الصفحة.',
      details,
      payload: 'civil_db_download:cancelled',
    );
  }

  static Future<void> showSyncOperationProgress({
    required String operationLabel,
    required double percentage,
  }) async {
    await _ensureInitialized();

    final bounded = percentage.clamp(0, 100).round();

    final androidDetails = AndroidNotificationDetails(
      'sync_operations_channel',
      'عمليات المزامنة',
      channelDescription: 'متابعة تقدم المزامنة والرفع والتنزيل',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: bounded,
      category: AndroidNotificationCategory.progress,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      _syncOperationNotificationId,
      'جارية عملية مزامنة ($bounded%)',
      operationLabel,
      details,
      payload: 'sync_operation:progress',
    );
  }

  static Future<void> showSyncOperationCompleted({required String summary}) async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'sync_operations_channel',
      'عمليات المزامنة',
      channelDescription: 'متابعة تقدم المزامنة والرفع والتنزيل',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      category: AndroidNotificationCategory.status,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      _syncOperationNotificationId,
      'اكتملت عملية المزامنة',
      summary,
      details,
      payload: 'sync_operation:completed',
    );
  }

  static Future<void> showSyncOperationFailed(String message) async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'sync_operations_channel',
      'عمليات المزامنة',
      channelDescription: 'متابعة تقدم المزامنة والرفع والتنزيل',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      category: AndroidNotificationCategory.error,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      _syncOperationNotificationId,
      'فشلت عملية المزامنة',
      message,
      details,
      payload: 'sync_operation:failed',
    );
  }

  static Future<void> showCodesInventoryAlert({
    required String title,
    required String body,
  }) async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'codes_inventory_channel',
      'تنبيهات مخزون الأكواد',
      channelDescription: 'تنبيهات تخص نفاد الأكواد وحدود الجهاز في نظام الحجز',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      category: AndroidNotificationCategory.reminder,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      _codesInventoryAlertNotificationId,
      title,
      body,
      details,
      payload: 'codes_inventory:alert',
    );
  }

  /// --- إشعارات خاصة بالتطبيق ---

  /// تذكير بزيارة مستفيد
  static Future<void> scheduleVisitReminder({
    required int beneficiaryId,
    required String beneficiaryName,
    required DateTime visitDate,
  }) async {
    final notificationId = 1000 + beneficiaryId;

    // Schedule notification 1 day before visit
    final reminderDate = visitDate.subtract(const Duration(days: 1));

    await scheduleNotification(
      id: notificationId,
      title: 'تذكير بزيارة',
      body: 'لديك زيارة مجدولة للمستفيد: $beneficiaryName',
      scheduledDate: reminderDate,
      payload: 'visit_reminder:$beneficiaryId',
    );
  }

  /// تذكير بانتهاء مستند
  static Future<void> scheduleDocumentExpiryReminder({
    required int beneficiaryId,
    required String beneficiaryName,
    required String documentType,
    required DateTime expiryDate,
  }) async {
    final notificationId = 2000 + beneficiaryId;

    // Schedule notification 7 days before expiry
    final reminderDate = expiryDate.subtract(const Duration(days: 7));

    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: notificationId,
        title: 'تنبيه انتهاء مستند',
        body: '$documentType للمستفيد $beneficiaryName سينتهي في ${expiryDate.toString().substring(0, 10)}',
        scheduledDate: reminderDate,
        payload: 'document_expiry:$beneficiaryId',
      );
    }
  }

  /// تذكير بانتهاء كفالة
  static Future<void> scheduleSponsorshipExpiryReminder({
    required int sponsorshipId,
    required String beneficiaryName,
    required DateTime endDate,
  }) async {
    final notificationId = 3000 + sponsorshipId;

    // Schedule notification 14 days before expiry
    final reminderDate = endDate.subtract(const Duration(days: 14));

    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: notificationId,
        title: 'تنبيه انتهاء كفالة',
        body: 'كفالة المستفيد $beneficiaryName ستنتهي في ${endDate.toString().substring(0, 10)}',
        scheduledDate: reminderDate,
        payload: 'sponsorship_expiry:$sponsorshipId',
      );
    }
  }

  /// إشعار بنجاح المزامنة
  static Future<void> showSyncSuccessNotification({
    required int itemsSynced,
  }) async {
    await showNotification(
      id: 9999,
      title: 'تمت المزامنة بنجاح',
      body: 'تم مزامنة $itemsSynced عنصر مع السيرفر',
    );
  }

  /// إشعار بفشل المزامنة
  static Future<void> showSyncFailureNotification({
    required String error,
  }) async {
    await showNotification(
      id: 9998,
      title: 'فشلت المزامنة',
      body: 'حدث خطأ أثناء المزامنة: $error',
    );
  }

  /// إشعار بنجاح النسخ الاحتياطي
  static Future<void> showBackupSuccessNotification() async {
    await showNotification(
      id: 9997,
      title: 'تم النسخ الاحتياطي بنجاح',
      body: 'تم حفظ نسخة احتياطية من البيانات',
    );
  }

  /// إشعار بفشل النسخ الاحتياطي
  static Future<void> showBackupFailureNotification({
    required String error,
  }) async {
    await showNotification(
      id: 9996,
      title: 'فشل النسخ الاحتياطي',
      body: 'حدث خطأ أثناء النسخ الاحتياطي: $error',
    );
  }
}
