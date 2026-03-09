Overview
This section handles complete CRUD operations for the central database tables including family records, orphans, deceased parents, and document attachments. It also includes a File ID Reservation System that reserves 5000 IDs at a time for offline use.

📋 File ID Reservation System
When a mobile device connects to the internet, it can reserve a batch of 5000 file IDs for creating new records offline. This ensures unique IDs across all devices.

Batch Size: 5000 IDs per reservation (configurable: 100-10000)
Expiry: Reservations expire after 30 days
Auto-renewal: Request new batch when remaining IDs < 1000
🔢 File ID Reservation Endpoints
POST
/api/mobile/database/file-ids/reserve
Description: Reserve a batch of 5000 file IDs for offline record creation. Call this when device connects to internet.
Request Body
Parameter Type Required Description
device_id string Yes Unique device identifier
batch_size integer No Number of IDs to reserve (default: 5000, max: 10000)
Request Example
POST /api/mobile/database/file-ids/reserve

{
"device_id": "550e8400-e29b-41d4-a716-446655440000",
"batch_size": 5000
}
Success Response (201 Created)
{
"success": true,
"message": "File IDs reserved successfully",
"data": {
"reservation": {
"id": 1,
"device_id": "550e8400-e29b-41d4-a716-446655440000",
"start_id": 1001,
"end_id": 6000,
"batch_size": 5000,
"used_count": 0,
"remaining_count": 5000,
"next_available_id": 1001,
"status": "active",
"expires_at": "2026-02-05T12:00:00+00:00",
"created_at": "2026-01-06T12:00:00+00:00"
},
"is_new": true
}
}
GET
/api/mobile/database/file-ids/reservations
Description: Get current file ID reservations for this device.
Query Parameters
Parameter Type Required Description
device_id string Yes Device identifier
Success Response (200 OK)
{
"success": true,
"data": {
"reservations": [...],
"active_reservation": {
"id": 1,
"start_id": 1001,
"end_id": 6000,
"remaining_count": 4500,
"next_available_id": 1501,
"status": "active"
},
"total_available": 4500
}
}
POST
/api/mobile/database/file-ids/sync-used
Description: Sync the count of used file IDs from mobile to server.
Request Body
{
"device_id": "550e8400-e29b-41d4-a716-446655440000",
"reservation_id": 1,
"used_count": 150
}
📊 Data Table (Main Family Records)
📋 Complete Field Coverage (45 Fields Total)
All API responses return complete database records with 100% field coverage, organized in these categories:

Basic Identification: id, file_id_number, original_file_id_from_excel
Name Information: Arabic names + normalized versions for efficient search (data_first_name, data_first_name_normalized, etc.)
Personal Information: ID number, birth date, gender
Contact Information: Phone numbers (primary + alternate)
Location: Province, city, current address, address before displacement
Status & Classification: Request status, sponsorship status, relationship, section ID
Family Composition Statistics: Total individuals, male count, female count, chronic diseases count, special needs count
Socioeconomic Information: Academic qualification, marital status, displacement status, employment status, housing status, housing type
Health & Special Needs: Health status, description of needs
System Fields: User who inserted data, timestamps (created_at, updated_at)
Search Optimization: All name fields include \*\_normalized versions for Arabic text search without diacritics (تشكيل).

