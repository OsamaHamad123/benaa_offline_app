import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/search_filter.dart' show AdvancedSearchFilter;
import '../providers/search_filter_provider.dart';

/// 🎛️ Advanced Filters Panel
///
/// لوحة الفلاتر المتقدمة

class AdvancedFiltersPanel extends ConsumerStatefulWidget {
  final VoidCallback? onApply;
  final VoidCallback? onClose;

  const AdvancedFiltersPanel({
    super.key,
    this.onApply,
    this.onClose,
  });

  @override
  ConsumerState<AdvancedFiltersPanel> createState() =>
      _AdvancedFiltersPanelState();
}

class _AdvancedFiltersPanelState extends ConsumerState<AdvancedFiltersPanel> {
  late TextEditingController _nameController;
  late TextEditingController _nationalIdController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;

  int? _minAge;
  int? _maxAge;
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedHealthStatus;
  int? _minFamilySize;
  int? _maxFamilySize;
  DateTime? _registrationStartDate;
  DateTime? _registrationEndDate;
  bool? _hasSponsorship;
  List<String> _selectedDocTypes = [];

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(searchFilterProvider).currentFilter;

    _nameController = TextEditingController(text: currentFilter.name);
    _nationalIdController =
        TextEditingController(text: currentFilter.nationalId);
    _phoneController = TextEditingController(text: currentFilter.phoneNumber);
    _cityController = TextEditingController(text: currentFilter.city);
    _districtController = TextEditingController(text: currentFilter.district);

    _minAge = currentFilter.minAge;
    _maxAge = currentFilter.maxAge;
    _selectedGender = currentFilter.gender;
    _selectedMaritalStatus = currentFilter.maritalStatus;
    _selectedHealthStatus = currentFilter.healthStatus;
    _minFamilySize = currentFilter.minFamilySize;
    _maxFamilySize = currentFilter.maxFamilySize;
    _registrationStartDate = currentFilter.registrationStartDate;
    _registrationEndDate = currentFilter.registrationEndDate;
    _hasSponsorship = currentFilter.hasSponsorship;
    _selectedDocTypes = currentFilter.documentTypes ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filter = AdvancedSearchFilter(
      name: _nameController.text.isEmpty ? null : _nameController.text,
      nationalId: _nationalIdController.text.isEmpty
          ? null
          : _nationalIdController.text,
      phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
      city: _cityController.text.isEmpty ? null : _cityController.text,
      district:
          _districtController.text.isEmpty ? null : _districtController.text,
      minAge: _minAge,
      maxAge: _maxAge,
      gender: _selectedGender,
      maritalStatus: _selectedMaritalStatus,
      healthStatus: _selectedHealthStatus,
      minFamilySize: _minFamilySize,
      maxFamilySize: _maxFamilySize,
      registrationStartDate: _registrationStartDate,
      registrationEndDate: _registrationEndDate,
      hasSponsorship: _hasSponsorship,
      documentTypes: _selectedDocTypes.isEmpty ? null : _selectedDocTypes,
    );

