import 'package:flutter/material.dart';

/// 🛠️ Helper Functions للمستفيدين
class BeneficiaryHelpers {
  BeneficiaryHelpers._(); // Private constructor (Utility class)

  /// استخراج الأحرف الأولى من الاسم
  static String getInitials(String name) {
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '؟';
    if (parts.length == 1) return parts[0][0];
    return '${parts[0][0]}${parts[1][0]}';
  }

  /// الحصول على لون الفئة
  static Color getCategoryColor(int? sectionId) {
    switch (sectionId) {
      case 1:
        return Colors.blue; // يتيم
      case 2:
        return Colors.purple; // أرملة
      case 3:
        return Colors.orange; // فقير
      case 4:
        return Colors.red; // معاق
      default:
        return Colors.grey;
    }
  }

  /// الحصول على تسمية الفئة
  static String getCategoryLabel(int? sectionId) {
    switch (sectionId) {
      case 1:
        return 'يتيم';
      case 2:
        return 'أرملة';
      case 3:
        return 'فقير';
      case 4:
        return 'معاق';
      default:
        return 'غير محدد';
    }
  }

  /// الحصول على اسم المحافظة
  /// TODO: يمكن تحسينها من خلال جلب البيانات من قاعدة البيانات
  static String getProvinceName(int? provinceId) {
    if (provinceId == null) return 'غير محدد';

    // يمكن استبدالها بـ lookup من قاعدة البيانات
    final provinceNames = {
      1: 'بغداد',
      2: 'البصرة',
      3: 'نينوى',
      4: 'الأنبار',
      5: 'ديالى',
      6: 'صلاح الدين',
      7: 'النجف',
      8: 'كربلاء',
      9: 'بابل',
      10: 'واسط',
      11: 'ذي قار',
      12: 'ميسان',
      13: 'المثنى',
      14: 'القادسية',
      15: 'كركوك',
      16: 'السليمانية',
      17: 'أربيل',
      18: 'دهوك',
    };

    return provinceNames[provinceId] ?? 'محافظة $provinceId';
  }

  /// التحقق من حالة المزامنة
  static bool isPending(String? syncState) {
    return syncState != null && syncState != 'synced';
  }

  /// التحقق من وجود موقع GPS
  static bool hasLocation(double? latitude, double? longitude) {
    return latitude != null && longitude != null;
  }

  /// التحقق من وجود رقم هاتف
  static bool hasPhone(String? phoneNumber) {
    return phoneNumber != null && phoneNumber.isNotEmpty;
  }

  /// تنسيق رقم الهاتف
  static String formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return 'لا يوجد';

    // إزالة المسافات والرموز
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // إضافة مفتاح الدولة إذا لم يكن موجوداً
    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('07')) {
        return '+964${cleaned.substring(1)}';
      }
      return cleaned;
    }

    return cleaned;
  }

  /// حساب العمر من تاريخ الميلاد
  static int? calculateAge(DateTime? birthDate) {
    if (birthDate == null) return null;

    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// تنسيق العمر مع النص
  static String formatAge(int? age) {
    if (age == null) return 'غير محدد';
    if (age < 2) return 'سنة واحدة';
    if (age < 11) return '$age سنوات';
    return '$age سنة';
  }
}
