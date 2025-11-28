import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../data/db/drift_database.dart';
import '../../../../core/providers/providers.dart';
import '../../services/beneficiaries_export_service.dart';

class BeneficiariesReportPage extends ConsumerStatefulWidget {
  const BeneficiariesReportPage({super.key});

  @override
  ConsumerState<BeneficiariesReportPage> createState() => _BeneficiariesReportPageState();
}

class _BeneficiariesReportPageState extends ConsumerState<BeneficiariesReportPage> {
  String _searchQuery = '';
  String? _selectedGovernorate;
  String? _selectedCategory;
  String? _selectedSyncState;
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);

    // 🔍 DEBUG: Print database instance
    print('🔍 [DEBUG] Database Provider: $database');
    print('🔍 [DEBUG] BeneficiariesDao: ${database.beneficiariesDao}');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('تقرير المستفيدين الشامل'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
            tooltip: 'الفلاتر',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedGovernorate = null;
                _selectedCategory = null;
                _selectedSyncState = null;
              });
            },
            tooltip: 'إعادة تعيين',
          ),
          // 🔍 DEBUG BUTTON
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              final db = ref.read(databaseProvider);
              final beneficiaries = await db.beneficiariesDao.getAllBeneficiaries();
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('🔍 Debug Info'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Database: ${db.runtimeType}'),
                        const SizedBox(height: 8),
                        Text('Beneficiaries Count: ${beneficiaries.length}'),
                        const SizedBox(height: 8),
                        Text('DAO: ${db.beneficiariesDao.runtimeType}'),
                        if (beneficiaries.isNotEmpty) ...[
                          const Divider(),
                          const Text(
                            'First Beneficiary:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Name: ${beneficiaries.first.fullName}'),
                          Text('ID: ${beneficiaries.first.idNumber}'),
                          Text('Sync: ${beneficiaries.first.syncState}'),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إغلاق'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Debug Info',
          ),
        ],
      ),
      body: FutureBuilder<List<Beneficiary>>(
        future: () async {
          print('🔍 [DEBUG] Starting to fetch beneficiaries...');
          try {
            final result = await database.beneficiariesDao.getAllBeneficiaries();
            print('🔍 [DEBUG] ✅ Fetch successful!');
            print('🔍 [DEBUG] Number of beneficiaries: ${result.length}');
            if (result.isNotEmpty) {
              print(
                '🔍 [DEBUG] First beneficiary: ${result.first.fullName} (ID: ${result.first.idNumber})',
              );
              print(
                '🔍 [DEBUG] Sync states: ${result.map((b) => b.syncState).toSet()}',
              );
            }
            return result;
          } catch (e, stackTrace) {
            print('🔍 [DEBUG] ❌ Error fetching beneficiaries: $e');
            print('🔍 [DEBUG] StackTrace: $stackTrace');
            rethrow;
          }
        }(),
        builder: (context, snapshot) {
          // 🔍 DEBUG: Print snapshot state
          print(
            '🔍 [DEBUG] Snapshot ConnectionState: ${snapshot.connectionState}',
          );
          print('🔍 [DEBUG] Snapshot hasData: ${snapshot.hasData}');
          print('🔍 [DEBUG] Snapshot hasError: ${snapshot.hasError}');
          if (snapshot.hasData) {
            print('🔍 [DEBUG] Snapshot data length: ${snapshot.data?.length}');
          }
          if (snapshot.hasError) {
            print('🔍 [DEBUG] Snapshot error: ${snapshot.error}');
          }

          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('🔍 [DEBUG] Showing loading state...');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SmallLoadingIndicator(color: Colors.blue.shade700),
                  const SizedBox(height: 16),
                  const Text(
                    'جاري تحميل البيانات...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Error State
          if (snapshot.hasError) {
            print('🔍 [DEBUG] Showing error state: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'حدث خطأ في تحميل البيانات',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'التفاصيل: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final allBeneficiaries = snapshot.data ?? [];

          // 🔍 DEBUG: Print beneficiaries data
          print(
            '🔍 [DEBUG] All beneficiaries count: ${allBeneficiaries.length}',
          );
          print('🔍 [DEBUG] Is empty: ${allBeneficiaries.isEmpty}');

          // Apply Filters
          var filteredBeneficiaries = allBeneficiaries.where((b) {
            // Search filter
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              if (!b.fullName.toLowerCase().contains(query) && !b.idNumber.toString().contains(query)) {
                return false;
              }
            }

            // Governorate filter
            if (_selectedGovernorate != null && b.province.toString() != _selectedGovernorate) {
              return false;
            }

            // Category filter
            if (_selectedCategory != null && b.sectionId.toString() != _selectedCategory) {
              return false;
            }

            // Sync state filter
            if (_selectedSyncState != null && b.syncState != _selectedSyncState) {
              return false;
            }

            return true;
          }).toList();

          // 🔍 DEBUG: Print filtered results
          print(
            '🔍 [DEBUG] Filtered beneficiaries count: ${filteredBeneficiaries.length}',
          );
          print(
            '🔍 [DEBUG] Active filters: searchQuery=$_searchQuery, syncState=$_selectedSyncState',
          );

          // Empty State
          if (allBeneficiaries.isEmpty) {
            print(
              '🔍 [DEBUG] ⚠️ Showing EMPTY state - no beneficiaries in database',
            );
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'لا يوجد مستفيدين بعد',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ابدأ بإضافة مستفيدين جدد',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to add beneficiary
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة مستفيد'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Statistics
          final stats = _calculateStatistics(allBeneficiaries);

          // 🔍 DEBUG: Print statistics
          print('🔍 [DEBUG] Statistics: $stats');

          return Column(
            children: [
              // Filters Panel
              if (_showFilters)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تصفية النتائج',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'بحث بالاسم أو الرقم الوطني',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'حالة المزامنة',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              value: _selectedSyncState,
                              items: const [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text('الكل'),
                                ),
                                DropdownMenuItem(
                                  value: 'pending',
                                  child: Text('معلق'),
                                ),
                                DropdownMenuItem(
                                  value: 'synced',
                                  child: Text('تمت المزامنة'),
                                ),
                                DropdownMenuItem(
                                  value: 'failed',
                                  child: Text('فشل'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedSyncState = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_searchQuery.isNotEmpty || _selectedSyncState != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'النتائج: ${filteredBeneficiaries.length} من ${allBeneficiaries.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // Statistics Cards
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'إجمالي المستفيدين',
                        value: stats['total'].toString(),
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'تمت المزامنة',
                        value: stats['synced'].toString(),
                        icon: Icons.cloud_done,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'بانتظار المزامنة',
                        value: stats['pending'].toString(),
                        icon: Icons.cloud_queue,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              // Data Table
              Expanded(
                child: filteredBeneficiaries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'لا توجد نتائج للفلاتر المحددة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'جرب تغيير معايير البحث',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.table_chart, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'بيانات المستفيدين (${filteredBeneficiaries.length})',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.file_download),
                                    tooltip: 'تصدير التقرير',
                                    onSelected: (value) {
                                      if (value == 'excel') {
                                        _exportToExcel(filteredBeneficiaries);
                                      } else if (value == 'pdf') {
                                        _exportToPdf(filteredBeneficiaries);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'excel',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.table_chart,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 12),
                                            Text('تصدير Excel'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'pdf',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.picture_as_pdf,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 12),
                                            Text('تصدير PDF'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.all(8),
                                itemCount: filteredBeneficiaries.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final b = filteredBeneficiaries[index];
                                  return _BeneficiaryListTile(beneficiary: b);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Map<String, int> _calculateStatistics(List<Beneficiary> beneficiaries) {
    return {
      'total': beneficiaries.length,
      'synced': beneficiaries.where((b) => b.syncState == 'synced').length,
      'pending': beneficiaries.where((b) => b.syncState == 'pending').length,
      'failed': beneficiaries.where((b) => b.syncState == 'failed').length,
    };
  }

  void _exportToExcel(List<Beneficiary> beneficiaries) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: SmallLoadingIndicator()),
      );

      final filePath = await BeneficiariesExportService.exportToExcel(
        beneficiaries,
      );

      // Close loading
      if (!mounted) return;
      Navigator.pop(context);

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تصدير التقرير بنجاح\n$filePath'),
          action: SnackBarAction(
            label: 'فتح',
            onPressed: () => BeneficiariesExportService.openFile(filePath),
          ),
          duration: const Duration(seconds: 5),
        ),
      );

      // Auto open file
      await BeneficiariesExportService.openFile(filePath);
    } catch (e) {
      // Close loading if still showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التصدير: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _exportToPdf(List<Beneficiary> beneficiaries) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: SmallLoadingIndicator()),
      );

      final filePath = await BeneficiariesExportService.exportToPdf(
        beneficiaries,
      );

      // Close loading
      if (!mounted) return;
      Navigator.pop(context);

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تصدير التقرير بنجاح\n$filePath'),
          action: SnackBarAction(
            label: 'فتح',
            onPressed: () => BeneficiariesExportService.openFile(filePath),
          ),
          duration: const Duration(seconds: 5),
        ),
      );

      // Auto open file
      await BeneficiariesExportService.openFile(filePath);
    } catch (e) {
      // Close loading if still showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التصدير: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

// Statistics Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

// Beneficiary List Tile Widget
class _BeneficiaryListTile extends StatelessWidget {
  final Beneficiary beneficiary;

  const _BeneficiaryListTile({required this.beneficiary});

  @override
  Widget build(BuildContext context) {
    final syncColor = beneficiary.syncState == 'synced'
        ? Colors.green
        : beneficiary.syncState == 'pending'
            ? Colors.orange
            : Colors.red;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Text(
          beneficiary.fullName.substring(0, 1),
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        beneficiary.fullName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.credit_card, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'الرقم الوطني: ${beneficiary.idNumber}',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          if (beneficiary.phoneNumber != 0) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  beneficiary.phoneNumber.toString(),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
          if (beneficiary.createdAt != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'تاريخ التسجيل: ${DateFormat('yyyy-MM-dd').format(beneficiary.createdAt!)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: syncColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: syncColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              beneficiary.syncState == 'synced'
                  ? Icons.cloud_done
                  : beneficiary.syncState == 'pending'
                      ? Icons.cloud_queue
                      : Icons.cloud_off,
              size: 16,
              color: syncColor,
            ),
            const SizedBox(width: 6),
            Text(
              beneficiary.syncState == 'synced'
                  ? 'مزامن'
                  : beneficiary.syncState == 'pending'
                      ? 'معلق'
                      : 'فشل',
              style: TextStyle(
                color: syncColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        // TODO: Navigate to beneficiary details
      },
    );
  }
}
