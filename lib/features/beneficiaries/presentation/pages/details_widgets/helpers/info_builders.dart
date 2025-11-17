import 'package:flutter/material.dart';
import '../../../../domain/helpers/beneficiary_domain_helpers.dart';
import '../info_section.dart';

/// 🏗️ Info Builders - Clean Architecture Helper
///
/// Builds info items for different sections of beneficiary details
class InfoBuilders {
  /// Build basic info items (ID, category, gender, birth date, etc.)
  static List<InfoItem> buildBasicInfoItems(dynamic beneficiary) {
    final items = <InfoItem>[];

    items.add(
      InfoItem(
        icon: Icons.badge_outlined,
        label: 'الرقم الوطني',
        value: beneficiary.nationalId,
      ),
    );

    if (beneficiary.fileNo != null) {
      items.add(
        InfoItem(
          icon: Icons.folder_outlined,
          label: 'رقم الملف',
          value: beneficiary.fileNo!,
        ),
      );
    }

    items.add(
      InfoItem(
        icon: Icons.category_outlined,
        label: 'الفئة',
        value: BeneficiaryDomainHelpers.getCategoryLabel(beneficiary.category),
      ),
    );

    items.add(
      InfoItem(
        icon: Icons.wc_outlined,
        label: 'الجنس',
        value: BeneficiaryDomainHelpers.getGenderLabel(beneficiary.gender),
      ),
    );

    if (beneficiary.birthDate != null) {
      items.add(
        InfoItem(
          icon: Icons.cake_outlined,
          label: 'تاريخ الميلاد',
          value: BeneficiaryDomainHelpers.formatDate(beneficiary.birthDate),
        ),
      );
    }

    if (beneficiary.governorate != null) {
      items.add(
        InfoItem(
          icon: Icons.location_on_outlined,
          label: 'المحافظة',
          value: BeneficiaryDomainHelpers.getGovernorateName(
            beneficiary.governorate,
          ),
        ),
      );
    }

    if (beneficiary.district != null) {
      items.add(
        InfoItem(
          icon: Icons.location_city_outlined,
          label: 'المدينة',
          value: BeneficiaryDomainHelpers.getDistrictName(beneficiary.district),
        ),
      );
    }

    return items;
  }

  /// Build contact info items (phone numbers)
  static List<InfoItem> buildContactInfoItems(dynamic beneficiary) {
    final items = <InfoItem>[];

    items.add(
      InfoItem(
        icon: Icons.phone,
        label: 'رقم الهاتف',
        value: beneficiary.phoneNumber ?? '-',
      ),
    );

    items.add(
      InfoItem(
        icon: Icons.phone_android,
        label: 'رقم هاتف بديل',
        value: beneficiary.altPhoneNumber ?? '-',
      ),
    );

    return items;
  }

