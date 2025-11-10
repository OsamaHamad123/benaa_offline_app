import 'package:flutter/material.dart';

class BeneficiaryConstants {
  // Governorates
  static const List<DropdownMenuItem<String>> governorateItems = [
    DropdownMenuItem(value: 'بغداد', child: Text('بغداد')),
    DropdownMenuItem(value: 'البصرة', child: Text('البصرة')),
    DropdownMenuItem(value: 'نينوى', child: Text('نينوى')),
    DropdownMenuItem(value: 'الأنبار', child: Text('الأنبار')),
    DropdownMenuItem(value: 'ديالى', child: Text('ديالى')),
    DropdownMenuItem(value: 'كربلاء', child: Text('كربلاء')),
    DropdownMenuItem(value: 'النجف', child: Text('النجف')),
    DropdownMenuItem(value: 'ذي قار', child: Text('ذي قار')),
    DropdownMenuItem(value: 'القادسية', child: Text('القادسية')),
    DropdownMenuItem(value: 'بابل', child: Text('بابل')),
    DropdownMenuItem(value: 'كركوك', child: Text('كركوك')),
    DropdownMenuItem(value: 'واسط', child: Text('واسط')),
    DropdownMenuItem(value: 'صلاح الدين', child: Text('صلاح الدين')),
    DropdownMenuItem(value: 'ميسان', child: Text('ميسان')),
    DropdownMenuItem(value: 'المثنى', child: Text('المثنى')),
  ];

  // Gender
  static const List<DropdownMenuItem<String>> genderItems = [
    DropdownMenuItem(value: 'male', child: Text('ذكر')),
    DropdownMenuItem(value: 'female', child: Text('أنثى')),
  ];

  // Categories
  static const List<DropdownMenuItem<String>> categoryItems = [
    DropdownMenuItem(value: 'orphan', child: Text('يتيم')),
    DropdownMenuItem(value: 'widow', child: Text('أرملة')),
    DropdownMenuItem(value: 'poor', child: Text('فقير')),
    DropdownMenuItem(value: 'disabled', child: Text('معاق')),
  ];

  // Health Status
  static const List<DropdownMenuItem<String>> healthStatusItems = [
    DropdownMenuItem(value: 'good', child: Text('جيدة')),
    DropdownMenuItem(value: 'fair', child: Text('متوسطة')),
    DropdownMenuItem(value: 'poor', child: Text('ضعيفة')),
  ];

  // Default values
  static const String defaultGovernorate = 'بغداد';
  static const String defaultGender = 'male';
  static const String defaultCategory = 'orphan';
  static const String defaultHealthStatus = 'good';
  static const int defaultFamilySize = 1;
}
