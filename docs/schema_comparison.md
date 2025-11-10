# Backend vs Local Database Schema Comparison

## Overview
This document compares the backend database schema (from `data.json`) with the local Drift database schema to identify discrepancies and plan necessary updates.

---

## 1. Backend "data" Table Schema

Based on the JSON export, the backend has a single table called **"data"** with the following columns:

| Backend Column | Type | Example | Nullable | Notes |
|---|---|---|---|---|
| `id` | Integer | "201" | No | Primary key (auto-increment) |
| `file_id_number` | String | "006066" | No | File identifier |
| `original_file_id_from_excel` | String | "400008207" | No | Original file ID from Excel import |
| `data_section_id` | Integer | "1" | No | Section identifier |
| `data_request_status` | Integer | "4" | No | Request status code |
| `data_id_number` | String | "400008207" | No | National ID |
| `data_first_name` | String | "انوار" | No | First name |
| `data_father_name` | String | "سمير" | No | Father's name |
| `data_grand_father_name` | String | "حسن" | No | Grandfather's name |
| `data_family_name` | String | "عياد" | No | Family name |
| `data_relationship` | Integer/String | "2" | Yes | Relationship type (widow=2, etc.) |
| `data_birth_date` | Date | "1994-05-22" | No | Birth date |
| `data_gender` | Integer | "2" | No | Gender (1=male, 2=female) |
| `data_phone_number` | String | "594022535" | No | Primary phone |
| `data_alt_phone_number` | String | "567267165" | No | Alternative phone |
| `data_number_of_individuals` | Integer | "3" | No | Family size |
| `data_marital_status` | Integer | "1" | No | Marital status code (1=widow, etc.) |
| `data_academic_qualification` | Integer | "5" | No | Education level code |
| `data_displacement_status` | Integer | "2" | No | Displacement status |
| `data_address_before_displacement` | String | "لم ينزح" | Yes | Address before displacement |
| `data_current_address` | String | null | Yes | Current address |
| `data_city` | Integer/String | "5" | No | City code |
| `data_province` | Integer/String | "2" | No | Province/governorate code |
| `data_health_status` | Integer | "1" | No | Health status code |
| `data_description_needs` | Text | "خيمة كسوة..." | Yes | Description of needs |
| `data_number_mail` | Integer | null | Yes | Number of males (unclear) |
| `data_number_female` | Integer | "2" | Yes | Number of females |
| `data_number_of_individuals_with_chronic_diseases` | Integer | "0" | Yes | Count of people with chronic diseases |
| `data_number_of_people_with_special_needs` | Integer | null | Yes | Count of people with special needs |
| `data_employment_status_breadwinner` | Integer | "1" | No | Employment status of breadwinner |
| `data_housing_status` | Integer | "1" | No | Housing status |
| `data_current_housing_type` | Integer | "4" | No | Current housing type |
| `data_user_insert_data` | Integer | "3" | No | User who inserted data |
| `created_at` | Datetime | "2025-11-09 13:51:47" | No | Creation timestamp |
| `updated_at` | Datetime | "2025-11-09 13:51:47" | No | Last update timestamp |

**Total Backend Fields**: 36 fields

---

## 2. Local "Beneficiaries" Table Schema

