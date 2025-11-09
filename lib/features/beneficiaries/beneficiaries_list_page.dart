import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../data/db/drift_database.dart';
import '../../core/utils/responsive_utils.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المستفيدين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: ResponsiveUtils.getResponsivePadding(context),
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
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
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
                        });
                      },
                    ),
                  if (_selectedGovernorate != 'all')
                    Chip(
                      label: Text(_selectedGovernorate),
                      onDeleted: () {
                        setState(() {
                          _selectedGovernorate = 'all';
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
                  return const Center(child: CircularProgressIndicator());
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
                      ],
                    ),
                  );
                }

                final beneficiaries = snapshot.data ?? [];

                if (beneficiaries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'لا يوجد مستفيدين'
                              : 'لا توجد نتائج للبحث',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    itemCount: beneficiaries.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final beneficiary = beneficiaries[index];
                      return _BeneficiaryCard(beneficiary: beneficiary);
                    },
                  ),
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
    var beneficiaries = await database.searchBeneficiaries(_searchQuery);

    // Apply category filter
    if (_selectedCategory != 'all') {
      beneficiaries = beneficiaries
          .where((b) => b.category == _selectedCategory)
          .toList();
    }

    // Apply governorate filter
    if (_selectedGovernorate != 'all') {
      beneficiaries = beneficiaries
          .where((b) => b.governorate == _selectedGovernorate)
          .toList();
    }

    return beneficiaries;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية النتائج'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الفئة', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('الكل'),
                  selected: _selectedCategory == 'all',
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = 'all';
                    });
                    Navigator.pop(context);
                  },
                ),
                ChoiceChip(
                  label: const Text('أيتام'),
                  selected: _selectedCategory == 'orphan',
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = 'orphan';
                    });
                    Navigator.pop(context);
                  },
                ),
                ChoiceChip(
                  label: const Text('فقراء'),
                  selected: _selectedCategory == 'poor',
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = 'poor';
                    });
                    Navigator.pop(context);
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
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
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
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'all';
                _selectedGovernorate = 'all';
              });
              Navigator.pop(context);
            },
            child: const Text('إعادة تعيين'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'orphan':
        return 'أيتام';
      case 'poor':
        return 'فقراء';
      default:
        return category;
    }
  }
}

class _BeneficiaryCard extends StatelessWidget {
  final Beneficiary beneficiary;

  const _BeneficiaryCard({required this.beneficiary});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      beneficiary.gender == 'male'
                          ? Icons.person
                          : Icons.person_outline,
                      color: Theme.of(context).colorScheme.primary,
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
                  ),
                  _InfoChip(
                    icon: Icons.category_outlined,
                    label: _getCategoryLabel(beneficiary.category),
                  ),
                  if (beneficiary.age != null)
                    _InfoChip(
                      icon: Icons.cake_outlined,
                      label: '${beneficiary.age} سنة',
                    ),
                  if (beneficiary.phoneNumber != null && 
                      beneficiary.phoneNumber!.isNotEmpty)
                    _InfoChip(
                      icon: Icons.phone_outlined,
                      label: beneficiary.phoneNumber!,
                    ),
                  if (beneficiary.district != null && 
                      beneficiary.district!.isNotEmpty)
                    _InfoChip(
                      icon: Icons.location_city_outlined,
                      label: beneficiary.district!,
                    ),
                  if (beneficiary.familySize != null)
                    _InfoChip(
                      icon: Icons.family_restroom_outlined,
                      label: '${beneficiary.familySize} أفراد',
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
      case 'poor':
        return 'فقير';
      default:
        return category;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
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
