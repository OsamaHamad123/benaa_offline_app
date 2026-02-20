import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

const bool _enableAutomaticDbMaintenance = false;

/// 🛠️ Database Maintenance Manager
/// Triggers database maintenance (VACUUM, ANALYZE) safely using the
/// existing database connection from the ProviderScope.
/// This prevents database locks and ANRs caused by duplicate connections.
class DatabaseMaintenanceManager extends ConsumerStatefulWidget {
  final Widget child;

  const DatabaseMaintenanceManager({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<DatabaseMaintenanceManager> createState() => _DatabaseMaintenanceManagerState();
}

class _DatabaseMaintenanceManagerState extends ConsumerState<DatabaseMaintenanceManager> {
  @override
  void initState() {
    super.initState();
    if (!_enableAutomaticDbMaintenance) {
      return;
    }

    // Schedule maintenance to run after the app starts
    // We delay it significantly to ensure UI is responsive first
    // Increased delay to 30 seconds to prevent ANRs on slower devices
    Future.delayed(const Duration(seconds: 30), _runMaintenance);
  }

  Future<void> _runMaintenance() async {
    if (!mounted) return;

    // Use read instead of watch to avoid rebuilding on changes
    final maintenanceService = ref.read(databaseMaintenanceProvider);

    // Run in background (unawaited by UI)
    try {
      // Logic inside performMaintenanceIfNeeded should handle errors
      await maintenanceService.performMaintenanceIfNeeded();
    } catch (e) {
      debugPrint('Database maintenance failed to start: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
