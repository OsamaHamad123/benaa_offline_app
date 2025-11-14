import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/v2_custom_text_field.dart';
import '../components/v2_section_card.dart';

/// Contact information tab
class V2ContactInfoTab extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController altPhoneController;
  final TextEditingController addressController;
  final TextEditingController neighborhoodController;
  final TextEditingController cityController;

  const V2ContactInfoTab({
    super.key,
    required this.phoneController,
    required this.altPhoneController,
    required this.addressController,
    required this.neighborhoodController,
    required this.cityController,
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
            V2CustomTextField(
              controller: phoneController,
              label: 'رقم الهاتف',
              prefixIcon: Icons.smartphone_rounded,
              keyboardType: TextInputType.phone,
              hint: 'مثال: 0912345678',
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: altPhoneController,
              label: 'رقم هاتف بديل',
              prefixIcon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              hint: 'اختياري',
            ),
          ],
        ),
        V2SectionCard(
          title: 'العنوان',
          icon: Icons.location_on_rounded,
          children: [
            V2CustomTextField(
              controller: cityController,
              label: 'المدينة',
              prefixIcon: Icons.location_city_rounded,
            ),
            SizedBox(height: 12.h),
            V2CustomTextField(
              controller: neighborhoodController,
              label: 'الحي',
              prefixIcon: Icons.home_work_rounded,
            ),
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
      ],
    );
  }
}
