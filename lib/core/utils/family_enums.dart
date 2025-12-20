/// 🏷️ Family Related Enums
/// جميع الـ enums المتعلقة بالعائلة موحدة مع جدول المستفيدين
library;

/// نوع المتوفى
class DeceasedType {
  static const int father = 1; // أب
  static const int mother = 2; // أم

  static String toArabic(int type) {
    switch (type) {
      case father:
        return 'أب';
      case mother:
        return 'أم';
      default:
        return 'غير معروف';
    }
  }

  static int fromArabic(String arabic) {
    switch (arabic) {
      case 'أب':
        return father;
      case 'أم':
        return mother;
      default:
        return father;
    }
  }

  static int fromEnglish(String english) {
    switch (english.toLowerCase()) {
      case 'father':
        return father;
      case 'mother':
        return mother;
      default:
        return father;
    }
  }

  static String toEnglish(int type) {
    switch (type) {
      case father:
        return 'father';
      case mother:
        return 'mother';
      default:
        return 'unknown';
    }
  }
}

/// سبب الوفاة
class DeathCause {
  static const int natural = 1; // طبيعية
  static const int disease = 2; // مرض
  static const int sudden = 3; // فجأة
  static const int accident = 4; // حادث
  static const int other = 5; // أخرى
  static const int suicide = 6; // انتحار
  static const int murdered = 7; // مغدور
  static const int unknown = 8; // غير معروف

  static String toArabic(int cause) {
    switch (cause) {
      case natural:
        return 'طبيعية';
      case disease:
        return 'مرض';
      case sudden:
        return 'فجأة';
      case accident:
        return 'حادث';
      case other:
        return 'أخرى';
      case suicide:
        return 'انتحار';
      case murdered:
        return 'مغدور';
      case unknown:
        return 'غير معروف';
      default:
        return 'غير معروف';
    }
  }

  static int fromArabic(String arabic) {
    switch (arabic) {
      case 'طبيعية':
        return natural;
      case 'مرض':
        return disease;
      case 'فجأة':
        return sudden;
      case 'حادث':
        return accident;
      case 'أخرى':
        return other;
      case 'انتحار':
        return suicide;
      case 'مغدور':
        return murdered;
      case 'غير معروف':
        return unknown;
      default:
        return unknown;
    }
  }

  static List<int> get allValues => [
        natural,
        disease,
        sudden,
        accident,
        other,
        suicide,
        murdered,
        unknown,
      ];

  static Map<int, String> get allArabic => {
        natural: toArabic(natural),
        disease: toArabic(disease),
        sudden: toArabic(sudden),
        accident: toArabic(accident),
        other: toArabic(other),
        suicide: toArabic(suicide),
        murdered: toArabic(murdered),
        unknown: toArabic(unknown),
      };
}

/// نوع الوثيقة
class DocumentType {
  static const int deathCertificate = 1; // شهادة وفاة
  static const int martyrCertificate = 2; // إفادة شهيد

  static String toArabic(int type) {
    switch (type) {
      case deathCertificate:
        return 'شهادة وفاة';
      case martyrCertificate:
        return 'إفادة شهيد';
      default:
        return 'غير معروف';
    }
  }

  static int fromArabic(String arabic) {
    switch (arabic) {
      case 'شهادة وفاة':
        return deathCertificate;
      case 'إفادة شهيد':
        return martyrCertificate;
      default:
        return deathCertificate;
    }
  }

  static Map<int, String> get allArabic => {
        deathCertificate: toArabic(deathCertificate),
        martyrCertificate: toArabic(martyrCertificate),
      };
}

/// الجنس (موحد مع جدول المستفيدين)
class Gender {
  static const int male = 1; // ذكر
  static const int female = 2; // أنثى

  static String toArabic(int gender) {
    switch (gender) {
      case male:
        return 'ذكر';
      case female:
        return 'أنثى';
      default:
        return 'غير معروف';
    }
  }

  static int fromArabic(String arabic) {
    switch (arabic) {
      case 'ذكر':
        return male;
      case 'أنثى':
        return female;
      default:
        return male;
    }
  }

  static int fromEnglish(String english) {
    switch (english.toLowerCase()) {
      case 'male':
        return male;
      case 'female':
        return female;
      default:
        return male;
    }
  }

  static String toEnglish(int gender) {
    switch (gender) {
      case male:
        return 'male';
      case female:
        return 'female';
      default:
        return 'unknown';
    }
  }

  static Map<int, String> get allArabic => {
        male: toArabic(male),
        female: toArabic(female),
      };
}

/// الحالة الصحية
class HealthStatus {
  static const int healthy = 1; // سليم
  static const int sick = 2; // مريض
  static const int chronic = 3; // مريض مزمن
  static const int disabled = 4; // معاق
  static const int unknown = 5; // غير معروف

  static String toArabic(int status) {
    switch (status) {
      case healthy:
        return 'سليم';
      case sick:
        return 'مريض';
      case chronic:
        return 'مريض مزمن';
      case disabled:
        return 'معاق';
      case unknown:
        return 'غير معروف';
      default:
        return 'غير معروف';
    }
  }

  static int fromArabic(String arabic) {
    switch (arabic) {
      case 'سليم':
        return healthy;
      case 'مريض':
        return sick;
      case 'مريض مزمن':
        return chronic;
      case 'معاق':
        return disabled;
      case 'غير معروف':
        return unknown;
      default:
        return unknown;
    }
  }

  static List<int> get allValues => [healthy, sick, chronic, disabled, unknown];

  static Map<int, String> get allArabic => {
        healthy: toArabic(healthy),
        sick: toArabic(sick),
        chronic: toArabic(chronic),
        disabled: toArabic(disabled),
        unknown: toArabic(unknown),
      };
}
