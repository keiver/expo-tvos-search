# Patterns Memory Bank

> **Category:** Implementation
> **Keywords:** patterns, validation, animation, backward compatibility, prop addition, SwiftUI
> **Last Updated:** 2026-01-26

## Quick Reference

- **Prop Addition:** 9-step checklist (TS interface → ViewModel → View didSet → Module Prop → child components → tests → build → demo)
- **Validation:** Module-layer clamp/truncate + onValidationWarning events (non-fatal)
- **Animation:** `.task(id:)` for cancellable async work, PreferenceKey for layout measurement
- **Backward Compat:** Custom shapes, `@available` checks, tvOS 15.0+ target
- **Events:** EventDispatcher with structured payloads (category/type + message + context)

---

## Prop Addition Pattern

Adding a new prop requires changes across 4 files in a specific order. Full checklist in `CLAUDE-adding-new-props.md`.

**Critical path (abbreviated):**

| Step | File | What |
|------|------|------|
| 1 | `src/index.tsx` | Add to `TvosSearchViewProps` with JSDoc, `@default`, type |
| 2 | `ios/ExpoTvosSearchView.swift` | Add to `SearchViewModel` with default value |
| 3 | `ios/ExpoTvosSearchView.swift` | Add property with `didSet` to `ExpoTvosSearchView` |
| **4** | **`ios/ExpoTvosSearchModule.swift`** | **`Prop("name")` registration — CRITICAL, most common miss** |
| 5 | `ios/ExpoTvosSearchView.swift` | Pass to child views (e.g., `SearchResultCard`) if needed |
| 6 | `src/__tests__/index.test.tsx` | Add acceptance tests |

**Common mistake:** Forgetting Step 4. Without `Prop("name")` registration in the module, the prop is silently ignored by the Expo bridge.

**Type conversions:**
- JS `number` → Swift `Double` → `CGFloat` (for dimensions/sizes)
- JS `boolean` → Swift `Bool`
- JS `string` → Swift `String`
- JS `string` (hex) → Swift `String` → `Color(hex:)` via `HexColorParser`

---

## Validation Pattern

All validation happens in the Expo Module layer (`ExpoTvosSearchModule.swift`), not in the SwiftUI views:

**Numeric clamping:**
```swift
Prop("columns") { (view: ExpoTvosSearchView, columns: Int) in
    let clampedValue = min(max(Self.minColumns, columns), Self.maxColumns)
    if clampedValue != columns {
        view.onValidationWarning([
            "type": "value_clamped",
            "message": "columns value \(columns) was clamped to range [\(Self.minColumns), \(Self.maxColumns)]",
            "context": "columns=\(clampedValue)"
        ])
    }
    view.columns = clampedValue
}
```

**String truncation:**
```swift
private static func truncateString(_ value: String, propName: String, view: ExpoTvosSearchView) -> String {
    let truncated = String(value.prefix(maxStringLength))
    if truncated.count < value.count {
        view.onValidationWarning([...])
    }
    return truncated
}
```

**Principles:**
- **Clamp, don't reject**: Out-of-range values are clamped to valid range, not rejected
- **Truncate, don't error**: Long strings are truncated, not refused
- **Warn, don't throw**: Non-fatal issues emit `onValidationWarning` events
- **Fatal errors only for truly broken state**: `onError` is reserved for unrecoverable issues

**Validation constants (ExpoTvosSearchModule):**
- `maxResults = 500`
- `minColumns = 1`, `maxColumns = 10`
- `maxMarqueeDelay = 60.0`
- `maxStringLength = 500`

---

## Animation Pattern

### `.task(id:)` for Cancellable Async Work

The primary pattern for animation lifecycle management (established after the marquee race condition fix):

```swift
.task(id: shouldAnimate) {
    if shouldAnimate {
        // Delay before starting
        try await Task.sleep(nanoseconds: UInt64(startDelay * 1_000_000_000))
        guard !Task.isCancelled else { return }
        // Start animation
        let distance = calculator.scrollDistance(textWidth: textWidth)
        let duration = calculator.animationDuration(for: distance)
        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
            offset = -distance
        }
    } else {
        // Reset
        if offset != 0 {
            withAnimation(.easeOut(duration: 0.2)) { offset = 0 }
        }
    }
}
```

**Why this works:**
- When `shouldAnimate` changes, SwiftUI automatically cancels the previous task and starts a new one
- No manual `Task` references, cancellation tracking, or cleanup needed
- Single control point: all animation logic in one place

**When to use:** Any async work tied to a boolean or enum state that can change while the work is in progress.

### PreferenceKey for Layout-Driven Animation

Used in `MarqueeText` for measuring text width without manual frame calculations:

```swift
Text(text).font(font).fixedSize()
    .background(GeometryReader { textGeometry in
        Color.clear.preference(key: TextWidthKey.self, value: textGeometry.size.width)
    })
    .hidden()
```

**When to use:** You need a measurement from one part of the view hierarchy to drive behavior in another part.

### `withAnimation` for Declarative Transitions

```swift
withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
    offset = -distance
}
```

