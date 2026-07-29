# Architecture Guide

Read this skill when working on data flow, the Swift/JS bridge, or understanding how props propagate.

## Data Flow

Props flow through three layers:

1. **TypeScript** (`src/index.tsx`): `TvosSearchViewProps` interface with JSDoc
2. **Expo Module** (`ios/ExpoTvosSearchModule.swift`): `Prop("name")` registrations with validation/clamping
3. **Swift View** (`ios/ExpoTvosSearchView.swift`): `ExpoTvosSearchView` properties with `didSet` sync to `SearchViewModel`

```
React Component → Expo Module (validate/clamp) → ExpoTvosSearchView (didSet) → SearchViewModel → SwiftUI Views
```

## UIHostingController Bridge

`ExpoTvosSearchView` extends `ExpoView` (UIView subclass). A `UIHostingController` wraps SwiftUI content and is pinned to all edges. Created once in `setupView()`. Property changes flow via `didSet` → viewModel → SwiftUI reactivity (no controller recreation).

## SearchViewModel

`SearchViewModel` (`ExpoTvosSearchView.swift:13-55`) is an `@ObservableObject`, single source of truth:

- `@Published` properties (`results`, `isLoading`, `searchText`): trigger SwiftUI updates
- Non-published properties (`columns`, `placeholder`, styling): set once per prop update
- Callbacks (`onSearch`, `onSelectItem`): closures that fire `EventDispatcher` events to JS

## Events (Swift → JS)

- `onSearch`: search text changes
- `onSelectItem`: result selected (passes `id`)
- `onError`: fatal errors
- `onValidationWarning`: non-fatal validation issues
- `onSearchFieldFocused` / `onSearchFieldBlurred`: focus changes

## Gesture Handler Management

When the native search field gains focus, RN gesture handlers are disabled for hardware keyboard input:
1. RCT notifications tell RN to stop/start cancelling touches
2. Direct walk up UIView hierarchy, disables tap/long-press recognizers (keeps swipe/pan)
3. Skipped on simulator (`#if !targetEnvironment(simulator)`)
4. `deinit` re-enables everything

Relevant code: `ExpoTvosSearchView.swift:314-410`

## Key Patterns

- **MarqueeText** uses `.task(id: shouldAnimate)` for cancellable async animation
- **MarqueeAnimationCalculator**: pure logic extracted from SwiftUI view for testability
- **HexColorParser**: DoS-protected parsing with `maxInputLength`, `Scanner`-based hex conversion
- **SelectiveRoundedRectangle**: custom Shape for tvOS 15.0+ backward compatibility (replaces `UnevenRoundedRectangle`)