| Local Column | Type | Default | Nullable | Notes |
|---|---|---|---|---|
| `id` | String | - | No | Local UUID (primary key) |
| `fullName` | String | - | No | Full name (concatenated) |
| `fullNameNorm` | String | - | No | Normalized name for search |
| `nationalId` | String | - | No | National ID |
| `fileNo` | String | - | No | File number |
| `governorate` | String | - | No | Governorate |
| `district` | String | - | Yes | District/القضاء |
| `address` | String | - | Yes | Full address |
| `phoneNumber` | String | - | Yes | Phone number |
| `motherName` | String | - | Yes | Mother's name |
| `fatherName` | String | - | Yes | Father's name |
| `familySize` | Integer | - | Yes | Family size |
| `gender` | String | - | No | Gender ('male', 'female') |
| `category` | String | - | No | Category (orphan, widow, etc.) |
| `birthDate` | DateTime | - | Yes | Birth date |
| `maritalStatus` | String | - | Yes | Marital status |
| `educationLevel` | String | - | Yes | Education level |
| `healthStatus` | String | - | Yes | Health status |
| `hasDisability` | Boolean | false | No | Has disability |
| `notes` | String | '' | No | Notes |
| `associationName` | String | - | Yes | Association name |
| `createdAt` | DateTime | - | No | Creation timestamp |
| `updatedAt` | DateTime | - | No | Update timestamp |
| `syncState` | String | 'pending' | No | Sync state |
| `serverId` | String | - | Yes | Server ID |
| `lastSyncedAt` | DateTime | - | Yes | Last sync timestamp |

**Total Local Fields**: 25 fields

---

## 3. Field Mapping Analysis

### ✅ Fields that Match (Direct Mapping)

| Backend Field | Local Field | Mapping Notes |
|---|---|---|
| `data_id_number` | `nationalId` | Direct |
| `file_id_number` | `fileNo` | Direct |
| `data_phone_number` | `phoneNumber` | Direct |
| `data_father_name` | `fatherName` | Direct |
| `data_birth_date` | `birthDate` | Direct |
| `data_number_of_individuals` | `familySize` | Direct |
| `data_province` | `governorate` | Direct (needs code-to-name mapping) |
| `data_city` | `district` | Direct (needs code-to-name mapping) |
| `created_at` | `createdAt` | Direct |
| `updated_at` | `updatedAt` | Direct |

### ⚠️ Fields Requiring Transformation

| Backend Field | Local Field | Transformation Needed |
|---|---|---|
| `data_first_name + data_father_name + data_grand_father_name + data_family_name` | `fullName` | **Concatenation**: Need to combine 4 separate name fields |
| `data_gender` (1, 2) | `gender` ('male', 'female') | **Enum mapping**: 1 → 'male', 2 → 'female' |
| `data_marital_status` (1, 2, ...) | `maritalStatus` | **Code-to-label**: 1 → 'widow', etc. |
| `data_academic_qualification` (1-11) | `educationLevel` | **Code-to-label**: Needs taxonomy lookup |
| `data_health_status` (1-4) | `healthStatus` | **Code-to-label**: Needs taxonomy lookup |
| `data_relationship` (2, 5, 15, ...) | `category` | **Category mapping**: 2 → 'widow', 5 → 'orphan', etc. |
| `data_number_of_people_with_special_needs` > 0 | `hasDisability` | **Boolean conversion**: >0 → true, else false |
| `data_description_needs` | `notes` | Direct copy |
| `id` (backend auto-increment) | `serverId` | Store backend ID in serverId field |

### ❌ Backend Fields NOT in Local Schema

These fields exist in backend but are **missing** from local database:

| Backend Field | Type | Purpose | Priority |
|---|---|---|---|
| `data_grand_father_name` | String | Part of full name | ⚠️ **High** (needed for fullName) |
| `data_family_name` | String | Part of full name | ⚠️ **High** (needed for fullName) |
| `data_alt_phone_number` | String | Alternative phone | 🔵 **Medium** |
| `data_displacement_status` | Integer | Displacement status | 🔵 **Medium** |
| `data_address_before_displacement` | String | Previous address | 🟢 **Low** |
| `data_current_address` | String | Current address (mostly null) | 🟢 **Low** |
| `data_number_mail` | Integer | Number of males (unclear name) | 🟢 **Low** |
| `data_number_female` | Integer | Number of females | 🔵 **Medium** |
| `data_number_of_individuals_with_chronic_diseases` | Integer | Chronic disease count | 🔵 **Medium** |
| `data_number_of_people_with_special_needs` | Integer | Special needs count | 🔵 **Medium** (used for hasDisability) |
| `data_employment_status_breadwinner` | Integer | Employment status | 🔵 **Medium** |
| `data_housing_status` | Integer | Housing status | 🔵 **Medium** |
| `data_current_housing_type` | Integer | Housing type | 🔵 **Medium** |
| `data_user_insert_data` | Integer | User who created record | 🟢 **Low** (backend-only) |
| `original_file_id_from_excel` | String | Excel import ID | 🟢 **Low** (backend-only) |
| `data_section_id` | Integer | Section ID | 🟢 **Low** (backend-only) |
| `data_request_status` | Integer | Request status | 🔵 **Medium** |

