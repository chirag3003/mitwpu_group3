# Custom Views

Custom UI components in the `View/` directory.

## Progress Views

### CircularProgressView

**File**: `View/CircularProgressView.swift`

A circular progress indicator for displaying metrics like calories and steps.

```swift
// Usage
circularProgressView.configure(progress: 0.75, thickness: .thick)
circularProgressView.setProgress(to: 0.5)
```

### SemicircularProgressView

**File**: `View/SemiCircularProgressView.swift`

A half-circle progress indicator for nutrients (carbs, protein, fiber).

```swift
// Usage
semicircularProgress.configure(progress: 0.65, thickness: .thin)
```

## Summary Cards

### SummaryCardView

**File**: `View/SummaryCardView.swift`

Reusable card component for dashboard summaries.

## Feature-Specific Views

### Meals

**Directory**: `View/Meals/`

- `MealItemCollectionView` - Collection view for meal items
- `MealItemCollectionViewCell` - Individual meal cell

### Symptoms

**Directory**: `View/Symptoms/`

- `SymptomTableViewCell` - Symptom list cell

### Documents

**Directory**: `View/Documents/`

- Document-related custom views

### Profile

**Directory**: `View/Profile/`

- Profile-related custom views

### Family

**Directory**: `View/Family/`

- Family member views

## View Styling

Views use extensions for consistent styling:

```swift
// Corner radius
view.addRoundedCorner(radius: UIConstants.CornerRadius.medium)

// Drop shadow
view.addDropShadow()

// Glass effect
view.applyLiquidGlassEffect()
```
