import 'package:flutter/material.dart';

/// 📞 Contact Info Tab Widget
///
/// Contains: Phone Numbers, Governorate, District, Address,
/// Current Address, Address Before Displacement
class ContactInfoTab extends StatelessWidget {
  final TextEditingController phoneNumberController;
  final TextEditingController altPhoneNumberController;
  final TextEditingController governorateController;
  final TextEditingController districtController;
  final TextEditingController addressController;
  final TextEditingController currentAddressController;
  final TextEditingController addressBeforeDisplacementController;

  const ContactInfoTab({
    super.key,
    required this.phoneNumberController,
    required this.altPhoneNumberController,
    required this.governorateController,
    required this.districtController,
    required this.addressController,
    required this.currentAddressController,
    required this.addressBeforeDisplacementController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات الاتصال
          _buildSectionHeader('معلومات الاتصال', Icons.phone, colorScheme),
          const SizedBox(height: 16),

          TextField(
            controller: phoneNumberController,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              hintText: '07xxxxxxxxx',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: altPhoneNumberController,
            decoration: InputDecoration(
              labelText: 'رقم هاتف بديل',
              hintText: '07xxxxxxxxx',
              prefixIcon: const Icon(Icons.phone_android),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          // معلومات العنوان
          _buildSectionHeader(
            'معلومات العنوان',
            Icons.location_on,
            colorScheme,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: governorateController,
                  decoration: InputDecoration(
                    labelText: 'المحافظة',
                    hintText: 'بغداد',
                    prefixIcon: const Icon(Icons.map),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: districtController,
                  decoration: InputDecoration(
                    labelText: 'القضاء',
                    hintText: 'الكرخ',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: addressController,
            decoration: InputDecoration(
              labelText: 'العنوان',
              hintText: 'الشارع، المنطقة، رقم الدار',
              prefixIcon: const Icon(Icons.home),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textDirection: TextDirection.rtl,
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          // معلومات النزوح (إن وجدت)
          _buildSectionHeader(
            'معلومات إضافية',
            Icons.info_outline,
            colorScheme,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: currentAddressController,
            decoration: InputDecoration(
              labelText: 'العنوان الحالي',
              hintText: 'إذا كان مختلفاً عن العنوان الأصلي',
              prefixIcon: const Icon(Icons.place),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              helperText: 'للنازحين: العنوان الحالي في منطقة النزوح',
            ),
            textDirection: TextDirection.rtl,
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: addressBeforeDisplacementController,
            decoration: InputDecoration(
              labelText: 'العنوان قبل النزوح',
              hintText: 'العنوان الأصلي قبل النزوح',
              prefixIcon: const Icon(Icons.home_work),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              helperText: 'للنازحين: العنوان الأصلي قبل ترك المنزل',
            ),
            textDirection: TextDirection.rtl,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
