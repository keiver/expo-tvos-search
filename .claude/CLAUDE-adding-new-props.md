# Memory Bank: Adding New Props to expo-tvos-search

This document provides a complete checklist for adding new props to the `expo-tvos-search` library. Following this checklist ensures that props are properly wired through the entire stack from JavaScript to native Swift rendering.

## Complete Checklist for Adding a New Prop

When adding a new prop, you **MUST** complete ALL of these steps. Missing any step will result in the prop being silently ignored or causing runtime errors.

### ✅ Step 1: TypeScript Interface Definition
**File**: `src/index.tsx`

Add the prop to the `TvosSearchViewProps` interface with:
- JSDoc documentation
- Type annotation
- `@default` tag documenting the default value
- `@example` tag showing usage (optional but recommended)

**Example**:
```typescript
/**
 * Font size for title in the blur overlay (when showTitleOverlay is true).
 * Allows customization of overlay text size for different card layouts.
 * @default 20
 * @example 18 for smaller cards, 24 for larger cards
 */
overlayTitleSize?: number;
```

**Location**: Within the `TvosSearchViewProps` interface, grouped logically with related props.

---

### ✅ Step 2: Swift ViewModel Property
**File**: `ios/ExpoTvosSearchView.swift`

Add the property to the `SearchViewModel` class with:
- `@Published` annotation if the value can change dynamically
- OR regular `var` if it's set once and doesn't need reactivity
- Type annotation (typically `CGFloat`, `Bool`, `String`, `Color`, etc.)
- Default value matching TypeScript documentation
- Inline comment describing purpose

**Example**:
```swift
// Layout spacing options (configurable from JS)
var cardMargin: CGFloat = 40  // Spacing between cards
var cardPadding: CGFloat = 16  // Padding inside cards
var overlayTitleSize: CGFloat = 20  // Font size for overlay title
```

**Location**: In the `SearchViewModel` class, grouped with related properties (around line 15-56).

---

### ✅ Step 3: Swift View Property with didSet
**File**: `ios/ExpoTvosSearchView.swift`

Add a property to the `ExpoTvosSearchView` class with:
- `didSet` observer that syncs to `viewModel`
- Type matching the native type (e.g., `CGFloat`, `Bool`, `String`)
- Default value matching TypeScript and ViewModel
- Type conversion if needed (e.g., `Double` from JS → `CGFloat` for Swift)

**Example**:
```swift
var overlayTitleSize: CGFloat = 20 {
    didSet {
        viewModel.overlayTitleSize = overlayTitleSize
    }
}
```

**Location**: In the `ExpoTvosSearchView` class properties section (around line 328-469).

---

### ✅ Step 4: Expo Module Prop Registration (CRITICAL!)
**File**: `ios/ExpoTvosSearchModule.swift`

Register the prop in the module definition with:
- `Prop("propName")` declaration
- Closure receiving `(view, value)`
- Type conversion from JS types to Swift types
- Value validation/clamping for safety
- Assignment to view property

**Example**:
```swift
Prop("overlayTitleSize") { (view: ExpoTvosSearchView, size: Double) in
    view.overlayTitleSize = CGFloat(max(8, min(72, size)))  // Clamp to reasonable font size range
}
```

**Location**: Inside the `View(ExpoTvosSearchView.self)` block (around line 14-134).

**⚠️ CRITICAL**: This step is easily missed but is REQUIRED. Without this registration, the prop will be silently ignored when passed from JavaScript!

**Common Type Conversions**:
- JavaScript `number` → Swift `Double` → `CGFloat` for dimensions/sizes
- JavaScript `boolean` → Swift `Bool`
- JavaScript `string` → Swift `String`
- JavaScript `string` (hex color) → Swift `String` → `Color(hex:)`

---

### ✅ Step 5: Pass Prop to Child Components (if applicable)
**File**: `ios/ExpoTvosSearchView.swift`

If the prop is used in child SwiftUI views (like `SearchResultCard`):

1. Add parameter to child struct initializer
2. Pass value when creating child instances
3. Use the value in the child's rendering logic

**Example for SearchResultCard**:

**5a. Add to struct parameters** (around line 178-193):
```swift
struct SearchResultCard: View {
    let item: SearchResultItem
    // ... other parameters ...
    let overlayTitleSize: CGFloat  // Add this
    let onSelect: () -> Void
}
```

**5b. Pass when instantiating** (around line 154-169):
```swift
SearchResultCard(
    item: item,
    showTitle: viewModel.showTitle,
    // ... other parameters ...
    overlayTitleSize: viewModel.overlayTitleSize,  // Add this
    onSelect: { viewModel.onSelectItem?(item.id) }
)
```

