# 🏗️ نظام إدارة الجمعيات - الرسم المعماري

## 📊 Database Schema (ERD)

```
┌─────────────────────────────────────────────────────┐
│              ASSOCIATION_REPRESENTATIVES            │
├─────────────────────────────────────────────────────┤
│ 🔑 id: TEXT (PK)                                    │
│ 📝 name: TEXT NOT NULL                              │
│ 📅 created_at: DATETIME                             │
│ 📅 updated_at: DATETIME                             │
│ 🔄 sync_state: TEXT                                 │
│ 🌐 server_id: INTEGER                               │
└─────────────────────────────────────────────────────┘
                        ▲
                        │
                        │ (One-to-One)
                        │ representative_id (FK)
                        │
┌─────────────────────────────────────────────────────┐
│                   ASSOCIATIONS                      │
├─────────────────────────────────────────────────────┤
│ 🔑 id: TEXT (PK)                                    │
│ 📝 name: TEXT NOT NULL                              │
│ 📝 short_name: TEXT                                 │
│ 📞 phone: TEXT NOT NULL                             │
│ 📧 email: TEXT                                      │
│ 🏦 bank_name: TEXT NOT NULL                         │
│ 🏦 account_number: TEXT NOT NULL                    │
│ 🏦 swift_code: TEXT                                 │
│ 📞 bank_phone: TEXT                                 │
│ 💰 account_currency: TEXT (IQD/USD/EUR)            │
│ 👤 representative_id: TEXT (FK) ───────────────────┘
│ ✅ is_active: BOOLEAN DEFAULT TRUE                  │
│ 📅 created_at: DATETIME                             │
│ 📅 updated_at: DATETIME                             │
│ 🔄 sync_state: TEXT DEFAULT 'pending'              │
│ 🌐 server_id: INTEGER                               │
│ 📅 last_synced_at: DATETIME                         │
└─────────────────────────────────────────────────────┘
                        ▲
                        │
                        │ (Many-to-One)
                        │ association_id (FK)
                        │
┌─────────────────────────────────────────────────────┐
│                  BENEFICIARIES                      │
├─────────────────────────────────────────────────────┤
│ 🔑 id: INTEGER (PK)                                 │
│ 📝 full_name: TEXT                                  │
│ 🆔 id_number: INTEGER                               │
│ 📞 phone_number: INTEGER                            │
│ ...                                                 │
│ 🏢 association_id: TEXT (FK) ──────────────────────┘
│ ...                                                 │
└─────────────────────────────────────────────────────┘
```

---

## 🏗️ Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│                     (UI / Flutter)                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📱 Pages                      🎨 Widgets                   │
│  ├── AssociationsListPage     ├── AssociationCard          │
│  └── AssociationFormPage      └── RepresentativeDropdown   │
│                                                             │
│  🔌 Providers (Riverpod)                                    │
│  ├── associationsProvider                                   │
│  └── Use Cases Providers                                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ calls
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                           │
│                    (Business Logic)                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  🎯 Use Cases                                               │
│  ├── GetAllActiveAssociations                               │
│  ├── GetAssociationById                                     │
│  ├── CreateAssociation                                      │
│  ├── UpdateAssociation                                      │
│  ├── DeleteAssociation                                      │
│  ├── GetAllRepresentatives                                  │
│  ├── CreateRepresentative                                   │
│  └── SearchAssociations                                     │
│                                                             │
│  📦 Entities                                                │
│  ├── Association                                            │
│  └── Representative                                         │
│                                                             │
│  📋 Repository Interface                                    │
│  └── AssociationRepository (abstract)                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ implements
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                            │
│                  (Data Management)                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  🔄 Repository Implementation                               │
│  └── AssociationRepositoryImpl                              │
│      ├── Maps Drift Models ↔ Domain Entities              │
│      └── Handles Result<T> Pattern                         │
│                                                             │
│  💾 Data Access Object (DAO)                                │
│  └── AssociationsDao                                        │
│      ├── getAllActiveAssociations()                         │
│      ├── getAssociationById()                               │
│      ├── addAssociation()                                   │
│      ├── updateAssociation()                                │
│      ├── deleteAssociation()                                │
│      ├── searchAssociations()                               │
│      ├── getAllRepresentatives()                            │
│      └── getAssociationWithRepresentative() (JOIN)          │
│                                                             │
│  📊 Tables (Drift)                                          │
│  ├── Associations                                           │
│  └── AssociationRepresentatives                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ connects to
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATABASE                               │
│                    (SQLite via Drift)                       │
├─────────────────────────────────────────────────────────────┤
│  associations                                               │
│  association_representatives                                │
│  beneficiaries                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow (تدفق البيانات)

### Create Association Flow

```
User Input (Form)
      │
      ├──> [AssociationFormPage]
      │         │
      │         │ onSave()
      │         ▼
      │    [AssociationsNotifier.createAssociation()]
      │         │
      │         ├──> [CreateAssociationUseCase.execute()]
      │         │         │
      │         │         ├──> Validates params
      │         │         │
      │         │         └──> [AssociationRepository.createAssociation()]
      │         │                   │
      │         │                   ├──> [AssociationRepositoryImpl]
      │         │                   │         │
      │         │                   │         ├──> Maps to Drift Companion
      │         │                   │         │
      │         │                   │         └──> [AssociationsDao.addAssociation()]
      │         │                   │                   │
      │         │                   │                   └──> INSERT INTO associations
      │         │                   │
      │         │                   └──> Returns Result<Association>
      │         │
      │         └──> Updates State
      │
      └──> UI Updates (SnackBar + Navigate Back)
```

