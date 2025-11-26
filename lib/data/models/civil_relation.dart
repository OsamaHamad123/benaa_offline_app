/// نموذج بيانات للعلاقات العائلية
class CivilRelation {
  final int id;
  final int personId; // CF_ID_NUM
  final int relativeId; // CF_ID_RELATIVE
  final int relationTypeId; // CF_RELATIVE_CD
  final String? relationType; // من category_of_relations
  final String? relativeName; // الاسم الكامل للقريب
  final int? relativeSex; // جنس القريب

  CivilRelation({
    required this.id,
    required this.personId,
    required this.relativeId,
    required this.relationTypeId,
    this.relationType,
    this.relativeName,
    this.relativeSex,
  });

  factory CivilRelation.fromMap(Map<String, dynamic> map) {
    // بناء الاسم الكامل
    final firstName = map['CI_FIRST_ARB'] as String?;
    final fatherName = map['CI_FATHER_ARB'] as String?;
    final familyName = map['CI_FAMILY_ARB'] as String?;

    final name = [
      firstName,
      fatherName,
      familyName,
    ].where((e) => e != null && e.isNotEmpty).join(' ');

    return CivilRelation(
      id: map['id'] as int,
      personId: map['CF_ID_NUM'] as int,
      relativeId: map['CF_ID_RELATIVE'] as int,
      relationTypeId: map['CF_RELATIVE_CD'] as int,
      relationType: map['relation_type'] as String?,
      relativeName: name.isNotEmpty ? name : null,
      relativeSex: map['CI_SEX_CD'] as int?,
    );
  }

  /// أيقونة حسب نوع العلاقة
  String get icon {
    switch (relationType) {
      case 'أب':
        return '👨';
      case 'أم':
        return '👩';
      case 'ابن':
        return '👦';
      case 'ابنة':
        return '👧';
      case 'زوج':
        return '🤵';
      case 'زوجة':
        return '👰';
      default:
        return '👤';
    }
  }

  /// هل هذا والد (أب أو أم)
  bool get isParent => relationType == 'أب' || relationType == 'أم';

  /// هل هذا طفل (ابن أو ابنة)
  bool get isChild => relationType == 'ابن' || relationType == 'ابنة';

  /// هل هذا زوج/ة
  bool get isSpouse => relationType == 'زوج' || relationType == 'زوجة';
}

/// نتيجة البحث في السجل المدني مع العلاقات
/// ⚠️ DEPRECATED: This class is no longer used - Civil Registry moved to separate database
@Deprecated('Use CivilPerson from features/search/domain/entities instead')
class CivilRecordWithRelations {
  final Map<String, dynamic> person; // Changed from CivilRegistryData
  final List<CivilRelation> relations;

  CivilRecordWithRelations({required this.person, required this.relations});

  /// الأب
  CivilRelation? get father =>
      relations.where((r) => r.relationType == 'أب').firstOrNull;

  /// الأم
  CivilRelation? get mother =>
      relations.where((r) => r.relationType == 'أم').firstOrNull;

  /// الأبناء (ذكور وإناث)
  List<CivilRelation> get children =>
      relations.where((r) => r.isChild).toList();

  /// الأبناء الذكور
  List<CivilRelation> get sons =>
      relations.where((r) => r.relationType == 'ابن').toList();

  /// البنات
  List<CivilRelation> get daughters =>
      relations.where((r) => r.relationType == 'ابنة').toList();

  /// الزوج/ة
  CivilRelation? get spouse => relations.where((r) => r.isSpouse).firstOrNull;

  /// عدد أفراد العائلة
  int get familySize => relations.length;

  /// هل لديه عائلة
  bool get hasFamily => relations.isNotEmpty;
}
