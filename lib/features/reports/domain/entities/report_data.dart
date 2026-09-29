/// Domain entities for report data
/// Clean Architecture - Domain Layer
library;

/// Gender count entity
class GenderCount {
  /// Labels the repository puts in [gender]. Compare against these, never a
  /// hand-typed string: the summary card once matched 'ذكر' while the repository
  /// emitted 'ذكور', so both counts always showed 0.
  static const String maleLabel = 'ذكور';
  static const String femaleLabel = 'إناث';

  final String gender;
  final int count;

  const GenderCount({required this.gender, required this.count});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GenderCount &&
        other.gender == gender &&
        other.count == count;
  }

  @override
  int get hashCode => gender.hashCode ^ count.hashCode;
}

/// Governorate count entity
class GovernorateCount {
  final String governorate;
  final int count;

  const GovernorateCount({required this.governorate, required this.count});

  double getPercentage(int total) {
    if (total == 0) return 0.0;
    return (count / total) * 100;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GovernorateCount &&
        other.governorate == governorate &&
        other.count == count;
  }

  @override
  int get hashCode => governorate.hashCode ^ count.hashCode;
}

/// Category count entity
class CategoryCount {
  final String category;
  final int count;

  const CategoryCount({required this.category, required this.count});

  double getPercentage(int total) {
    if (total == 0) return 0.0;
    return (count / total) * 100;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryCount &&
        other.category == category &&
        other.count == count;
  }

  @override
  int get hashCode => category.hashCode ^ count.hashCode;
}

/// Age bracket count entity
class AgeCount {
  final String ageBracket;
  final int count;

  const AgeCount({required this.ageBracket, required this.count});

  double getPercentage(int total) {
    if (total == 0) return 0.0;
    return (count / total) * 100;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgeCount &&
        other.ageBracket == ageBracket &&
        other.count == count;
  }

  @override
  int get hashCode => ageBracket.hashCode ^ count.hashCode;
}

/// Sync status count entity
class SyncStatusCount {
  final String status;
  final int count;

  const SyncStatusCount({required this.status, required this.count});

  double getPercentage(int total) {
    if (total == 0) return 0.0;
    return (count / total) * 100;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncStatusCount &&
        other.status == status &&
        other.count == count;
  }

  @override
  int get hashCode => status.hashCode ^ count.hashCode;
}