### Get Associations Flow

```
Page Load
      │
      ├──> [AssociationsListPage.initState()]
      │         │
      │         └──> [AssociationsNotifier.loadAssociations()]
      │                   │
      │                   └──> [GetAllActiveAssociationsUseCase.execute()]
      │                             │
      │                             └──> [AssociationRepository.getAllActiveAssociations()]
      │                                       │
      │                                       └──> [AssociationsDao.getAllActiveAssociations()]
      │                                                 │
      │                                                 └──> SELECT * FROM associations WHERE is_active = true
      │
      └──> Returns List<Association>
                │
                └──> UI Renders (ListView.builder)
```

---

## 🎨 UI Component Tree

```
AssociationsListPage
├── AppBar
│   └── Title: "🏢 إدارة الجمعيات"
├── Body (Column)
│   ├── SearchBar (Container)
│   │   └── TextField
│   └── AssociationsList (Expanded)
│       ├── Loading (CircularProgressIndicator)
│       ├── Error State
│       ├── Empty State
│       └── ListView.builder
│           └── AssociationCard
│               ├── Header Row
│               │   ├── Icon (Business)
│               │   ├── Name + Short Name
│               │   └── Status Badge
│               ├── Divider
│               ├── Info Rows
│               │   ├── Phone
│               │   ├── Email
│               │   ├── Bank
│               │   └── Representative
│               └── Actions Row
│                   ├── Edit Button
│                   └── Delete Button
└── FloatingActionButton (Add)
    │
    └──> AssociationFormPage
         ├── AppBar
         ├── Form (ListView)
         │   ├── Section: 📝 معلومات أساسية
         │   │   ├── Name Field *
         │   │   └── Short Name Field
         │   ├── Section: 📞 معلومات الاتصال
         │   │   ├── Phone Field *
         │   │   └── Email Field
         │   ├── Section: 🏦 المعلومات المصرفية
         │   │   ├── Bank Name Field *
         │   │   ├── Account Number Field *
         │   │   ├── SWIFT Code Field
         │   │   ├── Bank Phone Field
         │   │   └── Currency Dropdown
         │   ├── Section: 👤 مندوب الجمعية
         │   │   └── RepresentativeDropdown
         │   │       ├── Dropdown (List)
         │   │       └── Add New Button
         │   └── Actions Row
         │       ├── Cancel Button
         │       └── Save Button
         └── Loading Overlay
```

---

## 🔍 State Management (Riverpod)

```
Provider Tree
├── databaseProvider
│   └── AppDatabase instance
│
├── associationRepositoryProvider
│   └── AssociationRepositoryImpl(database)
│
├── Use Case Providers
│   ├── getAllActiveAssociationsUseCaseProvider
│   ├── getAssociationByIdUseCaseProvider
│   ├── createAssociationUseCaseProvider
│   ├── updateAssociationUseCaseProvider
│   ├── deleteAssociationUseCaseProvider
│   ├── getAllRepresentativesUseCaseProvider
│   ├── createRepresentativeUseCaseProvider
│   └── searchAssociationsUseCaseProvider
│
└── associationsProvider (StateNotifierProvider)
    └── AssociationsNotifier
        ├── State: AssociationsState
        │   ├── associations: List<Association>
        │   ├── representatives: List<Representative>
        │   ├── isLoading: bool
        │   └── errorMessage: String?
        │
        └── Methods
            ├── loadAssociations()
            ├── searchAssociations()
            ├── createAssociation()
            ├── updateAssociation()
            ├── deleteAssociation()
            ├── loadRepresentatives()
            └── createRepresentative()
```

---

## 📊 SQL Queries (Examples)

### Get All Active Associations
```sql
SELECT * FROM associations 
WHERE is_active = true 
ORDER BY name ASC;
```

### Search Associations
```sql
SELECT * FROM associations 
WHERE LOWER(name) LIKE '%بناء%' 
   OR LOWER(short_name) LIKE '%بناء%'
ORDER BY name ASC;
```

### Get Association with Representative (JOIN)
```sql
SELECT 
  a.*,
  r.id as rep_id,
  r.name as rep_name
FROM associations a
LEFT JOIN association_representatives r 
  ON a.representative_id = r.id
WHERE a.id = ?;
```

### Get Beneficiaries by Association
```sql
SELECT * FROM beneficiaries 
WHERE association_id = ?
ORDER BY full_name ASC;
```

---

## 🎯 Validation Rules

```
Association Validation
├── name: NOT NULL, trim(), min 2 chars
├── phone: NOT NULL, trim(), pattern
├── email: OPTIONAL, valid email format
├── bankName: NOT NULL, trim(), min 2 chars
├── accountNumber: NOT NULL, trim(), min 4 chars
├── swiftCode: OPTIONAL, uppercase, length 8-11
└── representativeId: OPTIONAL, must exist in DB

Representative Validation
└── name: NOT NULL, trim(), min 2 chars
```

---

## ⚡ Performance Optimizations

```
Database Indexes
├── idx_associations_name (name)
├── idx_associations_active (is_active)
├── idx_associations_sync (sync_state)
└── idx_representatives_name (name)

Caching Strategy
├── State caching in AssociationsNotifier
├── Lazy loading representatives
└── Pull-to-refresh for updates

Pagination (Future Enhancement)
└── Load 50 associations at a time
```

---

**Created:** 17 ديسمبر 2025  
**Purpose:** تصور معماري كامل لنظام إدارة الجمعيات
