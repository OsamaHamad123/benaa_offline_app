import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../background_sync_worker.dart';

/// 🔄 Sync Status Indicator - Shows sync status in AppBar
class SyncStatusIndicator extends ConsumerWidget {
  final bool showLabel;
  final double iconSize;

  const SyncStatusIndicator({
    super.key,
    this.showLabel = false,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Wire up with actual sync manager stream
    // For now, using mock data

    return _buildMockIndicator(context);
  }

  Widget _buildMockIndicator(BuildContext context) {
    const isSyncing = false;
    const pendingItems = 0;

    // ignore: dead_code
    if (isSyncing) {
      return _buildSyncingState();
    }

    if (pendingItems > 0) {
      return _buildPendingState(pendingItems);
    }

    return _buildIdleState();
  }

  Widget _buildSyncingState() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          const Text('جاري المزامنة...', style: TextStyle(fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildPendingState(int count) {
    return Badge(
      label: Text('$count'),
      backgroundColor: Colors.orange,
      child: Icon(Icons.cloud_upload, size: iconSize, color: Colors.white),
    );
  }

  Widget _buildIdleState() {
    return Icon(
      Icons.cloud_done,
      size: iconSize,
      color: Colors.white.withOpacity(0.7),
    );
  }
}

/// Sync Status Badge - Standalone widget with full status
class SyncStatusBadge extends ConsumerWidget {
  const SyncStatusBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_done, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 6),
          const Text(
            'متزامن',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Sync Action Button - Manual sync trigger
class SyncActionButton extends ConsumerWidget {
  final VoidCallback? onSyncComplete;

  const SyncActionButton({super.key, this.onSyncComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.sync),
      tooltip: 'مزامنة يدوية',
      onPressed: () async {
        await _handleManualSync(context);
        onSyncComplete?.call();
      },
    );
  }

  Future<void> _handleManualSync(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري المزامنة...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Trigger manual sync
      await BackgroundSyncWorker.triggerManualSync();

      // Wait a bit for sync to start
      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('تمت المزامنة بنجاح'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('فشلت المزامنة: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
