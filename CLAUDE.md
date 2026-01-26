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

## Lessons Learned

- **This is a library, not an app.** When reviewing code, doing security audits, or suggesting changes, always keep this in mind. The threat model is different: inputs come from developers integrating the lib, not from untrusted end users. A developer passing bad data into their own search results is a bug in their app, not a vulnerability in this lib. Don't apply app-level threat modeling to library code.
- **Know the audience.** Consumers are tvOS/Expo developers building media apps (Jellyfin clients, streaming apps). Recommendations should be practical for that context, not generic.

## Release Process

Releases are automated via GitHub Actions (`.github/workflows/release.yml`). No manual version bumping or npm publishing required.

### How to Release

1. Create a PR to `main` with your changes
2. Add ONE version label to the PR:
   - `version:patch` - Bug fixes, minor updates (1.3.2 → 1.3.3)
   - `version:minor` - New features, backwards compatible (1.3.2 → 1.4.0)
   - `version:major` - Breaking changes (1.3.2 → 2.0.0)
3. Merge the PR

### What the Workflow Does Automatically

1. Runs `npm run test:coverage` to verify tests pass
2. Bumps version in `package.json` based on label
3. Updates CHANGELOG.md with PR title and number
4. Commits changes with message `chore: release v{version}`
5. Creates and pushes git tag `v{version}`
6. Creates GitHub Release with changelog excerpt
7. Publishes to npm registry
8. Comments on the PR with release links

### Requirements

- `NPM_TOKEN` secret must be configured in GitHub repository settings
- PR must be merged (not just closed) for release to trigger
- Only one version label should be applied per PR

### Pre-release Checklist

Before adding a version label, ensure:
- [ ] All tests pass (`npm test`)
- [ ] TypeScript builds (`npm run build`)
- [ ] CHANGELOG.md has entry for changes (workflow adds PR reference, but detailed notes should exist)
- [ ] README.md updated if user-facing changes
- [ ] No breaking changes without `version:major` label
