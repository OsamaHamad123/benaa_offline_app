import 'package:flutter/material.dart';

/// 📊 Tab Progress Calculator
/// حساب نسبة اكتمال كل تاب
class TabProgressCalculator {
  /// حساب نسبة اكتمال التاب الأول (المعلومات الأساسية)
  static double calculateBasicInfoProgress({
    required String fullName,
    required String nationalId,
    required String fileNo,
    required String governorate,
    required String gender,
    required String category,
    String? associationName,
    String? birthDate,
    String? maritalStatus,
    String? educationLevel,
  }) {
    const int total = 10;
    int filled = 0;

    if (fullName.isNotEmpty) filled++;
    if (nationalId.isNotEmpty) filled++;
    if (fileNo.isNotEmpty) filled++;
    if (governorate.isNotEmpty) filled++;
    if (gender.isNotEmpty) filled++;
    if (category.isNotEmpty) filled++;
    if (associationName?.isNotEmpty ?? false) filled++;
    if (birthDate?.isNotEmpty ?? false) filled++;
    if (maritalStatus != null) filled++;
    if (educationLevel != null) filled++;

    return filled / total;
  }

  /// حساب نسبة اكتمال تاب العائلة
  static double calculateFamilyProgress({
    String? motherName,
    String? fatherName,
    String? grandFatherName,
    String? familyName,
    String? familySize,
    String? numberOfMales,
    String? numberOfFemales,
  }) {
    const int total = 7;
    int filled = 0;

    if (motherName?.isNotEmpty ?? false) filled++;
    if (fatherName?.isNotEmpty ?? false) filled++;
    if (grandFatherName?.isNotEmpty ?? false) filled++;
    if (familyName?.isNotEmpty ?? false) filled++;
    if (familySize?.isNotEmpty ?? false) filled++;
    if (numberOfMales?.isNotEmpty ?? false) filled++;
    if (numberOfFemales?.isNotEmpty ?? false) filled++;

    return filled / total;
  }

  /// حساب نسبة اكتمال تاب الموقع
  static double calculateLocationProgress({
    String? phoneNumber,
    String? altPhoneNumber,
    String? district,
    String? address,
    String? currentAddress,
    String? addressBeforeDisplacement,
    int? displacementStatus,
    int? employmentStatus,
    int? housingStatus,
    int? housingType,
  }) {
    const int total = 10;
    int filled = 0;

    if (phoneNumber?.isNotEmpty ?? false) filled++;
    if (altPhoneNumber?.isNotEmpty ?? false) filled++;
    if (district?.isNotEmpty ?? false) filled++;
    if (address?.isNotEmpty ?? false) filled++;
    if (currentAddress?.isNotEmpty ?? false) filled++;
    if (addressBeforeDisplacement?.isNotEmpty ?? false) filled++;
    if (displacementStatus != null) filled++;
    if (employmentStatus != null) filled++;
    if (housingStatus != null) filled++;
    if (housingType != null) filled++;

    return filled / total;
  }

  /// حساب نسبة اكتمال تاب الصحة
  static double calculateHealthProgress({
    required String healthStatus,
    required bool hasDisability,
    String? chronicDiseasesCount,
    String? specialNeedsCount,
    int? requestStatus,
    String? notes,
  }) {
    const int total = 6;
    int filled = 0;

    if (healthStatus.isNotEmpty) filled++;
    filled++; // hasDisability always has value
    if (chronicDiseasesCount?.isNotEmpty ?? false) filled++;
    if (specialNeedsCount?.isNotEmpty ?? false) filled++;
    if (requestStatus != null) filled++;
    if (notes?.isNotEmpty ?? false) filled++;

    return filled / total;
  }

  /// حساب النسبة الإجمالية
  static double calculateOverallProgress({
    required double basicProgress,
    required double familyProgress,
    required double locationProgress,
    required double healthProgress,
  }) {
    return (basicProgress +
            familyProgress +
            locationProgress +
            healthProgress) /
        4;
  }
}

/// Widget لعرض Progress في التاب
class TabProgressIndicator extends StatelessWidget {
  final double progress;
  final Color? color;

  const TabProgressIndicator({required this.progress, super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? Theme.of(context).colorScheme.primary;
    final percentage = (progress * 100).round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 4,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: progressColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(progressColor),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: progressColor,
          ),
        ),
      ],
    );
  }
}