GET
/api/mobile/database/data
Description: Sync main family/guardian records with pagination and incremental sync.
Query Parameters
Parameter Type Required Description
updated_after string No ISO 8601 timestamp for incremental sync
file_ids array|string No Specific file IDs to fetch (array or comma-separated string, e.g. "1001,1002,1003")
per_page integer No Items per page (default: 100, max: 500)
page integer No Page number
Success Response (200 OK)
{
"success": true,
"message": "Data records synced successfully",
"data": {
"records": [
{
// Basic Identification
"id": 1,
"file_id_number": 1001,
"original_file_id_from_excel": "EXC-1001",

                // Name Information (Arabic + Normalized for Search)
                "data_first_name": "محمد",
                "data_first_name_normalized": "محمد",
                "data_father_name": "أحمد",
                "data_father_name_normalized": "احمد",
                "data_grand_father_name": "علي",
                "data_grand_father_name_normalized": "علي",
                "data_family_name": "الغزاوي",
                "data_family_name_normalized": "الغزاوي",

                // Personal Information
                "data_id_number": "123456789",
                "data_birth_date": "1985-03-15",
                "data_gender": 1,

                // Contact Information
                "data_phone_number": "+970591234567",
                "data_alt_phone_number": "+970599876543",

                // Location
                "data_province": 1,
                "data_province_name": "غزة",
                "data_city": 1,
                "data_city_name": "غزة",
                "data_current_address": "حي الشجاعية، غزة",
                "data_address_before_displacement": "بيت حانون، شمال غزة",

                // Status & Classification
                "data_request_status": 2,
                "data_request_status_name": "مقبول",
                "sponsorship_status": 1,
                "data_relationship": 3,
                "data_section_id": 1,

                // Family Composition Statistics
                "data_number_of_individuals": 5,
                "data_number_mail": 2,
                "data_number_female": 3,
                "data_number_of_individuals_with_chronic_diseases": 1,
                "data_number_of_people_with_special_needs": 0,

                // Socioeconomic Information
                "data_academic_qualification": 2,
                "data_marital_status": 1,
                "data_marital_status_name": "متزوج",
                "data_displacement_status": 1,
                "data_employment_status_breadwinner": 3,
                "data_housing_status": 2,
                "data_current_housing_type": 1,

                // Health & Special Needs
                "data_health_status": 1,
                "data_health_status_name": "سليم",
                "data_description_needs": "احتياجات طبية دورية للأم",

                // System Fields
                "data_user_insert_data": 1,
                "created_at": "2026-01-01T00:00:00+00:00",
                "updated_at": "2026-01-06T12:00:00+00:00"
            }
        ],
        "pagination": {
            "current_page": 1,
            "last_page": 10,
            "per_page": 100,
            "total": 950
        },
        "sync_timestamp": "2026-01-06T12:00:00+00:00"
    }

}
GET
/api/mobile/database/data/{file_id_number}
Description: Get a complete data record with all related data (family members, deceased parents, attachments).
Success Response (200 OK)
{
"success": true,
"data": {
"record": {
// All 45 fields from Data table (same as sync endpoint above)
"file_id_number": 1001,
"data_first_name": "فاطمة",
"data_first_name_normalized": "فاطمة",
"data_family_name": "الفلسطينية",
"data_family_name_normalized": "الفلسطينية",
... // (all other data fields)

            // Related Data
            "family_members": [
                {
                    // Complete Re-People record with all 23 fields
                    "id": 1,
                    "registration_id": 1001,
                    "person_id": "456789123",

                    // Name Information (with normalized versions for search)
                    "first_name": "يوسف",
                    "first_name_normalized": "يوسف",
                    "second_name": "محمد",
                    "second_name_normalized": "محمد",
                    "third_name": "أحمد",
                    "third_name_normalized": "احمد",
                    "last_name": "الفلسطيني",
                    "last_name_normalized": "الفلسطيني",

                    // Personal Information
                    "person_birth_date": "2015-05-10",
                    "person_age": 9,
                    "person_gender": 1,

                    // Status Information
                    "person_health_status": 1,
                    "person_health_status_name": "سليم",
                    "sponsorship_status": 1,
                    "sponsorship_status_name": "مكفول",
                    "person_type_of_guarantee": 1,
                    "person_type_of_guarantee_name": "كفالة شاملة",

                    // Additional Information
                    "person_note": "طالب متفوق",

                    // Timestamps
                    "created_at": "2026-01-01T00:00:00+00:00",
                    "updated_at": "2026-01-06T12:00:00+00:00"
                }
            ],
            "deceased_parents": {
                "father": {
                    "first_name": "أحمد",
                    "death_date": "2024-10-15",
                    "death_reason_name": "شهيد"
                },
                "mother": null
            },
            "attachments": [
                {
                    // Complete Attachment record with all 13 fields
                    "id": 26872,
                    "person_identity_number": "123456789",

                    // File Information
                    "stored_file_name": "birth_certificate_001548.pdf",
                    "file_path": "uploads/001548/birth_certificate.pdf",
                    "file_size": 245678,
                    "mime_type": "application/pdf",
                    "file_type": 1,

                    // Google Drive Synchronization
                    "google_drive_file_id": "1A2B3C4D5E6F7G8H9I",
                    "google_drive_path": "/Documents/001548/birth_certificate.pdf",
                    "uploaded_to_drive_at": "2026-01-05T14:30:00+00:00",

                    // Download URL
                    "download_url": "/api/mobile/database/attachments/26872/download",

                    // Timestamps
                    "created_at": "2026-01-05T10:00:00+00:00",
                    "updated_at": "2026-01-05T14:30:00+00:00"
                }
            ]
        }
    }

}
POST
/api/mobile/database/data
Description: Create a new family record. Use a file_id_number from your reserved batch.
Request Body
{
"file_id_number": 1001,
"data_first_name": "سارة",
"data_father_name": "خالد",
"data_family_name": "الغزاوية",
"data_id_number": "987654321",
"data_birth_date": "1990-08-20",
"data_gender": 2,
"data_phone_number": "+970599876543",
"data_province": 1,
"data_city": 2,
"data_current_address": "حي الشجاعية، غزة",
"data_number_of_individuals": 4,
"device_id": "550e8400-e29b-41d4-a716-446655440000"
}
Note: data_gender accepts both integer (1=male/ذكر, 2=female/انثى) and string values ("male", "female", "ذكر", "انثى"). The API automatically converts strings to integers.
Success Response (201 Created)
{
"success": true,
"message": "Record created successfully",
"data": {
"record": {
"id": 1,
"file_id_number": 1001,
"data_first_name": "سارة",
...
}
}
}
PUT
/api/mobile/database/data/{file_id_number}
Description: Update an existing family record. Only include fields you want to change — all fields are optional.
Authentication: Required (Bearer token)
URL Parameter
Parameter Type Description
file_id_number integer The unique file ID of the record to update
Request Body (all fields optional)
{
"data_first_name": "سارة",
"data_father_name": "خالد",
"data_grand_father_name": "عمر",
"data_family_name": "الغزاوية",
"data_id_number": "987654321",
"data_birth_date": "1990-08-20",
"data_gender": 2,
"data_phone_number": "+970599876543",
"data_alt_phone_number": "+970591234567",
"data_province": 1,
"data_city": 2,
"data_current_address": "حي الشجاعية، غزة",
"data_address_before_displacement": "بيت لاهيا",
"data_number_of_individuals": 4,
"data_marital_status": 2,
"data_health_status": 1,
"data_request_status": 1,
"data_displacement_status": 1
}
Success Response (200 OK)
{
"success": true,
"message": "Record updated successfully",
"data": {
"record": {
"id": 1,
"file_id_number": 1001,
"data_first_name": "سارة",
"data_father_name": "خالد",
...
}
}
}
Error Response (404 Not Found)
{
"success": false,
"message": "Record not found"
}
DELETE
/api/mobile/database/data/{file_id_number}
Description: Permanently delete a family record and all its associated re_people members.
Authentication: Required (Bearer token)
⚠️ Warning: This is a permanent action and cannot be undone.
URL Parameter
Parameter Type Description
file_id_number integer The unique file ID of the record to delete
Success Response (200 OK)
{
"success": true,
"message": "Record deleted successfully"
}
Error Response (404 Not Found)
{
"success": false,
"message": "Record not found"
}
POST
/api/mobile/database/data/batch
Description: Batch create/update records. Use this to sync offline-created records.
Request Body
{
"records": [
{
"file_id_number": 1001,
"data_first_name": "محمد",
"data_family_name": "الفلسطيني",
...
},
{
"file_id_number": 1002,
"data_first_name": "أحمد",
...
}
],
"device_id": "550e8400-e29b-41d4-a716-446655440000"
}
Success Response (200 OK)
{
"success": true,
"message": "Batch sync completed",
"data": {
"created": [1001],
"created_count": 1,
"updated": [1002],
"updated_count": 1,
"failed": [],
"failed_count": 0
}
}
👨‍👩‍👧‍👦 Re-People (Family Members/Orphans)
📋 Complete Field Coverage (23 Fields Total)
All family member records include complete information organized in these categories:

