import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';
import '../../../pages/v2_form_helpers/widgets/material3_components.dart';
import '../../../pages/v2_form_helpers/form_constants.dart';

/// 📞 Contact & Notes Merged Tab (Contact Info + Notes)
///
/// دمج التبويبات: معلومات التواصل + الملاحظات
class V2ContactNotesMergedTab extends StatelessWidget {
  final BeneficiaryFormControllers formControllers;

  const V2ContactNotesMergedTab({super.key, required this.formControllers});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      physics: const ClampingScrollPhysics(), // ⚡ Smooth scroll
      cacheExtent: 100, // ⚡ Reduce repaints
      children: [
        // 📱 Contact Information Section
        M3SectionCard(
          title: 'معلومات التواصل',
          icon: Icons.contact_phone_rounded,
          headerColor: FormColors.tabGradients[2]![0].withOpacity(0.2),
          children: [
            M3TextField(
              controller: formControllers.phoneController,
              label: 'رقم الهاتف',
              prefixIcon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              isRequired: true,
              validator: (value) => value?.isEmpty ?? true
                  ? FormConstants.requiredFieldMessage
                  : null,
              helperText: 'أدخل رقم الهاتف الرئيسي',
            ),
            SizedBox(height: 12.h),
            M3TextField(
              controller: formControllers.altPhoneController,
              label: 'رقم هاتف بديل',
              prefixIcon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              helperText: 'رقم اتصال إضافي (اختياري)',
            ),
          ],
        ),

        // 📍 Address Information Section
        M3SectionCard(
          title: 'معلومات العنوان',
          icon: Icons.location_on_rounded,
          headerColor: FormColors.tabGradients[2]![0].withOpacity(0.15),
          children: [
            M3DropdownField<String>(
              value: formControllers.selectedProvince,
              label: 'المحافظة',
              prefixIcon: Icons.map_rounded,
              isRequired: true,
              onChanged: (value) => formControllers.selectedProvince = value,
              validator: (value) =>
                  value == null ? FormConstants.requiredFieldMessage : null,
              items: const [
                DropdownMenuItem(value: 'صنعاء', child: Text('صنعاء')),
                DropdownMenuItem(value: 'عدن', child: Text('عدن')),
                DropdownMenuItem(value: 'تعز', child: Text('تعز')),
                DropdownMenuItem(value: 'الحديدة', child: Text('الحديدة')),
                DropdownMenuItem(value: 'إب', child: Text('إب')),
                DropdownMenuItem(value: 'ذمار', child: Text('ذمار')),
                DropdownMenuItem(value: 'حضرموت', child: Text('حضرموت')),
                DropdownMenuItem(value: 'المحويت', child: Text('المحويت')),
                DropdownMenuItem(value: 'صعدة', child: Text('صعدة')),
                DropdownMenuItem(value: 'عمران', child: Text('عمران')),
                DropdownMenuItem(value: 'أخرى', child: Text('أخرى')),
              ],
            ),
            SizedBox(height: 12.h),
            M3DropdownField<String>(
              value: formControllers.selectedCity,
              label: 'المدينة',
              prefixIcon: Icons.location_city_rounded,
              onChanged: (value) => formControllers.selectedCity = value,
              items: const [
                DropdownMenuItem(value: 'مدينة 1', child: Text('مدينة 1')),
                DropdownMenuItem(value: 'مدينة 2', child: Text('مدينة 2')),
                DropdownMenuItem(value: 'أخرى', child: Text('أخرى')),
              ],
            ),
            SizedBox(height: 12.h),
            M3TextField(
              controller: formControllers.neighborhoodController,
              label: 'الحي',
              prefixIcon: Icons.home_work_rounded,
              helperText: 'اسم الحي أو المنطقة',
            ),
            SizedBox(height: 12.h),
            M3TextField(
              controller: formControllers.addressController,
              label: 'العنوان التفصيلي',
              prefixIcon: Icons.location_on_outlined,
              maxLines: 3,
              helperText: 'وصف تفصيلي للعنوان',
            ),
          ],
        ),

        // 🏠 Displacement Information (if applicable)
        M3SectionCard(
          title: 'معلومات النزوح',
          icon: Icons.moving_rounded,
          headerColor: FormColors.tabGradients[2]![1].withOpacity(0.15),
          children: [
            M3DropdownField<String>(
              value: formControllers.selectedDisplacementStatus,
              label: 'حالة النزوح',
              prefixIcon: Icons.alt_route_rounded,
              onChanged: (value) =>
                  formControllers.selectedDisplacementStatus = value,
              items: const [
                DropdownMenuItem(value: 'غير نازح', child: Text('غير نازح')),
                DropdownMenuItem(value: 'نازح', child: Text('نازح')),
                DropdownMenuItem(value: 'عائد', child: Text('عائد')),
              ],
            ),
            if (formControllers.selectedDisplacementStatus == 'نازح') ...[
              SizedBox(height: 12.h),
              M3TextField(
                controller: formControllers.addressBeforeDisplacementController,
                label: 'العنوان قبل النزوح',
                prefixIcon: Icons.home_outlined,
                maxLines: 2,
                helperText: 'المكان الذي كان يسكن فيه قبل النزوح',
              ),
            ],
          ],
        ),

        // 📝 Notes Section
        M3SectionCard(
          title: 'الملاحظات',
          icon: Icons.notes_rounded,
          headerColor: FormColors.tabGradients[2]![1].withOpacity(0.2),
          children: [
            M3TextField(
              controller: formControllers.notesController,
              label: 'ملاحظات عامة',
              prefixIcon: Icons.note_alt_rounded,
              maxLines: 6,
              helperText: 'أي معلومات إضافية أو ملاحظات مهمة',
            ),
          ],
        ),
      ],
    );
  }
}
