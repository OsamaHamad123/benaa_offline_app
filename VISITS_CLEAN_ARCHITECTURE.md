# Clean Architecture Implementation - Visits Feature

## 📁 Structure Overview

```
lib/
├── features/visits/
│   ├── domain/               # Business Logic Layer
│   │   ├── entities/
│   │   │   └── visit_entity.dart         # Core domain model
│   │   ├── repositories/
│   │   │   └── visit_repository.dart      # Repository contract
│   │   └── usecases/
│   │       ├── create_visit.dart          # Create visit use case
│   │       └── get_beneficiary_visits.dart # Get visits use case
│   │
│   ├── data/                 # Data Layer
│   │   ├── models/
│   │   │   └── visit_model.dart           # Data model with Drift conversion
│   │   ├── datasources/
│   │   │   └── visit_local_datasource.dart # Database wrapper
│   │   └── repositories/
│   │       └── visit_repository_impl.dart  # Repository implementation
│   │
│   └── presentation/         # UI Layer
│       ├── state/
│       │   ├── visit_state.dart           # State model
│       │   └── visit_notifier.dart        # State management
│       ├── providers/
│       │   └── visit_providers.dart        # Riverpod providers
│       └── pages/
│           └── record_visit_page_clean.dart # Record visit UI
│
└── core/widgets/beneficiary/ # Reusable Widgets
    ├── beneficiary_info_card.dart         # Beneficiary info display
    ├── date_time_picker_field.dart        # Date time picker
    └── visit_card.dart                    # Visit card display
```

## 🎯 Clean Architecture Layers

### 1. Domain Layer (Business Logic)
**Purpose**: Pure business logic, framework independent

- **Entities** (`visit_entity.dart`):
  - Core domain model
  - Uses Equatable for value equality
  - No external dependencies
  
- **Repositories** (`visit_repository.dart`):
  - Abstract interface (contract)
  - Defines 10 methods for visit operations
  - Independent of implementation details
  
- **Use Cases**:
  - `CreateVisit`: Single responsibility - create visit
  - `GetBeneficiaryVisits`: Single responsibility - fetch visits
  - Each use case wraps one repository method

### 2. Data Layer
**Purpose**: Data access and persistence

- **Models** (`visit_model.dart`):
  - Extends `VisitEntity`
  - Provides `fromDrift()` and `toDrift()` converters
  - Bridges domain and database layers
  
- **Data Sources** (`visit_local_datasource.dart`):
  - Wraps `AppDatabase` methods
  - Converts Drift `Visit` to `VisitModel`
  - Handles database operations
  
- **Repository Implementation** (`visit_repository_impl.dart`):
  - Implements `VisitRepository` interface
  - Delegates to data sources
  - Handles error scenarios

### 3. Presentation Layer
**Purpose**: UI and state management

- **State** (`visit_state.dart`):
  - Immutable state model
  - Contains visits list, loading, error states
  - Uses Equatable for comparison
  
- **Notifier** (`visit_notifier.dart`):
  - Extends `StateNotifier<VisitState>`
  - Manages state transitions
  - Calls use cases for business logic
  
- **Providers** (`visit_providers.dart`):
  - Riverpod providers for DI
  - Creates and wires dependencies
  - Provides `visitNotifierProvider` for UI
  
- **Pages** (`record_visit_page_clean.dart`):
  - UI for recording visits
  - Consumes `visitNotifierProvider`
  - Uses reusable widgets

## 🧩 Reusable Widgets

### BeneficiaryInfoCard
**Purpose**: Display beneficiary information consistently

**Usage**:
```dart
BeneficiaryInfoCard(
  beneficiary: beneficiary,
  compact: false, // true for smaller display
)
```

**Features**:
- Category-based color coding
- Avatar with first letter
- File number display
- Location info (governorate/district)
- Compact mode option

### DateTimePickerField
**Purpose**: Standardized date/time selection

**Usage**:
```dart
DateTimePickerField(
  selectedDate: _selectedDateTime,
  onTap: _selectDateTime,
  label: 'تاريخ ووقت الزيارة',
)
```