  /// Build family info items (father, grandfather, marital status, etc.)
  static List<InfoItem> buildFamilyInfoItems(dynamic beneficiary) {
    final items = <InfoItem>[];

    if (beneficiary.fatherName != null && beneficiary.fatherName!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.person_outlined,
          label: 'اسم الأب',
          value: beneficiary.fatherName!,
        ),
      );
    }

    if (beneficiary.grandFatherName != null &&
        beneficiary.grandFatherName!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.person_outline,
          label: 'اسم الجد',
          value: beneficiary.grandFatherName!,
        ),
      );
    }

    if (beneficiary.familyName != null && beneficiary.familyName!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.family_restroom,
          label: 'اسم العائلة',
          value: beneficiary.familyName!,
        ),
      );
    }

    if (beneficiary.maritalStatus != null) {
      items.add(
        InfoItem(
          icon: Icons.favorite_outline,
          label: 'الحالة الاجتماعية',
          value: BeneficiaryDomainHelpers.getMaritalStatusLabel(
            beneficiary.maritalStatus,
          ),
        ),
      );
    }

    if (beneficiary.familySize != null) {
      items.add(
        InfoItem(
          icon: Icons.groups_outlined,
          label: 'عدد أفراد الأسرة',
          value: '${beneficiary.familySize} فرد',
        ),
      );
    }

    if (beneficiary.numberOfMales != null) {
      items.add(
        InfoItem(
          icon: Icons.male,
          label: 'عدد الذكور',
          value: beneficiary.numberOfMales.toString(),
        ),
      );
    }

    if (beneficiary.numberOfFemales != null) {
      items.add(
        InfoItem(
          icon: Icons.female,
          label: 'عدد الإناث',
          value: beneficiary.numberOfFemales.toString(),
        ),
      );
    }

    return items;
  }

  /// Build location/displacement info items
  static List<InfoItem> buildLocationInfoItems(dynamic beneficiary) {
    final items = <InfoItem>[];

    if (beneficiary.currentAddress != null &&
        beneficiary.currentAddress!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.home,
          label: 'العنوان الحالي',
          value: beneficiary.currentAddress!,
        ),
      );
    }

    if (beneficiary.addressBeforeDisplacement != null &&
        beneficiary.addressBeforeDisplacement!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.location_city,
          label: 'العنوان قبل النزوح',
          value: beneficiary.addressBeforeDisplacement!,
        ),
      );
    }

    if (beneficiary.displacementStatus != null) {
      items.add(
        InfoItem(
          icon: Icons.move_down,
          label: 'حالة النزوح',
          value: BeneficiaryDomainHelpers.getDisplacementStatusLabel(
            beneficiary.displacementStatus,
          ),
        ),
      );
    }

    if (beneficiary.housingStatus != null) {
      items.add(
        InfoItem(
          icon: Icons.house_outlined,
          label: 'حالة السكن',
          value: BeneficiaryDomainHelpers.getHousingStatusLabel(
            beneficiary.housingStatus,
          ),
        ),
      );
    }

    if (beneficiary.housingType != null) {
      items.add(
        InfoItem(
          icon: Icons.home_work_outlined,
          label: 'نوع السكن',
          value: BeneficiaryDomainHelpers.getHousingTypeLabel(
            beneficiary.housingType,
          ),
        ),
      );
    }

    return items;
  }

  /// Build education and health info items
  static List<InfoItem> buildEducationHealthItems(dynamic beneficiary) {
    final items = <InfoItem>[];

    if (beneficiary.educationLevel != null) {
      items.add(
        InfoItem(
          icon: Icons.school,
          label: 'المستوى التعليمي',
          value: BeneficiaryDomainHelpers.getEducationLabel(
            beneficiary.educationLevel,
          ),
        ),
      );
    }

    if (beneficiary.employmentStatus != null) {
      items.add(
        InfoItem(
          icon: Icons.work_outline,
          label: 'حالة عمل المعيل',
          value: BeneficiaryDomainHelpers.getEmploymentStatusLabel(
            beneficiary.employmentStatus,
          ),
        ),
      );
    }

    items.add(
      InfoItem(
        icon: Icons.health_and_safety_outlined,
        label: 'الحالة الصحية',
        value: BeneficiaryDomainHelpers.getHealthStatusLabel(
          beneficiary.healthStatus,
        ),
      ),
    );

    if (beneficiary.chronicDiseasesCount != null &&
        beneficiary.chronicDiseasesCount! > 0) {
      items.add(
        InfoItem(
          icon: Icons.medical_services_outlined,
          label: 'عدد الأمراض المزمنة',
          value: beneficiary.chronicDiseasesCount.toString(),
        ),
      );
    }

    if (beneficiary.specialNeedsCount != null &&
        beneficiary.specialNeedsCount! > 0) {
      items.add(
        InfoItem(
          icon: Icons.accessible_forward,
          label: 'ذوي الاحتياجات الخاصة',
          value: '${beneficiary.specialNeedsCount} أفراد',
        ),
      );
    }

    return items;
  }

  /// Build system metadata info items
  static List<InfoItem> buildSystemInfoItems(dynamic beneficiary) {
    return [
      InfoItem(
        icon: Icons.access_time,
        label: 'تاريخ الإنشاء',
        value: BeneficiaryDomainHelpers.formatDateTime(beneficiary.createdAt),
      ),
      InfoItem(
        icon: Icons.update,
        label: 'آخر تحديث',
        value: BeneficiaryDomainHelpers.formatDateTime(beneficiary.updatedAt),
      ),
    ];
  }
}
