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
| `ios/ExpoTvosSearchView.swift` | `SearchViewModel`, `ExpoTvosSearchView` (UIKit bridge), `Color(hex:)` extension |
| `ios/SearchResultItem.swift` | `SearchResultItem` data model (`Identifiable`, `Equatable`) |
| `ios/SearchResultCard.swift` | `SearchResultCard` view, `SelectiveRoundedRectangle` shape |
| `ios/TvosSearchContentView.swift` | `TvosSearchContentView` — main search UI with grid, states, `.searchable` |
| `ios/MarqueeText.swift` | Marquee scrolling text component |
| `ios/MarqueeAnimationCalculator.swift` | Animation calculations for marquee |
| `ios/HexColorParser.swift` | DoS-protected hex color string → RGBA parsing |
| `ios/CachedAsyncImage.swift` | NSCache-backed image caching for search result cards |

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
- **Marquee State Machine Race (January 2026):** Three `onChange` handlers + manual `Task` management = non-deterministic animation on tvOS card focus. Fix: Replace with `.task(id: shouldAnimate)` — SwiftUI handles cancellation and restart automatically.
- **Marquee Text Disappearing (January 2026):** Visual gap in `Text(text + " " + text)` didn't match `calculator.spacing` used for scroll distance. Fix: `HStack(spacing: calculator.spacing)` — visual gap and scroll math must use the same source of truth.

See `memories/CLAUDE-lessons-learned.md` for full debugging narratives, root cause analysis, and the template for documenting new lessons.

## Known Production Edge Cases

Reviewed 2026-02-01. These are edge cases, not blockers — the lib is production-ready:

- **Image cache cost overflow**: `CachedAsyncImage.swift:22` — `bytesPerRow * height` can overflow `Int` on corrupt image metadata. Produces incorrect NSCache cost values.
- **NotificationCenter scope**: `ExpoTvosSearchView.swift:300-311` — text field observers use `object: nil`, matching all UITextFields. The `isDescendant(of:)` guard handles this, but there's a theoretical race window during dealloc.
- **Data URI validation order**: `ExpoTvosSearchView.swift:441-449` — data URI size check happens after `URL(string:)` parsing, so memory spikes before the 1MB limit kicks in.
- **URLSession defaults**: `CachedAsyncImage.swift:65` — image downloads use `URLSession.shared` with no timeout or size limits.

## Quality Patterns

Code worth studying when making architectural decisions:

- **MarqueeAnimationCalculator** (`ios/MarqueeAnimationCalculator.swift`): Extracted pure logic from a SwiftUI view into a testable struct. Model for how to make SwiftUI code unit-testable.
- **HexColorParser** (`ios/HexColorParser.swift`): DoS-protected parsing with `maxInputLength`, `Scanner`-based hex conversion, RGBA struct output. Security-minded even in library context.
- **Prop validation layer** (`ios/ExpoTvosSearchModule.swift`): Systematic clamping/truncation with non-fatal warning events. Defensive without being paranoid.
- **`.task(id:)` pattern** (`ios/MarqueeText.swift`): Single-control-point for cancellable async animation. Replaced a three-handler state machine that had race conditions.

## Memory Bank

Detailed memory files live in `memories/`. They are loaded based on context keywords.

### Memory Bank Usage

**I automatically load relevant memory files based on context:**

**Architecture & Implementation:**
- "architecture" / "data flow" / "SwiftUI" / "bridge" / "module" → `memories/CLAUDE-architecture.md`
- "pattern" / "validation" / "how do I" / "prop addition" → `memories/CLAUDE-patterns.md`
- "lessons" / "bug" / "debugging" / "marquee" → `memories/CLAUDE-lessons-learned.md`

**Testing & Development:**
- "testing" / "tests" / "coverage" / "jest" / "mocking" → `memories/CLAUDE-testing.md`
- "setup" / "build" / "release" / "CI" / "npm" → `memories/CLAUDE-development.md`

**Category-Based Loading:**
- "implementation files" → Load: architecture, patterns, lessons-learned
- "all memory files" / "complete documentation" → Load all 5 memory bank files

**You DON'T need to tell me to read these files.**

### Lessons Learned Auto-Append

After resolving a significant bug/issue, I will **automatically append** a new lesson to `memories/CLAUDE-lessons-learned.md`:
- Uses the template format in that file
- Captures: problem, root cause, solution, what went wrong, what worked
- No need to ask permission — just document it

**Most Recent:**
- **Marquee State Machine Race (January 2026):** Three onChange handlers + manual Task = non-deterministic animation. Fix: `.task(id: shouldAnimate)`.

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

### Known Gap

The release workflow bumps `package.json` but does **not** bump `ios/ExpoTvosSearch.podspec`. The podspec version must be updated manually or the workflow should be extended to handle it.

### Pre-release Checklist

Before adding a version label, ensure:
- [ ] All tests pass (`npm test`)
- [ ] TypeScript builds (`npm run build`)
- [ ] CHANGELOG.md has entry for changes (workflow adds PR reference, but detailed notes should exist)
- [ ] README.md updated if user-facing changes
- [ ] No breaking changes without `version:major` label
