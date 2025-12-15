# Data Models

All models conform to `Codable` for JSON serialization and persistence.

## Profile

**File**: `Model/ProfileModel.swift`

```swift
struct ProfileModel: Codable {
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var dateOfBirth: Date
    var gender: String
    var bloodType: String
    // ... additional health info
}
```

## Allergy

**File**: `Model/AllergyModel.swift`

```swift
struct Allergy: Codable, Identifiable {
    let id: UUID
    var name: String
    var severity: String
    var notes: String
}
```

## Symptom

**File**: `Model/SymptomModel.swift`

```swift
struct Symptom: Codable, Identifiable {
    let id: UUID
    var name: String
    var severity: Int
    var date: Date
    var notes: String
}
```

## Meal Data

**File**: `Model/MealDataModel.swift`

```swift
struct MealItem: Codable, Identifiable {
    let id: UUID
    var name: String
}

struct MealDetails: Codable {
    var calories: Int
    var protein: Double
    var carbs: Double
    var fiber: Double
}

struct CalendarDay: Codable {
    var date: Date
    var dayNumber: Int
    var dayName: String
    var isSelected: Bool
}
```

## Family

**File**: `Model/FamilyModel.swift`

```swift
struct FamilyMember: Codable {
    var name: String
    var relationship: String
    var permissions: [String]
}
```

## Documents

**File**: `Model/DocumentsModel.swift`

```swift
struct HealthDocument: Codable {
    var title: String
    var type: String
    var date: Date
    var filePath: String
}
```

## Summary

**File**: `Model/SummaryModel.swift`

Used for health summary cards on the dashboard.
