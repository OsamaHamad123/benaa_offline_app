import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/v2_custom_text_field.dart';
import '../components/v2_section_card.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart'; // 📱
import '../../../../../../core/validation/field_validators.dart'; // 📋
import '../../../../../../features/taxonomies/taxonomies.dart';

/// Contact information tab
class V2ContactInfoTab extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController altPhoneController;
  final TextEditingController addressController;
  final TextEditingController neighborhoodController;
  final String? selectedCity;
  final Function(String?) onCityChanged;
  final String? selectedProvince;
  final Function(String?) onProvinceChanged;
  final String? selectedDisplacementStatus;
  final Function(String?) onDisplacementStatusChanged;
  final TextEditingController? addressBeforeDisplacementController;

  const V2ContactInfoTab({
    required this.phoneController,
    required this.altPhoneController,
    required this.addressController,
    required this.neighborhoodController,
    required this.onCityChanged,
    required this.onProvinceChanged,
    required this.onDisplacementStatusChanged,
    super.key,
    this.selectedCity,
    this.selectedProvince,
    this.selectedDisplacementStatus,
    this.addressBeforeDisplacementController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      children: [
        V2SectionCard(
          title: 'معلومات الاتصال',
          icon: Icons.phone_rounded,
          children: [
            ResponsiveFormLayout(
              children: [
                V2CustomTextField(
                  controller: phoneController,
                  label: 'رقم الهاتف',
                  prefixIcon: Icons.smartphone_rounded,
                  keyboardType: TextInputType.phone,
                  hint: 'مثال: 0595735352 أو +970595735352',
                  maxLength: FieldValidators.phoneMaxLength,
                  inputFormatters: FieldValidators.phoneFormatters,
                  validator: FieldValidators.phoneOptional,
                ),
                V2CustomTextField(
                  controller: altPhoneController,
                  label: 'رقم هاتف بديل',
                  prefixIcon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  hint: 'اختياري',
                  maxLength: FieldValidators.phoneMaxLength,
                  inputFormatters: FieldValidators.phoneFormatters,
                  validator: FieldValidators.phoneOptional,
                ),
              ],
            ), // End ResponsiveFormLayout
          ],
        ),
        V2SectionCard(
          title: 'العنوان',
          icon: Icons.location_on_rounded,
          children: [
            ResponsiveFormLayout(
              children: [
                TaxonomyBridgeDropdown(
                  group: TaxonomyGroup.governorate,
                  selectedCode: selectedProvince,
                  labelText: 'المحافظة',
                  prefixIcon: Icons.map_rounded,
                  onCodeChanged: onProvinceChanged,
                ),
                TaxonomyBridgeDropdown(
                  group: TaxonomyGroup.city,
                  selectedCode: selectedCity,
                  labelText: 'المدينة',
                  prefixIcon: Icons.location_city_rounded,
                  onCodeChanged: onCityChanged,
                  autoSyncOnEmpty: true,
                ),
                V2CustomTextField(
                  controller: neighborhoodController,
                  label: 'الحي',
                  prefixIcon: Icons.home_work_rounded,
                ),
              ],
            ), // End ResponsiveFormLayout
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: addressController,
              label: 'العنوان التفصيلي',
              prefixIcon: Icons.signpost_rounded,
              maxLines: 3,
              hint: 'الشارع، رقم المبنى، تفاصيل إضافية',
            ),
          ],
        ),
        V2SectionCard(
          title: 'حالة النزوح',
          icon: Icons.move_to_inbox_rounded,
          children: [
            TaxonomyBridgeDropdown(
              group: TaxonomyGroup.displacementStatus,
              selectedCode: selectedDisplacementStatus,
              labelText: 'حالة النزوح',
              prefixIcon: Icons.group_rounded,
              onCodeChanged: onDisplacementStatusChanged,
            ),
            if (selectedDisplacementStatus != null && selectedDisplacementStatus!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              V2CustomTextField(
                controller: addressBeforeDisplacementController!,
                label: 'العنوان قبل النزوح',
                prefixIcon: Icons.history_rounded,
                maxLines: 2,
                hint: 'أدخل مكان الإقامة قبل النزوح',
              ),
            ],
          ],
        ),
      ],
    );
  }
}