**5c. Use in rendering** (around line 235-265):
```swift
Text(item.title)
    .font(.system(size: overlayTitleSize, weight: .semibold))
    .foregroundColor(.white)
```

---

### ✅ Step 6: Add Unit Tests
**File**: `src/__tests__/index.test.tsx`

Add tests covering:
- Prop acceptance without errors
- Various valid values
- Default behavior when prop is omitted
- Update the defaults documentation test

**Example**:
```typescript
describe('TvosSearchViewProps overlayTitleSize', () => {
  beforeEach(() => {
    jest.resetModules();
    mockTvOSPlatform();
    mockNativeModuleAvailable();
  });

  it('accepts overlayTitleSize as a number', () => {
    const { TvosSearchView } = require('../index');
    expect(() => {
      TvosSearchView({
        results: [],
        onSearch: jest.fn(),
        onSelectItem: jest.fn(),
        overlayTitleSize: 18,
      });
    }).not.toThrow();
  });

  it('works without overlayTitleSize (uses default)', () => {
    const { TvosSearchView } = require('../index');
    expect(() => {
      TvosSearchView({
        results: [],
        onSearch: jest.fn(),
        onSelectItem: jest.fn(),
      });
    }).not.toThrow();
  });
});
```

**Also update the defaults test**:
```typescript
describe('TvosSearchViewProps defaults', () => {
  it('all optional props have documented defaults', () => {
    const expectedDefaults = {
      // ... existing defaults ...
      overlayTitleSize: 20,  // Add this
    };

    expect(expectedDefaults.overlayTitleSize).toBe(20);
  });
});
```

---

### ✅ Step 7: Run Tests
**Command**: `npm test`

Verify all tests pass, including your new tests.

---

### ✅ Step 8: Build Library
**Command**: `npm run build`

Rebuilds TypeScript declarations and ensures no compilation errors.

---

### ✅ Step 9: Test in Demo App
**Steps**:
1. Update demo app to use the new prop
2. Run `npm run prebuild` in demo app
3. Launch app on tvOS simulator
4. Verify prop behavior matches expectations

---

## Quick Reference: File Locations

| Step | File | Approximate Lines |
|------|------|-------------------|
| 1. TypeScript Interface | `src/index.tsx` | ~97-300 (TvosSearchViewProps) |
| 2. Swift ViewModel | `ios/ExpoTvosSearchView.swift` | ~15-56 (SearchViewModel) |
| 3. Swift View Property | `ios/ExpoTvosSearchView.swift` | ~328-469 (ExpoTvosSearchView) |
| 4. Module Registration | `ios/ExpoTvosSearchModule.swift` | ~14-134 (Prop declarations) |
| 5. Child Components | `ios/ExpoTvosSearchView.swift` | ~178+ (SearchResultCard) |
| 6. Unit Tests | `src/__tests__/index.test.tsx` | End of file |

---

## Common Mistakes to Avoid

❌ **Forgetting Step 4 (Expo Module Registration)** - Most common mistake! Prop will be silently ignored.

❌ **Mismatched default values** - TypeScript, ViewModel, and View should all have the same default.

❌ **Wrong type conversion** - JavaScript number comes as `Double`, convert to `CGFloat` for dimensions.

❌ **No validation/clamping** - Always validate numeric props to prevent invalid values (negative dimensions, etc.).

❌ **Missing tests** - Always add unit tests to verify prop acceptance.

❌ **Not updating defaults test** - Keep the defaults documentation test in sync.

---

## Validation Checklist

Before considering a new prop "complete", verify:

- [ ] TypeScript interface has JSDoc with `@default`
- [ ] Swift ViewModel has property with default value
- [ ] Swift View has property with didSet syncing to ViewModel
- [ ] **Expo Module has Prop registration (CRITICAL!)**
- [ ] Child components receive and use the prop (if applicable)
- [ ] Unit tests added and passing
- [ ] Library builds without errors
- [ ] Demo app tested on tvOS simulator
- [ ] Default values match across TypeScript, Swift ViewModel, and Swift View
- [ ] Value validation/clamping implemented (for numeric props)

---

## Example: Complete Implementation of overlayTitleSize

See Git history for commit implementing `overlayTitleSize` as a reference example showing all 9 steps completed correctly.

**Files Changed**:
- `src/index.tsx` - TypeScript interface
- `ios/ExpoTvosSearchView.swift` - ViewModel, View, and SearchResultCard
- `ios/ExpoTvosSearchModule.swift` - Prop registration
- `src/__tests__/index.test.tsx` - Unit tests

---

**Last Updated**: 2026-01-21
**Library Version**: 1.2.3+
