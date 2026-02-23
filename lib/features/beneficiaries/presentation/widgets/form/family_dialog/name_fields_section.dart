import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../pages/v2_form_helpers/widgets/material3_components.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';

/// 🎯 Name Fields Section
///
/// قسم حقول الاسم الكامل (الاسم الأول، الأب، الجد، اللقب)
class NameFieldsSection extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController secondNameController;
  final TextEditingController thirdNameController;
  final TextEditingController familyNameController;
  final FocusNode? firstNameFocus;
  final FocusNode? secondNameFocus;
  final FocusNode? thirdNameFocus;
  final FocusNode? familyNameFocus;

  const NameFieldsSection({
    required this.firstNameController, required this.secondNameController, required this.thirdNameController, required this.familyNameController, super.key,
    this.firstNameFocus,
    this.secondNameFocus,
    this.thirdNameFocus,
    this.familyNameFocus,
  });

  @override
  Widget build(BuildContext context) {
    return M3SectionCard(
      title: 'الاسم الكامل',
      icon: Icons.person_rounded,
      children: [
        ResponsiveFormLayout(
          children: [
            M3TextField(
              controller: firstNameController,
              label: 'الاسم الأول',
              prefixIcon: Icons.person_rounded,
              isRequired: true,
              focusNode: firstNameFocus,
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
              ],
            ),
            M3TextField(
              controller: secondNameController,
              label: 'اسم الأب',
              prefixIcon: Icons.person_outline_rounded,
              focusNode: secondNameFocus,
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        ResponsiveFormLayout(
          children: [
            M3TextField(
              controller: thirdNameController,
              label: 'اسم الجد',
              prefixIcon: Icons.elderly_rounded,
              focusNode: thirdNameFocus,
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
              ],
            ),
            M3TextField(
              controller: familyNameController,
              label: 'اللقب',
              prefixIcon: Icons.family_restroom_rounded,
              isRequired: true,
              focusNode: familyNameFocus,
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
