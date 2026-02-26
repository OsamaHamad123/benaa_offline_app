import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';

/// 🔍 Advanced Search Filters Widget
class AdvancedSearchFilters extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final VoidCallback? onSaveSearch;

  const AdvancedSearchFilters({
    required this.onApplyFilters,
    super.key,
    this.onSaveSearch,
  });

  @override
  ConsumerState<AdvancedSearchFilters> createState() => _AdvancedSearchFiltersState();
}

class _AdvancedSearchFiltersState extends ConsumerState<AdvancedSearchFilters> {
  final List<String> _selectedGovernorates = [];
  final List<String> _selectedStatuses = [];
  final List<String> _selectedCategories = [];
  String? _ageRange;
  String? _gender;

  static const List<String> _fallbackGovernorates = [
    'دمشق',
    'ريف دمشق',
    'حلب',
    'حمص',
    'حماة',
    'اللاذقية',
    'طرطوس',
    'السويداء',
    'درعا',
    'القنيطرة',
    'دير الزور',
    'الرقة',
    'الحسكة',
    'إدلب',
  ];

  static const List<String> _fallbackCategories = [
    'عائلات',
    'أطفال',
    'مسنين',
    'ذوي احتياجات خاصة',
    'أيتام',
    'نازحين',
  ];

  final List<String> _statuses = ['نشط', 'معلق', 'محذوف', 'قيد المراجعة'];

  @override
  Widget build(BuildContext context) {
    final governoratesAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.governorate),
    );
    final sectionTaxonomiesAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.section),
    );
    final categoryTaxonomiesAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.category),
    );

    final governorates = _resolveLabels(governoratesAsync, _fallbackGovernorates);
    final categories = _resolveMergedLabels(
      sectionTaxonomiesAsync,
      categoryTaxonomiesAsync,
      _fallbackCategories,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'فلاتر متقدمة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  if (widget.onSaveSearch != null)
                    TextButton.icon(
                      onPressed: widget.onSaveSearch,
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('حفظ البحث'),
                    ),
                  Semantics(
                    label: 'مسح جميع الفلاتر',
                    button: true,
                    child: IconButton(
                      onPressed: _clearAllFilters,
                      icon: const Icon(Icons.clear_all),
                      tooltip: 'مسح الكل',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),

          // Governorates Filter
          const Text(
            'المحافظات',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: governorates.map((gov) {
              final isSelected = _selectedGovernorates.contains(gov);
              return FilterChip(
                label: Text(gov),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedGovernorates.add(gov);
                    } else {
                      _selectedGovernorates.remove(gov);
                    }
                  });
                },
                selectedColor: Colors.blue.shade100,
                checkmarkColor: Colors.blue.shade700,
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Status Filter
          const Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _statuses.map((status) {
              final isSelected = _selectedStatuses.contains(status);
              return ChoiceChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedStatuses.add(status);
                    } else {
                      _selectedStatuses.remove(status);
                    }
                  });
                },
                selectedColor: _getStatusColor(status).withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? _getStatusColor(status) : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Categories Filter
          const Text('الفئات', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: categories.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                  });
                },
                selectedColor: Colors.green.shade100,
                checkmarkColor: Colors.green.shade700,
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Age Range & Gender Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الفئة العمرية',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _ageRange,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      hint: const Text('اختر'),
                      items: [
                        '0-5',
                        '6-12',
                        '13-18',
                        '19-30',
                        '31-50',
                        '51-65',
                        '65+',
                      ].map((range) {
                        return DropdownMenuItem(
                          value: range,
                          child: Text(range),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _ageRange = value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الجنس',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'male',
                          label: Text('ذكر'),
                          icon: Icon(Icons.male, size: 18),
                        ),
                        ButtonSegment(
                          value: 'female',
                          label: Text('أنثى'),
                          icon: Icon(Icons.female, size: 18),
                        ),
                      ],
                      selected: _gender != null ? {_gender!} : {},
                      onSelectionChanged: (Set<String> selected) {
                        setState(() {
                          _gender = selected.isNotEmpty ? selected.first : null;
                        });
                      },
                      emptySelectionAllowed: true,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Semantics(
                label: 'إعادة تعيين جميع الفلاتر',
                button: true,
                child: OutlinedButton(
                  onPressed: _clearAllFilters,
                  child: const Text('إعادة تعيين'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.search),
                label: Text('تطبيق (${_getActiveFiltersCount()})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _resolveLabels(
    AsyncValue<List<taxonomy_domain.Taxonomy>> async,
    List<String> fallback,
  ) {
    final labels = async.maybeWhen(
      data: (items) =>
          items.map((item) => item.label.trim()).where((label) => label.isNotEmpty).toList(growable: false),
      orElse: () => const <String>[],
    );

    return labels.isNotEmpty ? labels : fallback;
  }

  List<String> _resolveMergedLabels(
    AsyncValue<List<taxonomy_domain.Taxonomy>> primary,
    AsyncValue<List<taxonomy_domain.Taxonomy>> secondary,
    List<String> fallback,
  ) {
    final primaryLabels = _resolveLabels(primary, const <String>[]);
    final secondaryLabels = _resolveLabels(secondary, const <String>[]);
    final merged = <String>{...primaryLabels, ...secondaryLabels};
    if (merged.isNotEmpty) {
      return merged.toList(growable: false);
    }
    return fallback;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'نشط':
        return Colors.green;
      case 'معلق':
        return Colors.orange;
      case 'محذوف':
        return Colors.red;
      case 'قيد المراجعة':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_selectedGovernorates.isNotEmpty) count++;
    if (_selectedStatuses.isNotEmpty) count++;
    if (_selectedCategories.isNotEmpty) count++;
    if (_ageRange != null) count++;
    if (_gender != null) count++;
    return count;
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'governorates': _selectedGovernorates,
      'statuses': _selectedStatuses,
      'categories': _selectedCategories,
      'ageRange': _ageRange,
      'gender': _gender,
    };
    widget.onApplyFilters(filters);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedGovernorates.clear();
      _selectedStatuses.clear();
      _selectedCategories.clear();
      _ageRange = null;
      _gender = null;
    });
  }
}

/// 💾 Saved Search Item
class SavedSearchItem {
  final String id;
  final String name;
  final Map<String, dynamic> filters;
  final DateTime createdAt;

  const SavedSearchItem({
    required this.id,
    required this.name,
    required this.filters,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filters': filters,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedSearchItem.fromJson(Map<String, dynamic> json) {
    return SavedSearchItem(
      id: json['id'] as String,
      name: json['name'] as String,
      filters: json['filters'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
