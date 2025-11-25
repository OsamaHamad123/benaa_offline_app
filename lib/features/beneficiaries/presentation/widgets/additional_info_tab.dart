import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/beneficiary.dart';
import '../pages/v2_form_helpers/widgets/material3_components.dart';
import '../../../../../core/utils/responsive_utils_v2.dart';

/// 📋 Additional Info Tab Widget (Updated with M3 Design)
///
/// Contains: Marital Status, Education Level, Health Status,
/// Displacement Status, Employment Status, Housing Status, Housing Type,
/// Monthly Income, Financial Support, Assets
class AdditionalInfoTab extends StatelessWidget {
  final MaritalStatus? maritalStatus;
  final EducationLevel? educationLevel;
  final HealthStatus? healthStatus;
  final DisplacementStatus? displacementStatus;
  final EmploymentStatus? employmentStatus;
  final HousingStatus? housingStatus;
  final HousingType? housingType;
  final TextEditingController monthlyIncomeController;
  final bool hasFinancialSupport;
  final TextEditingController supportSourceController;
  final TextEditingController supportAmountController;
  final bool hasAssets;
  final TextEditingController assetsDescriptionController;
  final Function(MaritalStatus?) onMaritalStatusChanged;
  final Function(EducationLevel?) onEducationLevelChanged;
  final Function(HealthStatus?) onHealthStatusChanged;
  final Function(DisplacementStatus?) onDisplacementStatusChanged;
  final Function(EmploymentStatus?) onEmploymentStatusChanged;
  final Function(HousingStatus?) onHousingStatusChanged;
  final Function(HousingType?) onHousingTypeChanged;
  final Function(bool) onHasFinancialSupportChanged;
  final Function(bool) onHasAssetsChanged;