Identity: id, registration_id (parent file number), person_id (national ID)
Name Information: Four-part name (first, second, third, last) + normalized versions for search
Personal Information: Birth date, calculated age, gender
Status Information: Health status, sponsorship status, guarantee type (with Arabic names)
Additional Information: Notes field for special remarks
Timestamps: created_at, updated_at
Normalized Names: All name fields include \*\_normalized versions (first_name_normalized, second_name_normalized, etc.) for efficient Arabic search without diacritics.

GET
/api/mobile/database/re-people
Description: Sync family member records (orphans, children).
Query Parameters
Parameter Type Required Description
updated_after string No Timestamp for incremental sync
registration_ids array|string No Filter by parent file IDs (array or comma-separated string, e.g. "1001,1002")
Success Response (200 OK)
{
"success": true,
"message": "Re-people records synced successfully",
"data": {
"records": [
{
// Identity
"id": 1,
"registration_id": 1001,
"person_id": "456789123",

                // Name Information (with normalized versions for search)
                "first_name": "يوسف",
                "first_name_normalized": "يوسف",
                "second_name": "محمد",
                "second_name_normalized": "محمد",
                "third_name": "أحمد",
                "third_name_normalized": "احمد",
                "last_name": "الفلسطيني",
                "last_name_normalized": "الفلسطيني",

                // Personal Information
                "person_birth_date": "2015-05-10",
                "person_age": 11,
                "person_gender": 1,

                // Status Information
                "person_health_status": 1,
                "person_health_status_name": "سليم",
                "sponsorship_status": 1,
                "sponsorship_status_name": "مكفول",
                "person_type_of_guarantee": 1,
                "person_type_of_guarantee_name": "كفالة شاملة",

                // Additional Information
                "person_note": null,

                // Timestamps
                "created_at": "2026-01-01T00:00:00+00:00",
                "updated_at": "2026-01-06T12:00:00+00:00"
            }
        ],
        "pagination": {
            "current_page": 1,
            "last_page": 5,
            "per_page": 100,
            "total": 450
        },
        "sync_timestamp": "2026-01-06T12:00:00+00:00"
    }

}
POST
/api/mobile/database/re-people
Description: Add a new family member to a record.
Request Body
{
"registration_id": 1001,
"first_name": "يوسف",
"second_name": "محمد",
"last_name": "الفلسطيني",
"person_id": "456789123",
"person_birth_date": "2018-03-10",
"person_gender": 1,
"person_health_status": 1,
"sponsorship_status": 2,
"person_type_of_guarantee": 1
}
Note: person_gender accepts both integer (1=male/ذكر, 2=female/انثى) and string values ("male", "female", "ذكر", "انثى"). The API automatically converts strings to integers.
Required Fields
Field Type Description
registration_id integer Must exist as file_id_number in the data table
first_name string (max 255) First name of the family member
Success Response (201 Created)
{
"success": true,
"message": "Re-people record created successfully",
"data": {
"record": {
"id": 42,
"registration_id": 1001,
"first_name": "يوسف",
"second_name": "محمد",
"third_name": null,
"last_name": "الفلسطيني",
"person_id": "456789123",
"person_birth_date": "2018-03-10",
"person_gender": 1,
"person_gender_label": "ذكر",
"person_health_status": 1,
"sponsorship_status": 2,
"person_type_of_guarantee": 1,
"person_note": null,
"created_at": "2026-02-25T10:00:00+00:00",
"updated_at": "2026-02-25T10:00:00+00:00"
}
}
}
PUT
/api/mobile/database/re-people/{id}
Description: Update an existing family member record. All fields optional.
Authentication: Required (Bearer token)
URL Parameter
Parameter Type Description
id integer The auto-incremented ID of the re_people record
Request Body (all fields optional)
{
"first_name": "يوسف",
"second_name": "محمد",
"third_name": "أحمد",
"last_name": "الفلسطيني",
"person_id": "456789123",
"person_birth_date": "2018-03-10",
"person_gender": 1,
"person_health_status": 1,
"sponsorship_status": 2,
"person_type_of_guarantee": 1,
"person_note": "ملاحظة اختيارية"
}
Success Response (200 OK)
{
"success": true,
"message": "Re-people record updated successfully",
"data": { "record": { "id": 42, ... } }
}
Error Response (404 Not Found)
{
"success": false,
"message": "Re-people record with ID 42 not found"
}
DELETE
/api/mobile/database/re-people/{id}
Description: Permanently delete a family member record.
Authentication: Required (Bearer token)
⚠️ Warning: Permanent — cannot be undone.
Success Response (200 OK)
{
"success": true,
"message": "Re-people record deleted successfully"
}
Error Response (404 Not Found)
{
"success": false,
"message": "Re-people record with ID 42 not found"
}
⚰️ Dead-People (Deceased Parents)
GET
/api/mobile/database/dead-people
Description: Retrieve deceased parent records with pagination and filtering options.
Authentication: Required (Bearer token)
Total Records: ~14,000+ deceased parent records
Query Parameters
Parameter Type Required Description
updated_after string No ISO 8601 timestamp for incremental sync (e.g., "2026-02-24T10:00:00Z")
file_ids array|string No Filter by re_file_id - array format or comma-separated (e.g., "000004,000009")
per_page integer No Records per page, max 1000 (default: 100)
page integer No Page number for pagination (default: 1)
Example Request
GET /api/mobile/database/dead-people?per_page=50&page=1
Authorization: Bearer YOUR_TOKEN
Success Response
Status Code: 200 OK
{
"success": true,
"message": "Dead people records synced successfully",
"data": {
"records": [
{
"re_file_id": "000004",
"father": {
"first_name": "أحمد",
"second_name": "محمود",
"third_name": "علي",
"last_name": "الفلسطيني",
"id_number": 123456789,
"death_date": "2024-10-15",
"death_reason": 1,
"death_reason_name": "شهيد"
},
"mother": {
"first_name": "فاطمة",
"second_name": "حسن",
"third_name": "أحمد",
"last_name": "الفلسطينية",
"id_number": 987654321,
"death_date": "2023-05-20",
"death_reason": 2,
"death_reason_name": "وفاة طبيعية"
},
"created_at": "2025-01-15T08:30:00Z",
"updated_at": "2026-02-20T14:20:00Z"
},
{
"re_file_id": "000009",
"father": {
"first_name": "محمد",
"second_name": "عبدالله",
"third_name": null,
"last_name": "السعيد",
"id_number": null,
"death_date": "2023-12-01",
"death_reason": 1,
"death_reason_name": "شهيد"
},
"mother": {
"first_name": null,
"second_name": null,
"third_name": null,
"last_name": null,
"id_number": null,
"death_date": null,
"death_reason": null,
"death_reason_name": null
},
"created_at": "2024-06-10T12:00:00Z",
"updated_at": "2024-06-10T12:00:00Z"
}
],
"pagination": {
"current_page": 1,
"last_page": 286,
"per_page": 50,
"total": 14264
},
"sync_timestamp": "2026-02-24T10:30:00Z"
}
}
💡 Response Structure Notes
Nested Objects: Father and mother data returned as separate nested objects
Death Reason Names: Includes both the code and the human-readable description
Complete Name Fields: All four name parts (first, second, third, last) included for both parents
Null Values: Fields are null if parent is alive or data not available
💡 Sync Strategy Tips
Initial Sync: Use per_page=1000 for fastest initial download
Incremental Sync: Use updated_after parameter with last sync timestamp
File-Specific: Use file_ids to get deceased parents for specific families only
Batch Processing: For 14,000+ records, process in batches to avoid memory issues
Store Locally: Save sync_timestamp from response for next incremental sync
POST
/api/mobile/database/dead-people
Description: Create or update deceased parent information linked to a family record.
Authentication: Required (Bearer token)
Request Body Fields
Field Type Required Description
re_file_id integer Yes Family file ID number (must exist in data table)
👨 Father Information
father_first_name string No Father's first name (max 255 chars)
father_second_name string No Father's second name (max 255 chars)
father_third_name string No Father's third name (max 255 chars)
father_last_name string No Father's last name (max 255 chars)
father_id string No Father's national ID number (max 50 chars)
father_death_date date No Father's death date (format: YYYY-MM-DD)
father_death_reason integer No Father's death reason code (foreign key to death_reasons table)
👩 Mother Information
mother_first_name string No Mother's first name (max 255 chars)
mother_second_name string No Mother's second name (max 255 chars)
mother_third_name string No Mother's third name (max 255 chars)
mother_last_name string No Mother's last name (max 255 chars)
mother_id string No Mother's national ID number (max 50 chars)
mother_death_date date No Mother's death date (format: YYYY-MM-DD)
mother_death_reason integer No Mother's death reason code (foreign key to death_reasons table)
Request Body Example (Complete)
{
"re_file_id": 1234,
"father_first_name": "أحمد",
"father_second_name": "محمود",
"father_third_name": "علي",
"father_last_name": "الفلسطيني",
"father_id": "123456789",
"father_death_date": "2024-10-15",
"father_death_reason": 1,
"mother_first_name": "فاطمة",
"mother_second_name": "حسن",
"mother_third_name": "أحمد",
"mother_last_name": "الفلسطينية",
"mother_id": "987654321",
"mother_death_date": "2023-05-20",
"mother_death_reason": 2
}
Request Body Example (Father Only)
{
"re_file_id": 1234,
"father_first_name": "أحمد",
"father_second_name": "محمود",
"father_third_name": "علي",
"father_last_name": "الفلسطيني",
"father_id": "123456789",
"father_death_date": "2024-10-15",
"father_death_reason": 1
}
Request Body Example (Mother Only)
{
"re_file_id": 1234,
"mother_first_name": "فاطمة",
"mother_second_name": "حسن",
"mother_third_name": "أحمد",
"mother_last_name": "الفلسطينية",
"mother_id": "987654321",
"mother_death_date": "2023-05-20",
"mother_death_reason": 2
}
Success Response (Created)
Status Code: 201 Created
{
"success": true,
"message": "Record created successfully",
"data": {
"record": {
"re_file_id": "001234",
"father": {
"first_name": "أحمد",
"second_name": "محمود",
"third_name": "علي",
"last_name": "الفلسطيني",
"id_number": "123456789",
"death_date": "2024-10-15",
"death_reason": 1,
"death_reason_name": "شهيد"
},
"mother": {
"first_name": "فاطمة",
"second_name": "حسن",
"third_name": "أحمد",
"last_name": "الفلسطينية",
"id_number": "987654321",
"death_date": "2023-05-20",
"death_reason": 2,
"death_reason_name": "وفاة طبيعية"
},
"created_at": "2026-02-24T10:30:00Z",
"updated_at": "2026-02-24T10:30:00Z"
},
"is_new": true
}
}
Success Response (Updated)
Status Code: 200 OK
{
"success": true,
"message": "Record updated successfully",
"data": {
"record": {
"re_file_id": "001234",
"father": { ... },
"mother": { ... },
"created_at": "2025-01-15T08:30:00Z",
"updated_at": "2026-02-24T10:30:00Z"
},
"is_new": false
}
}
Error Response - Validation Failed
Status Code: 422 Unprocessable Entity
{
"success": false,
"error": "validation_error",
"errors": {
"re_file_id": [
"The re file id field is required."
],
"father_death_date": [
"The father death date must be a valid date."
]
}
}
Error Response - File ID Not Found
Status Code: 422 Unprocessable Entity
{
"success": false,
"error": "validation_error",
"errors": {
"re_file_id": [
"The selected re file id is invalid."
]
}
}
💡 Important Implementation Notes
Required Field: Only re_file_id is required - must exist in the data table
Data Type: re_file_id passed as integer in request but stored as string in database
Update or Create: If record exists for the re_file_id, it will be updated, otherwise created
Partial Updates: You can update only father's data, only mother's data, or both
ID Fields: father_id and mother_id are strings (can contain leading zeros)
Death Reasons: Use integer codes from death_reasons table (API will include names in response)
Response Format: Returns nested structure with father/mother objects
is_new Flag: Response includes boolean flag indicating if record was created or updated
📎 Attachments
📋 Complete Attachment Metadata (13 Fields)
All attachment records include comprehensive file information:

Identity: id, person_identity_number (owner ID)
File Information: stored_file_name, file_path, file_size (bytes), mime_type, file_type
Google Drive Synchronization: google_drive_file_id, google_drive_path, uploaded_to_drive_at
Download URL: download_url (fully constructed endpoint URL)
Timestamps: created_at, updated_at
Note: Attachment metadata is included in full Data record responses and Re-People responses. File content is downloaded separately using the download endpoint.

GET
/api/mobile/database/attachments
Sync attachment metadata (not file content).
⚠️ CRITICAL — Response Key Exception for Flutter Developers
This endpoint does NOT follow the universal data.records[] pattern. It uses data.attachments[] instead.

// ❌ WRONG — will return null
final list = response['data']['records'];

// ✅ CORRECT
final list = response['data']['attachments'];

// ✅ Use the pre-built download_url field — already a complete URL
final url = attachment['download_url'];
// e.g. "https://palestine.benaadev.org/api/mobile/database/attachments/3556/download"
Full response shape:

{
"success": true,
"data": {
"attachments": [ <-- key is "attachments", not "records"
{
"id": 3556,
"person_identity_number": "420265142",
"stored_file_name": "4_001952_420265142.jpg",
"file_path": "storage/uploads/001952/4_001952_420265142.jpg",
"file_size": 204800,
"mime_type": "image/jpeg",
"file_type": "صورة شخصية",
"download_url": "https://palestine.benaadev.org/api/mobile/database/attachments/3556/download",
"created_at": "2025-01-01T00:00:00.000000Z",
"updated_at": "2025-01-01T00:00:00.000000Z"
}
],
"pagination": { "current_page": 1, "last_page": 13, "per_page": 100, "total": 1255 }
}
}
POST
/api/mobile/database/attachments
Description: Upload a document attachment (multipart/form-data).
Form Data
Field Type Required Description
person_identity_number string Yes Person's ID number
file file Yes Document file (max 10MB)
file_type string No Document type description
DELETE
/api/mobile/database/attachments/{id}
Delete an attachment.
GET
/api/mobile/database/attachments/{id}/download
Description: Download the actual file content for an attachment. Returns raw binary data (image/jpeg, image/png, application/pdf, etc.).
Authentication: Required (Bearer token)
Response: Binary file download (200 OK with Content-Disposition header)
Route Constraint: {id} must be a numeric integer only
💡 How to get Attachment IDs
The {id} parameter is the numeric attachment ID from the attachments table. Get it from the attachments list endpoint:

