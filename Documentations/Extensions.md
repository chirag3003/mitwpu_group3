# Extensions

Swift extensions for UIKit components in `Extensions/` directory.

## UIView+RoundedCorner

**File**: `Extensions/UIView+RoundedCorner.swift`

Adds rounded corners to any view.

```swift
// Default corner radius
view.addRoundedCorner()

// Custom corner radius
view.addRoundedCorner(radius: UIConstants.CornerRadius.large)
```

## DropShadow

**File**: `Extensions/DropShadow.swift`

Adds drop shadow effect to views.

```swift
view.addDropShadow()
```

Shadow properties from `Constants.swift`:
- Color: Black
- Opacity: 0.15
- Offset: (0, 2)
- Radius: 4

## UIView+GlassEffect

**File**: `Extensions/UIView+GlassEffect.swift`

Applies a modern glass/blur effect.

```swift
view.applyLiquidGlassEffect()
```

## TextView+Typography

**File**: `Extensions/TextView+Typography.swift`

Typography helpers for text views.

---

## Usage Example

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    // Apply styling
    cardView.addRoundedCorner(radius: UIConstants.CornerRadius.medium)
    cardView.addDropShadow()
    
    headerView.applyLiquidGlassEffect()
}
```
