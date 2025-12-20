import 'package:flutter/material.dart';
import 'autocomplete_field.dart';

/// 📚 Autocomplete Usage Examples
///
/// This file demonstrates how to use the autocomplete widgets

class AutocompleteExamples extends StatefulWidget {
  const AutocompleteExamples({super.key});

  @override
  State<AutocompleteExamples> createState() => _AutocompleteExamplesState();
}

class _AutocompleteExamplesState extends State<AutocompleteExamples> {
  final _districtController = TextEditingController();
  final _subDistrictController = TextEditingController();
  final _organizationController = TextEditingController();

  String? _selectedDistrict;
  String? _selectedSubDistrict;
  String? _selectedOrganization;

  @override
  void dispose() {
    _districtController.dispose();
    _subDistrictController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أمثلة Autocomplete')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Example 1: District selection
          const Text(
            'مثال 1: اختيار القضاء',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DistrictAutocomplete(
            controller: _districtController,
            onSelected: (district) {
              setState(() {
                _selectedDistrict = district;
                // Clear sub-district when district changes
                _selectedSubDistrict = null;
                _subDistrictController.clear();
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('تم اختيار: $district')));
            },
          ),

          if (_selectedDistrict != null) ...[
            const SizedBox(height: 8),
            Text(
              'القضاء المختار: $_selectedDistrict',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Example 2: Sub-district (depends on district)
          const Text(
            'مثال 2: اختيار الناحية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SubDistrictAutocomplete(
            controller: _subDistrictController,
            parentDistrict: _selectedDistrict,
            onSelected: (subDistrict) {
              setState(() => _selectedSubDistrict = subDistrict);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم اختيار: $subDistrict')),
              );
            },
          ),

          if (_selectedDistrict == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'ℹ️ اختر القضاء أولاً',
                style: TextStyle(color: Colors.orange),
              ),
            ),

          if (_selectedSubDistrict != null) ...[
            const SizedBox(height: 8),
            Text(
              'الناحية المختارة: $_selectedSubDistrict',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Example 3: Organization
          const Text(
            'مثال 3: اختيار الجمعية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          OrganizationAutocomplete(
            controller: _organizationController,
            onSelected: (org) {
              setState(() => _selectedOrganization = org);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('تم اختيار: $org')));
            },
          ),

          if (_selectedOrganization != null) ...[
            const SizedBox(height: 8),
            Text(
              'الجمعية المختارة: $_selectedOrganization',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Summary
          if (_selectedDistrict != null ||
              _selectedSubDistrict != null ||
              _selectedOrganization != null) ...[
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'ملخص الاختيارات:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_selectedDistrict != null)
              _buildSummaryItem('القضاء', _selectedDistrict!),
            if (_selectedSubDistrict != null)
              _buildSummaryItem('الناحية', _selectedSubDistrict!),
            if (_selectedOrganization != null)
              _buildSummaryItem('الجمعية', _selectedOrganization!),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}

/// 📝 Real Form Example with Autocomplete
class BeneficiaryLocationForm extends StatefulWidget {
  const BeneficiaryLocationForm({super.key});

  @override
  State<BeneficiaryLocationForm> createState() =>
      _BeneficiaryLocationFormState();
}

class _BeneficiaryLocationFormState extends State<BeneficiaryLocationForm> {
  final _formKey = GlobalKey<FormState>();

  final _districtController = TextEditingController();
  final _subDistrictController = TextEditingController();
  final _organizationController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedDistrict;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('معلومات الموقع')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DistrictAutocomplete(
              controller: _districtController,
              onSelected: (district) {
                setState(() {
                  _selectedDistrict = district;
                  _subDistrictController.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            SubDistrictAutocomplete(
              controller: _subDistrictController,
              parentDistrict: _selectedDistrict,
              onSelected: (_) {},
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'العنوان التفصيلي',
                hintText: 'المحلة، الزقاق، رقم الدار',
                prefixIcon: const Icon(Icons.home),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            OrganizationAutocomplete(
              controller: _organizationController,
              onSelected: (_) {},
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _showSummary();
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ملخص البيانات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('القضاء: ${_districtController.text}'),
            Text('الناحية: ${_subDistrictController.text}'),
            Text('العنوان: ${_addressController.text}'),
            Text('الجمعية: ${_organizationController.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

/// 🎯 Advanced Example: Custom Type
class CityData {
  final String name;
  final String nameEn;
  final int population;

  const CityData({
    required this.name,
    required this.nameEn,
    required this.population,
  });

  @override
  String toString() => name;
}

class CustomTypeExample extends StatefulWidget {
  const CustomTypeExample({super.key});

  @override
  State<CustomTypeExample> createState() => _CustomTypeExampleState();
}

class _CustomTypeExampleState extends State<CustomTypeExample> {
  static const cities = [
    CityData(name: 'بغداد', nameEn: 'Baghdad', population: 7000000),
    CityData(name: 'البصرة', nameEn: 'Basra', population: 2500000),
    CityData(name: 'الموصل', nameEn: 'Mosul', population: 1800000),
    CityData(name: 'أربيل', nameEn: 'Erbil', population: 1500000),
  ];

  CityData? _selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مثال نوع مخصص')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AutocompleteField<CityData>(
              label: 'اختر مدينة',
              suggestions: cities,
              displayStringForOption: (city) => '${city.name} (${city.nameEn})',
              onSelected: (city) {
                setState(() => _selectedCity = city);
              },
            ),
            if (_selectedCity != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCity!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('الاسم الإنجليزي: ${_selectedCity!.nameEn}'),
                      Text(
                        'عدد السكان: ${_selectedCity!.population.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} نسمة',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