GET /api/mobile/database/attachments
// ⚠️ Response key is "attachments" NOT "records" (unlike all other endpoints!)
{
"success": true,
"data": {
"attachments": [
{"id": 3556, "person_identity_number": "420265142", "stored_file_name": "4_001952_420265142.jpg", "download_url": "https://palestine.benaadev.org/api/mobile/database/attachments/3556/download", ...},
{"id": 3557, "person_identity_number": "420265142", "stored_file_name": "5_001952_420265142.jpg", "download_url": "https://palestine.benaadev.org/api/mobile/database/attachments/3557/download", ...}
],
"pagination": {"current_page": 1, "last_page": 13, "per_page": 100, "total": 1255}
}
}

// Dart — CORRECT:
final attachments = response['data']['attachments'] as List;

// Dart — WRONG (returns null):
// final attachments = response['data']['records'];

// Use pre-built download_url from the response, or build manually:
GET /api/mobile/database/attachments/3556/download
ℹ️ File Storage Architecture
Files are physically stored under storage/app/public/uploads/{re_file_id}/ on the server and served via Laravel's storage symlink. The file_path field in the database record contains the relative path (e.g. storage/uploads/001952/4_001952_420265142.jpg).

Path Parameters
Parameter Type Description
id integer|string Attachment ID (e.g., 26872) OR Person Identity Number (e.g., "003647")
Request Example (cURL)
curl -X GET \
 "https://palestine.benaadev.org/api/mobile/database/attachments/3556/download" \
 -H "Authorization: Bearer YOUR_TOKEN" \
 -H "Accept: application/json" \
 -o downloaded_file.jpg
