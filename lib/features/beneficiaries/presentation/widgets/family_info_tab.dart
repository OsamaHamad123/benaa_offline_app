import 'package:benaa_offline_app/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

/// 👨‍👩‍👧‍👦 Family Info Tab Widget
///
/// Contains: Mother Name, Father Name, Grandfather Name, Family Name,
/// Family Size, Number of Males/Females/Children/Elderly
class FamilyInfoTab extends StatelessWidget {
  final TextEditingController motherNameController;
  final TextEditingController fatherNameController;
  final TextEditingController grandFatherNameController;
  final TextEditingController familyNameController;
  final TextEditingController familySizeController;
  final TextEditingController numMalesController;
  final TextEditingController numFemalesController;
  final TextEditingController numChildrenController;
  final TextEditingController numElderlyController;
  final bool hasPwd;
  final bool hasChronicallyIll;
  final Function(bool) onHasPwdChanged;
  final Function(bool) onHasChronicallyIllChanged;

  const FamilyInfoTab({
    required this.motherNameController, required this.fatherNameController, required this.grandFatherNameController, required this.familyNameController, required this.familySizeController, required this.numMalesController, required this.numFemalesController, required this.numChildrenController, required this.numElderlyController, required this.hasPwd, required this.hasChronicallyIll, required this.onHasPwdChanged, required this.onHasChronicallyIllChanged, super.key,
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
          // معلومات الأسماء
          _buildSectionHeader(
            'معلومات العائلة',
            Icons.family_restroom,
            colorScheme,
          ),
          SizedBox(height: AppDimensions.md),

          TextField(
            controller: motherNameController,
            decoration: InputDecoration(
              labelText: 'اسم الأم',
              hintText: 'الاسم الثلاثي للأم',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: AppDimensions.md),

          TextField(
            controller: fatherNameController,
            decoration: InputDecoration(
              labelText: 'اسم الأب',
              hintText: 'الاسم الثلاثي للأب',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: grandFatherNameController,
            decoration: InputDecoration(
              labelText: 'اسم الجد',
              hintText: 'الاسم الثلاثي للجد',
              prefixIcon: const Icon(Icons.elderly),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: familyNameController,
            decoration: InputDecoration(
              labelText: 'اسم العائلة',
              hintText: 'اللقب',
              prefixIcon: const Icon(Icons.home),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: AppDimensions.lg),

          // معلومات الأسرة
          _buildSectionHeader('معلومات الأسرة', Icons.groups, colorScheme),
          SizedBox(height: AppDimensions.md),

          TextField(
            controller: familySizeController,
            decoration: InputDecoration(
              labelText: 'عدد أفراد الأسرة',
              hintText: '5',
              prefixIcon: const Icon(Icons.people),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusLG,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: AppDimensions.md),

          // الذكور والإناث في صف واحد
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: numMalesController,
                  decoration: InputDecoration(
                    labelText: 'عدد الذكور',
                    hintText: '3',
                    prefixIcon: const Icon(Icons.male),
                    border: OutlineInputBorder(
                      borderRadius: AppDimensions.borderRadiusLG,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: numFemalesController,
                  decoration: InputDecoration(
                    labelText: 'عدد الإناث',
                    hintText: '2',
                    prefixIcon: const Icon(Icons.female),
                    border: OutlineInputBorder(
                      borderRadius: AppDimensions.borderRadiusLG,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.md),

          // الأطفال وكبار السن في صف واحد
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: numChildrenController,
                  decoration: InputDecoration(
                    labelText: 'عدد الأطفال',
                    hintText: '2',
                    prefixIcon: const Icon(Icons.child_care),
                    border: OutlineInputBorder(
                      borderRadius: AppDimensions.borderRadiusLG,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: numElderlyController,
                  decoration: InputDecoration(
                    labelText: 'عدد كبار السن',
                    hintText: '1',
                    prefixIcon: const Icon(Icons.elderly),
                    border: OutlineInputBorder(
                      borderRadius: AppDimensions.borderRadiusLG,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.lg),

          // حالات خاصة
          _buildSectionHeader('حالات خاصة', Icons.accessible, colorScheme),
          SizedBox(height: AppDimensions.md),

          SwitchListTile(
            title: const Text('يوجد أفراد من ذوي الاحتياجات الخاصة'),
            subtitle: const Text('أشخاص يحتاجون رعاية خاصة'),
            value: hasPwd,
            onChanged: onHasPwdChanged,
            secondary: const Icon(Icons.accessible),
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.borderRadiusLG,
              side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
            ),
          ),
          SizedBox(height: AppDimensions.md12),

          SwitchListTile(
            title: const Text('يوجد أفراد يعانون من أمراض مزمنة'),
            subtitle: const Text('أمراض تحتاج علاج مستمر'),
            value: hasChronicallyIll,
            onChanged: onHasChronicallyIllChanged,
            secondary: const Icon(Icons.medication),
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.borderRadiusLG,
              side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
            ),
          ),
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
}
