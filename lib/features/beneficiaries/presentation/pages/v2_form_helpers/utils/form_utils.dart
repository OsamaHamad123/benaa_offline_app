import 'package:flutter/material.dart';

/// 🛠️ Form Utilities - مساعدات عامة للنماذج

class FormUtils {
  /// تنظيف النص (إزالة المسافات الزائدة)
  static String? cleanText(String? text) {
    return text?.trim().isEmpty ?? true ? null : text!.trim();
  }

  /// التحقق من صحة الرقم الوطني
  static bool isValidNationalId(String? nationalId, {int length = 9}) {
    if (nationalId == null || nationalId.isEmpty) return false;
    if (nationalId.length != length) return false;
    return RegExp(r'^\d+$').hasMatch(nationalId);
  }

  /// التحقق من صحة رقم الهاتف
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return cleaned.length >= 9 && cleaned.length <= 15;
  }

  /// تنسيق رقم الهاتف
  static String? formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // إذا لم يبدأ بـ + أو 00، أضف 00970
    if (!cleaned.startsWith('+') && !cleaned.startsWith('00')) {
      if (cleaned.startsWith('0')) {
        return '00970${cleaned.substring(1)}';
      }
      return '00970$cleaned';
    }

    return cleaned;
  }

  /// حساب العمر من تاريخ الميلاد
  static int? calculateAge(DateTime? birthDate) {
    if (birthDate == null) return null;
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// تنسيق التاريخ (dd/MM/yyyy)
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// تحليل التاريخ من نص (dd/MM/yyyy)
  static DateTime? parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;

    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  /// حساب عدد الحقول المملوءة
  static int countFilledFields(List<TextEditingController> controllers) {
    return controllers.where((c) => c.text.trim().isNotEmpty).length;
  }

  /// التحقق من اكتمال النموذج
  static bool isFormComplete(
    List<TextEditingController> requiredControllers,
    List<String?> requiredSelections,
  ) {
    // التحقق من الحقول النصية
    for (final controller in requiredControllers) {
      if (controller.text.trim().isEmpty) return false;
    }

    // التحقق من القوائم المنسدلة
    for (final selection in requiredSelections) {
      if (selection == null || selection.isEmpty) return false;
    }

    return true;
  }

  /// إنشاء اسم كامل من أجزاء
  static String buildFullName({
    String? firstName,
    String? fatherName,
    String? grandfatherName,
    String? lastName,
  }) {
    final parts = [
      firstName,
      fatherName,
      grandfatherName,
      lastName,
    ].where((part) => part != null && part.isNotEmpty);

    return parts.join(' ');
  }

  /// تطبيع الاسم للبحث (إزالة التشكيل والمسافات الزائدة)
  static String normalizeForSearch(String text) {
    // إزالة التشكيل العربي
    final normalized = text
        .replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .toLowerCase()
        .trim();

    // إزالة المسافات الزائدة
    return normalized.replaceAll(RegExp(r'\s+'), ' ');
  }

  /// التحقق من صحة الإيميل
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// تنسيق حجم الملف (bytes → KB/MB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// استخراج امتداد الملف
  static String? getFileExtension(String? fileName) {
    if (fileName == null || !fileName.contains('.')) return null;
    return fileName.split('.').last.toLowerCase();
  }

  /// التحقق من نوع الملف (صورة، PDF، إلخ)
  static bool isImageFile(String? fileName) {
    final ext = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  static bool isPdfFile(String? fileName) {
    return getFileExtension(fileName) == 'pdf';
  }

  /// تحويل قيمة boolean إلى نص عربي
  static String boolToArabic(bool? value) {
    if (value == null) return 'غير محدد';
    return value ? 'نعم' : 'لا';
  }

  /// الحصول على نص الجنس
  static String getGenderText(String? gender) {
    return switch (gender) {
      'male' => 'ذكر',
      'female' => 'أنثى',
      _ => 'غير محدد',
    };
  }

  /// الحصول على أيقونة الجنس
  static IconData getGenderIcon(String? gender) {
    return switch (gender) {
      'male' => Icons.male,
      'female' => Icons.female,
      _ => Icons.person,
    };
  }
}