### ❌ Local Fields NOT in Backend Schema

These fields exist locally but are **not** in backend:

| Local Field | Type | Purpose | Sync Strategy |
|---|---|---|---|
| `fullNameNorm` | String | Normalized search | 🔧 **Local-only** (derive from fullName) |
| `associationName` | String | Association name | ⚠️ **High** - Need to confirm if backend supports this |
| `syncState` | String | Sync status | 🔧 **Local-only** (not synced) |
| `lastSyncedAt` | DateTime | Last sync time | 🔧 **Local-only** (not synced) |

---

## 4. Critical Issues & Recommendations

### 🔴 **Issue 1: Name Structure Mismatch**
- **Backend**: Stores 4 separate fields (`first_name`, `father_name`, `grand_father_name`, `family_name`)
- **Local**: Stores as single `fullName` field
- **Solution**: 
  - When syncing FROM backend → concatenate 4 fields into `fullName`
  - When syncing TO backend → split `fullName` or add 4 separate columns locally

### 🔴 **Issue 2: Integer Codes vs String Labels**
- **Backend**: Uses integer codes (gender=2, maritalStatus=1, etc.)
- **Local**: Uses string labels ('female', 'widow', etc.)
- **Solution**: Create mapping tables in `TaxonomyService` for bidirectional conversion

### 🔴 **Issue 3: Missing Fields in Local Schema**
Local schema is missing **17 backend fields**. Key missing fields:
- `data_alt_phone_number` (alternative phone)
- `data_number_female` / `data_number_mail` (gender breakdown)
- `data_displacement_status` (displacement info)
- `data_employment_status_breadwinner` (employment)
- `data_housing_status` + `data_current_housing_type` (housing info)

**Recommendation**: Add these fields to local `Beneficiaries` table

### 🟡 **Issue 4: Association Name Field**
- Local has `associationName` but backend doesn't seem to have it
- **Action Required**: Confirm with backend team if this field exists

### 🟡 **Issue 5: Date Format**
- Backend: `"1994-05-22"` (ISO 8601 string)
- Local: Drift `dateTime()` type
- **Solution**: DateTime parsing on sync (ISO format is compatible)

### 🟡 **Issue 6: Phone Number Format**
- Backend: Single string like `"594022535"` (no country code)
- Local: Single `phoneNumber` field
- Backend also has `data_alt_phone_number`
- **Solution**: Add `altPhoneNumber` field to local schema

---

## 5. Proposed Database Migration

### Step 1: Add Missing Columns to `Beneficiaries` Table

```dart
class Beneficiaries extends Table {
  // ... existing fields ...
  
  // NEW FIELDS TO ADD:
  TextColumn get grandFatherName => text().nullable()(); // اسم الجد
  TextColumn get familyName => text().nullable()(); // اسم العائلة
  TextColumn get altPhoneNumber => text().nullable()(); // رقم هاتف بديل
  IntColumn get displacementStatus => integer().nullable()(); // حالة النزوح
  TextColumn get addressBeforeDisplacement => text().nullable()(); // عنوان قبل النزوح
  TextColumn get currentAddress => text().nullable()(); // العنوان الحالي
  IntColumn get numberOfMales => integer().nullable()(); // عدد الذكور
  IntColumn get numberOfFemales => integer().nullable()(); // عدد الإناث
  IntColumn get chronicDiseasesCount => integer().nullable()(); // عدد المصابين بأمراض مزمنة
  IntColumn get specialNeedsCount => integer().nullable()(); // عدد ذوي الاحتياجات الخاصة
  IntColumn get employmentStatus => integer().nullable()(); // حالة توظيف المعيل
  IntColumn get housingStatus => integer().nullable()(); // حالة السكن
  IntColumn get housingType => integer().nullable()(); // نوع السكن
  IntColumn get requestStatus => integer().nullable()(); // حالة الطلب
}
```

