import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/widgets/loading_state.dart';
import '../../core/sync/mobile_sync_service.dart';
import 'mobile_sync_page.dart';

final mobileSyncStatusProvider = StreamProvider<MobileSyncStatus>((ref) {
  final syncService = ref.watch(mobileSyncServiceProvider);
  return syncService.statusStream;
});

Future<void> _runOfficialSync(MobileSyncService syncService) async {
  await syncService.syncDown();
  await syncService.syncUp();
}

/// شريط عرض حالة المزامنة
class SyncStatusBar extends ConsumerWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(mobileSyncStatusProvider);

    return syncStatusAsync.when(
      data: (status) {
        if (!status.isSyncing && status.lastError == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          color: status.lastError != null ? Colors.red.shade100 : Colors.blue.shade100,
          child: Row(
            children: [
              if (status.isSyncing)
                const SmallLoadingIndicator()
              else if (status.lastError != null)
                Icon(Icons.error, color: Colors.red, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status.isSyncing)
                      Text(
                        'جاري المزامنة... ${status.currentOperation}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    else if (status.lastError != null)
                      const Text(
                        'خطأ في المزامنة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    if (status.isSyncing)
                      Text(
                        '${(status.progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade700,
                        ),
                      )
                    else if (status.lastError != null)
                      Text(
                        status.lastError!,
                        style: TextStyle(fontSize: 12.sp, color: Colors.red),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (status.isSyncing) ...[
                SizedBox(width: 8.w),
                SizedBox(
                  width: 60.w,
                  child: LinearProgressIndicator(value: status.progress),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// زر المزامنة اليدوية
class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(mobileSyncStatusProvider);
    final syncService = ref.watch(mobileSyncServiceProvider);

    return syncStatusAsync.when(
      data: (status) {
        return IconButton(
          icon: status.isSyncing ? const SmallLoadingIndicator() : const Icon(Icons.sync),
          onPressed: status.isSyncing ? null : () => _runOfficialSync(syncService),
          tooltip: status.isSyncing ? 'جاري المزامنة...' : 'مزامنة',
        );
      },
      loading: () => const IconButton(icon: Icon(Icons.sync), onPressed: null),
      error: (_, __) => IconButton(
        icon: const Icon(Icons.sync_problem),
        onPressed: () => _runOfficialSync(syncService),
        tooltip: 'إعادة المحاولة',
      ),
    );
  }
}

/// شاشة تفاصيل المزامنة
class SyncDetailsPage extends ConsumerWidget {
  const SyncDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(mobileSyncStatusProvider);
    final syncService = ref.watch(mobileSyncServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حالة المزامنة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _runOfficialSync(syncService),
            tooltip: 'مزامنة الآن',
          ),
        ],
      ),
      body: syncStatusAsync.when(
        data: (status) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // حالة المزامنة
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            status.isSyncing
                                ? Icons.sync
                                : status.lastError != null
                                    ? Icons.error
                                    : Icons.check_circle,
                            color: status.isSyncing
                                ? Colors.blue
                                : status.lastError != null
                                    ? Colors.red
                                    : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status.isSyncing
                                ? 'جاري المزامنة'
                                : status.lastError != null
                                    ? 'خطأ'
                                    : 'متزامن',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (status.isSyncing) ...[
                        const SizedBox(height: 16),
                        LinearProgressIndicator(value: status.progress),
                        const SizedBox(height: 8),
                        Text(
                          '${(status.progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                      if (status.lastError != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  status.lastError!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // معلومات إضافية
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('المزامنة التلقائية'),
                      subtitle: const Text('كل 5 دقائق عند توفر الإنترنت'),
                      trailing: Switch(
                        value: true, // TODO: Make this configurable
                        onChanged: (value) {
                          // TODO: Toggle auto sync
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.cloud_upload),
                      title: const Text('عناصر في الانتظار'),
                      trailing: Text(
                        status.isSyncing ? '...' : '-',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // زر المزامنة
              if (!status.isSyncing)
                ElevatedButton.icon(
                  onPressed: () => _runOfficialSync(syncService),
                  icon: const Icon(Icons.sync),
                  label: const Text('مزامنة الآن'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: SmallLoadingIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('خطأ: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _runOfficialSync(syncService),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
