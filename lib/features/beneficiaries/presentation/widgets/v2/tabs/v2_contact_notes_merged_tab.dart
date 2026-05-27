import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';
import '../../../pages/v2_form_helpers/bank_account_validator.dart';
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
    final theme = Theme.of(context);
    final hasAnyBankData = BankAccountValidator.hasAnyBankData(formControllers);

    Widget orderedField(double order, Widget child) {
      return FocusTraversalOrder(
        order: NumericFocusOrder(order),
        child: child,
      );
    }

    Widget contactGuidanceCard() {
      return Container(
        margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.tips_and_updates_outlined, size: 16.sp, color: theme.colorScheme.primary),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'ابدأ برقم الهاتف والمحافظة ثم أكمل العنوان والملاحظات لتقليل أخطاء المتابعة.',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
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
          contactGuidanceCard(),

          // 📱 Contact Information Section
          Semantics(
            container: true,
            label: 'قسم معلومات التواصل',
            child: M3SectionCard(
              title: 'معلومات التواصل',
              icon: Icons.contact_phone_rounded,
              headerColor: FormColors.tabGradients[2]![0].withValues(alpha: 0.2),
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
                    textInputAction: TextInputAction.next,
                    validator: (value) => value?.trim().isEmpty ?? true ? FormConstants.requiredFieldMessage : null,
                    helperText: 'أدخل رقم الهاتف الرئيسي (يفضل بصيغة محلية واضحة)',
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
                    textInputAction: TextInputAction.next,
                    helperText: 'رقم اتصال إضافي (اختياري)',
                  ),
                ),
              ],
            ),
          ),

          // 📍 Address Information Section
          Semantics(
            container: true,
            label: 'قسم معلومات العنوان',
            child: M3SectionCard(
              title: 'معلومات العنوان',
              icon: Icons.location_on_rounded,
              headerColor: FormColors.tabGradients[2]![0].withValues(alpha: 0.15),
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
                    textInputAction: TextInputAction.next,
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
          ),

          // 🏠 Displacement Information (if applicable)
          Semantics(
            container: true,
            label: 'قسم معلومات النزوح',
            child: M3SectionCard(
              title: 'معلومات النزوح',
              icon: Icons.moving_rounded,
              headerColor: FormColors.tabGradients[2]![1].withValues(alpha: 0.15),
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
          ),

          // 📝 Notes Section
          Semantics(
            container: true,
            label: 'قسم الملاحظات',
            child: M3SectionCard(
              title: 'الملاحظات',
              icon: Icons.notes_rounded,
              headerColor: FormColors.tabGradients[2]![1].withValues(alpha: 0.2),
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
          ),

          Semantics(
            container: true,
            label: 'قسم الحساب البنكي للوصي',
            child: M3SectionCard(
              title: 'الحساب البنكي للوصي',
              icon: Icons.account_balance_rounded,
              headerColor: FormColors.tabGradients[2]![0].withValues(alpha: 0.12),
              children: [
                orderedField(
                  100,
                  TaxonomyBridgeDropdown(
                    group: TaxonomyGroup.bankName,
                    selectedCode: formControllers.bankNameIdController.text.trim().isEmpty
                        ? null
                        : formControllers.bankNameIdController.text.trim(),
                    onCodeChanged: (value) {
                      formControllers.bankNameIdController.text = value ?? '';
                    },
                    onTaxonomyChanged: (taxonomy) {
                      formControllers.bankNameLabelController.text = taxonomy?.label ?? '';
                    },
                    labelText: 'اسم البنك',
                    prefixIcon: Icons.account_balance_outlined,
                    autoSyncOnEmpty: true,
                  ),
                ),
                SizedBox(height: 12.h),
                orderedField(
                  110,
                  M3TextField(
                    controller: formControllers.bankNameLabelController,
                    label: 'اسم البنك (نص احتياطي)',
                    prefixIcon: Icons.account_balance_outlined,
                    textInputAction: TextInputAction.next,
                    helperText: 'يُملأ تلقائياً من القائمة ويمكن تعديله عند الحاجة',
                    validator: (value) => BankAccountValidator.validateAtLeastOneBankName(
                      bankNameId: formControllers.bankNameIdController.text,
                      bankNameLabel: value,
                      hasAnyBankData: hasAnyBankData,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                orderedField(
                  120,
                  M3TextField(
                    controller: formControllers.ibanUsdController,
                    label: 'IBAN بالدولار',
                    prefixIcon: Icons.attach_money_rounded,
                    textInputAction: TextInputAction.next,
                    helperText: BankAccountValidator.ibanValidationEnabled ? null : 'سيتم التحقق من رقم الحساب لاحقاً',
                    validator: (value) => BankAccountValidator.validateIbanPair(
                      currentValue: value,
                      otherIbanValue: formControllers.ibanShekelController.text,
                      hasAnyBankData: hasAnyBankData,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                orderedField(
                  130,
                  M3TextField(
                    controller: formControllers.ibanShekelController,
                    label: 'IBAN بالشيكل',
                    prefixIcon: Icons.currency_exchange_rounded,
                    textInputAction: TextInputAction.next,
                    helperText: BankAccountValidator.ibanValidationEnabled ? null : 'سيتم التحقق من رقم الحساب لاحقاً',
                    validator: (value) => BankAccountValidator.validateIbanPair(
                      currentValue: value,
                      otherIbanValue: formControllers.ibanUsdController.text,
                      hasAnyBankData: hasAnyBankData,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                orderedField(
                  140,
                  M3TextField(
                    controller: formControllers.bankGuardianNameController,
                    label: 'اسم الوصي/ممثل الحساب',
                    prefixIcon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(height: 12.h),
                orderedField(
                  150,
                  M3TextField(
                    controller: formControllers.bankRepresentativeIdController,
                    label: 'هوية ممثل الحساب',
                    prefixIcon: Icons.badge_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(height: 12.h),
                orderedField(
                  160,
                  M3TextField(
                    controller: formControllers.bankRepresentativePhoneController,
                    label: 'هاتف ممثل الحساب',
                    prefixIcon: Icons.phone_in_talk_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(height: 12.h),
                orderedField(
                  170,
                  M3TextField(
                    controller: formControllers.bankOwnerIdentityController,
                    label: 'هوية صاحب الحساب',
                    prefixIcon: Icons.fingerprint_rounded,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                SizedBox(height: 8.h),
                SwitchListTile.adaptive(
                  value: formControllers.bankCheckAccountApproved,
                  onChanged: (value) => formControllers.bankCheckAccountApproved = value,
                  title: const Text('الحساب البنكي مُعتمد'),
                  subtitle: const Text('عند التفعيل يتم إرسال check_account = 1'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