### Step 2: Update Sync Logic

Create bidirectional mapping in `lib/core/services/sync_service.dart`:

```dart
class BeneficiaryMapper {
  // Backend → Local
  static BeneficiariesCompanion fromBackend(Map<String, dynamic> json) {
    return BeneficiariesCompanion.insert(
      id: Value(Uuid().v4()),
      fullName: '${json['data_first_name']} ${json['data_father_name']} ${json['data_grand_father_name']} ${json['data_family_name']}',
      fullNameNorm: normalizeArabic('${json['data_first_name']} ...'),
      nationalId: json['data_id_number'],
      fileNo: json['file_id_number'],
      fatherName: Value(json['data_father_name']),
      motherName: Value(null), // Not in backend
      grandFatherName: Value(json['data_grand_father_name']),
      familyName: Value(json['data_family_name']),
      phoneNumber: Value(json['data_phone_number']),
      altPhoneNumber: Value(json['data_alt_phone_number']),
      familySize: Value(json['data_number_of_individuals']),
      gender: _mapGender(json['data_gender']),
      category: _mapCategory(json['data_relationship']),
      birthDate: Value(DateTime.parse(json['data_birth_date'])),
      maritalStatus: Value(_getMaritalStatusLabel(json['data_marital_status'])),
      educationLevel: Value(_getEducationLabel(json['data_academic_qualification'])),
      healthStatus: Value(_getHealthStatusLabel(json['data_health_status'])),
      governorate: _getGovernorateLabel(json['data_province']),
      district: Value(_getCityLabel(json['data_city'])),
      address: Value(json['data_current_address']),
      displacementStatus: Value(json['data_displacement_status']),
      addressBeforeDisplacement: Value(json['data_address_before_displacement']),
      currentAddress: Value(json['data_current_address']),
      numberOfMales: Value(json['data_number_mail']),
      numberOfFemales: Value(json['data_number_female']),
      chronicDiseasesCount: Value(json['data_number_of_individuals_with_chronic_diseases']),
      specialNeedsCount: Value(json['data_number_of_people_with_special_needs']),
      hasDisability: Value((json['data_number_of_people_with_special_needs'] ?? 0) > 0),
      employmentStatus: Value(json['data_employment_status_breadwinner']),
      housingStatus: Value(json['data_housing_status']),
      housingType: Value(json['data_current_housing_type']),
      requestStatus: Value(json['data_request_status']),
      notes: Value(json['data_description_needs'] ?? ''),
      serverId: Value(json['id'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      syncState: const Value('synced'),
      lastSyncedAt: Value(DateTime.now()),
    );
  }
  
  // Local → Backend
  static Map<String, dynamic> toBackend(Beneficiary beneficiary) {
    var nameParts = beneficiary.fullName.split(' ');
    return {
      'id': beneficiary.serverId != null ? int.parse(beneficiary.serverId!) : null,
      'file_id_number': beneficiary.fileNo,
      'data_id_number': beneficiary.nationalId,
      'data_first_name': nameParts.isNotEmpty ? nameParts[0] : '',
      'data_father_name': beneficiary.fatherName ?? (nameParts.length > 1 ? nameParts[1] : ''),
      'data_grand_father_name': beneficiary.grandFatherName ?? (nameParts.length > 2 ? nameParts[2] : ''),
      'data_family_name': beneficiary.familyName ?? (nameParts.length > 3 ? nameParts[3] : ''),
      'data_phone_number': beneficiary.phoneNumber ?? '',
      'data_alt_phone_number': beneficiary.altPhoneNumber,
      'data_number_of_individuals': beneficiary.familySize,
      'data_gender': _mapGenderCode(beneficiary.gender),
      'data_relationship': _mapCategoryCode(beneficiary.category),
      'data_birth_date': beneficiary.birthDate?.toIso8601String().split('T')[0],
      'data_marital_status': _getMaritalStatusCode(beneficiary.maritalStatus),
      'data_academic_qualification': _getEducationCode(beneficiary.educationLevel),
      'data_health_status': _getHealthStatusCode(beneficiary.healthStatus),
      'data_province': _getGovernorateCode(beneficiary.governorate),
      'data_city': _getCityCode(beneficiary.district),
      'data_current_address': beneficiary.currentAddress,
      'data_displacement_status': beneficiary.displacementStatus,
      'data_address_before_displacement': beneficiary.addressBeforeDisplacement,
      'data_number_mail': beneficiary.numberOfMales,
      'data_number_female': beneficiary.numberOfFemales,
      'data_number_of_individuals_with_chronic_diseases': beneficiary.chronicDiseasesCount,
      'data_number_of_people_with_special_needs': beneficiary.specialNeedsCount,
      'data_employment_status_breadwinner': beneficiary.employmentStatus,
      'data_housing_status': beneficiary.housingStatus,
      'data_current_housing_type': beneficiary.housingType,
      'data_request_status': beneficiary.requestStatus,
      'data_description_needs': beneficiary.notes,
      'created_at': beneficiary.createdAt.toIso8601String(),
      'updated_at': beneficiary.updatedAt.toIso8601String(),
    };
  }
  
  static String _mapGender(int code) => code == 1 ? 'male' : 'female';
  static int _mapGenderCode(String gender) => gender == 'male' ? 1 : 2;
  
  static String _mapCategory(int? code) {
    // Based on data: 2=widow, 5=orphan, 15=other
    switch (code) {
      case 2: return 'widow';
      case 5: return 'orphan';
      default: return 'other';
    }
  }
  
  static int _mapCategoryCode(String category) {
    switch (category) {
      case 'widow': return 2;
      case 'orphan': return 5;
      default: return 1;
    }
  }
  
  // Similar mapping functions for other enums...
}
```

