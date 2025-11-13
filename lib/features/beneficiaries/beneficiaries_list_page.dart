import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../data/db/drift_database.dart';
import '../../core/utils/responsive_utils.dart';
import '../../theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

class BeneficiariesListPage extends ConsumerStatefulWidget {
  const BeneficiariesListPage({super.key});

  @override
  ConsumerState<BeneficiariesListPage> createState() =>
      _BeneficiariesListPageState();
}

class _BeneficiariesListPageState extends ConsumerState<BeneficiariesListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedGovernorate = 'all';
  String _sortBy = 'name';
  bool _sortAscending = true;
  List<Beneficiary>? _cachedBeneficiaries;
  String _cacheKey = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _currentCacheKey =>
      '$_searchQuery|$_selectedCategory|$_selectedGovernorate|$_sortBy|$_sortAscending';

  int get _activeFiltersCount {
    int count = 0;
    if (_selectedCategory != 'all') count++;
    if (_selectedGovernorate != 'all') count++;
    return count;
  }

  String get _sortLabel {
    switch (_sortBy) {
      case 'name':
        return 'الاسم';
      case 'date':
        return 'التاريخ';
      case 'fileNo':
        return 'رقم الملف';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('قائمة المستفيدين'),
            if (_sortBy != 'name')
              Text(
                'مرتب حسب: $_sortLabel ${_sortAscending ? '↑' : '↓'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.sort),
                tooltip: 'ترتيب',
                onPressed: _showSortOptions,
              ),
              if (_sortBy != 'name')
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
            ],
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'تصفية',
                onPressed: _showFilterBottomSheet,
              ),
              if (_activeFiltersCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        _activeFiltersCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Summary
          _buildStatisticsSummary(database),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم، الرقم الوطني، أو رقم الملف...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _cachedBeneficiaries = null;
                });
              },
            ),
          ),

          // Filter Chips
          if (_selectedCategory != 'all' || _selectedGovernorate != 'all')
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 16.0,
                  tablet: 20.0,
                  desktop: 24.0,
                ),
              ),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedCategory != 'all')
                    Chip(
                      label: Text(_getCategoryLabel(_selectedCategory)),
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = 'all';
                          _cachedBeneficiaries = null;
                        });
                      },
                    ),
                  if (_selectedGovernorate != 'all')
                    Chip(
                      label: Text(_selectedGovernorate),
                      onDeleted: () {
                        setState(() {
                          _selectedGovernorate = 'all';
                          _cachedBeneficiaries = null;
                        });
                      },
                    ),
                ],
              ),
            ),

          // Beneficiaries List
          Expanded(
            child: FutureBuilder<List<Beneficiary>>(
              future: _loadBeneficiaries(database),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingShimmer();
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('حدث خطأ: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                final beneficiaries = snapshot.data ?? [];

                if (beneficiaries.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  children: [
                    // Results Count Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'عدد النتائج: ${beneficiaries.length}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Spacer(),
                          if (_sortBy != 'name')
                            Text(
                              '$_sortLabel ${_sortAscending ? '↑' : '↓'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Beneficiaries List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {});
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                        },
                        child: ListView.builder(
                          itemCount: beneficiaries.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final beneficiary = beneficiaries[index];
                            return Dismissible(
                              key: Key(beneficiary.id.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('تأكيد الحذف'),
                                        content: Text(
                                          'هل أنت متأكد من حذف ${beneficiary.fullName}؟',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('إلغاء'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('حذف'),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;
                              },
                              onDismissed: (direction) {
                                _deleteBeneficiary(beneficiary);
                              },
                              child: _BeneficiaryCard(
                                beneficiary: beneficiary,
                                onDelete: () => _deleteBeneficiary(beneficiary),
                                onEdit: () => context.push(
                                  '/beneficiaries/edit/${beneficiary.id}',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/beneficiaries/add'),
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة مستفيد'),
      ),
    );
  }

  Future<List<Beneficiary>> _loadBeneficiaries(AppDatabase database) async {
    final cacheKey = _currentCacheKey;
    if (_cacheKey == cacheKey && _cachedBeneficiaries != null) {
      return _cachedBeneficiaries!;
    }

    try {
      var beneficiaries = await database.searchBeneficiaries(_searchQuery);

      if (_selectedCategory != 'all') {
        beneficiaries = beneficiaries
            .where((b) => b.category == _selectedCategory)
            .toList();
      }

      if (_selectedGovernorate != 'all') {
        beneficiaries = beneficiaries
            .where((b) => b.governorate == _selectedGovernorate)
            .toList();
      }

      beneficiaries.sort((a, b) {
        int comparison;
        switch (_sortBy) {
          case 'name':
            comparison = a.fullName.compareTo(b.fullName);
          case 'date':
            comparison = a.createdAt.compareTo(b.createdAt);
          case 'fileNo':
            comparison = a.fileNo.compareTo(b.fileNo);
          default:
            comparison = 0;
        }
        return _sortAscending ? comparison : -comparison;
      });

      _cachedBeneficiaries = beneficiaries;
      _cacheKey = cacheKey;
      return beneficiaries;
    } catch (e) {
      rethrow;
    }
  }

  Widget _buildStatisticsSummary(AppDatabase database) {
    return FutureBuilder<Map<String, int>>(
      future: _getStatistics(database),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data!;
        final total = stats['total'] ?? 0;
        final pending = stats['pending'] ?? 0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.people,
                  label: 'الإجمالي',
                  value: total.toString(),
                  color: AppColors.primary,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Expanded(
                child: _StatItem(
                  icon: Icons.sync,
                  label: 'معلق',
                  value: pending.toString(),
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, int>> _getStatistics(AppDatabase database) async {
    final results = await Future.wait([
      database.countBeneficiaries(),
      database.countPendingSync(),
    ]);

    return {'total': results[0], 'pending': results[1]};
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ترتيب حسب',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('الاسم'),
              trailing: _sortBy == 'name'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() {
                  if (_sortBy == 'name') {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortBy = 'name';
                    _sortAscending = true;
                  }
                  _cachedBeneficiaries = null;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('تاريخ الإضافة'),
              trailing: _sortBy == 'date'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() {
                  if (_sortBy == 'date') {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortBy = 'date';
                    _sortAscending = false;
                  }
                  _cachedBeneficiaries = null;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.numbers),
              title: const Text('رقم الملف'),
              trailing: _sortBy == 'fileNo'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() {
                  if (_sortBy == 'fileNo') {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortBy = 'fileNo';
                    _sortAscending = true;
                  }
                  _cachedBeneficiaries = null;
                });
                Navigator.pop(context);
              },
            ),
            // مسافة للـ handle bar
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تصفية النتائج',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'all';
                        _selectedGovernorate = 'all';
                        _cachedBeneficiaries = null;
                      });
                      setModalState(() {});
                    },
                    child: const Text('إعادة تعيين'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'الفئة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('الكل'),
                    selected: _selectedCategory == 'all',
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = 'all';
                        _cachedBeneficiaries = null;
                      });
                      setModalState(() {});
                    },
                  ),
                  FilterChip(
                    label: const Text('أيتام'),
                    selected: _selectedCategory == 'orphan',
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = 'orphan';
                        _cachedBeneficiaries = null;
                      });
                      setModalState(() {});
                    },
                  ),
                  FilterChip(
                    label: const Text('أرامل'),
                    selected: _selectedCategory == 'widow',
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = 'widow';
                        _cachedBeneficiaries = null;
                      });
                      setModalState(() {});
                    },
                  ),
                  FilterChip(
                    label: const Text('فقراء'),
                    selected: _selectedCategory == 'poor',
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = 'poor';
                        _cachedBeneficiaries = null;
                      });
                      setModalState(() {});
                    },
                  ),
                  FilterChip(
                    label: const Text('معاقين'),
                    selected: _selectedCategory == 'disabled',
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = 'disabled';
                        _cachedBeneficiaries = null;
                      });
                      setModalState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'المحافظة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGovernorate,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('الكل')),
                  DropdownMenuItem(value: 'بغداد', child: Text('بغداد')),
                  DropdownMenuItem(value: 'البصرة', child: Text('البصرة')),
                  DropdownMenuItem(value: 'نينوى', child: Text('نينوى')),
                  DropdownMenuItem(value: 'الأنبار', child: Text('الأنبار')),
                  DropdownMenuItem(value: 'ديالى', child: Text('ديالى')),
                  DropdownMenuItem(value: 'كربلاء', child: Text('كربلاء')),
                  DropdownMenuItem(value: 'النجف', child: Text('النجف')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGovernorate = value ?? 'all';
                    _cachedBeneficiaries = null;
                  });
                  setModalState(() {});
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('تطبيق'),
                ),
              ),
              // مسافة للـ handle bar
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    // مصفوفة بارتفاعات متنوعة لجعل التحميل أكثر واقعية
    final heights = [180.0, 220.0, 200.0, 190.0, 210.0];
    final chipCounts = [2, 4, 3, 3, 5]; // عدد مختلف من الـ chips

    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: heights[index],
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar shimmer
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name shimmer
                        Container(
                          width: 150 + (index * 20.0),
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // File number shimmer
                        Container(
                          width: 100 + (index * 10.0),
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Sync status shimmer
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Info chips shimmer
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  chipCounts[index],
                  (chipIndex) => Container(
                    width: 70 + (chipIndex * 15.0),
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
      title: _searchQuery.isEmpty
          ? 'لا يوجد مستفيدين بعد'
          : 'لا توجد نتائج للبحث',
      message: _searchQuery.isEmpty
          ? 'ابدأ بإضافة مستفيدين جدد'
          : 'جرب تغيير كلمات البحث',
      actionLabel: _searchQuery.isEmpty ? 'إضافة مستفيد جديد' : null,
      onAction: _searchQuery.isEmpty
          ? () => context.push('/beneficiaries/add')
          : null,
    );
  }

  Future<void> _deleteBeneficiary(Beneficiary beneficiary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ${beneficiary.fullName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final database = ref.read(databaseProvider);
        await database.deleteBeneficiary(beneficiary.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم الحذف بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {}); // Refresh list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل الحذف: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'orphan':
        return 'أيتام';
      case 'widow':
        return 'أرامل';
      case 'poor':
        return 'فقراء';
      case 'disabled':
        return 'معاقين';
      default:
        return category;
    }
  }
}

