import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';
import '../../../pages/v2_form_helpers/widgets/material3_components.dart';
import '../../../pages/v2_form_helpers/form_constants.dart';
import '../../../../../../features/taxonomies/taxonomies.dart';

/// 📞 Contact & Notes Merged Tab (Contact Info + Notes)
///
/// دمج التبويبات: معلومات التواصل + الملاحظات
class V2ContactNotesMergedTab extends StatelessWidget {
  final BeneficiaryFormControllers formControllers;
  final VoidCallback? onRequestNextTab;
  final VoidCallback? onRequestReviewTab;
  final FocusNode? firstFieldFocusNode;

  const V2ContactNotesMergedTab(
      {required this.formControllers,
      super.key,
      this.onRequestNextTab,
      this.onRequestReviewTab,
      this.firstFieldFocusNode});

  @override
  Widget build(BuildContext context) {
    Widget orderedField(double order, Widget child) {
      return FocusTraversalOrder(
        order: NumericFocusOrder(order),
        child: child,
      );
    }

    void showNextTabHint() {
      final readyForReview = formControllers.firstNameController.text.trim().isNotEmpty &&
          formControllers.fatherNameController.text.trim().isNotEmpty &&
          formControllers.lastNameController.text.trim().isNotEmpty &&
          formControllers.selectedGender != null &&
          formControllers.nationalIdController.text.trim().length == FormConstants.nationalIdLength &&
          formControllers.phoneController.text.trim().isNotEmpty &&
          formControllers.pendingAttachments.isNotEmpty;

      final callback = readyForReview ? (onRequestReviewTab ?? onRequestNextTab) : onRequestNextTab;
      if (callback == null) {
        return;
      }

      final actionLabel = readyForReview ? 'المراجعة' : 'التالي';
      final message = readyForReview
          ? 'البيانات الأساسية مكتملة. الانتقال مباشرة إلى المراجعة النهائية؟'
          : 'تم إنهاء قسم التواصل والملاحظات. الذهاب للمرفقات؟';

      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: actionLabel,
            onPressed: callback,
          ),
        ),
      );
    }

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: ListView(
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
              orderedField(
                10,
                M3TextField(
                  controller: formControllers.phoneController,
                  label: 'رقم الهاتف',
                  prefixIcon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  focusNode: firstFieldFocusNode,
                  isRequired: true,
                  validator: (value) => value?.isEmpty ?? true ? FormConstants.requiredFieldMessage : null,
                  helperText: 'أدخل رقم الهاتف الرئيسي',
                ),
              ),
              SizedBox(height: 12.h),
              orderedField(
                20,
                M3TextField(
                  controller: formControllers.altPhoneController,
                  label: 'رقم هاتف بديل',
                  prefixIcon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  helperText: 'رقم اتصال إضافي (اختياري)',
                ),
              ),
            ],
          ),

          // 📍 Address Information Section
          M3SectionCard(
            title: 'معلومات العنوان',
            icon: Icons.location_on_rounded,
            headerColor: FormColors.tabGradients[2]![0].withOpacity(0.15),
            children: [
              orderedField(
                30,
                TaxonomyBridgeDropdown(
                  group: TaxonomyGroup.governorate,
                  selectedCode: formControllers.selectedProvince,
                  onCodeChanged: (value) => formControllers.selectedProvince = value,
                  labelText: 'المحافظة',
                  isRequired: true,
                  prefixIcon: Icons.map_rounded,
                ),
              ),
              SizedBox(height: 12.h),
              orderedField(
                40,
                TaxonomyBridgeDropdown(
                  group: TaxonomyGroup.city,
                  selectedCode: formControllers.selectedCity,
                  onCodeChanged: (value) => formControllers.selectedCity = value,
                  labelText: 'المدينة',
                  prefixIcon: Icons.location_city_rounded,
                  autoSyncOnEmpty: true,
                ),
              ),
              SizedBox(height: 12.h),
              orderedField(
                50,
                M3TextField(
                  controller: formControllers.neighborhoodController,
                  label: 'الحي',
                  prefixIcon: Icons.home_work_rounded,
                  helperText: 'اسم الحي أو المنطقة',
                ),
              ),
              SizedBox(height: 12.h),
              orderedField(
                60,
                M3TextField(
                  controller: formControllers.addressController,
                  label: 'العنوان التفصيلي',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 3,
                  helperText: 'وصف تفصيلي للعنوان',
                ),
              ),
            ],
          ),

          // 🏠 Displacement Information (if applicable)
          M3SectionCard(
            title: 'معلومات النزوح',
            icon: Icons.moving_rounded,
            headerColor: FormColors.tabGradients[2]![1].withOpacity(0.15),
            children: [
              orderedField(
                70,
                TaxonomyBridgeDropdown(
                  group: TaxonomyGroup.displacementStatus,
                  selectedCode: formControllers.selectedDisplacementStatus,
                  onCodeChanged: (value) => formControllers.selectedDisplacementStatus = value,
                  labelText: 'حالة النزوح',
                  prefixIcon: Icons.alt_route_rounded,
                ),
              ),
              if (formControllers.selectedDisplacementStatus != null &&
                  formControllers.selectedDisplacementStatus!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                orderedField(
                  80,
                  M3TextField(
                    controller: formControllers.addressBeforeDisplacementController,
                    label: 'العنوان قبل النزوح',
                    prefixIcon: Icons.home_outlined,
                    maxLines: 2,
                    helperText: 'المكان الذي كان يسكن فيه قبل النزوح',
                  ),
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
              orderedField(
                90,
                M3TextField(
                  controller: formControllers.notesController,
                  label: 'ملاحظات عامة',
                  prefixIcon: Icons.note_alt_rounded,
                  maxLines: 6,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => showNextTabHint(),
                  helperText: 'أي معلومات إضافية أو ملاحظات مهمة',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
