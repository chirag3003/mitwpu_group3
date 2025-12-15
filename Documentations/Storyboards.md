# Storyboards

The app uses multiple storyboards for organization.

## Storyboard Files

| File | Location | Description |
|------|----------|-------------|
| `Main.storyboard` | `Base.lproj/` | Main entry point and tab bar |
| `Home.storyboard` | `Base.lproj/` | Home dashboard |
| `LaunchScreen.storyboard` | `Base.lproj/` | App launch screen |
| `Meals.storyboard` | Root | Meal tracking screens |
| `Symptoms.storyboard` | Root | Symptom tracking screens |
| `Documents.storyboard` | Root | Document management screens |
| `Browse.storyboard` | Root | Browse feature screens |

---

## 📝 PLACEHOLDER: Storyboard Structure

<!-- 
TODO: Add your explanation of how storyboards are structured and connected.

Consider documenting:
- Navigation flow between storyboards
- How storyboard references are set up
- Tab bar structure and organization
- Segue connections and identifiers
- Initial view controllers for each storyboard
-->

### Navigation Structure

_[Add your explanation here]_

### Storyboard References

_[Explain how storyboards reference each other]_

### Tab Bar Organization

_[Describe the tab bar structure]_

### Segue Connections

_[Document key segues and their identifiers]_

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
