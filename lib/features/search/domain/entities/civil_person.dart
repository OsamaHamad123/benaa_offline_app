/// 👤 Civil Person Entity - Domain Layer
///
/// This represents the core business object for a person in civil registry.
/// Independent of any data source or framework.
class CivilPerson {
  final String nationalId;
  final String firstName;
  final String fatherName;
  final String grandFatherName;
  final String familyName;
  final String? motherName;
  final Gender gender;
  final String? birthDate;
  final String? city;
  final String? governorate;

  const CivilPerson({
    required this.nationalId,
    required this.firstName,
    required this.fatherName,
    required this.grandFatherName,
    required this.familyName,
    this.motherName,
    required this.gender,
    this.birthDate,
    this.city,
    this.governorate,
  });

  /// Get full name
  String get fullName {
    return '$firstName $fatherName $grandFatherName $familyName'.trim();
  }

  /// Get display name (first + family)
  String get displayName {
    return '$firstName $familyName'.trim();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CivilPerson && other.nationalId == nationalId;
  }

  @override
  int get hashCode => nationalId.hashCode;

  @override
  String toString() => 'CivilPerson(nationalId: $nationalId, name: $fullName)';
}

/// 🚻 Gender enum
enum Gender {
  male('ذكر'),
  female('أنثى'),
  unknown('غير محدد');

  final String arabicLabel;
  const Gender(this.arabicLabel);

  static Gender fromCode(int? code) {
    switch (code) {
      case 1:
        return Gender.male;
      case 2:
        return Gender.female;
      default:
        return Gender.unknown;
    }
  }

  int get code {
    switch (this) {
      case Gender.male:
        return 1;
      case Gender.female:
        return 2;
      default:
        return 0;
    }
  }
}
