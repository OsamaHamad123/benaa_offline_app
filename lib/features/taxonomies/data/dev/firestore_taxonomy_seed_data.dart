class FirestoreTaxonomySeedItem {
  final String id;
  final String group;
  final String nameAr;
  final String nameEn;
  final String slug;
  final String? parentId;
  final String journeyType;
  final int sortOrder;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const FirestoreTaxonomySeedItem({
    required this.id,
    required this.group,
    required this.nameAr,
    required this.nameEn,
    required this.slug,
    this.parentId,
    this.journeyType = 'general',
    this.sortOrder = 0,
    this.isActive = true,
    this.metadata = const <String, dynamic>{},
  });

  String get documentId => slug;
}

FirestoreTaxonomySeedItem _seed(
  String group,
  String slug,
  String nameAr,
  String nameEn, {
  String? parentId,
  String journeyType = 'beneficiary',
  int sortOrder = 0,
  Map<String, dynamic> metadata = const <String, dynamic>{},
}) {
  return FirestoreTaxonomySeedItem(
    id: slug,
    group: group,
    nameAr: nameAr,
    nameEn: nameEn,
    slug: slug,
    parentId: parentId,
    journeyType: journeyType,
    sortOrder: sortOrder,
    isActive: true,
    metadata: metadata,
  );
}

List<FirestoreTaxonomySeedItem> _groupSeeds(
  String group,
  List<({String slug, String ar, String en})> rows, {
  String journeyType = 'beneficiary',
}) {
  return List<FirestoreTaxonomySeedItem>.generate(
    rows.length,
    (index) => _seed(
      group,
      rows[index].slug,
      rows[index].ar,
      rows[index].en,
      journeyType: journeyType,
      sortOrder: index + 1,
    ),
  );
}