Request Example (JavaScript/Fetch)
const token = 'YOUR_ACCESS_TOKEN';

// Use numeric attachment ID from /api/mobile/database/attachments response
const attachmentId = 3556; // example ID from actual production data
const url1 = `https://palestine.benaadev.org/api/mobile/database/attachments/${attachmentId}/download`;

// Download function (works with both methods)
async function downloadAttachment(url, filename = 'attachment.jpg') {
try {
const response = await fetch(url, {
method: 'GET',
headers: {
'Authorization': `Bearer ${token}`,
'Accept': 'application/json'
}
});

        if (!response.ok) {
            const error = await response.json();
            console.error('Download failed:', error);
            alert(error.message || 'Download failed');
            return;
        }

        // Create download link
        const blob = await response.blob();
        const downloadUrl = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = downloadUrl;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(downloadUrl);
        document.body.removeChild(a);

        console.log('File downloaded successfully');
    } catch (error) {
        console.error('Error:', error);
        alert('An error occurred while downloading');
    }

}

// Usage
downloadAttachment(url1); // e.g. attachment ID 3556
Request Example (Flutter/Dart)
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// Download attachment by numeric ID (from /api/mobile/database/attachments records[].id)
Future<File?> downloadAttachmentById(int attachmentId, String token) async {
final url = 'https://palestine.benaadev.org/api/mobile/database/attachments/$attachmentId/download';
return _downloadFile(url, token, 'attachment_$attachmentId');
}

// Common download function
Future<File?> \_downloadFile(String url, String token, String filePrefix) async {
try {
final response = await http.get(
Uri.parse(url),
headers: {
'Authorization': 'Bearer $token',
'Accept': 'application/json',
},
);

    if (response.statusCode == 200) {
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filePrefix.jpg';

      // Write file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      print('File downloaded: $filePath');
      print('File size: ${response.bodyBytes.length} bytes');

      return file;
    } else if (response.statusCode == 404) {
      print('Attachment not found: ${response.body}');
      return null;
    } else {
      print('Download failed: ${response.statusCode}');
      print('Error: ${response.body}');
      return null;
    }

} catch (e) {
print('Error downloading attachment: $e');
return null;
}
}

// Usage:
// File? file = await downloadAttachmentById(3556, token);
Request Example (Android/Kotlin)
import okhttp3.\*
import java.io.File
import java.io.FileOutputStream

