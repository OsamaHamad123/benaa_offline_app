import 'package:benaa_offline_app/core/theme/app_dimensions.dart';
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
      padding: AppDimensions.paddingMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات الاتصال
          _buildSectionHeader('معلومات الاتصال', Icons.phone, colorScheme),
          SizedBox(height: AppDimensions.md),

          TextField(
            controller: phoneNumberController,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              hintText: '07xxxxxxxxx',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: AppDimensions.md),

          TextField(
            controller: altPhoneNumberController,
            decoration: InputDecoration(
              labelText: 'رقم هاتف بديل',
              hintText: '07xxxxxxxxx',
              prefixIcon: const Icon(Icons.phone_android),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: AppDimensions.lg),

          // معلومات العنوان
          _buildSectionHeader(
            'معلومات العنوان',
            Icons.location_on,
            colorScheme,
          ),
          SizedBox(height: AppDimensions.md),

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
                      borderRadius: AppDimensions.borderRadiusLG,
                    ),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              SizedBox(width: AppDimensions.md),
              Expanded(
                child: TextField(
                  controller: districtController,
                  decoration: InputDecoration(
                    labelText: 'القضاء',
                    hintText: 'الكرخ',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: AppDimensions.borderRadiusLG,
                    ),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.md),

          TextField(
            controller: addressController,
            decoration: InputDecoration(
              labelText: 'العنوان',
              hintText: 'الشارع، المنطقة، رقم الدار',
              prefixIcon: const Icon(Icons.home),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            textDirection: TextDirection.rtl,
            maxLines: 2,
          ),
          SizedBox(height: AppDimensions.lg),

          // معلومات النزوح (إن وجدت)
          _buildSectionHeader(
            'معلومات إضافية',
            Icons.info_outline,
            colorScheme,
          ),
          SizedBox(height: AppDimensions.md),

          TextField(
            controller: currentAddressController,
            decoration: InputDecoration(
              labelText: 'العنوان الحالي',
              hintText: 'إذا كان مختلفاً عن العنوان الأصلي',
              prefixIcon: const Icon(Icons.place),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
              helperText: 'للنازحين: العنوان الحالي في منطقة النزوح',
            ),
            textDirection: TextDirection.rtl,
            maxLines: 2,
          ),
          SizedBox(height: AppDimensions.md),

          TextField(
            controller: addressBeforeDisplacementController,
            decoration: InputDecoration(
              labelText: 'العنوان قبل النزوح',
              hintText: 'العنوان الأصلي قبل النزوح',
              prefixIcon: const Icon(Icons.home_work),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
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
        SizedBox(width: AppDimensions.sm),
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