  const AdditionalInfoTab({
    super.key,
    required this.maritalStatus,
    required this.educationLevel,
    required this.healthStatus,
    required this.displacementStatus,
    required this.employmentStatus,
    required this.housingStatus,
    required this.housingType,
    required this.monthlyIncomeController,
    required this.hasFinancialSupport,
    required this.supportSourceController,
    required this.supportAmountController,
    required this.hasAssets,
    required this.assetsDescriptionController,
    required this.onMaritalStatusChanged,
    required this.onEducationLevelChanged,
    required this.onHealthStatusChanged,
    required this.onDisplacementStatusChanged,
    required this.onEmploymentStatusChanged,
    required this.onHousingStatusChanged,
    required this.onHousingTypeChanged,
    required this.onHasFinancialSupportChanged,
    required this.onHasAssetsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      physics: const ClampingScrollPhysics(),
      children: [
        // 🎨 الحالة الشخصية
        M3SectionCard(
          title: 'الحالة الشخصية',
          icon: Icons.person_pin,
          headerColor: colorScheme.primary.withOpacity(0.1),
          children: [
            ResponsiveFormLayout(
              children: [
                M3DropdownField<MaritalStatus>(
                  value: maritalStatus,
                  label: 'الحالة الاجتماعية',
                  prefixIcon: Icons.favorite,
                  items: MaritalStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_getMaritalStatusLabel(status)),
                        ),
                      )
                      .toList(),
                  onChanged: onMaritalStatusChanged,
                ),
                M3DropdownField<EducationLevel>(
                  value: educationLevel,
                  label: 'المستوى التعليمي',
                  prefixIcon: Icons.school,
                  items: EducationLevel.values
                      .map(
                        (level) => DropdownMenuItem(
                          value: level,
                          child: Text(_getEducationLevelLabel(level)),
                        ),
                      )
                      .toList(),
                  onChanged: onEducationLevelChanged,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            M3DropdownField<HealthStatus>(
              value: healthStatus,
              label: 'الحالة الصحية',
              prefixIcon: Icons.health_and_safety,
              items: HealthStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(_getHealthStatusLabel(status)),
                    ),
                  )
                  .toList(),
              onChanged: onHealthStatusChanged,
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // 🏠 النزوح والسكن
        M3SectionCard(
          title: 'النزوح والسكن',
          icon: Icons.home_work,
          headerColor: colorScheme.secondary.withOpacity(0.1),
          children: [
            ResponsiveFormLayout(
              children: [
                M3DropdownField<DisplacementStatus>(
                  value: displacementStatus,
                  label: 'حالة النزوح',
                  prefixIcon: Icons.moving,
                  items: DisplacementStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_getDisplacementStatusLabel(status)),
                        ),
                      )
                      .toList(),
                  onChanged: onDisplacementStatusChanged,
                ),
                M3DropdownField<HousingStatus>(
                  value: housingStatus,
                  label: 'حالة السكن',
                  prefixIcon: Icons.house,
                  items: HousingStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_getHousingStatusLabel(status)),
                        ),
                      )
                      .toList(),
                  onChanged: onHousingStatusChanged,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            M3DropdownField<HousingType>(
              value: housingType,
              label: 'نوع السكن',
              prefixIcon: Icons.apartment,
              items: HousingType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(_getHousingTypeLabel(type)),
                    ),
                  )
                  .toList(),
              onChanged: onHousingTypeChanged,
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // 💼 العمل والدخل
        M3SectionCard(
          title: 'العمل والدخل',
          icon: Icons.work,
          headerColor: colorScheme.tertiary.withOpacity(0.1),
          children: [
            ResponsiveFormLayout(
              children: [
                M3DropdownField<EmploymentStatus>(
                  value: employmentStatus,
                  label: 'حالة التوظيف',
                  prefixIcon: Icons.business_center,
                  items: EmploymentStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_getEmploymentStatusLabel(status)),
                        ),
                      )
                      .toList(),
                  onChanged: onEmploymentStatusChanged,
                ),
                M3TextField(
                  controller: monthlyIncomeController,
                  label: 'الدخل الشهري',
                  hint: '0',
                  prefixIcon: Icons.attach_money,
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(top: 14.h),
                    child: Text(
                      'IQD',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // 💰 الدعم المالي والممتلكات
        M3SectionCard(
          title: 'الدعم المالي والممتلكات',
          icon: Icons.account_balance,
          headerColor: colorScheme.primary.withOpacity(0.15),
          children: [
            // Switch للدعم المالي
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: SwitchListTile(
                title: Text(
                  'يتلقى دعماً مالياً',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'من جهات أخرى',
                  style: TextStyle(fontSize: 12.sp),
                ),
                value: hasFinancialSupport,
                onChanged: onHasFinancialSupportChanged,
                secondary: Icon(
                  Icons.monetization_on,
                  color: colorScheme.primary,
                ),
              ),
            ),

            if (hasFinancialSupport) ...[
              SizedBox(height: 12.h),
              ResponsiveFormLayout(
                children: [
                  M3TextField(
                    controller: supportSourceController,
                    label: 'مصدر الدعم',
                    hint: 'منظمة، جمعية، إلخ',
                    prefixIcon: Icons.business,
                  ),
                  M3TextField(
                    controller: supportAmountController,
                    label: 'مبلغ الدعم الشهري',
                    hint: '0',
                    prefixIcon: Icons.money,
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(top: 14.h),
                      child: Text(
                        'IQD',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ],

            SizedBox(height: 12.h),

            // Switch للممتلكات
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: SwitchListTile(
                title: Text(
                  'يمتلك ممتلكات أو أصول',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'منزل، أرض، سيارة، إلخ',
                  style: TextStyle(fontSize: 12.sp),
                ),
                value: hasAssets,
                onChanged: onHasAssetsChanged,
                secondary: Icon(Icons.inventory, color: colorScheme.primary),
              ),
            ),

            if (hasAssets) ...[
              SizedBox(height: 12.h),
              M3TextField(
                controller: assetsDescriptionController,
                label: 'وصف الممتلكات',
                hint: 'منزل في بغداد، سيارة، إلخ',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _getMaritalStatusLabel(MaritalStatus status) {
    switch (status) {
      case MaritalStatus.single:
        return 'أعزب/عزباء';
      case MaritalStatus.married:
        return 'متزوج/متزوجة';
      case MaritalStatus.divorced:
        return 'مطلق/مطلقة';
      case MaritalStatus.widowed:
        return 'أرمل/أرملة';
    }
  }

  String _getEducationLevelLabel(EducationLevel level) {
    switch (level) {
      case EducationLevel.none:
        return 'أمي';
      case EducationLevel.illiterate:
        return 'غير متعلم';
      case EducationLevel.primary:
        return 'ابتدائي';
      case EducationLevel.intermediate:
        return 'إعدادي';
      case EducationLevel.secondary:
        return 'ثانوي';
      case EducationLevel.diploma:
        return 'دبلوم';
      case EducationLevel.bachelor:
        return 'بكالوريوس';
      case EducationLevel.master:
        return 'ماجستير';
      case EducationLevel.phd:
        return 'دكتوراه';
    }
  }

  String _getHealthStatusLabel(HealthStatus status) {
    switch (status) {
      case HealthStatus.good:
        return 'جيد';
      case HealthStatus.fair:
        return 'متوسط';
      case HealthStatus.poor:
        return 'سيئ';
      case HealthStatus.chronicDisease:
        return 'مزمن';
      case HealthStatus.disability:
        return 'معاق';
    }
  }

  String _getDisplacementStatusLabel(DisplacementStatus status) {
    switch (status) {
      case DisplacementStatus.notDisplaced:
        return 'غير نازح';
      case DisplacementStatus.displaced:
        return 'نازح';
      case DisplacementStatus.refugee:
        return 'لاجئ';
      case DisplacementStatus.returned:
        return 'عائد';
      case DisplacementStatus.returnee:
        return 'عائد';
    }
  }

  String _getEmploymentStatusLabel(EmploymentStatus status) {
    switch (status) {
      case EmploymentStatus.employed:
        return 'موظف';
      case EmploymentStatus.unemployed:
        return 'عاطل عن العمل';
      case EmploymentStatus.selfEmployed:
        return 'عمل حر';
      case EmploymentStatus.student:
        return 'طالب';
      case EmploymentStatus.retired:
        return 'متقاعد';
      case EmploymentStatus.disabled:
        return 'معاق';
    }
  }

  String _getHousingStatusLabel(HousingStatus status) {
    switch (status) {
      case HousingStatus.owned:
        return 'ملك';
      case HousingStatus.rented:
        return 'إيجار';
      case HousingStatus.shared:
        return 'مشترك';
      case HousingStatus.sharedOwned:
        return 'مشترك ملك';
      case HousingStatus.withFamily:
        return 'مع العائلة';
      case HousingStatus.homeless:
        return 'مشرد';
      case HousingStatus.temporary:
        return 'مؤقت';
    }
  }

  String _getHousingTypeLabel(HousingType type) {
    switch (type) {
      case HousingType.house:
        return 'منزل';
      case HousingType.apartment:
        return 'شقة';
      case HousingType.room:
        return 'غرفة';
      case HousingType.tent:
        return 'خيمة';
      case HousingType.caravan:
        return 'قافلة';
      case HousingType.shelter:
        return 'مأوى';
      case HousingType.other:
        return 'أخرى';
    }
  }
}
