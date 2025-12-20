/// 👨‍👩‍👧‍👦 Relationship - صلة القرابة
enum Relationship {
  widow(2, 'أرملة'),
  widower(3, 'أرمل'),
  orphan(4, 'يتيم'),
  orphanGirl(5, 'يتيمة'),
  guardian(6, 'ولي أمر'),
  other(99, 'أخرى');

  final int code;
  final String arabicLabel;

  const Relationship(this.code, this.arabicLabel);

  static Relationship? fromCode(int? code) {
    if (code == null) return null;
    try {
      return Relationship.values.firstWhere((e) => e.code == code);
    } catch (e) {
      return null;
    }
  }

  static List<Relationship> get allValues => Relationship.values;
}

/// 🏢 Department/Section - القسم
enum Department {
  section1(1, 'القسم الأول'),
  section2(2, 'القسم الثاني'),
  section3(3, 'القسم الثالث'),
  section4(4, 'القسم الرابع'),
  section5(5, 'القسم الخامس');

  final int code;
  final String arabicLabel;

  const Department(this.code, this.arabicLabel);

  static Department? fromCode(int? code) {
    if (code == null) return null;
    try {
      return Department.values.firstWhere((e) => e.code == code);
    } catch (e) {
      return null;
    }
  }

  static List<Department> get allValues => Department.values;
}
