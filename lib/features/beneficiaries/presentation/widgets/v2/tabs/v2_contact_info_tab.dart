import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/v2_custom_text_field.dart';
import '../components/v2_dropdown_field.dart';
import '../components/v2_section_card.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart'; // 📱
import '../../../../../../core/validation/field_validators.dart'; // 📋

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
    super.key,
    required this.phoneController,
    required this.altPhoneController,
    required this.addressController,
    required this.neighborhoodController,
    this.selectedCity,
    required this.onCityChanged,
    this.selectedProvince,
    required this.onProvinceChanged,
    this.selectedDisplacementStatus,
    required this.onDisplacementStatusChanged,
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
                V2DropdownField<String>(
                  value: selectedProvince,
                  label: 'المحافظة',
                  prefixIcon: Icons.map_rounded,
                  onChanged: onProvinceChanged,
                  items: const [
                    DropdownMenuItem(value: 'damascus', child: Text('رفح')),
                    DropdownMenuItem(value: 'aleppo', child: Text('خانيونس')),
                    DropdownMenuItem(value: 'homs', child: Text('القرارة')),
                    DropdownMenuItem(value: 'hama', child: Text('حماة')),
                    DropdownMenuItem(value: 'latakia', child: Text('اللاذقية')),
                    DropdownMenuItem(value: 'tartus', child: Text('طرطوس')),
                    DropdownMenuItem(value: 'idlib', child: Text('إدلب')),
                    DropdownMenuItem(value: 'daraa', child: Text('درعا')),
                    DropdownMenuItem(
                      value: 'quneitra',
                      child: Text('القنيطرة'),
                    ),
                    DropdownMenuItem(value: 'suwayda', child: Text('السويداء')),
                    DropdownMenuItem(
                      value: 'deir_ez_zor',
                      child: Text('دير الزور'),
                    ),
                    DropdownMenuItem(value: 'raqqa', child: Text('الرقة')),
                    DropdownMenuItem(value: 'hasakah', child: Text('الحسكة')),
                    DropdownMenuItem(
                      value: 'rif_dimashq',
                      child: Text('ريف دمشق'),
                    ),
                  ],
                ),
                V2DropdownField<String>(
                  value: selectedCity,
                  label: 'المدينة',
                  prefixIcon: Icons.location_city_rounded,
                  onChanged: onCityChanged,
                  hint: 'اختر المدينة',
                  items: const [
                    DropdownMenuItem(
                      value: 'damascus_city',
                      child: Text('دمشق'),
                    ),
                    DropdownMenuItem(value: 'aleppo_city', child: Text('حلب')),
                    DropdownMenuItem(value: 'homs_city', child: Text('حمص')),
                    DropdownMenuItem(value: 'hama_city', child: Text('حماة')),
                    DropdownMenuItem(
                      value: 'latakia_city',
                      child: Text('اللاذقية'),
                    ),
                    DropdownMenuItem(value: 'other', child: Text('أخرى')),
                  ],
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
            V2DropdownField<String>(
              value: selectedDisplacementStatus,
              label: 'حالة النزوح',
              prefixIcon: Icons.group_rounded,
              onChanged: onDisplacementStatusChanged,
              items: const [
                DropdownMenuItem(
                  value: 'notDisplaced',
                  child: Text('غير نازح'),
                ),
                DropdownMenuItem(value: 'displaced', child: Text('نازح')),
                DropdownMenuItem(value: 'refugee', child: Text('لاجئ')),
                DropdownMenuItem(value: 'returned', child: Text('عائد')),
              ],
            ),
            if (selectedDisplacementStatus == 'displaced' ||
                selectedDisplacementStatus == 'refugee') ...[
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
