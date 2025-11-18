/// Enum for age bracket categories
enum AgeBracket {
  age0to12('0-12'),
  age13to18('13-18'),
  age19to35('19-35'),
  age36to50('36-50'),
  age51Plus('51+');

  const AgeBracket(this.label);

  final String label;

  /// Get AgeBracket from label string
  static AgeBracket? fromLabel(String label) {
    try {
      return AgeBracket.values.firstWhere((bracket) => bracket.label == label);
    } catch (e) {
      return null;
    }
  }

  /// Get age bracket from age number
  static AgeBracket fromAge(int age) {
    if (age <= 12) return AgeBracket.age0to12;
    if (age <= 18) return AgeBracket.age13to18;
    if (age <= 35) return AgeBracket.age19to35;
    if (age <= 50) return AgeBracket.age36to50;
    return AgeBracket.age51Plus;
  }

  /// Get minimum age for this bracket
  int get minAge {
    switch (this) {
      case AgeBracket.age0to12:
        return 0;
      case AgeBracket.age13to18:
        return 13;
      case AgeBracket.age19to35:
        return 19;
      case AgeBracket.age36to50:
        return 36;
      case AgeBracket.age51Plus:
        return 51;
    }
  }

  /// Get maximum age for this bracket (null for 51+)
  int? get maxAge {
    switch (this) {
      case AgeBracket.age0to12:
        return 12;
      case AgeBracket.age13to18:
        return 18;
      case AgeBracket.age19to35:
        return 35;
      case AgeBracket.age36to50:
        return 50;
      case AgeBracket.age51Plus:
        return null; // No upper limit
    }
  }

  /// Get display label with "سنة"
  String get displayLabel => '$label سنة';
}
