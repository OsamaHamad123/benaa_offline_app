/// 🆔 Civil Registry Person Entity
///
/// Represents a person record from the civil registry database.
/// This is a pure domain entity with no dependencies on external packages.
class CivilRegistryPerson {
  final String nationalId;
  final String firstName;
  final String fatherName;
  final String? grandfatherName;
  final String lastName;
  final String? motherName;
  final DateTime? birthDate;
  final String? gender; // 'ذكر' or 'أنثى'
  final String? birthPlace;
  final String? address;
  final String? province;
  final String? city;
  final DateTime? registrationDate;
  final String? status; // 'active', 'deceased', etc.

  const CivilRegistryPerson({
    required this.nationalId,
    required this.firstName,
    required this.fatherName,
    this.grandfatherName,
    required this.lastName,
    this.motherName,
    this.birthDate,
    this.gender,
    this.birthPlace,
    this.address,
    this.province,
    this.city,
    this.registrationDate,
    this.status,
  });

  /// Full name in Arabic format
  String get fullName {
    final parts = [
      firstName,
      fatherName,
      if (grandfatherName?.isNotEmpty ?? false) grandfatherName,
      lastName,
    ];
    return parts.join(' ');
  }

  /// Check if person is active in civil registry
  bool get isActive => status == null || status == 'active';

  /// Age calculation
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CivilRegistryPerson &&
          runtimeType == other.runtimeType &&
          nationalId == other.nationalId;

  @override
  int get hashCode => nationalId.hashCode;

  @override
  String toString() =>
      'CivilRegistryPerson(nationalId: $nationalId, name: $fullName)';

  /// Create a copy with updated fields
  CivilRegistryPerson copyWith({
    String? nationalId,
    String? firstName,
    String? fatherName,
    String? grandfatherName,
    String? lastName,
    String? motherName,
    DateTime? birthDate,
    String? gender,
    String? birthPlace,
    String? address,
    String? province,
    String? city,
    DateTime? registrationDate,
    String? status,
  }) {
    return CivilRegistryPerson(
      nationalId: nationalId ?? this.nationalId,
      firstName: firstName ?? this.firstName,
      fatherName: fatherName ?? this.fatherName,
      grandfatherName: grandfatherName ?? this.grandfatherName,
      lastName: lastName ?? this.lastName,
      motherName: motherName ?? this.motherName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      birthPlace: birthPlace ?? this.birthPlace,
      address: address ?? this.address,
      province: province ?? this.province,
      city: city ?? this.city,
      registrationDate: registrationDate ?? this.registrationDate,
      status: status ?? this.status,
    );
  }
}
