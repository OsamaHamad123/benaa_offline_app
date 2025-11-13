import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/civil_database_manager.dart';
import '../../core/services/civil_download_manager.dart';

/// صفحة تحميل قاعدة بيانات السجل المدني
class CivilDatabaseDownloadPage extends ConsumerStatefulWidget {
  final String downloadUrl;
  final String? expectedChecksum;

  const CivilDatabaseDownloadPage({
    super.key,
    required this.downloadUrl,
    this.expectedChecksum,
  });

  @override
  ConsumerState<CivilDatabaseDownloadPage> createState() =>
      _CivilDatabaseDownloadPageState();
}

class _CivilDatabaseDownloadPageState
    extends ConsumerState<CivilDatabaseDownloadPage> {
  late CivilDatabaseManager _dbManager;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeManager();
  }

  Future<void> _initializeManager() async {
    final prefs = await SharedPreferences.getInstance();
    _dbManager = CivilDatabaseManager(prefs);
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final downloadProgress = ref.watch(civilDatabaseDownloadProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('تحميل السجل المدني'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // أيقونة كبيرة
              _buildHeaderIcon(downloadProgress.state),
              const SizedBox(height: 32),

              // عنوان الحالة
              _buildStateTitle(downloadProgress.state),
              const SizedBox(height: 16),

              // معلومات التحميل
              _buildDownloadInfo(downloadProgress),
              const SizedBox(height: 32),

              // شريط التقدم
              _buildProgressBar(downloadProgress),
              const SizedBox(height: 24),

              // الإحصائيات
              _buildStats(downloadProgress),
              const Spacer(),

              // أزرار التحكم
              _buildControlButtons(downloadProgress),
              const SizedBox(height: 16),

              // رسالة الخطأ
              if (downloadProgress.error != null)
                _buildErrorMessage(downloadProgress.error!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(DownloadState state) {
    IconData icon;
    Color color;

    switch (state) {
      case DownloadState.idle:
        icon = Icons.cloud_download;
        color = Colors.blue;
        break;
      case DownloadState.downloading:
        icon = Icons.downloading;
        color = Colors.blue;
        break;
      case DownloadState.paused:
        icon = Icons.pause_circle;
        color = Colors.orange;
        break;
      case DownloadState.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case DownloadState.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      case DownloadState.verifying:
        icon = Icons.verified;
        color = Colors.purple;
        break;
      case DownloadState.extracting:
        icon = Icons.folder_zip;
        color = Colors.amber;
        break;
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 60, color: color),
    );
  }

  Widget _buildStateTitle(DownloadState state) {
    String title;

    switch (state) {
      case DownloadState.idle:
        title = 'جاهز للتحميل';
        break;
      case DownloadState.downloading:
        title = 'جاري التحميل...';
        break;
      case DownloadState.paused:
        title = 'متوقف مؤقتاً';
        break;
      case DownloadState.completed:
        title = 'اكتمل التحميل بنجاح!';
        break;
      case DownloadState.failed:
        title = 'فشل التحميل';
        break;
      case DownloadState.verifying:
        title = 'جاري التحقق من الملف...';
        break;
      case DownloadState.extracting:
        title = 'جاري فك الضغط...';
        break;
    }

    return Text(
      title,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDownloadInfo(DownloadProgress progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الحجم المحمل:', style: TextStyle(color: Colors.grey)),
              Text(
                '${progress.downloadedFormatted} / ${progress.totalFormatted}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('السرعة:', style: TextStyle(color: Colors.grey)),
              Text(
                progress.speedFormatted,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(DownloadProgress progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              progress.progressPercent,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            if (progress.remainingTime != null)
              Text(
                'المتبقي: ${_formatDuration(progress.remainingTime!)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress.progress,
            minHeight: 12,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(progress.state),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(DownloadProgress progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.timer,
            label: 'الوقت المنقضي',
            value: progress.elapsedTime != null
                ? _formatDuration(progress.elapsedTime!)
                : '--',
          ),
          Container(width: 1, height: 40, color: Colors.blue[200]),
          _buildStatItem(
            icon: Icons.speed,
            label: 'السرعة',
            value: progress.speed > 0 ? progress.speedFormatted : '--',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[700], size: 28),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildControlButtons(DownloadProgress progress) {
    switch (progress.state) {
      case DownloadState.idle:
      case DownloadState.failed:
        return _buildStartButton();

      case DownloadState.downloading:
      case DownloadState.verifying:
      case DownloadState.extracting:
        return _buildPauseButton();

      case DownloadState.paused:
        return Row(
          children: [
            Expanded(child: _buildResumeButton()),
            const SizedBox(width: 12),
            Expanded(child: _buildCancelButton()),
          ],
        );

      case DownloadState.completed:
        return _buildDoneButton();
    }
  }

  Widget _buildStartButton() {
    return ElevatedButton.icon(
      onPressed: () => _startDownload(),
      icon: const Icon(Icons.download, size: 24),
      label: const Text('بدء التحميل', style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPauseButton() {
    return ElevatedButton.icon(
      onPressed: () => _pauseDownload(),
      icon: const Icon(Icons.pause, size: 24),
      label: const Text('إيقاف مؤقت', style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildResumeButton() {
    return ElevatedButton.icon(
      onPressed: () => _resumeDownload(),
      icon: const Icon(Icons.play_arrow, size: 24),
      label: const Text('استئناف', style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton.icon(
      onPressed: () => _cancelDownload(),
      icon: const Icon(Icons.close, size: 24),
      label: const Text('إلغاء', style: TextStyle(fontSize: 18)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDoneButton() {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pop(context, true),
      icon: const Icon(Icons.check, size: 24),
      label: const Text('تم', style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(error, style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(DownloadState state) {
    switch (state) {
      case DownloadState.downloading:
      case DownloadState.verifying:
        return Colors.blue;
      case DownloadState.paused:
        return Colors.orange;
      case DownloadState.completed:
        return Colors.green;
      case DownloadState.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours س $minutes د';
    } else if (minutes > 0) {
      return '$minutes د $seconds ث';
    } else {
      return '$seconds ث';
    }
  }

  void _startDownload() {
    ref
        .read(civilDatabaseDownloadProvider.notifier)
        .startDownload(
          downloadUrl: widget.downloadUrl,
          dbManager: _dbManager,
          expectedChecksum: widget.expectedChecksum,
        );
  }

  void _pauseDownload() {
    ref.read(civilDatabaseDownloadProvider.notifier).pauseDownload();
  }

  void _resumeDownload() {
    ref
        .read(civilDatabaseDownloadProvider.notifier)
        .resumeDownload(
          downloadUrl: widget.downloadUrl,
          dbManager: _dbManager,
          expectedChecksum: widget.expectedChecksum,
        );
  }

  void _cancelDownload() {
    ref.read(civilDatabaseDownloadProvider.notifier).cancelDownload(_dbManager);
  }
}
