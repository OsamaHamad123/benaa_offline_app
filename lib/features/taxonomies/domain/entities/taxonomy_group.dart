/// 🏷️ Taxonomy Groups - مجموعات التصنيفات
///
/// تمثل الفئات الرئيسية للتصنيفات في النظام
/// كل مجموعة تحتوي على قائمة من التصنيفات الفرعية
enum TaxonomyGroup {
  /// المحافظات
  governorate('governorate', 'المحافظات', 'gov'),

  /// المدن
  city('city', 'المدن', 'city'),

  /// الفئات (يتيم، فقير، أرملة، إلخ)
  category('category', 'الفئات', 'cat'),

  /// الحالة الاجتماعية
  maritalStatus('marital_status', 'الحالة الاجتماعية', 'mar'),

  /// حالة النزوح
  displacementStatus('displacement_status', 'حالة النزوح', 'disp'),

  /// حالة التوظيف
  employmentStatus('employment_status', 'حالة التوظيف', 'emp'),

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

  /// نوع الضمان
  guaranteeType('guarantee_type', 'نوع الضمان', 'guar'),

  /// أنواع الوثائق
  documentType('document_type', 'أنواع الوثائق', 'doc'),

  /// أسماء البنوك
  bankName('bank_name', 'أسماء البنوك', 'bank'),

  /// العملات
  currency('currency', 'العملات', 'curr'),

  /// أسباب الوفاة
  deathReason('death_reason', 'أسباب الوفاة', 'death'),

  /// الجنس
  gender('gender', 'الجنس', 'gen'),

  /// نوع الزيارة
  visitType('visit_type', 'نوع الزيارة', 'visit'),

  /// نوع المساعدة
  assistanceType('assistance_type', 'نوع المساعدة', 'assist'),

  /// حالة المستفيد
  beneficiaryStatus('beneficiary_status', 'حالة المستفيد', 'ben_status'),

  /// صلة القرابة
  relationship('relationship', 'صلة القرابة', 'rel'),

  /// القسم (إداري، مالي، إلخ)
  section('section', 'القسم', 'sec');

  /// القيمة المستخدمة في API و Database
  final String value;

  /// الاسم العربي للعرض
  final String arabicName;

  /// الاختصار للـ ID
  final String prefix;

  const TaxonomyGroup(this.value, this.arabicName, this.prefix);

  /// تحويل من String إلى Enum
  static TaxonomyGroup? fromString(String? value) {
    final normalized = normalizeValue(value);
    if (normalized == null) return null;
    for (final group in TaxonomyGroup.values) {
      if (group.value == normalized) {
        return group;
      }
    }
    return null;
  }

  /// تطبيع قيمة المجموعة القادمة من API أو قاعدة البيانات
  ///
  /// ترجع قيمة قياسية مطابقة لقيم enum عند القدرة على التعرف عليها.
  /// إذا تعذر التعرف، ترجع القيمة بعد التطبيع الشكلي فقط.
  static String? normalizeValue(String? rawValue) {
    if (rawValue == null) return null;

    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) return null;