// Statistics Item Widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}

class _BeneficiaryCard extends StatelessWidget {
  final Beneficiary beneficiary;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const _BeneficiaryCard({
    required this.beneficiary,
    this.onDelete,
    this.onEdit,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'orphan':
        return Colors.blue;
      case 'widow':
        return Colors.purple;
      case 'poor':
        return Colors.orange;
      case 'disabled':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(beneficiary.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: categoryColor.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: () => context.push('/beneficiaries/${beneficiary.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: categoryColor.withOpacity(0.1),
                    child: Icon(
                      beneficiary.gender == 'male'
                          ? Icons.person
                          : Icons.person_outline,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          beneficiary.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'رقم الملف: ${beneficiary.fileNo}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SyncStatusBadge(syncState: beneficiary.syncState),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          context.push('/beneficiaries/${beneficiary.id}');
                          break;
                        case 'edit':
                          if (onEdit != null) {
                            onEdit!();
                          } else {
                            context.push(
                              '/beneficiaries/edit/${beneficiary.id}',
                            );
                          }
                          break;
                        case 'delete':
                          if (onDelete != null) onDelete!();
                          break;
                        case 'share':
                          // يمكن إضافة وظيفة المشاركة لاحقاً
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('سيتم إضافة المشاركة قريباً'),
                            ),
                          );
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 8),
                            Text('عرض التفاصيل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 20),
                            SizedBox(width: 8),
                            Text('مشاركة'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('حذف', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: beneficiary.governorate,
                    color: Colors.grey[700]!,
                  ),
                  _InfoChip(
                    icon: Icons.category_outlined,
                    label: _getCategoryLabel(beneficiary.category),
                    color: categoryColor,
                  ),
                  if (beneficiary.age != null)
                    _InfoChip(
                      icon: Icons.cake_outlined,
                      label: '${beneficiary.age} سنة',
                      color: Colors.grey[700]!,
                    ),
                  if (beneficiary.phoneNumber != null &&
                      beneficiary.phoneNumber!.isNotEmpty)
                    _InfoChip(
                      icon: Icons.phone_outlined,
                      label: beneficiary.phoneNumber!,
                      color: Colors.grey[700]!,
                    ),
                  if (beneficiary.district != null &&
                      beneficiary.district!.isNotEmpty)
                    _InfoChip(
                      icon: Icons.location_city_outlined,
                      label: beneficiary.district!,
                      color: Colors.grey[700]!,
                    ),
                  if (beneficiary.familySize != null)
                    _InfoChip(
                      icon: Icons.family_restroom_outlined,
                      label: '${beneficiary.familySize} أفراد',
                      color: Colors.grey[700]!,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'orphan':
        return 'يتيم';
      case 'widow':
        return 'أرملة';
      case 'poor':
        return 'فقير';
      case 'disabled':
        return 'معاق';
      default:
        return category;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Colors.grey[700]!;
    final backgroundColor = color?.withOpacity(0.1) ?? Colors.grey[100]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: color != null
            ? Border.all(color: color!.withOpacity(0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: chipColor,
              fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncStatusBadge extends StatelessWidget {
  final String syncState;

  const _SyncStatusBadge({required this.syncState});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (syncState) {
      case 'synced':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'failed':
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.orange;
        icon = Icons.sync;
    }

    return Icon(icon, color: color, size: 20);
  }
}
