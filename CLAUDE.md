# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

expo-tvos-search is a native tvOS search component for Expo/React Native that wraps SwiftUI's `.searchable` modifier. It provides the native tvOS search experience with keyboard navigation, focus handling, and grid results display.

**Platform Support**: tvOS 15.0+, Expo SDK 51+, React Native tvOS 0.71+

## Common Commands

```bash
# Build TypeScript to build/ directory
npm run build

# Run Jest tests
npm test
npm run test:watch      # Watch mode
npm run test:coverage   # With coverage report

# Clean build artifacts
npm run clean
```

## Architecture

### Data Flow: TypeScript → Swift

Props flow through three layers:

1. **TypeScript Interface** (`src/index.tsx`) - `TvosSearchViewProps` defines all props with JSDoc
2. **Expo Module** (`ios/ExpoTvosSearchModule.swift`) - Registers props via `Prop("name")` declarations
3. **Swift View** (`ios/ExpoTvosSearchView.swift`) - `ExpoTvosSearchView` receives props and syncs to `SearchViewModel`

The native view uses SwiftUI with a `UIHostingController` bridge. The `SearchViewModel` is an `@ObservableObject` that holds all reactive state.

### Key Files

| File | Purpose |
|------|---------|
| `src/index.tsx` | TypeScript exports, `TvosSearchView` component, `isNativeSearchAvailable()` |
| `ios/ExpoTvosSearchModule.swift` | Expo module definition, prop registration with validation |
| `ios/ExpoTvosSearchView.swift` | SwiftUI views (`TvosSearchContentView`, `SearchResultCard`), `SearchViewModel` |
| `ios/MarqueeText.swift` | Marquee scrolling text component |
| `ios/MarqueeAnimationCalculator.swift` | Animation calculations for marquee |

### Native Module Loading

The component only loads on tvOS. `NativeView` is set via `requireNativeViewManager("ExpoTvosSearch")` at module initialization. Use `isNativeSearchAvailable()` to check before rendering.

### Event Flow

Events from Swift to JS:
- `onSearch` - Search text changes
- `onSelectItem` - Result selected (passes `id`)
- `onError` - Fatal errors
- `onValidationWarning` - Non-fatal validation issues
- `onSearchFieldFocused`/`onSearchFieldBlurred` - Search field focus changes

## Adding New Props

Follow the 9-step checklist in `CLAUDE-adding-new-props.md`. Key steps:

1. Add to `TvosSearchViewProps` interface in `src/index.tsx`
2. Add to `SearchViewModel` in `ios/ExpoTvosSearchView.swift`
3. Add property with `didSet` to `ExpoTvosSearchView`
4. **CRITICAL**: Register with `Prop("name")` in `ios/ExpoTvosSearchModule.swift`
5. Pass to child components if needed (`SearchResultCard`)
6. Add unit tests

Missing Step 4 is the most common mistake - props will be silently ignored.

## Testing

Tests mock the React Native platform and expo-modules-core. Key test files:
- `src/__tests__/index.test.tsx` - Component and availability tests
- `src/__tests__/events.test.ts` - Event structure validation
- `src/__tests__/__mocks__/` - Platform and module mocks

Swift tests in `ios/Tests/` can be run via Xcode.

## Commit Conventions

Uses [Conventional Commits](https://www.conventionalcommits.org/):
- `feat(scope):` - New features
- `fix(scope):` - Bug fixes
- `refactor(scope):` - Code changes without feature/bug changes
- `test(scope):` - Test additions/updates

Common scopes: `search`, `results`, `focus`, `marquee`, `validation`, `props`, `ios`, `types`

## tvOS Compatibility

Target tvOS 15.0+. Avoid APIs requiring tvOS 16.0+ without fallbacks:
- Use custom `SelectiveRoundedRectangle` instead of `UnevenRoundedRectangle`
- Use `@available(tvOS 16.0, *)` checks when newer APIs are required

## Gesture Handler Management

The view automatically manages React Native gesture handlers when the search field is focused to enable hardware keyboard input on Apple TV devices. This is handled via:
- `RCTTVDisableGestureHandlersCancelTouchesNotification` / `RCTTVEnableGestureHandlersCancelTouchesNotification`
- Direct gesture recognizer disabling on parent views (tap/long press only, keeps swipe/pan for navigation)