List<FirestoreTaxonomySeedItem> _citySeeds() {
  final rows = <({String parentId, String slug, String ar, String en})>[
    (parentId: 'north_gaza', slug: 'beit_hanoun', ar: 'بيت حانون', en: 'Beit Hanoun'),
    (parentId: 'north_gaza', slug: 'beit_lahia', ar: 'بيت لاهيا', en: 'Beit Lahia'),
    (parentId: 'north_gaza', slug: 'jabalia', ar: 'جباليا', en: 'Jabalia'),
    (parentId: 'north_gaza', slug: 'jabalia_camp', ar: 'مخيم جباليا', en: 'Jabalia Camp'),
    (parentId: 'north_gaza', slug: 'umm_al_nasr', ar: 'أم النصر', en: 'Umm Al Nasr'),
    (parentId: 'gaza', slug: 'gaza_city', ar: 'مدينة غزة', en: 'Gaza City'),
    (parentId: 'gaza', slug: 'al_shati_camp', ar: 'مخيم الشاطئ', en: 'Al Shati Camp'),
    (parentId: 'gaza', slug: 'al_zahra', ar: 'الزهراء', en: 'Al Zahra'),
    (parentId: 'gaza', slug: 'al_mughraqa', ar: 'المغراقة', en: 'Al Mughraqa'),
    (parentId: 'gaza', slug: 'juhor_ad_dik', ar: 'جحر الديك', en: 'Juhor Ad Dik'),
    (parentId: 'deir_al_balah', slug: 'deir_al_balah_city', ar: 'دير البلح', en: 'Deir Al Balah City'),
    (parentId: 'deir_al_balah', slug: 'deir_al_balah_camp', ar: 'مخيم دير البلح', en: 'Deir Al Balah Camp'),
    (parentId: 'deir_al_balah', slug: 'nuseirat', ar: 'النصيرات', en: 'Nuseirat'),
    (parentId: 'deir_al_balah', slug: 'nuseirat_camp', ar: 'مخيم النصيرات', en: 'Nuseirat Camp'),
    (parentId: 'deir_al_balah', slug: 'al_bureij', ar: 'البريج', en: 'Al Bureij'),
    (parentId: 'deir_al_balah', slug: 'al_bureij_camp', ar: 'مخيم البريج', en: 'Al Bureij Camp'),
    (parentId: 'deir_al_balah', slug: 'al_maghazi', ar: 'المغازي', en: 'Al Maghazi'),
    (parentId: 'deir_al_balah', slug: 'al_maghazi_camp', ar: 'مخيم المغازي', en: 'Al Maghazi Camp'),
    (parentId: 'deir_al_balah', slug: 'al_zawayda', ar: 'الزوايدة', en: 'Al Zawayda'),
    (parentId: 'deir_al_balah', slug: 'al_musaddar', ar: 'المصدر', en: 'Al Musaddar'),
    (parentId: 'deir_al_balah', slug: 'wadi_as_salqa', ar: 'وادي السلقا', en: 'Wadi As Salqa'),
    (parentId: 'khan_yunis', slug: 'khan_yunis_city', ar: 'خان يونس', en: 'Khan Yunis City'),
    (parentId: 'khan_yunis', slug: 'khan_yunis_camp', ar: 'مخيم خان يونس', en: 'Khan Yunis Camp'),
    (parentId: 'khan_yunis', slug: 'bani_suheila', ar: 'بني سهيلا', en: 'Bani Suheila'),
    (parentId: 'khan_yunis', slug: 'abasan_al_kabira', ar: 'عبسان الكبيرة', en: 'Abasan Al Kabira'),
    (parentId: 'khan_yunis', slug: 'abasan_as_saghira', ar: 'عبسان الصغيرة', en: 'Abasan As Saghira'),
    (parentId: 'khan_yunis', slug: 'khuzaa', ar: 'خزاعة', en: 'Khuzaa'),
    (parentId: 'khan_yunis', slug: 'al_qarara', ar: 'القرارة', en: 'Al Qarara'),
    (parentId: 'khan_yunis', slug: 'al_fukhari', ar: 'الفخاري', en: 'Al Fukhari'),
    (parentId: 'rafah', slug: 'rafah_city', ar: 'رفح', en: 'Rafah City'),
    (parentId: 'rafah', slug: 'rafah_camp', ar: 'مخيم رفح', en: 'Rafah Camp'),
    (parentId: 'rafah', slug: 'al_nasr', ar: 'النصر', en: 'Al Nasr'),
    (parentId: 'rafah', slug: 'shokat_as_sufi', ar: 'شوكة الصوفي', en: 'Shokat As Sufi'),
    (parentId: 'rafah', slug: 'tal_al_sultan', ar: 'تل السلطان', en: 'Tal Al Sultan'),
    (parentId: 'rafah', slug: 'al_mawasi_rafah', ar: 'مواصي رفح', en: 'Al Mawasi Rafah'),
  ];

  return List<FirestoreTaxonomySeedItem>.generate(
    rows.length,
    (index) => _seed(
      'city',
      rows[index].slug,
      rows[index].ar,
      rows[index].en,
      parentId: rows[index].parentId,
      sortOrder: index + 1,
    ),
  );
}