fun downloadAttachment(attachmentId: Int, token: String, savePath: String): Boolean {
val client = OkHttpClient()
val url = "https://palestine.benaadev.org/api/mobile/database/attachments/$attachmentId/download"

    val request = Request.Builder()
        .url(url)
        .header("Authorization", "Bearer $token")
        .header("Accept", "application/json")
        .build()

    return try {
        val response = client.newCall(request).execute()

        if (response.isSuccessful) {
            val file = File(savePath, "attachment_$attachmentId.jpg")
            val inputStream = response.body?.byteStream()
            val outputStream = FileOutputStream(file)

            inputStream?.copyTo(outputStream)
            outputStream.close()
            inputStream?.close()

            println("File downloaded: ${file.absolutePath}")
            println("File size: ${file.length()} bytes")
            true
        } else {
            println("Download failed: ${response.code}")
            println("Error: ${response.body?.string()}")
            false
        }
    } catch (e: Exception) {
        println("Error downloading attachment: ${e.message}")
        false
    }

}
Success Response
Status Code: 200 OK
Content-Type: image/jpeg (or file's actual mime type)
Content-Disposition: attachment; filename="filename.jpg"
Body: Binary file content
Error Responses
Status Error Code Description
401 UNAUTHENTICATED Missing or invalid authentication token
404 ATTACHMENT_NOT_FOUND No attachment found with given ID or person identity number
404 FILE_NOT_FOUND Attachment record exists but file not found on server
500 SERVER_ERROR Internal server error during download
Error Response Examples
Case 1: Attachment Not Found

{
"success": false,
"message": "Attachment not found. Please use attachment ID or person identity number.",
"error_code": "ATTACHMENT_NOT_FOUND",
"hint": "Get attachment IDs from /api/mobile/database/data/{file_id} endpoint"
}
Case 2: File Not Found on Server

{
"success": false,
"message": "Attachment file not found on server",
"error_code": "FILE_NOT_FOUND",
"attachment_info": {
"id": 26872,
"person_identity_number": "003647",
"stored_file_name": "birth_certificate_001548.pdf",
"file_path": "uploads/001548/birth_certificate.pdf"
}
}
💡 Implementation Notes
ID Parameter Flexibility: Accepts both attachment.id (numeric) and person_identity_number (string)
Recommended Approach: Use attachment.id for precise file selection, especially when multiple attachments exist for one person
Person ID Method: Returns first attachment when using person_identity_number - useful for quick access but may not be the desired file if multiple exist
File Storage: Files are stored in storage/app/public/uploads/ directory
Path Resolution: System automatically checks multiple possible paths for backward compatibility
Authentication: Bearer token required - obtain from login endpoint
File Types: Supports all file types (images, PDFs, documents, etc.)
Logging: All download attempts are logged with both attachment.id and person_identity_number for security auditing
Testing: Use test page at /test-attachment-download.html for interactive testing
⚠️ Common Mistake - Using Wrong ID Type
Problem: Getting 404 error when trying to download

Wrong: Using file_id_number (e.g., "001548") - this is the family record ID, not attachment ID

Correct Option 1: Use attachment.id from the attachments array (e.g., 26872)

Correct Option 2: Use person_identity_number (e.g., "003647") - the national ID of the person

// Get attachment IDs from data record:
GET /api/mobile/database/data/001548

// Response includes:
{
"attachments": [
{
"id": 26872, // ← Use this for download
"person_identity_number": "003647", // ← Or use this
"download_url": "/api/mobile/database/attachments/26872/download"
}
]
}
🧪 Available Test Attachment IDs (Local Development)
The following attachment IDs have actual files on local server and can be used for testing:

26872-26876: From folder 001623 (JPG files, sizes: 141-155 KB)
26877: From folder 001548 (JPG file, 171 KB)
26878-26879: From folder 001549 (JPG files, 40-130 KB)
26880-26881: From folder 001550 (JPG files, 57-158 KB)
26882-26883: From folder 001624 (JPG files, 72-191 KB)
26884-26885: From folder 001626 (JPG files, 29-33 KB)
26886-26887: From folder 001627 (JPG files, 39-47 KB)
Example Test URL: GET /api/mobile/database/attachments/26872/download

🏦 Guardian Bank Accounts (الحسابات البنكية للأوصياء)
📋 Complete Bank Account Fields (14 Fields)
All bank account records include the following fields:

Identity: id, guardian_registration (file_id_number of the guardian)
Bank: bank_name_id (integer FK), bank_name_label (resolved name string)
IBANs: iban_usd, iban_shekel
Representative: re_id_number, re_guardian_name, re_phone_number
National ID: person_owner_identity_number
Status: check_account (0/1), is_approved (boolean alias of check_account)
Timestamps: created_at, updated_at
Note: Bank account data is also embedded inside full Data record responses under the bank_account key.

GET
/api/mobile/database/bank-accounts
Description: Sync all guardian bank accounts with pagination and incremental sync support.
Query Parameters
Parameter Type Required Description
updated_after string No ISO 8601 timestamp for incremental sync
per_page integer No Records per page (default: 100, max: 1000)
page integer No Page number (default: 1)
Success Response
{
"success": true,
"message": "Bank accounts retrieved successfully",
"data": {
"records": [
{
"id": 1,
"guardian_registration": 1234,
"bank_name_id": 3,
"bank_name_label": "البنك الإسلامي الفلسطيني",
"iban_usd": "PS92PIBC000000000012345678901",
"iban_shekel": "PS92PIBC000000000012345678902",
"re_id_number": "987654321",
"re_guardian_name": "محمد أحمد",
"re_phone_number": "0591234567",
"person_owner_identity_number": "123456789",
"check_account": 1,
"is_approved": true,
"created_at": "2024-01-01T00:00:00.000000Z",
"updated_at": "2024-06-01T12:00:00.000000Z"
}
],
"pagination": {
"current_page": 1,
"last_page": 1,
"per_page": 100,
"total": 1
},
"sync_timestamp": "2026-02-25T10:00:00.000000Z"
}
}
GET
/api/mobile/database/bank-accounts/{id}
Description: Retrieve a single bank account record by its ID.
Success Response
{
"success": true,
"message": "Bank account retrieved successfully",
"data": {
"bank_account": {
"id": 1,
"guardian_registration": 1234,
"bank_name_id": 3,
"bank_name_label": "البنك الإسلامي الفلسطيني",
"iban_usd": "PS92PIBC000000000012345678901",
"iban_shekel": null,
"re_id_number": "987654321",
"re_guardian_name": "محمد أحمد",
"re_phone_number": "0591234567",
"person_owner_identity_number": "123456789",
"check_account": 1,
"is_approved": true,
"created_at": "2024-01-01T00:00:00.000000Z",
"updated_at": "2024-06-01T12:00:00.000000Z"
}
}
}
Error Responses
Status Error Code Description
401 UNAUTHENTICATED Missing or invalid authentication token
404 NOT_FOUND No bank account found with given ID
POST
/api/mobile/database/bank-accounts
Description: Create a new guardian bank account record.
Request Body
Parameter Type Required Description
guardian_registration integer Yes Guardian's file_id_number (FK → data.file_id_number)
bank_name integer Yes Bank ID (FK → bank_names.id)
iban_usd string Yes USD IBAN number
iban_shekel string No Shekel IBAN number
re_id_number string No Representative national ID
re_guardian_name string No Representative name
re_phone_number string No Representative phone
person_owner_identity_number string No Account owner national ID
check_account integer No Approval status: 0=pending, 1=approved (default: 0)
Request Example
{
"guardian_registration": 1234,
"bank_name": 3,
"iban_usd": "PS92PIBC000000000012345678901",
"iban_shekel": "PS92PIBC000000000012345678902",
"re_id_number": "987654321",
"re_guardian_name": "محمد أحمد",
"re_phone_number": "0591234567",
"person_owner_identity_number": "123456789",
"check_account": 0
}
Success Response
{
"success": true,
"message": "Bank account created successfully",
"data": {
"bank_account": { ... }
}
}
Error Responses
Status Description
401 Unauthenticated
422 Validation error — guardian_registration, bank_name, or iban_usd missing/invalid
PUT
/api/mobile/database/bank-accounts/{id}
Description: Update an existing guardian bank account. All fields are optional (partial update supported).
Success Response
{
"success": true,
"message": "Bank account updated successfully",
"data": {
"bank_account": { ... }
}
}
Error Responses
Status Description
401 Unauthenticated
404 Bank account not found
422 Validation error
DELETE
/api/mobile/database/bank-accounts/{id}
Description: Delete a guardian bank account record permanently.
Success Response
{
"success": true,
"message": "Bank account deleted successfully"
}
Error Responses
Status Description
401 Unauthenticated
404 Bank account not found
💡 Implementation Notes
Embedded in Data Record: When fetching a full data record via GET /api/mobile/database/data/{file_id}, the bank account is included as data.bank_account (null if none exists)
bank_name_id vs bank_name: The request field is bank_name (integer ID); the response returns both bank_name_id and bank_name_label (resolved Arabic name)
is_approved: Boolean alias of check_account — true when check_account = 1
One Per Guardian: Each guardian (data record) has at most one bank account (hasOne relationship)
Authentication: Bearer token required — obtain from login endpoint
Bank Names List: Use GET /api/mobile/bank-names to retrieve available bank IDs and names
📱 Mobile Sync Strategy
Recommended Sync Flow for Central Database
Reserve File IDs: Call POST /file-ids/reserve when online
Store Reservation: Save start_id, end_id, and next_available_id locally
Create Records Offline: Use reserved IDs for new records
Track Used IDs: Increment local next_available_id after each use
Sync When Online: Call POST /data/batch to upload offline records
Report Usage: Call POST /file-ids/sync-used to update server
Request New Batch: When remaining < 1000, request new reservation
// Mobile Implementation Example
class CentralDatabaseSync {

    // Reserve file IDs on app startup when online
    async reserveFileIds() {
        if (!isOnline()) return;

        const currentReservation = await localDB.getActiveReservation();

        // Only request new batch if running low
        if (currentReservation && currentReservation.remaining_count > 1000) {
            return currentReservation;
        }

        const response = await api.post('/api/mobile/database/file-ids/reserve', {
            device_id: getDeviceId(),
            batch_size: 5000
        });

        if (response.success) {
            await localDB.saveReservation(response.data.reservation);
            return response.data.reservation;
        }
    }

    // Get next available file ID for new record
    async getNextFileId() {
        const reservation = await localDB.getActiveReservation();

        if (!reservation || reservation.remaining_count <= 0) {
            throw new Error('No available file IDs. Connect to internet to reserve more.');
        }

        const nextId = reservation.next_available_id;

        // Update local reservation
        await localDB.updateReservation(reservation.id, {
            next_available_id: nextId + 1,
            used_count: reservation.used_count + 1,
            remaining_count: reservation.remaining_count - 1
        });

        return nextId;
    }

    // Create record offline
    async createRecordOffline(recordData) {
        const fileId = await this.getNextFileId();

        const record = {
            ...recordData,
            file_id_number: fileId,
            pending_sync: true,
            created_offline: true,
            created_at: new Date().toISOString()
        };

        await localDB.saveRecord('data', record);
        return record;
    }

    // Sync offline records when online
    async syncOfflineRecords() {
        if (!isOnline()) return;

        const pendingRecords = await localDB.getRecords('data', { pending_sync: true });

        if (pendingRecords.length === 0) return;

        const response = await api.post('/api/mobile/database/data/batch', {
            records: pendingRecords,
            device_id: getDeviceId()
        });

        if (response.success) {
            // Mark synced records
            for (const fileId of [...response.data.created, ...response.data.updated]) {
                await localDB.updateRecord('data', fileId, { pending_sync: false });
            }

            // Sync used count to server
            await this.syncUsedFileIds();
        }
    }

    async syncUsedFileIds() {
        const reservation = await localDB.getActiveReservation();
        if (!reservation) return;

        await api.post('/api/mobile/database/file-ids/sync-used', {
            device_id: getDeviceId(),
            reservation_id: reservation.id,
            used_count: reservation.used_count
        });
    }

}

---

## Remaining To Green (Closure Checklist - 2026-03-10)

### تم إنجازه

- [x] تنفيذ backfill parity وتشغيله من Sync UI.
- [x] إضافة parity diagnostics counters + recommended actions.
- [x] إضافة اختبارات عقدية أساسية (mapper/parser/repository/file-ids/taxonomy).
- [x] إضافة failure-path tests إضافية لـ parser/repository.
- [x] توثيق قرار معماري رسمي: `sidecar-first` لهذا الإصدار.

### متبقٍ للإغلاق الكامل

- [ ] توسيع field-coverage parity (data/re_people/dead_people/attachments) من "مقبول تشغيليًا" إلى "مكتمل توافقيًا".
- [ ] رفع تغطية failure-path لكل كيان إلى مستوى release-signoff النهائي.
- [ ] تحديث مصفوفة parity إلى `Green` فقط بعد نجاح كل معايير Closure Gate المعتمدة.

### مراجع الإغلاق

- `docs/CENTRAL_SYNC_FIELD_PARITY_MATRIX_2026-03-09.md`
- `docs/SYNC_PARITY_ARCHITECTURE_DECISION_2026-03-10.md`
- `.github/workflows/release_gate_sync.yml`
