import 'civil_person.dart';

/// 📊 Search Statistics Entity
class SearchStatistics {
  final int totalPersons;
  final int malesCount;
  final int femalesCount;
  final int relationsCount;
  final List<String> governorates;

  const SearchStatistics({
    required this.totalPersons,
    required this.malesCount,
    required this.femalesCount,
    required this.relationsCount,
    required this.governorates,
  });

  int get unknownGenderCount => totalPersons - malesCount - femalesCount;

  double get malePercentage =>
      totalPersons > 0 ? (malesCount / totalPersons) * 100 : 0;

  double get femalePercentage =>
      totalPersons > 0 ? (femalesCount / totalPersons) * 100 : 0;
}

/// 🔍 Search Filter
class SearchFilter {
  final String? governorate;
  final Gender? gender;
  final int? minAge;
  final int? maxAge;

  const SearchFilter({this.governorate, this.gender, this.minAge, this.maxAge});

  bool get hasActiveFilters =>
      governorate != null || gender != null || minAge != null || maxAge != null;

  bool get hasAgeFilter => minAge != null || maxAge != null;

  String get ageRangeText {
    if (minAge != null && maxAge != null) {
      return '$minAge-$maxAge سنة';
    } else if (minAge != null) {
      return 'من $minAge سنة';
    } else if (maxAge != null) {
      return 'حتى $maxAge سنة';
    }
    return '';
  }

  SearchFilter copyWith({
    String? governorate,
    Gender? gender,
    int? minAge,
    int? maxAge,
  }) {
    return SearchFilter(
      governorate: governorate ?? this.governorate,
      gender: gender ?? this.gender,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
    );
  }

  SearchFilter clearGovernorate() {
    return SearchFilter(
      governorate: null,
      gender: gender,
      minAge: minAge,
      maxAge: maxAge,
    );
  }

  SearchFilter clearGender() {
    return SearchFilter(
      governorate: governorate,
      gender: null,
      minAge: minAge,
      maxAge: maxAge,
    );
  }

  SearchFilter clearAge() {
    return SearchFilter(
      governorate: governorate,
      gender: gender,
      minAge: null,
      maxAge: null,
    );
  }

  SearchFilter clearAll() {
    return const SearchFilter();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchFilter &&
        other.governorate == governorate &&
        other.gender == gender;
  }

  @override
  int get hashCode => Object.hash(governorate, gender);
}

/// 📄 Search Result with pagination info
class SearchResult {
  final List<CivilPerson> persons;
  final bool hasMore;
  final int currentPage;
  final int totalResults;

  const SearchResult({
    required this.persons,
    required this.hasMore,
    required this.currentPage,
    required this.totalResults,
  });

  bool get isEmpty => persons.isEmpty;
  bool get isNotEmpty => persons.isNotEmpty;
}
