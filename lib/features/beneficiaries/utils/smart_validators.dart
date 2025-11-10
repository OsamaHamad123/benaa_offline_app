/// 🧠 Smart Validators - تحقق ذكي متقدم
class SmartValidators {
  /// التحقق من تطابق عدد أفراد الأسرة
  static String? validateFamilySize({
    String? familySize,
    String? numberOfMales,
    String? numberOfFemales,
  }) {
    if (familySize == null || familySize.isEmpty) return null;
    if (numberOfMales == null || numberOfMales.isEmpty) return null;
    if (numberOfFemales == null || numberOfFemales.isEmpty) return null;

    final total = int.tryParse(familySize);
    final males = int.tryParse(numberOfMales);
    final females = int.tryParse(numberOfFemales);

    if (total == null || males == null || females == null) return null;

    final sum = males + females;
    if (sum != total) {
      return 'عدد الذكور ($males) + الإناث ($females) = $sum لا يساوي العدد الكلي ($total)';
    }

    return null;
  }

  /// التحقق من العمر المنطقي
  static String? validateAge(DateTime? birthDate) {
    if (birthDate == null) return null;

    final now = DateTime.now();
    final age = now.year - birthDate.year;

    if (age < 0) {
      return 'تاريخ الميلاد لا يمكن أن يكون في المستقبل';
    }

    if (age > 120) {
      return 'العمر ($age سنة) غير منطقي';
    }

    // تحذير للأطفال الصغار جداً
    if (age < 1) {
      return null; // يمكن أن يكون رضيع
    }

    return null;
  }

  /// التحقق من صحة الرقم الوطني العراقي (checksum بسيط)
  static String? validateIraqiNationalId(String? nationalId) {
    if (nationalId == null || nationalId.isEmpty) return null;

    final digitsOnly = nationalId.replaceAll(RegExp(r'\D'), '');

    // الرقم الوطني العراقي: 11-12 رقم
    if (digitsOnly.length < 11 || digitsOnly.length > 12) {
      return 'الرقم الوطني يجب أن يكون 11-12 رقم';
    }

    // التحقق من أن جميع الأرقام ليست صفر
    if (digitsOnly == '0' * digitsOnly.length) {
      return 'الرقم الوطني غير صحيح';
    }

    // التحقق من أن الأرقام الأولى منطقية (رمز المحافظة)
    final governorateCode = int.tryParse(digitsOnly.substring(0, 2));
    if (governorateCode == null ||
        governorateCode < 1 ||
        governorateCode > 19) {
      return 'رمز المحافظة في الرقم الوطني غير صحيح';
    }

    return null;
  }

  /// استخراج المعلومات من الرقم الوطني العراقي
  static Map<String, dynamic>? extractInfoFromNationalId(String? nationalId) {
    if (nationalId == null || nationalId.isEmpty) return null;

    final digitsOnly = nationalId.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 11) return null;

    try {
      // رمز المحافظة (أول رقمين)
      final governorateCode = int.parse(digitsOnly.substring(0, 2));

      // سنة الميلاد (الأرقام 3-6)
      final yearStr = digitsOnly.substring(2, 6);
      final year = int.parse(yearStr);

      // شهر الميلاد (الأرقام 7-8)
      final monthStr = digitsOnly.substring(6, 8);
      final month = int.parse(monthStr);

      // يوم الميلاد (الأرقام 9-10)
      final dayStr = digitsOnly.substring(8, 10);
      final day = int.parse(dayStr);

      // الجنس (آخر رقم - فردي للذكور، زوجي للإناث)
      final lastDigit = int.parse(digitsOnly[digitsOnly.length - 1]);
      final gender = lastDigit.isOdd ? 'male' : 'female';

      // تاريخ الميلاد
      DateTime? birthDate;
      try {
        birthDate = DateTime(year, month, day);
      } catch (e) {
        // تاريخ غير صحيح
        return null;
      }

      // المحافظة
      final governorate = _getGovernorateFromCode(governorateCode);

      return {
        'governorate': governorate,
        'birthDate': birthDate,
        'gender': gender,
        'age': DateTime.now().year - year,
      };
    } catch (e) {
      return null;
    }
  }

  /// تحويل رمز المحافظة إلى اسم
  static String _getGovernorateFromCode(int code) {
    const governorates = {
      1: 'بغداد',
      2: 'نينوى',
      3: 'البصرة',
      4: 'ذي قار',
      5: 'القادسية',
      6: 'المثنى',
      7: 'ديالى',
      8: 'الأنبار',
      9: 'كركوك',
      10: 'صلاح الدين',
      11: 'بابل',
      12: 'النجف',
      13: 'كربلاء',
      14: 'واسط',
      15: 'ميسان',
      16: 'أربيل',
      17: 'دهوك',
      18: 'السليمانية',
      19: 'حلبجة',
    };

    return governorates[code] ?? '';
  }

  /// التحقق من الأرقام الموجبة فقط
  static String? validatePositiveCount(String? value, String fieldName) {
    if (value == null || value.isEmpty) return null;

    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName يجب أن يكون رقم صحيح';
    }

    if (number < 0) {
      return '$fieldName لا يمكن أن يكون سالباً';
    }

    if (number > 100) {
      return '$fieldName ($number) يبدو كبير جداً. تأكد من الرقم';
    }

    return null;
  }
}
