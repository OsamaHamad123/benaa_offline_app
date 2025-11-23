import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// حالة الاتصال
enum ConnectivityStatus {
  wifi('WiFi', '📶'),
  mobile('بيانات الجوال', '📱'),
  offline('غير متصل', '❌'),
  unknown('غير معروف', '❓');

  final String label;
  final String emoji;

  const ConnectivityStatus(this.label, this.emoji);
}

/// 🌐 Connectivity Monitor - مراقب الاتصال بالإنترنت
class ConnectivityMonitor {
  static final ConnectivityMonitor _instance = ConnectivityMonitor._();
  factory ConnectivityMonitor() => _instance;
  ConnectivityMonitor._();

  final Connectivity _connectivity = Connectivity();
  final _connectionController =
      StreamController<ConnectivityStatus>.broadcast();

  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// حالة الاتصال الحالية
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Stream لمتابعة تغييرات الاتصال
  Stream<ConnectivityStatus> get connectionStream =>
      _connectionController.stream;

  /// بدء المراقبة
  Future<void> startMonitoring() async {
    // فحص الحالة الأولية
    await _checkInitialConnection();

    // الاستماع للتغييرات
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
      onError: (error) {
        if (kDebugMode) {
          debugPrint('❌ Connectivity Error: $error');
        }
      },
    );
  }

  Future<void> _checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to check connectivity: $e');
      }
      _updateStatus(ConnectivityStatus.offline);
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet,
    );

    if (hasConnection) {
      final hasWifi = results.contains(ConnectivityResult.wifi);
      _updateStatus(
        hasWifi ? ConnectivityStatus.wifi : ConnectivityStatus.mobile,
      );
    } else {
      _updateStatus(ConnectivityStatus.offline);
    }
  }

  void _updateStatus(ConnectivityStatus newStatus) {
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _connectionController.add(newStatus);

      if (kDebugMode) {
        print('🌐 Connectivity changed: ${newStatus.name}');
      }
    }
  }

  /// فحص الاتصال مرة واحدة
  Future<bool> isConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any(
        (result) =>
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet,
      );
    } catch (e) {
      return false;
    }
  }

  /// التحقق من نوع الاتصال
  Future<bool> isWifi() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.wifi);
    } catch (e) {
      return false;
    }
  }

  /// إيقاف المراقبة
  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stopMonitoring();
    _connectionController.close();
  }
}

/// 🎯 Connectivity-Aware Widget
/// Widget يتفاعل مع حالة الاتصال
class ConnectivityAware extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext, ConnectivityStatus)? builder;
  final bool showBanner;

  const ConnectivityAware({
    super.key,
    required this.child,
    this.builder,
    this.showBanner = true,
  });

  @override
  State<ConnectivityAware> createState() => _ConnectivityAwareState();
}

class _ConnectivityAwareState extends State<ConnectivityAware> {
  StreamSubscription<ConnectivityStatus>? _subscription;
  ConnectivityStatus _status = ConnectivityStatus.unknown;

  @override
  void initState() {
    super.initState();
    _status = ConnectivityMonitor().currentStatus;
    _subscription = ConnectivityMonitor().connectionStream.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(context, _status);
    }

    return Column(
      children: [
        if (widget.showBanner && _status == ConnectivityStatus.offline)
          _buildOfflineBanner(),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    return Material(
      color: Colors.red.shade700,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'لا يوجد اتصال بالإنترنت',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// مُساعد للعمليات التي تتطلب اتصال
class ConnectivityHelper {
  /// تنفيذ عملية فقط عند وجود اتصال
  static Future<T?> executeIfConnected<T>(
    Future<T> Function() action, {
    VoidCallback? onOffline,
  }) async {
    final isConnected = await ConnectivityMonitor().isConnected();

    if (isConnected) {
      return await action();
    } else {
      onOffline?.call();
      return null;
    }
  }

  /// تنفيذ عملية فقط عند الاتصال بـ WiFi
  static Future<T?> executeIfWifi<T>(
    Future<T> Function() action, {
    VoidCallback? onNoWifi,
  }) async {
    final isWifi = await ConnectivityMonitor().isWifi();

    if (isWifi) {
      return await action();
    } else {
      onNoWifi?.call();
      return null;
    }
  }
}