**Rule:** Never have overlapping `withAnimation` blocks from concurrent Tasks — they create undefined interpolation. Use `.task(id:)` to ensure only one animation runs at a time.

---

## Backward Compatibility Pattern

**Target:** tvOS 15.0+ (minimum)

### Custom Shapes (SelectiveRoundedRectangle)
When a SwiftUI API isn't available on tvOS 15.0, create a custom implementation:

```swift
// Instead of UnevenRoundedRectangle (tvOS 16.0+)
struct SelectiveRoundedRectangle: Shape {
    var topLeadingRadius: CGFloat
    var topTrailingRadius: CGFloat
    var bottomLeadingRadius: CGFloat
    var bottomTrailingRadius: CGFloat
    // Custom path drawing...
}
```

### `@available` Checks (when custom implementation isn't practical)
```swift
if #available(tvOS 16.0, *) {
    // Use new API
} else {
    // Fallback
}
```

**Prefer custom implementations** (Option A) over `@available` checks (Option B) for library code — maximizes compatibility without runtime branching.

---

## Event Pattern

Events flow from Swift to JavaScript via Expo's `EventDispatcher`:

```swift
// Declaration (ExpoTvosSearchView)
let onSearch = EventDispatcher()
let onError = EventDispatcher()
let onValidationWarning = EventDispatcher()

// Registration (ExpoTvosSearchModule)
Events("onSearch", "onSelectItem", "onError", "onValidationWarning", ...)

// Firing
onSearch(["query": query])
onSelectItem(["id": id])
onValidationWarning(["type": "value_clamped", "message": "...", "context": "..."])
```

**Structured payloads:**
- `onSearch`: `{ query: string }`
- `onSelectItem`: `{ id: string }`
- `onError`: `{ category: string, message: string, context?: string }`
- `onValidationWarning`: `{ type: string, message: string, context?: string }`
- `onSearchFieldFocused`/`onSearchFieldBlurred`: `{}` (empty payload)

**Debug-only context:** The `emitWarning` helper adds extra context in `#if DEBUG` builds:
```swift
private func emitWarning(type: String, message: String, context: String? = nil, debugContext: String? = nil) {
    #if DEBUG
    let ctx = debugContext ?? context ?? "validation completed"
    #else
    let ctx = context ?? "validation completed"
    #endif
    onValidationWarning(["type": type, "message": message, "context": ctx])
}
```

---

## Focus Management Pattern

tvOS focus is managed through SwiftUI's `@FocusState` and React Native gesture handler coordination:

**SwiftUI side (`SearchResultCard`):**
```swift
@FocusState private var isFocused: Bool

Button(action: onSelect) { ... }
    .buttonStyle(.card)
    .focused($isFocused)
```

`isFocused` drives:
- Focus border visibility (`showFocusBorder && isFocused`)
- Marquee animation (`animate: isFocused`)

**RN gesture handler side (`ExpoTvosSearchView`):**

When the search field gets focus (keyboard input mode):
1. Post `RCTTVDisableGestureHandlersCancelTouchesNotification`
2. Walk up UIView hierarchy, disable `UITapGestureRecognizer` and `UILongPressGestureRecognizer`
3. Keep `UISwipeGestureRecognizer` and `UIPanGestureRecognizer` enabled (needed for navigation)
4. On blur: reverse all of the above

**Simulator guard:** Step 2 is skipped on simulator (`#if !targetEnvironment(simulator)`) because Mac keyboard events use UIPress through the responder chain.

---

## Color Pattern

Hex color strings from JS are parsed by `HexColorParser` (extracted for testability):

**Supported formats:**
- `"#FFC312"` — 6-char RRGGBB (most common)
- `"#FC3"` — 3-char RGB shorthand
- `"#80FFC312"` — 8-char AARRGGBB (with alpha)
- `"FFC312"` — without `#` prefix (stripped automatically)

**DoS protection:** `maxInputLength = 20` rejects strings before parsing (prevents Scanner from processing megabyte-length strings accidentally passed by developers).

**Integration:**
```swift
// Color extension (ExpoTvosSearchView.swift)
init?(hex: String) {
    guard let rgba = HexColorParser.parse(hex) else { return nil }
    self.init(.sRGB, red: rgba.red, green: rgba.green, blue: rgba.blue, opacity: rgba.alpha)
}

// Usage in ExpoTvosSearchView
var accentColor: String = "#FFC312" {
    didSet {
        viewModel.accentColor = Color(hex: accentColor) ?? Color(red: 1, green: 0.765, blue: 0.07)
    }
}
```

Fallback to default color if parsing fails — never crashes on invalid input.

---

## Related Documentation

- [`CLAUDE-architecture.md`](./CLAUDE-architecture.md) - Where these patterns live in the codebase
- [`CLAUDE-testing.md`](./CLAUDE-testing.md) - How to test these patterns
- [`CLAUDE-lessons-learned.md`](./CLAUDE-lessons-learned.md) - Bugs that shaped these patterns
- [`CLAUDE-development.md`](./CLAUDE-development.md) - Build and release workflow
