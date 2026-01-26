# Architecture Memory Bank

> **Category:** Architecture
> **Keywords:** architecture, data flow, SwiftUI, bridge, module, ViewModel, UIHostingController
> **Last Updated:** 2026-01-26

## Quick Reference

- **Data flow:** TypeScript props → Expo Module (`Prop("name")`) → `ExpoTvosSearchView` (`didSet`) → `SearchViewModel` → SwiftUI Views
- **Bridge:** `UIHostingController` wraps SwiftUI content inside React Native's UIView hierarchy
- **State:** `SearchViewModel` is an `@ObservableObject` with `@Published` properties for reactive UI updates
- **Events:** Swift → JS via `EventDispatcher` (onSearch, onSelectItem, onError, onValidationWarning, onSearchFieldFocused, onSearchFieldBlurred)

---

## Data Flow Diagram

```
┌──────────────────────┐
│  React Component     │  TvosSearchView (src/index.tsx)
│  <TvosSearchView     │  - Checks NativeView != null
│    results={...}     │  - Passes all props to native view
│    onSearch={...}    │
│  />                  │
└────────┬─────────────┘
         │ Props (JS → Native)
         ▼
┌──────────────────────┐
│  Expo Module         │  ExpoTvosSearchModule.swift
│  Prop("results")     │  - Validates/clamps values
│  Prop("columns")     │  - Truncates strings > 500 chars
│  Prop("placeholder") │  - Emits onValidationWarning for issues
│  ...                 │
└────────┬─────────────┘
         │ Validated values
         ▼
┌──────────────────────┐
│  ExpoTvosSearchView  │  ExpoTvosSearchView (UIView subclass)
│  var columns: Int {  │  - Properties with didSet observers
│    didSet {          │  - Each didSet syncs to viewModel
│      viewModel.col   │  - Manages UIHostingController
│    }                 │  - Handles gesture recognizer lifecycle
│  }                   │
└────────┬─────────────┘
         │ viewModel property updates
         ▼
┌──────────────────────┐
│  SearchViewModel     │  @ObservableObject
│  @Published results  │  - Holds all reactive state
│  @Published isLoading│  - Callbacks: onSearch, onSelectItem
│  columns, placeholder│  - Non-@Published props don't trigger re-render
│  showTitle, etc.     │
└────────┬─────────────┘
         │ SwiftUI observation
         ▼
┌──────────────────────┐
│  SwiftUI Views       │
│  TvosSearchContentView  - NavigationView + .searchable
│  SearchResultCard       - Individual result cards
│  MarqueeText            - Scrolling text overlay
└──────────────────────┘
```

---

## UIHostingController Bridge

The bridge between React Native's `UIView` hierarchy and SwiftUI is in `ExpoTvosSearchView.setupView()`:

```swift
// ios/ExpoTvosSearchView.swift:548-571
let contentView = TvosSearchContentView(viewModel: viewModel)
let controller = UIHostingController(rootView: contentView)
controller.view.backgroundColor = .clear
hostingController = controller

addSubview(controller.view)
controller.view.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([...])  // Pin to all edges
```

Key points:
- `ExpoTvosSearchView` extends `ExpoView` (UIView subclass from expo-modules-core)
- The `UIHostingController` is created once in `setupView()` and its view is pinned to all edges
- The `viewModel` is shared between the hosting controller's root view and the `ExpoTvosSearchView`
- Property changes flow through `didSet` → `viewModel` → SwiftUI reactivity (no hosting controller recreation)

---

## SearchViewModel Pattern

`SearchViewModel` (`ios/ExpoTvosSearchView.swift:55-97`) is the single source of truth for all view state:

- **`@Published` properties** (`results`, `isLoading`, `searchText`): Trigger SwiftUI view updates when changed
- **Non-published properties** (`columns`, `placeholder`, styling options): Set once per prop update, don't need observation overhead
- **Callbacks** (`onSearch`, `onSelectItem`): Closures set in `setupView()` that fire `EventDispatcher` events back to JS

The `ExpoTvosSearchView` properties use `didSet` to sync values to the view model, which propagates changes to SwiftUI views via Combine's `@ObservedObject`/`@ObservableObject` mechanism.

---

## PreferenceKey Pattern (MarqueeText)

