import 'package:benaa_offline_app/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/beneficiary.dart';

/// 📋 Additional Info Tab Widget
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

    return SingleChildScrollView(
      padding: AppDimensions.paddingMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الحالة الشخصية
          _buildSectionHeader('الحالة الشخصية', Icons.person_pin, colorScheme),
          SizedBox(height: AppDimensions.md),

          DropdownButtonFormField<MaritalStatus>(
            value: maritalStatus,
            decoration: InputDecoration(
              labelText: 'الحالة الاجتماعية',
              prefixIcon: const Icon(Icons.favorite),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            items: MaritalStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(_getMaritalStatusLabel(status)),
              );
            }).toList(),
            onChanged: onMaritalStatusChanged,
          ),
          SizedBox(height: AppDimensions.md),

          DropdownButtonFormField<EducationLevel>(
            value: educationLevel,
            decoration: InputDecoration(
              labelText: 'المستوى التعليمي',
              prefixIcon: const Icon(Icons.school),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            items: EducationLevel.values.map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(_getEducationLevelLabel(level)),
              );
            }).toList(),
            onChanged: onEducationLevelChanged,
          ),
          SizedBox(height: AppDimensions.md),

          DropdownButtonFormField<HealthStatus>(
            value: healthStatus,
            decoration: InputDecoration(
              labelText: 'الحالة الصحية',
              prefixIcon: const Icon(Icons.health_and_safety),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            items: HealthStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(_getHealthStatusLabel(status)),
              );
            }).toList(),
            onChanged: onHealthStatusChanged,
          ),
          SizedBox(height: AppDimensions.lg),

          // معلومات النزوح والسكن
          _buildSectionHeader('النزوح والسكن', Icons.home_work, colorScheme),
          SizedBox(height: AppDimensions.md),

          DropdownButtonFormField<DisplacementStatus>(
            value: displacementStatus,
            decoration: InputDecoration(
              labelText: 'حالة النزوح',
              prefixIcon: const Icon(Icons.moving),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            items: DisplacementStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(_getDisplacementStatusLabel(status)),
              );
            }).toList(),
            onChanged: onDisplacementStatusChanged,
          ),
          SizedBox(height: AppDimensions.md),

          DropdownButtonFormField<HousingStatus>(
            value: housingStatus,
            decoration: InputDecoration(
              labelText: 'حالة السكن',
              prefixIcon: const Icon(Icons.house),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            items: HousingStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(_getHousingStatusLabel(status)),
              );
            }).toList(),
            onChanged: onHousingStatusChanged,
          ),
          SizedBox(height: AppDimensions.md),

          DropdownButtonFormField<HousingType>(
            value: housingType,
            decoration: InputDecoration(
              labelText: 'نوع السكن',
              prefixIcon: const Icon(Icons.apartment),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            items: HousingType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getHousingTypeLabel(type)),
              );
            }).toList(),
            onChanged: onHousingTypeChanged,
          ),
          SizedBox(height: AppDimensions.lg),

          // معلومات العمل والدخل
          _buildSectionHeader('العمل والدخل', Icons.work, colorScheme),
          SizedBox(height: AppDimensions.md),

          DropdownButtonFormField<EmploymentStatus>(
            value: employmentStatus,
            decoration: InputDecoration(
              labelText: 'حالة التوظيف',
              prefixIcon: const Icon(Icons.business_center),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            items: EmploymentStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(_getEmploymentStatusLabel(status)),
              );
            }).toList(),
            onChanged: onEmploymentStatusChanged,
          ),
          SizedBox(height: AppDimensions.md),

          TextField(
            controller: monthlyIncomeController,
            decoration: InputDecoration(
              labelText: 'الدخل الشهري',
              hintText: '0',
              prefixIcon: const Icon(Icons.attach_money),
              suffixText: 'IQD',
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: AppDimensions.lg),

          // الدعم المالي
          _buildSectionHeader(
            'الدعم المالي والممتلكات',
            Icons.account_balance,
            colorScheme,
          ),
          SizedBox(height: AppDimensions.md),

          SwitchListTile(
            title: const Text('يتلقى دعماً مالياً'),
            subtitle: const Text('من جهات أخرى'),
            value: hasFinancialSupport,
            onChanged: onHasFinancialSupportChanged,
            secondary: const Icon(Icons.monetization_on),
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.borderRadiusLG,
              side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
            ),
          ),

          if (hasFinancialSupport) ...[
            SizedBox(height: AppDimensions.md),
            TextField(
              controller: supportSourceController,
              decoration: InputDecoration(
                labelText: 'مصدر الدعم',
                hintText: 'منظمة، جمعية، إلخ',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: AppDimensions.borderRadiusLG,
                ),
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: AppDimensions.md),
            TextField(
              controller: supportAmountController,
              decoration: InputDecoration(
                labelText: 'مبلغ الدعم الشهري',
                hintText: '0',
                prefixIcon: const Icon(Icons.money),
                suffixText: 'IQD',
                border: OutlineInputBorder(
                  borderRadius: AppDimensions.borderRadiusLG,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ],

          SizedBox(height: AppDimensions.md),

          SwitchListTile(
            title: const Text('يمتلك ممتلكات أو أصول'),
            subtitle: const Text('منزل، أرض، سيارة، إلخ'),
            value: hasAssets,
            onChanged: onHasAssetsChanged,
            secondary: const Icon(Icons.inventory),
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.borderRadiusLG,
              side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
            ),
          ),

          if (hasAssets) ...[
            SizedBox(height: AppDimensions.md),
            TextField(
              controller: assetsDescriptionController,
              decoration: InputDecoration(
                labelText: 'وصف الممتلكات',
                hintText: 'منزل في بغداد، سيارة، إلخ',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: AppDimensions.borderRadiusLG,
                ),
              ),
              textDirection: TextDirection.rtl,
              maxLines: 3,
            ),
          ],
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
