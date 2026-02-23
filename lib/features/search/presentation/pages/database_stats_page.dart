import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../../core/widgets/enhanced_refresh_indicator.dart';
import '../../data/datasources/civil_registry_database.dart';
import '../../data/services/search_analytics.dart';

/// 📊 Database Statistics Page - Comprehensive analytics and maintenance
class DatabaseStatsPage extends ConsumerStatefulWidget {
  const DatabaseStatsPage({super.key});

  @override
  ConsumerState<DatabaseStatsPage> createState() => _DatabaseStatsPageState();
}

class _DatabaseStatsPageState extends ConsumerState<DatabaseStatsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _dbStats;
  Map<String, dynamic>? _searchStats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = await CivilRegistryDatabase.instance.database;
      if (db == null) {
        setState(() {
          _error = 'قاعدة بيانات السجل المدني غير متوفرة. يرجى تحميلها من الإعدادات.';
          _isLoading = false;
        });
        return;
      }
      final queries = await db.rawQuery('PRAGMA database_list');

      // Get database file info
      final dbPath = queries.first['file'] as String?;
      int dbSize = 0;
      String dbSizeMB = '0';

      if (dbPath != null && dbPath.isNotEmpty) {
        final file = File(dbPath);
        if (await file.exists()) {
          dbSize = await file.length();
          dbSizeMB = (dbSize / (1024 * 1024)).toStringAsFixed(2);
        }
      }

      // Get table stats
      final personCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM persons',
      );
      final maleCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM persons WHERE CI_SEX_CD = "1"',
      );
      final femaleCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM persons WHERE CI_SEX_CD = "2"',
      );

      // Get index info
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='persons'",
      );

      // Get cities
      final cities = await db.rawQuery(
        'SELECT DISTINCT CITY FROM persons WHERE CITY IS NOT NULL ORDER BY CITY',
      );

      // Get search analytics
      final searchAnalytics = SearchAnalytics.getSummary();

      setState(() {
        _dbStats = {
          'size': dbSize,
          'sizeMB': dbSizeMB,
          'path': dbPath ?? 'Unknown',
          'totalPersons': personCount.first['count'] as int,
          'maleCount': maleCount.first['count'] as int,
          'femaleCount': femaleCount.first['count'] as int,
          'indexCount': indexes.length,
          'indexes': indexes.map((i) => i['name'] as String).toList(),
          'cityCount': cities.length,
          'cities': cities.map((c) => c['CITY'] as String?).where((c) => c != null).toList(),
        };
        _searchStats = searchAnalytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _rebuildIndexes() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('إعادة بناء الفهارس'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري إعادة بناء الفهارس...'),
            Text(
              'قد يستغرق 5-10 دقائق',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    try {
      final db = await CivilRegistryDatabase.instance.database;
      if (db == null) {
        throw Exception('قاعدة البيانات غير متوفرة');
      }

      // Run ANALYZE
      await db.rawQuery('ANALYZE');

      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم تحديث الفهارس بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      _loadStats(); // Reload stats
    } catch (e) {
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل تحديث الفهارس: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearCache() async {
    try {
      // Clear search analytics
      SearchAnalytics.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم مسح الـ Cache بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      _loadStats(); // Reload stats
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل مسح الـ Cache: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إحصائيات قاعدة البيانات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'حدث خطأ:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStats,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : EnhancedRefreshIndicator(
                  onRefresh: _loadStats,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Database Info Section
                      _buildSectionHeader('معلومات قاعدة البيانات', Icons.storage),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        title: 'حجم القاعدة',
                        value: '${_dbStats!['sizeMB']} MB',
                        icon: Icons.data_usage,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      _buildStatCard(
                        title: 'عدد السجلات',
                        value: _formatNumber(_dbStats!['totalPersons']),
                        icon: Icons.people,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'ذكور',
                              value: _formatNumber(_dbStats!['maleCount']),
                              icon: Icons.male,
                              color: Colors.blueAccent,
                              compact: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              title: 'إناث',
                              value: _formatNumber(_dbStats!['femaleCount']),
                              icon: Icons.female,
                              color: Colors.pinkAccent,
                              compact: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildStatCard(
                        title: 'عدد المحافظات',
                        value: '${_dbStats!['cityCount']}',
                        icon: Icons.location_city,
                        color: Colors.orange,
                      ),

                      const SizedBox(height: 24),

                      // Indexes Section
                      _buildSectionHeader('الفهارس (Indexes)', Icons.list_alt),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        title: 'عدد الفهارس',
                        value: '${_dbStats!['indexCount']}',
                        icon: Icons.numbers,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: ExpansionTile(
                          leading: const Icon(Icons.visibility),
                          title: const Text('عرض قائمة الفهارس'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: (_dbStats!['indexes'] as List<String>)
                                    .map(
                                      (idx) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: Colors.green,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                idx,
                                                style: const TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Search Analytics Section
                      _buildSectionHeader('إحصائيات البحث', Icons.analytics),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        title: 'إجمالي عمليات البحث',
                        value: '${_searchStats!['totalSearches']}',
                        icon: Icons.search,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 8),
                      _buildStatCard(
                        title: 'عمليات بحث ناجحة',
                        value: '${_searchStats!['successfulSearches']}',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildStatCard(
                        title: 'معدل النجاح',
                        value: '${(_searchStats!['successRate'] * 100).toStringAsFixed(1)}%',
                        icon: Icons.trending_up,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 8),
                      _buildStatCard(
                        title: 'متوسط وقت البحث',
                        value: '${_searchStats!['averageSearchDuration'].toStringAsFixed(1)} ms',
                        icon: Icons.speed,
                        color: Colors.amber,
                      ),

                      const SizedBox(height: 16),

                      // Popular Queries
                      if ((_searchStats!['popularQueries'] as List).isNotEmpty) ...[
                        Card(
                          child: ExpansionTile(
                            leading: const Icon(Icons.star),
                            title: const Text('الاستعلامات الأكثر شيوعاً'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: (_searchStats!['popularQueries'] as List<MapEntry>)
                                      .map(
                                        (entry) => ListTile(
                                          dense: true,
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.blue.shade100,
                                            child: Text(
                                              '${entry.value}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          title: Text(entry.key),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Slow Queries
                      if ((_searchStats!['slowQueries'] as List).isNotEmpty) ...[
                        Card(
                          color: Colors.orange.shade50,
                          child: ExpansionTile(
                            leading: const Icon(Icons.warning, color: Colors.orange),
                            title: const Text('استعلامات بطيئة (> 200ms)'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: (_searchStats!['slowQueries'] as List<String>)
                                      .map(
                                        (query) => ListTile(
                                          dense: true,
                                          leading: const Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.orange,
                                          ),
                                          title: Text(query),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Maintenance Actions
                      _buildSectionHeader('عمليات الصيانة', Icons.build),
                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        onPressed: _rebuildIndexes,
                        icon: const Icon(Icons.refresh),
                        label: const Text('تحديث الفهارس (ANALYZE)'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.blue.shade700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      ElevatedButton.icon(
                        onPressed: _clearCache,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('مسح الـ Cache'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.orange.shade700,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Database Path
                      Card(
                        color: Colors.grey.shade100,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.folder,
                                    size: 20,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'مسار القاعدة:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                _dbStats!['path'],
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool compact = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(compact ? 8 : 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: compact ? 20 : 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: compact ? 12 : 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: compact ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