final List<FirestoreTaxonomySeedItem> firestoreTaxonomySeedData = [
  ..._groupSeeds('governorate', [
    (slug: 'north_gaza', ar: 'شمال غزة', en: 'North Gaza'),
    (slug: 'gaza', ar: 'غزة', en: 'Gaza'),
    (slug: 'deir_al_balah', ar: 'دير البلح', en: 'Deir Al Balah'),
    (slug: 'khan_yunis', ar: 'خان يونس', en: 'Khan Yunis'),
    (slug: 'rafah', ar: 'رفح', en: 'Rafah'),
  ]),
  ..._citySeeds(),
  ..._groupSeeds('gender', [
    (slug: 'male', ar: 'ذكر', en: 'Male'),
    (slug: 'female', ar: 'أنثى', en: 'Female'),
  ]),
  ..._groupSeeds('marital_status', [
    (slug: 'single', ar: 'أعزب/عزباء', en: 'Single'),
    (slug: 'married', ar: 'متزوج/ة', en: 'Married'),
    (slug: 'divorced', ar: 'مطلق/ة', en: 'Divorced'),
    (slug: 'widowed', ar: 'أرمل/ة', en: 'Widowed'),
    (slug: 'separated', ar: 'منفصل/ة', en: 'Separated'),
  ]),
  ..._groupSeeds('relationship', [
    (slug: 'self', ar: 'نفسه/نفسها', en: 'Self'),
    (slug: 'father', ar: 'أب', en: 'Father'),
    (slug: 'mother', ar: 'أم', en: 'Mother'),
    (slug: 'son', ar: 'ابن', en: 'Son'),
    (slug: 'daughter', ar: 'ابنة', en: 'Daughter'),
    (slug: 'husband', ar: 'زوج', en: 'Husband'),
    (slug: 'wife', ar: 'زوجة', en: 'Wife'),
    (slug: 'brother', ar: 'أخ', en: 'Brother'),
    (slug: 'sister', ar: 'أخت', en: 'Sister'),
    (slug: 'grandfather', ar: 'جد', en: 'Grandfather'),
    (slug: 'grandmother', ar: 'جدة', en: 'Grandmother'),
    (slug: 'uncle', ar: 'عم/خال', en: 'Uncle'),
    (slug: 'aunt', ar: 'عمة/خالة', en: 'Aunt'),
    (slug: 'guardian', ar: 'ولي أمر', en: 'Guardian'),
    (slug: 'other', ar: 'أخرى', en: 'Other'),
  ]),
  ..._groupSeeds('education_level', [
    (slug: 'none', ar: 'لا يوجد', en: 'None'),
    (slug: 'primary', ar: 'ابتدائي', en: 'Primary'),
    (slug: 'preparatory', ar: 'إعدادي', en: 'Preparatory'),
    (slug: 'secondary', ar: 'ثانوي', en: 'Secondary'),
    (slug: 'diploma', ar: 'دبلوم', en: 'Diploma'),
    (slug: 'university', ar: 'جامعي', en: 'University'),
    (slug: 'postgraduate', ar: 'دراسات عليا', en: 'Postgraduate'),
    (slug: 'other', ar: 'أخرى', en: 'Other'),
  ]),
  ..._groupSeeds('employment_status', [
    (slug: 'unemployed', ar: 'عاطل عن العمل', en: 'Unemployed'),
    (slug: 'employed', ar: 'يعمل', en: 'Employed'),
    (slug: 'daily_worker', ar: 'عامل يومي', en: 'Daily Worker'),
    (slug: 'self_employed', ar: 'عمل حر', en: 'Self Employed'),
    (slug: 'student', ar: 'طالب', en: 'Student'),
    (slug: 'retired', ar: 'متقاعد', en: 'Retired'),
    (slug: 'unable_to_work', ar: 'غير قادر على العمل', en: 'Unable To Work'),
    (slug: 'other', ar: 'أخرى', en: 'Other'),
  ]),
  ..._groupSeeds('health_status', [
    (slug: 'good', ar: 'جيدة', en: 'Good'),
    (slug: 'chronic_disease', ar: 'مرض مزمن', en: 'Chronic Disease'),
    (slug: 'disability', ar: 'إعاقة', en: 'Disability'),
    (slug: 'injured', ar: 'مصاب', en: 'Injured'),
    (slug: 'pregnant', ar: 'حامل', en: 'Pregnant'),
    (slug: 'elderly', ar: 'كبار سن', en: 'Elderly'),
    (slug: 'needs_care', ar: 'يحتاج رعاية', en: 'Needs Care'),
    (slug: 'other', ar: 'أخرى', en: 'Other'),
  ]),
  ..._groupSeeds('housing_status', [
    (slug: 'owned', ar: 'ملك', en: 'Owned'),
    (slug: 'rented', ar: 'إيجار', en: 'Rented'),
    (slug: 'hosted', ar: 'مستضاف', en: 'Hosted'),
    (slug: 'displaced', ar: 'نازح', en: 'Displaced'),
    (slug: 'shelter', ar: 'مركز إيواء', en: 'Shelter'),
    (slug: 'tent', ar: 'خيمة', en: 'Tent'),
    (slug: 'destroyed', ar: 'مدمر', en: 'Destroyed'),
    (slug: 'partially_damaged', ar: 'متضرر جزئياً', en: 'Partially Damaged'),
    (slug: 'other', ar: 'أخرى', en: 'Other'),
  ]),
  ..._groupSeeds('housing_type', [
    (slug: 'apartment', ar: 'شقة', en: 'Apartment'),
    (slug: 'house', ar: 'منزل', en: 'House'),
    (slug: 'room', ar: 'غرفة', en: 'Room'),
    (slug: 'tent', ar: 'خيمة', en: 'Tent'),
    (slug: 'shelter_center', ar: 'مركز إيواء', en: 'Shelter Center'),
    (slug: 'caravan', ar: 'كرفان', en: 'Caravan'),
    (slug: 'damaged_house', ar: 'منزل متضرر', en: 'Damaged House'),
    (slug: 'other', ar: 'أخرى', en: 'Other'),
  ]),
  ..._groupSeeds('displacement_status', [
    (slug: 'not_displaced', ar: 'غير نازح', en: 'Not Displaced'),
    (slug: 'displaced_same_governorate', ar: 'نازح داخل نفس المحافظة', en: 'Displaced Same Governorate'),
    (slug: 'displaced_other_governorate', ar: 'نازح لمحافظة أخرى', en: 'Displaced Other Governorate'),
    (slug: 'returned', ar: 'عائد', en: 'Returned'),
    (slug: 'multiple_displacement', ar: 'نزوح متكرر', en: 'Multiple Displacement'),
  ]),
  ..._groupSeeds('disability_type', [
    (slug: 'physical', ar: 'إعاقة حركية', en: 'Physical Disability'),
    (slug: 'visual', ar: 'إعاقة بصرية', en: 'Visual Disability'),
    (slug: 'hearing', ar: 'إعاقة سمعية', en: 'Hearing Disability'),
    (slug: 'speech', ar: 'إعاقة نطق', en: 'Speech Disability'),
    (slug: 'intellectual', ar: 'إعاقة ذهنية', en: 'Intellectual Disability'),
    (slug: 'psychosocial', ar: 'إعاقة نفسية/اجتماعية', en: 'Psychosocial Disability'),
    (slug: 'multiple', ar: 'إعاقات متعددة', en: 'Multiple Disabilities'),
    (slug: 'chronic_illness_related', ar: 'مرتبطة بمرض مزمن', en: 'Chronic Illness Related'),
    (slug: 'other', ar: 'أخرى', en: 'Other'),
  ]),
  ..._groupSeeds('death_reason', [
    (slug: 'death_reason_natural', ar: 'وفاة طبيعية', en: 'Natural Death'),
    (slug: 'death_reason_war_related', ar: 'نتيجة الحرب', en: 'War Related'),
    (slug: 'death_reason_bombing', ar: 'قصف', en: 'Bombing'),
    (slug: 'death_reason_injury', ar: 'إصابة', en: 'Injury'),
    (slug: 'death_reason_disease', ar: 'مرض', en: 'Disease'),
    (slug: 'death_reason_missing_confirmed_dead', ar: 'مفقود مؤكد الوفاة', en: 'Missing Confirmed Dead'),
    (slug: 'death_reason_other', ar: 'أخرى', en: 'Other'),
  ]),
  ..._groupSeeds('document_type', [
    (slug: 'document_type_id_card', ar: 'بطاقة هوية', en: 'ID Card'),
    (slug: 'document_type_birth_certificate', ar: 'شهادة ميلاد', en: 'Birth Certificate'),
    (slug: 'document_type_death_certificate', ar: 'شهادة وفاة', en: 'Death Certificate'),
    (slug: 'document_type_medical_report', ar: 'تقرير طبي', en: 'Medical Report'),
    (slug: 'document_type_disability_report', ar: 'تقرير إعاقة', en: 'Disability Report'),
    (slug: 'document_type_proof_of_residence', ar: 'إثبات سكن', en: 'Proof Of Residence'),
    (slug: 'document_type_family_book', ar: 'دفتر عائلة', en: 'Family Book'),
    (slug: 'document_type_aid_card', ar: 'بطاقة مساعدات', en: 'Aid Card'),
    (slug: 'document_type_other', ar: 'أخرى', en: 'Other'),
  ]),
  ..._groupSeeds('beneficiary_status', [
    (slug: 'active', ar: 'نشط', en: 'Active'),
    (slug: 'pending_review', ar: 'قيد المراجعة', en: 'Pending Review'),
    (slug: 'suspended', ar: 'موقوف', en: 'Suspended'),
    (slug: 'deceased', ar: 'متوفى', en: 'Deceased'),
    (slug: 'archived', ar: 'مؤرشف', en: 'Archived'),
  ]),
  ..._groupSeeds('assistance_type', [
    (slug: 'cash', ar: 'مساعدة نقدية', en: 'Cash Assistance'),
    (slug: 'food', ar: 'سلة غذائية', en: 'Food Assistance'),
    (slug: 'medical', ar: 'مساعدة طبية', en: 'Medical Assistance'),
    (slug: 'shelter', ar: 'إيواء', en: 'Shelter'),
    (slug: 'education', ar: 'تعليم', en: 'Education'),
    (slug: 'psychological_support', ar: 'دعم نفسي', en: 'Psychological Support'),
    (slug: 'clothing', ar: 'ملابس', en: 'Clothing'),
    (slug: 'hygiene', ar: 'مواد نظافة', en: 'Hygiene Supplies'),
    (slug: 'other', ar: 'أخرى', en: 'Other'),
  ]),
  ..._groupSeeds('guarantee_type', [
    (slug: 'orphan_sponsorship', ar: 'كفالة يتيم', en: 'Orphan Sponsorship'),
    (slug: 'family_sponsorship', ar: 'كفالة أسرة', en: 'Family Sponsorship'),
    (slug: 'medical_sponsorship', ar: 'كفالة علاجية', en: 'Medical Sponsorship'),
    (slug: 'education_sponsorship', ar: 'كفالة تعليمية', en: 'Education Sponsorship'),
    (slug: 'emergency_sponsorship', ar: 'كفالة طارئة', en: 'Emergency Sponsorship'),
    (slug: 'other', ar: 'أخرى', en: 'Other'),
  ]),
  ..._groupSeeds(
      'association_type',
      [
        (slug: 'charity', ar: 'جمعية خيرية', en: 'Charity Association'),
        (slug: 'medical', ar: 'جمعية طبية', en: 'Medical Association'),
        (slug: 'educational', ar: 'جمعية تعليمية', en: 'Educational Association'),
        (slug: 'relief', ar: 'جمعية إغاثية', en: 'Relief Association'),
        (slug: 'development', ar: 'جمعية تنموية', en: 'Development Association'),
        (slug: 'local_committee', ar: 'لجنة محلية', en: 'Local Committee'),
        (slug: 'other', ar: 'أخرى', en: 'Other'),
      ],
      journeyType: 'general'),
  ..._groupSeeds('sponsorship_type', [
    (slug: 'monthly', ar: 'شهرية', en: 'Monthly'),
    (slug: 'quarterly', ar: 'ربع سنوية', en: 'Quarterly'),
    (slug: 'yearly', ar: 'سنوية', en: 'Yearly'),
    (slug: 'one_time', ar: 'مرة واحدة', en: 'One Time'),
    (slug: 'emergency', ar: 'طارئة', en: 'Emergency'),
  ]),
  ..._groupSeeds(
      'bank_name',
      [
        (slug: 'bank_of_palestine', ar: 'بنك فلسطين', en: 'Bank of Palestine'),
        (slug: 'palestine_islamic_bank', ar: 'المصرف الإسلامي الفلسطيني', en: 'Palestine Islamic Bank'),
        (slug: 'arab_islamic_bank', ar: 'البنك الإسلامي العربي', en: 'Arab Islamic Bank'),
        (slug: 'cairo_amman_bank', ar: 'بنك القاهرة عمان', en: 'Cairo Amman Bank'),
        (slug: 'quds_bank', ar: 'بنك القدس', en: 'Quds Bank'),
        (slug: 'national_bank', ar: 'البنك الوطني', en: 'National Bank'),
        (slug: 'safwa_bank', ar: 'بنك الصفوة', en: 'Safwa Bank'),
        (slug: 'cash', ar: 'نقداً', en: 'Cash'),
        (slug: 'wallet', ar: 'محفظة إلكترونية', en: 'E-Wallet'),
        (slug: 'other', ar: 'أخرى', en: 'Other'),
      ],
      journeyType: 'general'),
  ..._groupSeeds(
      'currency',
      [
        (slug: 'ils', ar: 'شيكل', en: 'Israeli Shekel'),
        (slug: 'usd', ar: 'دولار أمريكي', en: 'US Dollar'),
        (slug: 'jod', ar: 'دينار أردني', en: 'Jordanian Dinar'),
        (slug: 'eur', ar: 'يورو', en: 'Euro'),
      ],
      journeyType: 'general'),
  ..._groupSeeds(
      'visit_type',
      [
        (slug: 'first_visit', ar: 'زيارة أولى', en: 'First Visit'),
        (slug: 'follow_up', ar: 'متابعة', en: 'Follow Up'),
        (slug: 'emergency', ar: 'طارئة', en: 'Emergency'),
        (slug: 'verification', ar: 'تحقق', en: 'Verification'),
        (slug: 'other', ar: 'أخرى', en: 'Other'),
      ],
      journeyType: 'general'),
  ..._groupSeeds('section', [
    (slug: 'personal_info', ar: 'البيانات الشخصية', en: 'Personal Info'),
    (slug: 'family_info', ar: 'بيانات الأسرة', en: 'Family Info'),
    (slug: 'housing_info', ar: 'بيانات السكن', en: 'Housing Info'),
    (slug: 'health_info', ar: 'البيانات الصحية', en: 'Health Info'),
    (slug: 'documents', ar: 'المستندات', en: 'Documents'),
    (slug: 'assistance', ar: 'المساعدات', en: 'Assistance'),
    (slug: 'notes', ar: 'ملاحظات', en: 'Notes'),
  ]),
  ..._groupSeeds('category', [
    (slug: 'orphan', ar: 'يتيم', en: 'Orphan'),
    (slug: 'widow', ar: 'أرملة', en: 'Widow'),
    (slug: 'elderly', ar: 'كبار سن', en: 'Elderly'),
    (slug: 'disabled', ar: 'ذوي إعاقة', en: 'Disabled'),
    (slug: 'injured', ar: 'مصاب', en: 'Injured'),
    (slug: 'displaced', ar: 'نازح', en: 'Displaced'),
    (slug: 'poor_family', ar: 'أسرة فقيرة', en: 'Poor Family'),
    (slug: 'medical_case', ar: 'حالة مرضية', en: 'Medical Case'),
    (slug: 'student', ar: 'طالب', en: 'Student'),
    (slug: 'other', ar: 'أخرى', en: 'Other'),
  ]),
  ..._groupSeeds('income_source', [
    (slug: 'salary', ar: 'راتب', en: 'Salary'),
    (slug: 'daily_work', ar: 'عمل يومي', en: 'Daily Work'),
    (slug: 'aid', ar: 'مساعدات', en: 'Aid'),
    (slug: 'pension', ar: 'معاش', en: 'Pension'),
    (slug: 'remittances', ar: 'حوالات', en: 'Remittances'),
    (slug: 'none', ar: 'بدون دخل', en: 'No Income'),
    (slug: 'other', ar: 'أخرى', en: 'Other'),
  ]),
];
