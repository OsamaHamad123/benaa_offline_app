/// 🏷️ Taxonomy Groups - مجموعات التصنيفات
///
/// تمثل الفئات الرئيسية للتصنيفات في النظام
/// كل مجموعة تحتوي على قائمة من التصنيفات الفرعية
enum TaxonomyGroup {
  /// المحافظات
  governorate('governorate', 'المحافظات', 'gov'),

  /// الفئات (يتيم، فقير، أرملة، إلخ)
  category('category', 'الفئات', 'cat'),

  /// الحالة الاجتماعية
  maritalStatus('marital_status', 'الحالة الاجتماعية', 'mar'),

  /// المستوى التعليمي
  educationLevel('education_level', 'المستوى التعليمي', 'edu'),

  /// الحالة الصحية
  healthStatus('health_status', 'الحالة الصحية', 'health'),

  /// نوع السكن
  housingType('housing_type', 'نوع السكن', 'housing'),

  /// حالة السكن
  housingStatus('housing_status', 'حالة السكن', 'h_status'),

  /// نوع الإعاقة
  disabilityType('disability_type', 'نوع الإعاقة', 'dis'),

  /// مصدر الدخل
  incomeSource('income_source', 'مصدر الدخل', 'income'),

  /// نوع الجمعية
  associationType('association_type', 'نوع الجمعية', 'assoc'),

  /// نوع الكفالة
  sponsorshipType('sponsorship_type', 'نوع الكفالة', 'spons'),

  /// الجنس
  gender('gender', 'الجنس', 'gen'),

  /// نوع الزيارة
  visitType('visit_type', 'نوع الزيارة', 'visit'),

  /// نوع المساعدة
  assistanceType('assistance_type', 'نوع المساعدة', 'assist'),

  /// حالة المستفيد
  beneficiaryStatus('beneficiary_status', 'حالة المستفيد', 'ben_status');

  /// القيمة المستخدمة في API و Database
  final String value;

  /// الاسم العربي للعرض
  final String arabicName;

  /// الاختصار للـ ID
  final String prefix;

  const TaxonomyGroup(this.value, this.arabicName, this.prefix);

  /// تحويل من String إلى Enum
  static TaxonomyGroup? fromString(String? value) {
    if (value == null) return null;
    return TaxonomyGroup.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaxonomyGroup.category,
    );
  }

  /// التحقق من وجود مجموعة
  static bool isValidGroup(String value) {
    return TaxonomyGroup.values.any((e) => e.value == value);
  }

  @override
  String toString() => value;
}

/// Extension لإضافة وظائف مساعدة
extension TaxonomyGroupExtension on TaxonomyGroup {
  /// هل هي مجموعة مطلوبة (لا يمكن أن تكون فارغة)
  bool get isRequired {
    return [
      TaxonomyGroup.governorate,
      TaxonomyGroup.category,
      TaxonomyGroup.gender,
    ].contains(this);
  }

  /// هل هي قابلة للتعديل من قبل المستخدم
  bool get isEditable {
    // بعض المجموعات لا يمكن تعديلها (مثل الجنس)
    return this != TaxonomyGroup.gender;
  }

  /// الحصول على أيقونة المجموعة
  String get iconName {
    switch (this) {
      case TaxonomyGroup.governorate:
        return 'location_city';
      case TaxonomyGroup.category:
        return 'category';
      case TaxonomyGroup.maritalStatus:
        return 'people';
      case TaxonomyGroup.educationLevel:
        return 'school';
      case TaxonomyGroup.healthStatus:
        return 'health_and_safety';
      case TaxonomyGroup.housingType:
        return 'home';
      case TaxonomyGroup.housingStatus:
        return 'house';
      case TaxonomyGroup.disabilityType:
        return 'accessible';
      case TaxonomyGroup.incomeSource:
        return 'attach_money';
      case TaxonomyGroup.associationType:
        return 'business';
      case TaxonomyGroup.sponsorshipType:
        return 'volunteer_activism';
      case TaxonomyGroup.gender:
        return 'wc';
      case TaxonomyGroup.visitType:
        return 'event';
      case TaxonomyGroup.assistanceType:
        return 'handshake';
      case TaxonomyGroup.beneficiaryStatus:
        return 'person';
    }
  }
}
