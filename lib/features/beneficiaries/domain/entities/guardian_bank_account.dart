class GuardianBankAccount {
  final int? localId;
  final int? serverId;
  final int guardianRegistration;
  final int? bankNameId;
  final String? bankNameLabel;
  final String? ibanUsd;
  final String? ibanShekel;
  final String? representativeIdNumber;
  final String? guardianName;
  final String? representativePhone;
  final String? ownerIdentityNumber;
  final bool checkAccountApproved;

  const GuardianBankAccount({
    this.localId,
    this.serverId,
    required this.guardianRegistration,
    this.bankNameId,
    this.bankNameLabel,
    this.ibanUsd,
    this.ibanShekel,
    this.representativeIdNumber,
    this.guardianName,
    this.representativePhone,
    this.ownerIdentityNumber,
    this.checkAccountApproved = false,
  });

  bool get hasAnyData {
    return [
      bankNameId?.toString(),
      bankNameLabel,
      ibanUsd,
      ibanShekel,
      representativeIdNumber,
      guardianName,
      representativePhone,
      ownerIdentityNumber,
    ].any((value) => value != null && value.trim().isNotEmpty);
  }
}
