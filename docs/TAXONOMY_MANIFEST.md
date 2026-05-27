# Taxonomy Manifest

## Scope

- Date: 2026-05-28
- Audit target: Add Beneficiary flow and related dialogs/forms/widgets.
- Canonical taxonomy source for this audit: `firestore_taxonomy_seed_data.dart` (version `gaza_v1`).

## Phase 1 Audit Results

| Group               | Source file / widget / field                                         | Required or optional                       | Expected Arabic labels             | Exists in Firestore seed | Notes                                    |
| ------------------- | -------------------------------------------------------------------- | ------------------------------------------ | ---------------------------------- | ------------------------ | ---------------------------------------- |
| gender              | `v2_basic_info_tab.dart` -> `الجنس`                                  | Required                                   | ذكر، أنثى                          | Yes                      | Also used in merged/review/details views |
| category            | `v2_basic_info_tab.dart` -> `فئة المستفيد` + subcategory chain       | Required                                   | يتيم، أرملة، كبار سن...            | Yes                      | Canonical group is `category`            |
| section             | `v2_basic_info_tab.dart` -> `القسم`                                  | Optional                                   | البيانات الشخصية، بيانات الأسرة... | Yes                      | Used in search/list/report mapping       |
| relationship        | `v2_basic_info_tab.dart`, `v2_family_info_tab.dart` -> `صلة القرابة` | Required                                   | أب، أم، ابن...                     | Yes                      | Essential coverage group                 |
| marital_status      | `v2_family_info_tab.dart` -> `الحالة الاجتماعية`                     | Required                                   | أعزب/عزباء، متزوج/ة...             | Yes                      | Essential coverage group                 |
| governorate         | `v2_contact_info_tab.dart` -> `المحافظة`                             | Required                                   | شمال غزة، غزة...                   | Yes                      | Gaza-only geography                      |
| city                | `v2_contact_info_tab.dart` -> `المدينة`                              | Required                                   | مدن/مناطق قطاع غزة                 | Yes                      | Parent linked to governorate             |
| displacement_status | `v2_contact_info_tab.dart` -> `حالة النزوح`                          | Required                                   | غير نازح، نازح...                  | Yes                      | Essential coverage group                 |
| education_level     | `v2_additional_info_tab.dart` -> `المستوى التعليمي`                  | Required                                   | ابتدائي، جامعي...                  | Yes                      | Essential coverage group                 |
| employment_status   | `v2_additional_info_tab.dart` -> `حالة العمل`                        | Required                                   | يعمل، عاطل...                      | Yes                      | Essential coverage group                 |
| health_status       | `v2_additional_info_tab.dart` -> `الحالة الصحية`                     | Required                                   | جيدة، مرض مزمن...                  | Yes                      | Used by family dialogs too               |
| housing_status      | `v2_additional_info_tab.dart` -> `حالة السكن`                        | Required                                   | ملك، إيجار، نازح...                | Yes                      | Essential coverage group                 |
| housing_type        | `v2_additional_info_tab.dart` -> `نوع السكن`                         | Required                                   | شقة، منزل، خيمة...                 | Yes                      | Essential coverage group                 |
| disability_type     | `v2_personal_info_merged_tab.dart` -> `نوع الإعاقة`                  | Optional (required when special needs > 0) | إعاقة حركية...                     | Yes                      | Essential form coverage                  |
| income_source       | `v2_personal_info_merged_tab.dart` -> `مصدر الدخل`                   | Optional                                   | راتب، مساعدات...                   | Yes                      | Required by essential contract           |
| beneficiary_status  | `v2_additional_info_tab.dart`, `family_members_form.dart`            | Required in workflows                      | نشط، قيد المراجعة...               | Yes                      | Also used as sponsorship status alias    |
| assistance_type     | `v2_personal_info_merged_tab.dart` -> `نوع المساعدة`                 | Required in workflow                       | نقدية، غذائية...                   | Yes                      | Essential coverage group                 |
| guarantee_type      | `v2_personal_info_merged_tab.dart`, `family_members_form.dart`       | Required in workflow                       | كفالة يتيم...                      | Yes                      | Explicitly listed missing before fix     |
| sponsorship_type    | `family_members_form.dart`, `kafalat/*`                              | Optional by screen                         | شهرية، سنوية...                    | Yes                      | Needed by Kafalat forms                  |
| document_type       | `document_type_selector*.dart`, `family_deceased_form.dart`          | Required in deceased/doc flows             | بطاقة هوية...                      | Yes                      | IDs normalized (no `__fallback_`)        |
| death_reason        | `death_cause_selector.dart`, `family_deceased_form.dart`             | Required in deceased flow                  | وفاة طبيعية، قصف...                | Yes                      | IDs normalized (no `__fallback_`)        |
| association_type    | `association_form_bottom_sheet*.dart`                                | Optional by module                         | جمعية خيرية...                     | Yes                      | Needed by associations module            |
| bank_name           | `v2_contact_notes_merged_tab.dart`, `associations`, `kafalat`        | Optional by screen                         | بنك فلسطين...                      | Yes                      | Gaza/Palestine options + cash/wallet     |
| currency            | `associations`, `kafalat` forms                                      | Optional by module                         | شيكل، دولار...                     | Yes                      | Shared across modules                    |
| visit_type          | `record_visit_page*.dart`                                            | Required by visits flow                    | زيارة أولى...                      | Yes                      | Used outside Add Beneficiary directly    |

## Local Hardcoded Dropdowns / Fallbacks Found

- `family_members_form.dart`: uses hardcoded `Gender` and `HealthStatus` integer enum dropdowns in legacy section.
- `zero_lag_family_dialog.dart` and related family dialogs: rely on integer resolution from taxonomy codes/ids.
- `taxonomy_integrity_guard.dart`: had local fallback taxonomy IDs pattern `__fallback_*` (normalized in this fix).

## Missing Groups (Before This Fix)

- relationship
- marital_status
- governorate
- city
- displacement_status
- education_level
- employment_status
- health_status
- housing_status
- housing_type
- guarantee_type
- plus parse-impact groups: death_reason, document_type

## Seed Coverage (gaza_v1)

| Group               |   Count |
| ------------------- | ------: |
| governorate         |       5 |
| city                |      35 |
| gender              |       2 |
| marital_status      |       5 |
| relationship        |      15 |
| education_level     |       8 |
| employment_status   |       8 |
| health_status       |       8 |
| housing_status      |       9 |
| housing_type        |       8 |
| displacement_status |       5 |
| disability_type     |       9 |
| death_reason        |       7 |
| document_type       |       9 |
| beneficiary_status  |       5 |
| assistance_type     |       9 |
| guarantee_type      |       6 |
| association_type    |       7 |
| sponsorship_type    |       5 |
| bank_name           |      10 |
| currency            |       4 |
| visit_type          |       5 |
| section             |       7 |
| category            |      10 |
| income_source       |       7 |
| **Total**           | **208** |

## Group Naming Normalization

- Canonical beneficiary group is `category`.
- Seed does not create `categories` as a separate group; compatibility remains via existing group normalization/query aliases in taxonomy services.
