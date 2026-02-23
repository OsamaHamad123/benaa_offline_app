import 'package:benaa_offline_app/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:benaa_offline_app/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

/// 📋 Basic Info Tab Widget
///
/// Contains: Full Name, National ID, Gender, Category, Birth Date, File No, Association
class BasicInfoTab extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController nationalIdController;
  final TextEditingController fileNoController;
  final TextEditingController associationNameController;
  final TextEditingController birthDateController;
  final Gender gender;
  final BeneficiaryCategory category;
  final DateTime? birthDate;
  final Function(Gender) onGenderChanged;
  final Function(BeneficiaryCategory) onCategoryChanged;
  final VoidCallback onScanQR;
  final VoidCallback onSelectDate;

  const BasicInfoTab({
    required this.fullNameController, required this.nationalIdController, required this.fileNoController, required this.associationNameController, required this.birthDateController, required this.gender, required this.category, required this.birthDate, required this.onGenderChanged, required this.onCategoryChanged, required this.onScanQR, required this.onSelectDate, super.key,
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
          // الاسم الكامل
          TextField(
            controller: fullNameController,
            decoration: InputDecoration(
              labelText: 'الاسم الكامل *',
              hintText: 'أدخل الاسم الرباعي',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusMD,
              ),
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: AppDimensions.md),

          // الرقم الوطني مع QR Scanner
          TextField(
            controller: nationalIdController,
            decoration: InputDecoration(
              labelText: 'الرقم الوطني *',
              hintText: '12345678901',
              prefixIcon: const Icon(Icons.badge),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: onScanQR,
                tooltip: 'مسح QR Code',
              ),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusMD,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: AppDimensions.md),

          // الجنس والفئة في صف واحد
          Row(
            children: [
              Expanded(child: _buildGenderSelector(colorScheme)),
              SizedBox(width: AppDimensions.md),
              Expanded(child: _buildCategorySelector(colorScheme)),
            ],
          ),
          SizedBox(height: AppDimensions.md),

          // تاريخ الميلاد
          TextField(
            controller: birthDateController,
            decoration: InputDecoration(
              labelText: 'تاريخ الميلاد',
              hintText: 'اختر التاريخ',
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: birthDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        birthDateController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusMD,
              ),
            ),
            readOnly: true,
            onTap: onSelectDate,
          ),
          SizedBox(height: AppDimensions.md),

          // رقم الملف
          TextField(
            controller: fileNoController,
            decoration: InputDecoration(
              labelText: 'رقم الملف',
              hintText: 'F-2024-001',
              prefixIcon: const Icon(Icons.folder_outlined),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusMD,
              ),
            ),
          ),
          SizedBox(height: AppDimensions.md),

          // اسم الجمعية
          TextField(
            controller: associationNameController,
            decoration: InputDecoration(
              labelText: 'اسم الجمعية',
              hintText: 'جمعية بناء الخيرية',
              prefixIcon: const Icon(Icons.business),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusMD,
              ),
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الجنس *',
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: AppDimensions.xs),
        SegmentedButton<Gender>(
          segments: const [
            ButtonSegment(
              value: Gender.male,
              label: Text('ذكر'),
              icon: Icon(Icons.male),
            ),
            ButtonSegment(
              value: Gender.female,
              label: Text('أنثى'),
              icon: Icon(Icons.female),
            ),
          ],
          selected: {gender},
          onSelectionChanged: (Set<Gender> selection) {
            onGenderChanged(selection.first);
          },
        ),
      ],
    );
  }

  Widget _buildCategorySelector(ColorScheme colorScheme) {
    return DropdownButtonFormField<BeneficiaryCategory>(
      initialValue: category,
      decoration: InputDecoration(
        labelText: 'فئة المستفيد *',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: AppDimensions.borderRadiusMD),
      ),
      items: BeneficiaryCategory.values.map((cat) {
        return DropdownMenuItem(
          value: cat,
          child: Text(_getCategoryLabel(cat)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onCategoryChanged(value);
      },
    );
  }

  String _getCategoryLabel(BeneficiaryCategory category) {
    switch (category) {
      case BeneficiaryCategory.orphan:
        return 'يتيم';
      case BeneficiaryCategory.poor:
        return 'فقير';
      case BeneficiaryCategory.displaced:
        return 'نازح';
      case BeneficiaryCategory.disabled:
        return 'ذوي احتياجات خاصة';
      case BeneficiaryCategory.elderly:
        return 'مسن';
      case BeneficiaryCategory.martyr:
        return 'شهيد';
      case BeneficiaryCategory.injured:
        return 'جريح';
      case BeneficiaryCategory.widow:
        return 'أرملة';
      case BeneficiaryCategory.divorced:
        return 'مطلقة';
      case BeneficiaryCategory.prisoner:
        return 'أسير';
      case BeneficiaryCategory.other:
        return 'أخرى';
    }
  }
}
