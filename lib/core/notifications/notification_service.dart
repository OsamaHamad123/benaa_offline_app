import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🔔 Notification System - نظام إشعارات متقدم
class AppNotificationService {
  static final AppNotificationService _instance = AppNotificationService._();
  factory AppNotificationService() => _instance;
  AppNotificationService._();

  final List<AppNotification> _notifications = [];
  final _notificationController = StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get notificationStream =>
      _notificationController.stream;

  /// عرض إشعار
  void show({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      duration: duration,
      onTap: onTap,
      actionLabel: actionLabel,
      onAction: onAction,
    );

    _notifications.add(notification);
    _notificationController.add(notification);

    // حذف تلقائي بعد المدة المحددة
    Future.delayed(duration, () {
      dismiss(notification.id);
    });
  }

  /// حذف إشعار
  void dismiss(String id) {
    _notifications.removeWhere((n) => n.id == id);
  }

  /// حذف جميع الإشعارات
  void dismissAll() {
    _notifications.clear();
  }

  /// الإشعارات الحالية
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  void dispose() {
    _notificationController.close();
  }
}

/// نموذج الإشعار
class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final Duration duration;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.duration = const Duration(seconds: 3),
    this.onTap,
    this.actionLabel,
    this.onAction,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.blue;
    }
  }
}

enum NotificationType { success, error, warning, info }

/// Provider للإشعارات
final notificationServiceProvider = Provider<AppNotificationService>((ref) {
  return AppNotificationService();
});

/// 🎨 Notification Overlay Widget
class NotificationOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const NotificationOverlay({super.key, required this.child});

  @override
  ConsumerState<NotificationOverlay> createState() =>
      _NotificationOverlayState();
}

class _NotificationOverlayState extends ConsumerState<NotificationOverlay> {
  final List<AppNotification> _activeNotifications = [];

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    ref.read(notificationServiceProvider).notificationStream.listen((
      notification,
    ) {
      if (mounted) {
        setState(() {
          _activeNotifications.add(notification);
        });

        // حذف بعد Duration
        Future.delayed(notification.duration, () {
          if (mounted) {
            setState(() {
              _activeNotifications.removeWhere((n) => n.id == notification.id);
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Notifications Overlay
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Column(
            children: _activeNotifications.map((notification) {
              return _NotificationCard(
                notification: notification,
                onDismiss: () {
                  setState(() {
                    _activeNotifications.remove(notification);
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// بطاقة الإشعار
class _NotificationCard extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onDismiss,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  right: BorderSide(color: widget.notification.color, width: 4),
                ),
              ),
              child: InkWell(
                onTap: widget.notification.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.notification.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.notification.icon,
                          color: widget.notification.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.notification.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.notification.message,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Button
                      if (widget.notification.actionLabel != null)
                        TextButton(
                          onPressed: widget.notification.onAction,
                          child: Text(widget.notification.actionLabel!),
                        ),

                      // Close Button
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: _dismiss,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// استخدام سريع للإشعارات
class QuickNotifications {
  static void success(BuildContext context, String message, {String? title}) {
    AppNotificationService().show(
      title: title ?? 'نجح',
      message: message,
      type: NotificationType.success,
    );
  }

  static void error(BuildContext context, String message, {String? title}) {
    AppNotificationService().show(
      title: title ?? 'خطأ',
      message: message,
      type: NotificationType.error,
      duration: const Duration(seconds: 5),
    );
  }

  static void warning(BuildContext context, String message, {String? title}) {
    AppNotificationService().show(
      title: title ?? 'تحذير',
      message: message,
      type: NotificationType.warning,
      duration: const Duration(seconds: 4),
    );
  }

  static void info(BuildContext context, String message, {String? title}) {
    AppNotificationService().show(
      title: title ?? 'معلومة',
      message: message,
      type: NotificationType.info,
    );
  }
}
