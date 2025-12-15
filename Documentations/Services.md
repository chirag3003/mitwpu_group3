# Data Services

All services follow the **Singleton** pattern and handle data persistence via `UserDefaults`.

## ProfileService

**File**: `DataService/ProfileService.swift`

Manages user profile data.

| Method | Description |
|--------|-------------|
| `getProfile()` | Returns current profile |
| `updateProfile(_:)` | Updates and saves profile |

## AllergyService

**File**: `DataService/AllergyService.swift`

Manages user allergies.

| Method | Description |
|--------|-------------|
| `fetchAllergies()` | Returns all allergies |
| `addAllergy(_:)` | Adds new allergy |
| `removeAllergy(_:)` | Removes allergy by model |
| `deleteAllergy(at:)` | Removes allergy by index |
| `getAllergyByID(_:)` | Finds allergy by UUID |

## SymptomService

**File**: `DataService/SymptomService.swift`

Manages symptom tracking with automatic notifications.

| Method | Description |
|--------|-------------|
| `getSymptoms()` | Returns all symptoms |
| `addSymptom(_:)` | Adds new symptom |
| `deleteSymptom(at:)` | Removes symptom by index |

**Notifications**: Posts `symptomsUpdated` on data changes.

## MealDataStore

**File**: `MealDataStore.swift`

Manages meal data with calendar integration.

| Method | Description |
|--------|-------------|
| `getMealItem()` | Returns meal items |
| `getMealDetails()` | Returns meal nutritional details |
| `getDays()` | Returns calendar days |
| `addMealItem(_:)` | Adds new meal item |

## Persistence Flow

```
┌─────────────┐    didSet    ┌─────────────┐
│  Modify     │─────────────►│   save()    │
│  Data       │              │  to JSON    │
└─────────────┘              └──────┬──────┘
                                    │
                                    ▼
                            ┌─────────────┐
                            │ UserDefaults│
                            └─────────────┘
```

## Storage Keys

All keys are centralized in `Constants.swift`:

```swift
struct StorageKeys {
    static let profile = "userProfile"
    static let allergies = "userAllergies"
    static let symptoms = "userSymptoms"
    static let mealItems = "mealItems"
    static let mealDetails = "mealDetails"
    static let calendarDays = "calendarDays"
}
```
