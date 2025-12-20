/// 📄 Document Types - أنواع الوثائق المرفقة
enum DocumentType {
  idCard('id_card', 'صورة هوية'),
  medicalReport('medical_report', 'تقرير طبي'),
  birthCertificate('birth_certificate', 'شهادة الميلاد'),
  lastCertificate('last_certificate', 'آخر شهادة'),
  personalPhoto('personal_photo', 'صورة شخصية'),
  fullPhoto('full_photo', 'صورة طولية'),
  inheritanceDeed('inheritance_deed', 'حضر إرث'),
  orphanCareDeed('orphan_care_deed', 'حجة أعالة يتيم'),
  testDocument('test_document', 'test'),
  otherDocuments('other_documents', 'أوراق ثبوتية أخرى'),
  agencyDeed('agency_deed', 'وكالة في شؤون الولاية'),
  widowhoodDeed('widowhood_deed', 'حجة ترمل'),
  parenthoodDeed('parenthood_deed', 'حجة والدة'),
  walletAccountPhoto('wallet_account_photo', 'صورة حساب المحفظة'),
  deathCertificate('death_certificate', 'شهادة الوفاة'),
  guardianDeed('guardian_deed', 'حجة الوصاية'),
  other('other', 'أخرى');

  final String code;
  final String arabicName;

  const DocumentType(this.code, this.arabicName);

  static DocumentType? fromCode(String? code) {
    if (code == null) return null;
    try {
      return DocumentType.values.firstWhere((e) => e.code == code);
    } catch (e) {
      return null;
    }
  }

  static DocumentType? fromArabicName(String? name) {
    if (name == null) return null;
    try {
      return DocumentType.values.firstWhere((e) => e.arabicName == name);
    } catch (e) {
      return null;
    }
  }
}

/// 👤 Person Types for Attachments - أنواع الأشخاص المرتبطين بالمرفقات
enum AttachmentPersonType {
  fileOwner('file_owner', 'صاحب الملف'),
  familyMember('family_member', 'أفراد الأسرة'),
  deceasedMember('deceased_member', 'الأفراد المتوفيين'),
  deceasedFather('deceased_father', 'الأب المتوفي'),
  deceasedMother('deceased_mother', 'الأم المتوفية');

  final String code;
  final String arabicName;

  const AttachmentPersonType(this.code, this.arabicName);

  static AttachmentPersonType? fromCode(String? code) {
    if (code == null) return null;
    try {
      return AttachmentPersonType.values.firstWhere((e) => e.code == code);
    } catch (e) {
      return null;
    }
  }

  static AttachmentPersonType? fromArabicName(String? name) {
    if (name == null) return null;
    try {
      return AttachmentPersonType.values.firstWhere((e) => e.arabicName == name);
    } catch (e) {
      return null;
    }
  }
}

/// 🏢 Department/Section - القسم
enum Department {
  section1(1, 'القسم الأول'),
  section2(2, 'القسم الثاني'),
  section3(3, 'القسم الثالث'),
  section4(4, 'القسم الرابع'),
  section5(5, 'القسم الخامس');

  final int id;
  final String arabicName;

  const Department(this.id, this.arabicName);

  static Department? fromId(int? id) {
    if (id == null) return null;
    try {
      return Department.values.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// 👨‍👩‍👧‍👦 Relationship - صلة القرابة
enum Relationship {
  widow(2, 'أرملة'),
  widower(3, 'أرمل'),
  orphan(4, 'يتيم'),
  orphanGirl(5, 'يتيمة'),
  guardian(6, 'ولي أمر'),
  other(99, 'أخرى');

  final int id;
  final String arabicName;

  const Relationship(this.id, this.arabicName);

  static Relationship? fromId(int? id) {
    if (id == null) return null;
    try {
      return Relationship.values.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Relationship> get allValues => Relationship.values;
}
