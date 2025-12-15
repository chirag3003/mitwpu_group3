# Architecture

## Key Components

### Services (Singleton Pattern)
Data services use the singleton pattern for global access:

- `ProfileService.shared` - User profile management
- `AllergyService.shared` - Allergy data management  
- `SymptomService.shared` - Symptom tracking
- `MealDataStore.shared` - Meal logging

We are using UserDefaults in each service to ensure data persistance between restarts

### Communication Pattern
Services notify controllers of data changes via `NotificationCenter`:

```swift
// Posting updates
NotificationCenter.default.post(name: .symptomsUpdated, object: nil)

// Observing updates
NotificationCenter.default.addObserver(self, selector: #selector(updateUI), ...)
```

## Constants

Centralized constants in `Constants.swift`:

| Category | Purpose |
|----------|---------|
| `UIConstants` | Corner radius, spacing, shadows |
| `StorageKeys` | UserDefaults keys |
| `NotificationNames` | NotificationCenter names |
| `CellIdentifiers` | TableView/CollectionView cell IDs |
| `SegueIdentifiers` | Storyboard segue IDs |

## File Organization

```
Controller/
├── HomeViewController.swift      # Main dashboard
├── Browse/                       # Browse feature
├── Document/                     # Document management
├── Family/                       # Family members
├── Meals/                        # Meal tracking
├── Profile/                      # User profile
├── Symptoms/                     # Symptom logging
└── Trends/                       # Health trends
```
