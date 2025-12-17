import 'package:equatable/equatable.dart';

/// 🏢 Association Entity - Domain Layer
///
/// كيان الجمعية يحتوي على جميع المعلومات الأساسية والمالية
class Association extends Equatable {
  final String id;
  final String name;
  final String? shortName;
  final String phone;
  final String? email;
  final String bankName;
  final String accountNumber;
  final String? swiftCode;
  final String? bankPhone;
  final String? accountCurrency; // IQD, USD, EUR
  final String? representativeId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Association({
    required this.id,
    required this.name,
    this.shortName,
    required this.phone,
    this.email,
    required this.bankName,
    required this.accountNumber,
    this.swiftCode,
    this.bankPhone,
    this.accountCurrency,
    this.representativeId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Display name (الاسم المختصر أو الكامل)
  String get displayName => shortName?.isNotEmpty == true ? shortName! : name;

  /// Is valid for operations
  bool get isValid => name.isNotEmpty && phone.isNotEmpty && bankName.isNotEmpty && accountNumber.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        shortName,
        phone,
        email,
        bankName,
        accountNumber,
        swiftCode,
        bankPhone,
        accountCurrency,
        representativeId,
        isActive,
        createdAt,
        updatedAt,
      ];

  Association copyWith({
    String? id,
    String? name,
    String? shortName,
    String? phone,
    String? email,
    String? bankName,
    String? accountNumber,
    String? swiftCode,
    String? bankPhone,
    String? accountCurrency,
    String? representativeId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Association(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      swiftCode: swiftCode ?? this.swiftCode,
      bankPhone: bankPhone ?? this.bankPhone,
      accountCurrency: accountCurrency ?? this.accountCurrency,
      representativeId: representativeId ?? this.representativeId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Association($name, $phone)';
}
