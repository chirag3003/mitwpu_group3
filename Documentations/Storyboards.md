# Storyboards

The app uses multiple storyboards for organization.

## Storyboard Files

| File | Location | Description |
|------|----------|-------------|
| `Main.storyboard` | `Base.lproj/` | Main entry point and tab bar |
| `Home.storyboard` | Root | Home dashboard |
| `LaunchScreen.storyboard` | `Base.lproj/` | App launch screen |
| `Meals.storyboard` | Root | Meal tracking screens |
| `Symptoms.storyboard` | Root | Symptom tracking screens |
| `Documents.storyboard` | Root | Document management screens |
| `Browse.storyboard` | Root | Browse feature screens |

---

## Storyboard Architecture

### Main Storyboard (Entry Point)

`Main.storyboard` contains **only** the Tab Bar Controller with 4 storyboard references:

### Home Storyboard (Complex Navigation)

`Home.storyboard` contains multiple connected screens:

- **Home Screen** - Main dashboard
- **Profile Screen** - User profile management
- **Allergies Screen** - Allergy tracking
- **Glucose & Trends Screen** - Health metrics visualization

For additional features, Home references **separate storyboards**:
- `Meals.storyboard` - Meal tracking feature
- `Symptoms.storyboard` - Symptom logging feature

### Standalone Storyboards

These storyboards contain only their own features **without external references**:

| Storyboard | Scope |
|------------|-------|
| `Family.storyboard` | Family member management only |
| `Documents.storyboard` | Document management only |
| `Browse.storyboard` | Browse/Search feature only |

### Benefits of This Approach

1. **Parallel Development** - Team members can work on different storyboards simultaneously without Git conflicts
2. **Faster Loading** - Smaller storyboards load faster in Xcode
3. **Better Organization** - Clear separation of concerns by feature

---

## Segue Identifiers

Defined in `Constants.swift`:

```swift
struct SegueIdentifiers {
    static let showMealDetail = "showMealDetail"
    static let showAddMeal = "showAddMeal"
    static let showSymptomDetail = "showSymptomDetail"
    static let showAddSymptom = "showAddSymptom"
    static let showProfile = "showProfile"
    static let showEditProfile = "showEditProfile"
    // ... etc
}
```

## Cell Identifiers

```swift
struct CellIdentifiers {
    static let mealItemCell = "MealItemCell"
    static let symptomCell = "SymptomCell"
    static let allergyCell = "AllergyCell"
    static let dateCell = "DateCell"
    static let familyMemberCell = "FamilyMemberCell"
    // ... etc
}
```