`MarqueeText` (`ios/MarqueeText.swift:7-133`) uses SwiftUI's `PreferenceKey` system for reactive text width measurement:

```swift
// Hidden text measures actual width
Text(text).font(font).fixedSize()
    .background(GeometryReader { textGeometry in
        Color.clear.preference(key: TextWidthKey.self, value: textGeometry.size.width)
    })
    .hidden()

// Preference change updates state
.onPreferenceChange(TextWidthKey.self) { width in
    textWidth = width
}
```

This avoids manual frame calculations — SwiftUI's layout system measures the text and propagates the width up through the preference key.

---

## SelectiveRoundedRectangle

Custom `Shape` (`ios/ExpoTvosSearchView.swift:13-44`) for backward compatibility with tvOS 15.0+:

- Replaces `UnevenRoundedRectangle` (tvOS 16.0+ only)
- Draws a rounded rectangle path with independently controllable corner radii
- Used by `SearchResultCard` for cards where bottom corners are square when title/subtitle section is shown

---

## Notification-Based Gesture Control

When the native search field gains focus, the view must disable React Native's gesture handlers to allow hardware keyboard input:

1. **RCT Notifications**: `RCTTVDisableGestureHandlersCancelTouchesNotification` / `RCTTVEnableGestureHandlersCancelTouchesNotification` — tells RN to stop/start cancelling touches
2. **Direct gesture recognizer management**: Walks up the UIView hierarchy, disables `UITapGestureRecognizer` and `UILongPressGestureRecognizer` (keeps swipe/pan for navigation)
3. **Simulator guard**: Direct gesture recognizer management is skipped on simulator (`#if !targetEnvironment(simulator)`) because Mac keyboard events use the responder chain differently
4. **Cleanup**: `deinit` re-enables everything to prevent leaked disabled state

Relevant code: `ios/ExpoTvosSearchView.swift:588-684`

---

## HexColorParser

`ios/HexColorParser.swift` — extracted struct for testable hex color parsing:

- **DoS protection**: `maxInputLength = 20` rejects excessively long strings before parsing
- **Format support**: 3-char (RGB), 6-char (RRGGBB), 8-char (AARRGGBB)
- **Parsing**: Uses `Scanner.scanHexInt64` for safe hex → UInt64 conversion
- **Output**: `RGBA` struct with `Double` values in 0.0–1.0 range
- **Integration**: `Color(hex:)` extension calls `HexColorParser.parse()`, returns nil on failure

---

## Key Files with Line Ranges

| File | Lines | Purpose |
|------|-------|---------|
| `src/index.tsx` | 1-491 | TypeScript exports, event types, `TvosSearchView`, `isNativeSearchAvailable()` |
| `ios/ExpoTvosSearchModule.swift` | 1-163 | Expo module definition, all `Prop("name")` registrations with validation |
| `ios/ExpoTvosSearchView.swift` | 1-893 | Full native implementation |
| ↳ `SelectiveRoundedRectangle` | 13-44 | Custom backward-compatible rounded rect shape |
| ↳ `SearchResultItem` | 46-51 | Identifiable data model |
| ↳ `SearchViewModel` | 55-97 | ObservableObject state holder |
| ↳ `TvosSearchContentView` | 99-217 | Main SwiftUI view with search, grid, state views |
| ↳ `SearchResultCard` | 219-359 | Individual result card with focus, overlay, marquee |
| ↳ `ExpoTvosSearchView` | 361-821 | UIView bridge, props, gesture management, result validation |
| `ios/MarqueeText.swift` | 1-145 | Scrolling text with `.task(id:)` animation, fade mask |
| `ios/MarqueeAnimationCalculator.swift` | 1-41 | Pure logic: shouldScroll, scrollDistance, animationDuration |
| `ios/HexColorParser.swift` | 1-55 | DoS-protected hex → RGBA parsing |

---

## Related Documentation

- [`CLAUDE-patterns.md`](./CLAUDE-patterns.md) - Implementation patterns used across the codebase
- [`CLAUDE-lessons-learned.md`](./CLAUDE-lessons-learned.md) - Debugging history and architectural decisions
- [`CLAUDE-development.md`](./CLAUDE-development.md) - Build, release, and CI pipeline
