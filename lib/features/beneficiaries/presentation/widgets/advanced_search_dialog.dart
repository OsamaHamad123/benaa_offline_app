import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/list/filters_provider.dart';
import '../providers/list/beneficiaries_list_provider.dart';
import '../../../../core/utils/feedback_utils.dart';

/// 🔍 Advanced Search Dialog - بحث متقدم مع فلاتر متعددة
class AdvancedSearchDialog extends ConsumerStatefulWidget {
  const AdvancedSearchDialog({super.key});

  @override
  ConsumerState<AdvancedSearchDialog> createState() =>
      _AdvancedSearchDialogState();
}

class _AdvancedSearchDialogState extends ConsumerState<AdvancedSearchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _fileNumberController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedGender;
  String? _selectedMaritalStatus;
  int? _ageMin;
  int? _ageMax;
  final List<int> _selectedSections = [];

  @override
  void dispose() {
    _nameController.dispose();
    _nationalIdController.dispose();
    _fileNumberController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_formKey.currentState?.validate() ?? false) {
      final filters = ref.read(filtersProvider.notifier);

      // تطبيق البحث بالاسم
      if (_nameController.text.isNotEmpty) {
        filters.setSearchQuery(_nameController.text);
      }

      // في المستقبل يمكن إضافة فلاتر أخرى (gender, maritalStatus, etc)
      // حالياً نستخدم البحث الأساسي فقط

      // تحديث القائمة
      ref.read(beneficiariesListProvider.notifier).refresh();

      // إغلاق الـ Dialog
      Navigator.of(context).pop();

      HapticPatterns.success();
      VisualFeedback.showSuccess(context, 'تم تطبيق البحث المتقدم');
    }
  }

  void _clearFilters() {
    setState(() {
      _nameController.clear();
      _nationalIdController.clear();
      _fileNumberController.clear();
      _phoneController.clear();
      _selectedGender = null;
      _selectedMaritalStatus = null;
      _ageMin = null;
      _ageMax = null;
      _selectedSections.clear();
    });

    ref.read(filtersProvider.notifier).clearFilters();
    HapticPatterns.medium();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.search, size: 28, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Text(
                    'بحث متقدم',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Search Fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الاسم
                      _buildTextField(
                        controller: _nameController,
                        label: 'الاسم الكامل',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),

                      // الرقم الوطني
                      _buildTextField(
                        controller: _nationalIdController,
                        label: 'الرقم الوطني',
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // رقم الملف
                      _buildTextField(
                        controller: _fileNumberController,
                        label: 'رقم الملف',
                        icon: Icons.folder,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // رقم الهاتف
                      _buildTextField(
                        controller: _phoneController,
                        label: 'رقم الهاتف',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),

                      // الجنس
                      const Text(
                        'الجنس',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('ذكر'),
                            selected: _selectedGender == 'male',
                            onSelected: (selected) {
                              setState(() {
                                _selectedGender = selected ? 'male' : null;
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('أنثى'),
                            selected: _selectedGender == 'female',
                            onSelected: (selected) {
                              setState(() {
                                _selectedGender = selected ? 'female' : null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // الحالة الاجتماعية
                      const Text(
                        'الحالة الاجتماعية',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('أعزب/عزباء'),
                            selected: _selectedMaritalStatus == 'single',
                            onSelected: (selected) {
                              setState(() {
                                _selectedMaritalStatus = selected
                                    ? 'single'
                                    : null;
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('متزوج/ة'),
                            selected: _selectedMaritalStatus == 'married',
                            onSelected: (selected) {
                              setState(() {
                                _selectedMaritalStatus = selected
                                    ? 'married'
                                    : null;
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('أرمل/ة'),
                            selected: _selectedMaritalStatus == 'widowed',
                            onSelected: (selected) {
                              setState(() {
                                _selectedMaritalStatus = selected
                                    ? 'widowed'
                                    : null;
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('مطلق/ة'),
                            selected: _selectedMaritalStatus == 'divorced',
                            onSelected: (selected) {
                              setState(() {
                                _selectedMaritalStatus = selected
                                    ? 'divorced'
                                    : null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // العمر
                      const Text(
                        'العمر',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNumberField(
                              value: _ageMin,
                              label: 'من',
                              onChanged: (value) {
                                setState(() => _ageMin = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildNumberField(
                              value: _ageMax,
                              label: 'إلى',
                              onChanged: (value) {
                                setState(() => _ageMax = value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear_all),
                      label: const Text('مسح الكل'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _performSearch,
                      icon: const Icon(Icons.search),
                      label: const Text('بحث'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildNumberField({
    required int? value,
    required String label,
    required ValueChanged<int?> onChanged,
  }) {
    return TextFormField(
      initialValue: value?.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (text) {
        onChanged(int.tryParse(text));
      },
    );
  }
}