    ref.read(searchFilterProvider.notifier).updateFilter(filter);
    widget.onApply?.call();
  }

  void _clearFilters() {
    setState(() {
      _nameController.clear();
      _nationalIdController.clear();
      _phoneController.clear();
      _cityController.clear();
      _districtController.clear();
      _minAge = null;
      _maxAge = null;
      _selectedGender = null;
      _selectedMaritalStatus = null;
      _selectedHealthStatus = null;
      _minFamilySize = null;
      _maxFamilySize = null;
      _registrationStartDate = null;
      _registrationEndDate = null;
      _hasSponsorship = null;
      _selectedDocTypes = [];
    });

    ref.read(searchFilterProvider.notifier).clearFilter();
  }

  void _showSaveFilterDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حفظ الفلتر', textDirection: TextDirection.rtl),
        content: TextField(
          controller: nameController,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            labelText: 'اسم الفلتر',
            hintText: 'مثال: مستفيدين بدون كفالات',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _applyFilters();
                ref
                    .read(searchFilterProvider.notifier)
                    .saveCurrentFilter(nameController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ الفلتر بنجاح')),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
                  onPressed: widget.onClose,
                ),
                Expanded(
                  child: Text(
                    'الفلاتر المتقدمة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.save, color: Colors.white, size: 24.sp),
                  onPressed: _showSaveFilterDialog,
                  tooltip: 'حفظ الفلتر',
                ),
              ],
            ),
          ),

          // Filters Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Basic Info Section
                  _buildSectionTitle('المعلومات الأساسية'),
                  _buildTextField('الاسم', _nameController, Icons.person),
                  SizedBox(height: 12.h),
                  _buildTextField(
                      'رقم الهوية', _nationalIdController, Icons.badge),
                  SizedBox(height: 12.h),
                  _buildTextField('رقم الهاتف', _phoneController, Icons.phone),

                  SizedBox(height: 24.h),

                  // Location Section
                  _buildSectionTitle('الموقع'),
                  _buildTextField(
                      'المدينة', _cityController, Icons.location_city),
                  SizedBox(height: 12.h),
                  _buildTextField(
                      'الحي', _districtController, Icons.location_on),

                  SizedBox(height: 24.h),

                  // Age Range Section
                  _buildSectionTitle('نطاق العمر'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField('من', _minAge, (value) {
                          setState(() => _minAge = value);
                        }),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildNumberField('إلى', _maxAge, (value) {
                          setState(() => _maxAge = value);
                        }),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Gender Section
                  _buildSectionTitle('الجنس'),
                  _buildDropdown(
                    _selectedGender,
                    ['ذكر', 'أنثى'],
                    (value) => setState(() => _selectedGender = value),
                    'اختر الجنس',
                  ),

                  SizedBox(height: 24.h),

                  // Marital Status Section
                  _buildSectionTitle('الحالة الاجتماعية'),
                  _buildDropdown(
                    _selectedMaritalStatus,
                    ['أعزب', 'متزوج', 'مطلق', 'أرمل'],
                    (value) => setState(() => _selectedMaritalStatus = value),
                    'اختر الحالة',
                  ),

                  SizedBox(height: 24.h),

                  // Health Status Section
                  _buildSectionTitle('الحالة الصحية'),
                  _buildDropdown(
                    _selectedHealthStatus,
                    ['سليم', 'مريض', 'معاق', 'مزمن'],
                    (value) => setState(() => _selectedHealthStatus = value),
                    'اختر الحالة',
                  ),

                  SizedBox(height: 24.h),

                  // Family Size Section
                  _buildSectionTitle('حجم الأسرة'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField('من', _minFamilySize, (value) {
                          setState(() => _minFamilySize = value);
                        }),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child:
                            _buildNumberField('إلى', _maxFamilySize, (value) {
                          setState(() => _maxFamilySize = value);
                        }),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Sponsorship Section
                  _buildSectionTitle('الكفالة'),
                  _buildSwitchTile(
                    'لديه كفالة',
                    _hasSponsorship ?? false,
                    (value) => setState(() => _hasSponsorship = value),
                  ),

                  SizedBox(height: 80.h), // Space for buttons
                ],
              ),
            ),
          ),

          // Bottom Buttons
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'مسح الكل',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'تطبيق الفلاتر',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    int? value,
    Function(int?) onChanged,
  ) {
    final controller = TextEditingController(text: value?.toString() ?? '');

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textDirection: TextDirection.rtl,
      onChanged: (text) {
        onChanged(int.tryParse(text));
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String? value,
    List<String> items,
    Function(String?) onChanged,
    String hint,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, textDirection: TextDirection.rtl),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SwitchListTile(
        title: Text(title, textDirection: TextDirection.rtl),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
