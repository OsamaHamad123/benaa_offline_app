import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/civil_database_manager.dart';
import 'civil_database_download_page.dart';

/// صفحة الإعداد الأولي لقاعدة بيانات السجل المدني
class InitialSetupPage extends StatefulWidget {
  /// URL لتحميل قاعدة البيانات
  final String downloadUrl;

  /// Checksum المتوقع للتحقق من سلامة الملف
  final String? expectedChecksum;

  const InitialSetupPage({
    required this.downloadUrl, super.key,
    this.expectedChecksum,
  });

  @override
  State<InitialSetupPage> createState() => _InitialSetupPageState();
}

class _InitialSetupPageState extends State<InitialSetupPage> {
  late CivilDatabaseManager _dbManager;
  bool _isLoading = true;
  bool _databaseExists = false;
  Map<String, dynamic>? _dbStats;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _dbManager = CivilDatabaseManager(prefs);

    final exists = await _dbManager.isDatabaseExists();
    final stats = await _dbManager.getDatabaseStats();

    setState(() {
      _databaseExists = exists;
      _dbStats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // شعار التطبيق
              _buildLogo(),
              const SizedBox(height: 40),

              // العنوان
              _buildTitle(),
              const SizedBox(height: 16),

              // الوصف
              _buildDescription(),
              const SizedBox(height: 40),

              // معلومات التحميل
              _buildDownloadInfo(),
              const SizedBox(height: 24),

              // المميزات
              _buildFeatures(),
              const Spacer(),

              // حالة قاعدة البيانات
              if (_databaseExists) _buildDatabaseStatus(),
              const SizedBox(height: 16),

              // أزرار الإجراءات
              _buildActionButtons(),
              const SizedBox(height: 16),

              // رابط التخطي
              _buildSkipLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.insert_drive_file,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'قاعدة بيانات السجل المدني',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      'للعمل بدون إنترنت، يجب تحميل قاعدة بيانات السجل المدني. '
      'يمكنك تحميلها الآن أو لاحقاً من الإعدادات.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
    );
  }

  Widget _buildDownloadInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.file_download,
            label: 'حجم التحميل',
            value: '~1.5 GB (مضغوط)',
            iconColor: Colors.blue,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.storage,
            label: 'المساحة المطلوبة',
            value: '~4.5 GB',
            iconColor: Colors.orange,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.timer,
            label: 'الوقت المتوقع',
            value: '5-15 دقيقة',
            iconColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المميزات:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem('✅ بحث سريع في ملايين السجلات'),
        _buildFeatureItem('✅ عمل كامل بدون إنترنت'),
        _buildFeatureItem('✅ تحديثات تلقائية للبيانات الجديدة'),
        _buildFeatureItem('✅ أمان وخصوصية عالية'),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'قاعدة البيانات موجودة',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  'الحجم: ${_dbStats?['sizeFormatted'] ?? 'غير معروف'}',
                  style: TextStyle(fontSize: 12, color: Colors.green[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_databaseExists) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _continueToApp(),
              icon: const Icon(Icons.arrow_forward, size: 24),
              label: const Text('متابعة', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _redownload(),
              icon: const Icon(Icons.refresh, size: 24),
              label: const Text(
                'إعادة التحميل',
                style: TextStyle(fontSize: 18),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _startDownload(),
      icon: const Icon(Icons.download, size: 24),
      label: const Text('تحميل الآن', style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSkipLink() {
    return TextButton(
      onPressed: () => _skipForNow(),
      child: const Text(
        'تخطي الآن (يمكن التحميل لاحقاً من الإعدادات)',
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  Future<void> _startDownload() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CivilDatabaseDownloadPage(
          downloadUrl: widget.downloadUrl,
          expectedChecksum: widget.expectedChecksum,
        ),
      ),
    );

    if (result == true && mounted) {
      // تم التحميل بنجاح
      await _initialize();
    }
  }

  Future<void> _redownload() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد'),
        content: const Text(
          'هل تريد حذف قاعدة البيانات الحالية وإعادة التحميل؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف وإعادة التحميل'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // حذف القاعدة الحالية
      await _dbManager.deleteDatabase();
      await _initialize();

      // بدء التحميل
      await _startDownload();
    }
  }

  void _continueToApp() {
    Navigator.pop(context, true);
  }

  void _skipForNow() {
    Navigator.pop(context, false);
  }
}
