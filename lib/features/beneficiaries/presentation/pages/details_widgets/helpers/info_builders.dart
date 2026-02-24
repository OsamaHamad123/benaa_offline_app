import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../../domain/helpers/beneficiary_domain_helpers.dart';
import '../../../utils/taxonomy_value_resolver.dart';
import '../info_section.dart';

/// 🏗️ Info Builders - Clean Architecture Helper
///
/// Builds info items for different sections of beneficiary details
class InfoBuilders {
  /// Build basic info items (ID, category, gender, birth date, etc.)
  static List<InfoItem> buildBasicInfoItems(
    dynamic beneficiary, {
    Map<String, String> categoryLabelsByCode = const <String, String>{},
    Map<String, String> genderLabelsByCode = const <String, String>{},
    Map<String, String> governorateLabelsByCode = const <String, String>{},
    Map<String, String> cityLabelsByCode = const <String, String>{},
  }) {
    final items = <InfoItem>[];

    final nationalId = _cleanText(beneficiary.nationalId);
    if (nationalId != null) {
      items.add(
        InfoItem(
          icon: Icons.badge_outlined,
          label: 'الرقم الوطني',
          value: nationalId,
        ),
      );
    }

    final fileNo = _cleanText(beneficiary.fileNo);
    if (fileNo != null) {
      items.add(
        InfoItem(
          icon: Icons.folder_outlined,
          label: 'رقم الملف',
          value: fileNo,
        ),
      );
    }

    final categoryRaw =
        _cleanText(beneficiary.sectionId?.toString()) ?? _cleanText(beneficiary.category?.code?.toString());
    final categoryLabel = TaxonomyValueResolver.displayLabel(
      rawValue: categoryRaw,
      resolvedLabel: _resolveTaxonomyLabel(categoryRaw, categoryLabelsByCode) ??
          BeneficiaryDomainHelpers.getCategoryLabel(beneficiary.category),
    );
    items.add(
      InfoItem(
        icon: Icons.category_outlined,
        label: 'الفئة',
        value: categoryLabel,
      ),
    );

    final genderRaw =
        _cleanText(beneficiary.gender?.toString().split('.').last) ?? _cleanText(beneficiary.gender?.englishValue);
    final genderLabel = TaxonomyValueResolver.displayLabel(
      rawValue: genderRaw,
      resolvedLabel: _resolveTaxonomyLabel(genderRaw, genderLabelsByCode) ??
          BeneficiaryDomainHelpers.getGenderLabel(beneficiary.gender),
    );
    items.add(
      InfoItem(
        icon: Icons.wc_outlined,
        label: 'الجنس',
        value: genderLabel,
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

      // إضافة العمر
      final age = beneficiary.age;
      if (age != null) {
        items.add(
          InfoItem(
            icon: Icons.calendar_today_outlined,
            label: 'العمر',
            value: '$age سنة',
          ),
        );
      }
    }

    final governorate = _cleanText(beneficiary.governorate);
    if (governorate != null) {
      final governorateLabel = _resolveTaxonomyLabel(governorate, governorateLabelsByCode) ??
          BeneficiaryDomainHelpers.getGovernorateName(governorate);
      items.add(
        InfoItem(
          icon: Icons.location_on_outlined,
          label: 'المحافظة',
          value: governorateLabel,
        ),
      );
    }

    final city = _cleanText(beneficiary.district);
    if (city != null) {
      final cityLabel = _resolveTaxonomyLabel(city, cityLabelsByCode) ?? BeneficiaryDomainHelpers.getDistrictName(city);
      items.add(
        InfoItem(
          icon: Icons.location_city_outlined,
          label: 'المدينة',
          value: cityLabel,
        ),
      );
    }

    return items;
  }

  /// Build contact info items (phone numbers)
  static List<InfoItem> buildContactInfoItems(dynamic beneficiary) {
    final items = <InfoItem>[];
    final primaryPhone = _normalizedPhone(beneficiary.phoneNumber);
    final altPhone = _normalizedPhone(beneficiary.altPhoneNumber);

    if (primaryPhone != null) {
      items.add(
        InfoItem(
          icon: Icons.phone,
          label: 'رقم الهاتف',
          value: primaryPhone,
        ),
      );
    }

    if (altPhone != null) {
      items.add(
        InfoItem(
          icon: Icons.phone_android,
          label: 'رقم هاتف بديل',
          value: altPhone,
        ),
      );
    }

    if (items.isEmpty) {
      items.add(
        InfoItem(
          icon: Icons.phone_disabled_outlined,
          label: 'معلومات الاتصال',
          value: 'لا يوجد رقم هاتف صالح',
        ),
      );
    }

    return items;
  }

  /// Build family info items (father, grandfather, marital status, etc.)
  static List<InfoItem> buildFamilyInfoItems(dynamic beneficiary) {
    final items = <InfoItem>[];

    if (beneficiary.motherName != null && beneficiary.motherName!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.person_outlined,
          label: 'اسم الأم',
          value: beneficiary.motherName!,
        ),
      );
    }

