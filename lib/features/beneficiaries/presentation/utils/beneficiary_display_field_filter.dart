/// Presentation-only helper for filtering and labelling beneficiary fields.
///
/// PURPOSE
/// -------
/// Prevent raw technical/internal field keys from being rendered in the
/// Beneficiary Details UI. This is a display-layer filter only:
/// - Does NOT mutate stored records.
/// - Does NOT affect sync payloads or database writes.
/// - Does NOT remove data from any model or repository.
///
/// USAGE
/// -----
/// Call [shouldDisplayBeneficiaryField] before adding a field to a UI list.
/// Call [beneficiaryFieldLabel] to get an Arabic-friendly label for a key.
/// Call [normalizeBeneficiaryFieldValue] to render a safe display string for a value.

// ---------------------------------------------------------------------------
// Internal configuration
// ---------------------------------------------------------------------------

const Set<String> _technicalKeys = <String>{
  // Generic metadata
  'metadata',
  'meta',
  'raw',
  'json',
  'data',
  'data.json',
  'payload',
  'debug',
  // Sync internals
  'syncstatus',
  'syncversion',
  'syncstate',
  'syncat',
  'syncmetadata',
  // Timestamp internals
  'createdatmillis',
  'updatedatmillis',
  'createdatlocal',
  'updatedatlocal',
  // ID internals
  'firestoreid',
  'localid',
  'deviceid',
  'userid',
  'internalid',
  // Misc
  'internal',
  'tombstone',
  'deleted',
  'version',
};

const Map<String, String> _arabicLabels = <String, String>{
  'fullname': 'الاسم الكامل',
  'firstname': 'الاسم الأول',
  'lastname': 'اسم العائلة',
  'familyname': 'اسم العائلة',
  'fathername': 'اسم الأب',
  'mothername': 'اسم الأم',
  'grandfathername': 'اسم الجد',
  'nationalid': 'رقم الهوية',
  'idnumber': 'رقم الهوية',
  'fileno': 'رقم الملف',
  'fileidnumber': 'رقم الملف',
  'phone': 'رقم الجوال',
  'phonenumber': 'رقم الجوال',
  'altphonenumber': 'رقم الجوال البديل',
  'address': 'العنوان',
  'currentaddress': 'العنوان الحالي',
  'addressbeforedisplacement': 'العنوان قبل النزوح',
  'governorate': 'المحافظة',
  'province': 'المحافظة',
  'city': 'المدينة',
  'district': 'الحي/القضاء',
  'familymembers': 'أفراد الأسرة',
  'familysize': 'عدد أفراد الأسرة',
  'healthstatus': 'الحالة الصحية',
  'incomelevel': 'مستوى الدخل',
  'incomesource': 'مصدر الدخل',
  'notes': 'ملاحظات',
  'needs': 'الاحتياجات',
  'category': 'التصنيف',
  'sectionid': 'الفئة',
  'subcategory': 'الفئة الفرعية',
  'subsubcategory': 'الفئة الفرعية الثانية',
  'createdat': 'تاريخ الإضافة',
  'updatedat': 'آخر تحديث',
  'maritalstatus': 'الحالة الاجتماعية',
  'gender': 'الجنس',
  'birthdate': 'تاريخ الميلاد',
  'age': 'العمر',
  'educationlevel': 'المستوى التعليمي',
  'employmentstatus': 'حالة العمل',
  'displacementstatus': 'حالة النزوح',
  'housingstatus': 'حالة السكن',
  'housingtype': 'نوع السكن',
  'assistancetype': 'نوع المساعدة',
  'disabilitytype': 'نوع الإعاقة',
  'hasdisability': 'يعاني من إعاقة',
  'chronicdiseasescount': 'عدد الأمراض المزمنة',
  'specialneedscount': 'ذوي الاحتياجات الخاصة',
  'requeststatus': 'حالة الطلب',
  'associationname': 'اسم الجمعية',
  'casedescription': 'وصف الحالة',
  'recommendations': 'التوصيات',
  'healthneeds': 'الاحتياجات الصحية',
  'housingneeds': 'الاحتياجات السكنية',
  'assistanceneeds': 'احتياجات المساعدة',
};

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Returns `true` if [key] is a meaningful beneficiary field that should be
/// shown to the user. Returns `false` for technical/internal keys.
bool shouldDisplayBeneficiaryField(String key) {
  final normalized = key.trim().toLowerCase();
  // Hide underscore-prefixed internal keys
  if (normalized.startsWith('_')) return false;
  // Hide known technical keys (case-insensitive)
  if (_technicalKeys.contains(normalized)) return false;
  return true;
}

/// Returns an Arabic-friendly label for [key], or the original key if no
/// mapping is known.
String beneficiaryFieldLabel(String key) {
  final normalized = key.trim().toLowerCase();
  return _arabicLabels[normalized] ?? key;
}

/// Returns a safe display string for [value] associated with [key].
///
/// Rules:
/// - null / empty string → returns `null` (caller should skip the row)
/// - Map (nested object) → returns `null` unless whitelisted (hide raw maps)
/// - List of simple strings → joins with '، '
/// - List with nested maps → returns `null`
/// - String that looks like raw JSON → returns `null`
/// - Boolean → Arabic yes/no
/// - Other primitives → `.toString()`
String? normalizeBeneficiaryFieldValue(String key, dynamic value) {
  if (value == null) return null;

  if (value is bool) return value ? 'نعم' : 'لا';

  if (value is Map) {
    // Do not render raw nested maps
    return null;
  }

  if (value is List) {
    final parts = <String>[];
    for (final item in value) {
      if (item is Map || item is List) return null;
      final text = item?.toString().trim();
      if (text != null && text.isNotEmpty && !_looksLikeRawJson(text)) {
        parts.add(text);
      }
    }
    if (parts.isEmpty) return null;
    return parts.join('، ');
  }

  final text = value.toString().trim();
  if (text.isEmpty) return null;
  if (_looksLikeRawJson(text)) return null;
  return text;
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

bool _looksLikeRawJson(String value) {
  final trimmed = value.trim();
  return (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
      (trimmed.startsWith('[') && trimmed.endsWith(']')) ||
      trimmed.contains('"metadata"') ||
      trimmed.contains('"payload"') ||
      trimmed.contains('"syncStatus"') ||
      trimmed.contains(r'#meta:');
}
