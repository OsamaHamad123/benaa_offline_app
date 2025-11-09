import 'package:json_annotation/json_annotation.dart';

part 'beneficiary.g.dart';

@JsonSerializable()
class Beneficiary {
  final String id;
  final String fullName;
  final String fullNameNorm;
  final String nationalId;
  final String fileNo;
  final String governorate;
  final String gender;
  final String category;
  final DateTime? birthDate;
  final String notes;
  final String? associationName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;

  const Beneficiary({
    required this.id,
    required this.fullName,
    required this.fullNameNorm,
    required this.nationalId,
    required this.fileNo,
    required this.governorate,
    required this.gender,
    required this.category,
    this.birthDate,
    this.notes = '',
    this.associationName,
    required this.createdAt,
    required this.updatedAt,
    this.syncState = 'pending',
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) =>
      _$BeneficiaryFromJson(json);

  Map<String, dynamic> toJson() => _$BeneficiaryToJson(this);

  Beneficiary copyWith({
    String? id,
    String? fullName,
    String? fullNameNorm,
    String? nationalId,
    String? fileNo,
    String? governorate,
    String? gender,
    String? category,
    DateTime? birthDate,
    String? notes,
    String? associationName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncState,
  }) {
    return Beneficiary(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      fullNameNorm: fullNameNorm ?? this.fullNameNorm,
      nationalId: nationalId ?? this.nationalId,
      fileNo: fileNo ?? this.fileNo,
      governorate: governorate ?? this.governorate,
      gender: gender ?? this.gender,
      category: category ?? this.category,
      birthDate: birthDate ?? this.birthDate,
      notes: notes ?? this.notes,
      associationName: associationName ?? this.associationName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
    );
  }

  bool get isSynced => syncState == 'synced';
  bool get isPending => syncState == 'pending';
  bool get hasFailed => syncState == 'failed';

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }
}