    final normalized = trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), '_').replaceAll('-', '_');

    if (trimmed.contains('المحافظ')) return 'governorate';
    if (trimmed.contains('المدن') || trimmed.contains('المدينة') || trimmed.contains('مدين')) return 'city';
    if (trimmed.contains('الفئ')) return 'category';
    if (trimmed.contains('الحالة الاجتماعية')) return 'marital_status';
    if (trimmed.contains('النزوح')) return 'displacement_status';
    if (trimmed.contains('التوظيف') || trimmed.contains('العمل')) return 'employment_status';
    if (trimmed.contains('المستوى التعليمي')) return 'education_level';
    if (trimmed.contains('الحالة الصحية')) return 'health_status';
    if (trimmed.contains('نوع السكن')) return 'housing_type';
    if (trimmed.contains('حالة السكن')) return 'housing_status';
    if (trimmed.contains('الإعاقة')) return 'disability_type';
    if (trimmed.contains('مصدر الدخل')) return 'income_source';
    if (trimmed.contains('نوع الجمعية')) return 'association_type';
    if (trimmed.contains('نوع الكفالة')) return 'sponsorship_type';
    if (trimmed.contains('نوع الضمان')) return 'guarantee_type';
    if (trimmed.contains('الوثائ')) return 'document_type';
    if (trimmed.contains('البنوك') || trimmed.contains('البنك')) return 'bank_name';
    if (trimmed.contains('العملات') || trimmed.contains('عملة')) return 'currency';
    if (trimmed.contains('أسباب الوفاة') || trimmed.contains('اسباب الوفاة') || trimmed.contains('الوفاة')) {
      return 'death_reason';
    }
    if (trimmed.contains('نوع الزيارة')) return 'visit_type';
    if (trimmed.contains('نوع المساعدة')) return 'assistance_type';
    if (trimmed.contains('حالة المستفيد')) return 'beneficiary_status';
    if (trimmed.contains('صلة القرابة')) return 'relationship';
    if (trimmed.contains('القسم')) return 'section';
    if (trimmed.contains('الجنس')) return 'gender';

    const aliases = <String, String>{
      'categories': 'category',
      'beneficiary_categories': 'category',
      'province': 'governorate',
      'provinces': 'governorate',
      'governorates': 'governorate',
      'cities': 'city',
      'relations': 'relationship',
      'marital_statuses': 'marital_status',
      'social_status': 'marital_status',
      'social_statuses': 'marital_status',
      'displacement_statuses': 'displacement_status',
      'employment_statuses': 'employment_status',
      'job_status': 'employment_status',
      'job_statuses': 'employment_status',
      'education_levels': 'education_level',
      'educational_levels': 'education_level',
      'academic_degrees': 'education_level',
      'health_statuses': 'health_status',
      'health_conditions': 'health_status',
      'housing_types': 'housing_type',
      'accommodation_types': 'housing_type',
      'residence_types': 'housing_type',
      'housing_statuses': 'housing_status',
      'housing_conditions': 'housing_status',
      'residence_status': 'housing_status',
      'disability_types': 'disability_type',
      'special_needs_types': 'disability_type',
      'income_sources': 'income_source',
      'association_types': 'association_type',
      'associations_types': 'association_type',
      'sponsorship_types': 'sponsorship_type',
      'guarantee_types': 'guarantee_type',
      'document_types': 'document_type',
      'document_type': 'document_type',
      'bank_names': 'bank_name',
      'bank_name': 'bank_name',
      'currencies': 'currency',
      'currency': 'currency',
      'death_reasons': 'death_reason',
      'death_reason': 'death_reason',
      'visit_types': 'visit_type',
      'assistance_types': 'assistance_type',
      'aid_types': 'assistance_type',
      'aid_statuses': 'assistance_type',
      'beneficiary_statuses': 'beneficiary_status',
      'request_statuses': 'beneficiary_status',
      'request_status': 'beneficiary_status',
      'sponsorship_statuses': 'beneficiary_status',
      'beneficiary_state': 'beneficiary_status',
      'relationships': 'relationship',
      'kinship': 'relationship',
      'departments': 'section',
      'department': 'section',
      'sections': 'section',
      'sex': 'gender',
      'genders': 'gender',
      'sexes': 'gender',
      'visit': 'visit_type',
      'visits': 'visit_type',
      'association': 'association_type',
      'associations': 'association_type',
    };

    final direct = aliases[normalized] ?? normalized;

    if (TaxonomyGroup.values.any((group) => group.value == direct)) {
      return direct;
    }

    if (direct.contains('marital') || direct.contains('social_status')) return 'marital_status';
    if (direct.contains('displacement')) return 'displacement_status';
    if (direct.contains('employment') || direct.contains('job_status')) return 'employment_status';
    if (direct.contains('education') || direct.contains('academic_degree')) return 'education_level';
    if (direct.contains('health')) return 'health_status';
    if (direct.contains('housing_type') || direct.contains('residence_type')) return 'housing_type';
    if (direct.contains('housing_status') || direct.contains('housing_condition')) return 'housing_status';
    if (direct.contains('disability') || direct.contains('special_needs')) return 'disability_type';
    if (direct.contains('income')) return 'income_source';
    if (direct.contains('association')) return 'association_type';
    if (direct.contains('guarantee')) return 'guarantee_type';
    if (direct.contains('sponsorship')) return 'sponsorship_type';
    if (direct.contains('document_type') || direct.contains('document')) return 'document_type';
    if (direct.contains('bank_name') || direct.contains('bank')) return 'bank_name';
    if (direct.contains('currency') || direct.contains('currenc')) return 'currency';
    if (direct.contains('death_reason') || direct.contains('death')) return 'death_reason';
    if (direct.contains('visit')) return 'visit_type';
    if (direct.contains('assistance') || direct.contains('aid_type') || direct.contains('aid_status')) {
      return 'assistance_type';
    }
    if (direct.contains('beneficiary_status') || direct.contains('beneficiary_state')) return 'beneficiary_status';
    if (direct.contains('relationship') || direct.contains('kinship')) return 'relationship';
    if (direct.contains('section') || direct.contains('department')) return 'section';
    if (direct.contains('gender') || direct.contains('sex')) return 'gender';
    if (direct.contains('city') || direct.contains('cities')) return 'city';
    if (direct.contains('governorate') || direct.contains('province') || direct.contains('city')) return 'governorate';
    if (direct.contains('category')) return 'category';

    return direct;
  }

  /// التحقق من وجود مجموعة
  static bool isValidGroup(String value) {
    final normalized = normalizeValue(value);
    if (normalized == null) return false;
    return TaxonomyGroup.values.any((e) => e.value == normalized);
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
      case TaxonomyGroup.city:
        return 'location_on';
      case TaxonomyGroup.category:
        return 'category';
      case TaxonomyGroup.maritalStatus:
        return 'people';
      case TaxonomyGroup.displacementStatus:
        return 'alt_route';
      case TaxonomyGroup.employmentStatus:
        return 'work';
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
      case TaxonomyGroup.guaranteeType:
        return 'verified';
      case TaxonomyGroup.documentType:
        return 'description';
      case TaxonomyGroup.bankName:
        return 'account_balance';
      case TaxonomyGroup.currency:
        return 'currency_exchange';
      case TaxonomyGroup.deathReason:
        return 'heart_broken';
      case TaxonomyGroup.gender:
        return 'wc';
      case TaxonomyGroup.visitType:
        return 'event';
      case TaxonomyGroup.assistanceType:
        return 'handshake';
      case TaxonomyGroup.beneficiaryStatus:
        return 'person';
      case TaxonomyGroup.relationship:
        return 'family_restroom';
      case TaxonomyGroup.section:
        return 'account_tree';
    }
  }
}