    if (beneficiary.fatherName != null && beneficiary.fatherName!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.person_outlined,
          label: 'اسم الأب',
          value: beneficiary.fatherName!,
        ),
      );
    }

    if (beneficiary.grandFatherName != null && beneficiary.grandFatherName!.isNotEmpty) {
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

    if (beneficiary.address != null && beneficiary.address!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.location_on,
          label: 'العنوان',
          value: beneficiary.address!,
        ),
      );
    }

    if (beneficiary.district != null && beneficiary.district!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.map_outlined,
          label: 'الحي/القضاء',
          value: beneficiary.district!,
        ),
      );
    }

    if (beneficiary.currentAddress != null && beneficiary.currentAddress!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.home,
          label: 'العنوان الحالي',
          value: beneficiary.currentAddress!,
        ),
      );
    }

    if (beneficiary.addressBeforeDisplacement != null && beneficiary.addressBeforeDisplacement!.isNotEmpty) {
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
  static List<InfoItem> buildEducationHealthItems(
    dynamic beneficiary, {
    Map<String, String> assistanceTypeLabelsByCode = const <String, String>{},
    Map<String, String> disabilityTypeLabelsByCode = const <String, String>{},
    Map<String, String> incomeSourceLabelsByCode = const <String, String>{},
  }) {
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

    if (beneficiary.hasDisability) {
      items.add(
        InfoItem(
          icon: Icons.accessible,
          label: 'يعاني من إعاقة',
          value: 'نعم',
          valueColor: Colors.orange,
        ),
      );
    }

    if (beneficiary.chronicDiseasesCount != null && beneficiary.chronicDiseasesCount! > 0) {
      items.add(
        InfoItem(
          icon: Icons.medical_services_outlined,
          label: 'عدد الأمراض المزمنة',
          value: beneficiary.chronicDiseasesCount.toString(),
        ),
      );
    }

    if (beneficiary.specialNeedsCount != null && beneficiary.specialNeedsCount! > 0) {
      items.add(
        InfoItem(
          icon: Icons.accessible_forward,
          label: 'ذوي الاحتياجات الخاصة',
          value: '${beneficiary.specialNeedsCount} أفراد',
        ),
      );
    }

    final metadata = _extractDetailsMetadata(beneficiary.notes);
    final assistanceTypeRaw = metadata['assistanceType'];
    final disabilityTypeRaw = metadata['disabilityType'];
    final incomeSourceRaw = metadata['incomeSource'];

    if (assistanceTypeRaw != null) {
      items.add(
        InfoItem(
          icon: Icons.handshake_outlined,
          label: 'نوع المساعدة',
          value: TaxonomyValueResolver.displayLabel(
            rawValue: assistanceTypeRaw,
            resolvedLabel: _resolveTaxonomyLabel(
              assistanceTypeRaw,
              assistanceTypeLabelsByCode,
            ),
          ),
        ),
      );
    }

    if (disabilityTypeRaw != null) {
      items.add(
        InfoItem(
          icon: Icons.accessible_forward_outlined,
          label: 'نوع الإعاقة',
          value: TaxonomyValueResolver.displayLabel(
            rawValue: disabilityTypeRaw,
            resolvedLabel: _resolveTaxonomyLabel(
              disabilityTypeRaw,
              disabilityTypeLabelsByCode,
            ),
          ),
        ),
      );
    }

    if (incomeSourceRaw != null) {
      items.add(
        InfoItem(
          icon: Icons.account_balance_wallet_outlined,
          label: 'مصدر الدخل',
          value: TaxonomyValueResolver.displayLabel(
            rawValue: incomeSourceRaw,
            resolvedLabel: _resolveTaxonomyLabel(
              incomeSourceRaw,
              incomeSourceLabelsByCode,
            ),
          ),
        ),
      );
    }

    return items;
  }

  static String? _cleanText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static String? _normalizedPhone(dynamic value) {
    final phone = value?.toString().trim();
    if (phone == null || phone.isEmpty || phone == '0') return null;
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty || int.tryParse(digits) == 0) return null;
    return phone;
  }

  static String? _resolveTaxonomyLabel(String? raw, Map<String, String> labelsByCode) {
    final value = _cleanText(raw);
    if (value == null) return null;

    return labelsByCode[value] ??
        labelsByCode[value.toLowerCase()] ??
        labelsByCode[value.trim()] ??
        labelsByCode[int.tryParse(value)?.toString() ?? ''];
  }

  static Map<String, String> _extractDetailsMetadata(String? notes) {
    final text = _cleanText(notes);
    if (text == null) return const <String, String>{};

    const marker = '\n\n#meta:';
    final markerIndex = text.lastIndexOf(marker);
    if (markerIndex == -1) return const <String, String>{};

    final rawJson = text.substring(markerIndex + marker.length).trim();
    if (rawJson.isEmpty) return const <String, String>{};

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map) return const <String, String>{};
      return decoded.map((key, value) => MapEntry(key.toString(), value.toString()));
    } catch (_) {
      return const <String, String>{};
    }
  }

  /// Build system metadata info items
  static List<InfoItem> buildSystemInfoItems(dynamic beneficiary) {
    final items = <InfoItem>[];

    if (beneficiary.associationName != null && beneficiary.associationName!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.business_outlined,
          label: 'اسم الجمعية',
          value: beneficiary.associationName!,
        ),
      );
    }

    if (beneficiary.requestStatus != null) {
      items.add(
        InfoItem(
          icon: Icons.info_outlined,
          label: 'حالة الطلب',
          value: BeneficiaryDomainHelpers.getRequestStatusLabel(
            beneficiary.requestStatus,
          ),
        ),
      );
    }

    items.addAll([
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
    ]);

    return items;
  }
}