---

## 6. Action Items

### Immediate (Before Sync Implementation):
1. ✅ **Document complete**: Schema comparison complete
2. ⚠️ **Database migration**: Add 13 missing fields to `Beneficiaries` table
3. ⚠️ **Taxonomy expansion**: Add code mappings for all enums
4. ⚠️ **Confirm associationName**: Check with backend if this field exists

### During Sync Implementation:
5. **Create BeneficiaryMapper** class with bidirectional mapping
6. **Update sync endpoints** to use proper field names
7. **Test data transformation** with backend sample data
8. **Handle null values** appropriately during sync

### Testing:
9. **Pull test**: Fetch 10 beneficiaries from backend and verify all fields map correctly
10. **Push test**: Create local beneficiary and verify it syncs with all 36 backend fields
11. **Round-trip test**: Pull → modify locally → push → pull again, verify data integrity

---

## 7. Conclusion

**Schema Compatibility**: 📊 **60% Compatible**
- Direct mappings: 10/36 fields
- Transformation needed: 9/36 fields
- Missing locally: 17/36 fields
- Missing in backend: 1 field (associationName - needs confirmation)

**Next Steps**:
1. Run database migration to add missing columns
2. Implement `BeneficiaryMapper` class
3. Update `TaxonomyService` with backend code mappings
4. Test sync with sample backend data
5. Handle edge cases (null values, data validation)

**Estimated Work**: 4-6 hours
- Migration: 1 hour
- Mapper implementation: 2 hours
- Testing & debugging: 2-3 hours