**Features**:
- Arabic date formatting
- Static `formatDateTime()` helper
- Custom label support
- Calendar icon + dropdown indicator

### VisitCard
**Purpose**: Display visit information in lists

**Usage**:
```dart
VisitCard(
  visit: visitEntity,
  onTap: () => _viewVisitDetails(visit),
)
```

**Features**:
- Visit date/time display
- Staff name and notes
- Submission status indicator
- Tap callback for details
- Static `formatDateTime()` helper

## 🔌 Integration Guide

### Step 1: Override Database Provider
In `main.dart` or app initialization:

```dart
runApp(
  ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(database),
    ],
    child: MyApp(),
  ),
);
```

### Step 2: Use RecordVisitPageClean
Replace old `RecordVisitPage` with:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RecordVisitPageClean(
      beneficiary: beneficiary,
    ),
  ),
);
```

### Step 3: Display Visits List
In `view_beneficiary_page.dart`:

```dart
// Load visits
ref.read(visitNotifierProvider.notifier)
   .loadBeneficiaryVisits(beneficiaryId);

// Display visits
final visitState = ref.watch(visitNotifierProvider);

if (visitState.isLoading) {
  return CircularProgressIndicator();
}

if (visitState.visits.isEmpty) {
  return Text('لا توجد زيارات');
}

return ListView.builder(
  itemCount: visitState.visits.length,
  itemBuilder: (context, index) {
    return VisitCard(
      visit: visitState.visits[index],
      onTap: () => _viewVisitDetails(visitState.visits[index]),
    );
  },
);
```

## ✅ Benefits of This Architecture

### 1. Separation of Concerns
- Each layer has clear responsibility
- Business logic independent of UI/database
- Easy to modify one layer without affecting others

### 2. Testability
- Use cases can be tested independently
- Mock repositories for unit tests
- UI tests don't need real database

### 3. Reusability
- Widgets used across multiple pages
- Use cases shared between features
- Repository interface allows multiple implementations

### 4. Maintainability
- Clear folder structure
- Single source of truth for entities
- Easy to locate and modify code

### 5. Scalability
- Add new use cases without touching existing ones
- Switch data sources (e.g., local to remote)
- Add new UI pages using same state management

## 🔄 Data Flow

### Creating a Visit:
```
UI (RecordVisitPageClean)
  → VisitNotifier.createNewVisit()
    → CreateVisit UseCase
      → VisitRepository Interface
        → VisitRepositoryImpl
          → VisitLocalDataSource
            → AppDatabase (Drift)
```

### Loading Visits:
```
UI (Consumer Widget)
  → VisitNotifier.loadBeneficiaryVisits()
    → GetBeneficiaryVisits UseCase
      → VisitRepository Interface
        → VisitRepositoryImpl
          → VisitLocalDataSource
            → AppDatabase (Drift)
              → Returns List<VisitModel>
                → Converted to List<VisitEntity>
                  → Updates VisitState
                    → UI Rebuilds
```

## 📝 Next Steps

### Immediate:
1. ✅ Update `view_beneficiary_page.dart` to use `VisitCard`
2. ✅ Replace old `RecordVisitPage` with `RecordVisitPageClean`
3. ✅ Override `databaseProvider` in `main.dart`

### Future Enhancements:
1. Add `UpdateVisit` use case
2. Add `DeleteVisit` use case
3. Create `VisitDetailsPage` for viewing/editing
4. Add visit filtering/sorting
5. Implement visit statistics dashboard
6. Add offline sync indicators

## 🐛 Troubleshooting

### Issue: "UnimplementedError: Database provider must be overridden"
**Solution**: Override `databaseProvider` in `ProviderScope` at app startup

### Issue: Widgets not updating after creating visit
**Solution**: Ensure `loadBeneficiaryVisits()` is called after creation

### Issue: Compile errors in repository_impl
**Solution**: Run `dart run build_runner build --delete-conflicting-outputs`

## 📚 References

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Riverpod Documentation](https://riverpod.dev/)
- [Drift Documentation](https://drift.simonbinder.eu/)
