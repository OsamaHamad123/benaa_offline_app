import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/pages/details_widgets/helpers/info_builders.dart';

void main() {
  Beneficiary buildBaseBeneficiary({
    String? phoneNumber,
    String? altPhoneNumber,
    String? governorate,
    String? district,
    int? sectionId,
    String? notes,
  }) {
    return Beneficiary(
      id: '1',
      fullName: 'محمد أحمد',
      nationalId: '123456789',
      gender: Gender.male,
      category: BeneficiaryCategory.other,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
      phoneNumber: phoneNumber,
      altPhoneNumber: altPhoneNumber,
      governorate: governorate,
      district: district,
      sectionId: sectionId,
      notes: notes,
      healthStatus: HealthStatus.good,
    );
  }

  group('InfoBuilders.buildContactInfoItems', () {
    test('hides invalid phone numbers and shows fallback when none valid', () {
      final beneficiary = buildBaseBeneficiary(
        phoneNumber: '0',
        altPhoneNumber: '0000',
      );

      final items = InfoBuilders.buildContactInfoItems(beneficiary);

      expect(items, hasLength(1));
      expect(items.first.label, 'معلومات الاتصال');
      expect(items.first.value, 'لا يوجد رقم هاتف صالح');
    });

    test('shows valid phone numbers only', () {
      final beneficiary = buildBaseBeneficiary(
        phoneNumber: '0599123456',
        altPhoneNumber: '0',
      );

      final items = InfoBuilders.buildContactInfoItems(beneficiary);

      expect(items, hasLength(1));
      expect(items.first.label, 'رقم الهاتف');
      expect(items.first.value, '0599123456');
    });
  });

  group('InfoBuilders.buildBasicInfoItems', () {
    test('prefers taxonomy labels for category/governorate/city', () {
      final beneficiary = buildBaseBeneficiary(
        governorate: '10',
        district: '21',
        sectionId: 3,
      );

      final items = InfoBuilders.buildBasicInfoItems(
        beneficiary,
        categoryLabelsByCode: const {'3': 'تصنيف ديناميكي'},
        governorateLabelsByCode: const {'10': 'محافظة ديناميكية'},
        cityLabelsByCode: const {'21': 'مدينة ديناميكية'},
      );

      final categoryItem = items.firstWhere((item) => item.label == 'الفئة');
      final governorateItem = items.firstWhere((item) => item.label == 'المحافظة');
      final cityItem = items.firstWhere((item) => item.label == 'المدينة');

      expect(categoryItem.value, 'تصنيف ديناميكي');
      expect(governorateItem.value, 'محافظة ديناميكية');
      expect(cityItem.value, 'مدينة ديناميكية');
    });
  });

  group('InfoBuilders.buildEducationHealthItems', () {
    test('extracts and renders metadata-backed extra fields', () {
      final beneficiary = buildBaseBeneficiary(
        notes: 'ملاحظة مهمة\n\n#meta:{"assistanceType":"A1","disabilityType":"D3","incomeSource":"I2"}',
      );

      final items = InfoBuilders.buildEducationHealthItems(
        beneficiary,
        assistanceTypeLabelsByCode: const {'A1': 'مساعدة غذائية'},
        disabilityTypeLabelsByCode: const {'D3': 'إعاقة حركية'},
        incomeSourceLabelsByCode: const {'I2': 'عمل يومي'},
      );

      final assistanceItem = items.firstWhere((item) => item.label == 'نوع المساعدة');
      final disabilityItem = items.firstWhere((item) => item.label == 'نوع الإعاقة');
      final incomeItem = items.firstWhere((item) => item.label == 'مصدر الدخل');

      expect(assistanceItem.value, 'مساعدة غذائية');
      expect(disabilityItem.value, 'إعاقة حركية');
      expect(incomeItem.value, 'عمل يومي');
    });
  });
}
