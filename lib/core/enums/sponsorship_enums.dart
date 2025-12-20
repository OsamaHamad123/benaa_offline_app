/// 🤝 Sponsorship Status - حالة الكفالة
enum SponsorshipStatus {
  sponsored(1, 'مكفول'),
  notSponsored(2, 'غير مكفول'),
  pending(3, 'قيد الانتظار');

  final int id;
  final String arabicName;

  const SponsorshipStatus(this.id, this.arabicName);

  static SponsorshipStatus? fromId(int? id) {
    if (id == null) return null;
    try {
      return SponsorshipStatus.values.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<SponsorshipStatus> get allValues => SponsorshipStatus.values;
}

/// 💰 Sponsorship Type - نوع الكفالة
enum SponsorshipType {
  full(1, 'كفالة كاملة'),
  partial(2, 'كفالة جزئية'),
  seasonal(3, 'كفالة موسمية');

  final int id;
  final String arabicName;

  const SponsorshipType(this.id, this.arabicName);

  static SponsorshipType? fromId(int? id) {
    if (id == null) return null;
    try {
      return SponsorshipType.values.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<SponsorshipType> get allValues => SponsorshipType.values;
}
