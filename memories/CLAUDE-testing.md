# Testing Memory Bank

> **Category:** Testing
> **Keywords:** testing, tests, coverage, jest, mocking, Swift tests, Xcode
> **Last Updated:** 2026-02-01

## Quick Reference

- **TypeScript tests:** `npm test` (Jest with ts-jest, 80% coverage threshold)
- **Swift tests:** Xcode → `ios/Tests/` (unit tests for extracted pure logic)
- **Mocking strategy:** Global state-based platform mocks (`__mockPlatformOS`, `__mockPlatformIsTV`)
- **Key principle:** Extract pure logic from SwiftUI views into testable structs

---

## Two Test Layers

### 1. TypeScript Tests (Jest)

**Config:** `jest.config.js`
- Preset: `ts-jest`
- Environment: `node` (not jsdom — no DOM needed for native module testing)
- Match pattern: `**/src/__tests__/**/*.test.ts?(x)`
- Setup file: `src/__tests__/setup.ts`

**Coverage thresholds (all 80%):**
- Branches: 80%
- Functions: 80%
- Lines: 80%
- Statements: 80%

**Run commands:**
```bash
npm test                # Standard run
npm run test:watch      # Watch mode
npm run test:coverage   # With coverage report
```

### 2. Swift Tests (Xcode)

**Location:** `ios/Tests/`
- `HexColorParserTests.swift` — Hex parsing (formats, edge cases, DoS protection)
- `MarqueeAnimationCalculatorTests.swift` — Animation math (shouldScroll, scrollDistance, duration)
- `SearchViewModelTests.swift` — ViewModel defaults and property behavior
- `SearchResultItemTests.swift` — Data model equality and properties

**Run:** Open in Xcode, run test target against tvOS simulator.

---

## TypeScript Mocking Strategy

### Platform Mocking

The platform mock uses **global state** that persists across `jest.resetModules()` calls:

```typescript
// src/__tests__/__mocks__/react-native.ts
declare global {
  var __mockPlatformOS: 'ios' | 'android' | 'web';
  var __mockPlatformIsTV: boolean;
}

if (globalThis.__mockPlatformOS === undefined) {
  globalThis.__mockPlatformOS = 'web';  // Default: non-tvOS
}
if (globalThis.__mockPlatformIsTV === undefined) {
  globalThis.__mockPlatformIsTV = false;
}

export const Platform = {
  get OS() { return globalThis.__mockPlatformOS; },
  set OS(value) { globalThis.__mockPlatformOS = value; },
  get isTV() { return globalThis.__mockPlatformIsTV; },
  set isTV(value) { globalThis.__mockPlatformIsTV = value; },
};
```

**Why global state?** Because `jest.resetModules()` re-executes module code, but global state survives. This lets tests configure the platform before importing the module.

### Helper Functions

Tests use helpers (in `setup.ts` or test file) to set platform state:

```typescript
function mockTvOSPlatform() {
  globalThis.__mockPlatformOS = 'ios';
  globalThis.__mockPlatformIsTV = true;
}

function mockNonTvOSPlatform() {
  globalThis.__mockPlatformOS = 'web';
  globalThis.__mockPlatformIsTV = false;
}

function mockNativeModuleAvailable() {
  // Sets up expo-modules-core mock to return a component
  globalThis.__mockNativeModuleAvailable = true;
}
```

### Module Mock (expo-modules-core)

```typescript
// src/__tests__/__mocks__/expo-modules-core.ts
export function requireNativeViewManager(name: string) {
  // Returns a mock component or null based on global state
}
```

### Test Pattern

```typescript
describe('TvosSearchView on tvOS', () => {
  beforeEach(() => {
    jest.resetModules();          // Clear module cache
    mockTvOSPlatform();           // Set platform before import
    mockNativeModuleAvailable();  // Set native module available
  });

  it('renders on tvOS', () => {
    const { TvosSearchView } = require('../index');
    // NativeView was resolved during module initialization
    expect(/* ... */).toBeDefined();
  });
});
```

**Critical:** `jest.resetModules()` must be called before each test because `NativeView` is set at **module initialization time** (near the end of `src/index.tsx`). Without reset, the first test's platform configuration would be cached for all subsequent tests.

---

## Test Categories

### Platform Availability Tests
- `isNativeSearchAvailable()` returns `true` on tvOS
- `isNativeSearchAvailable()` returns `false` on non-tvOS
- Component renders on tvOS
- Component returns null on non-tvOS

### Component Rendering Tests
- Accepts required props (results, onSearch, onSelectItem)
- Accepts all optional props
- Works with default values (no optional props)

### Event Structure Tests (`events.test.ts`)
- `SearchEvent` structure validation
- `SelectItemEvent` structure validation
- `SearchViewErrorEvent` with all categories
- `ValidationWarningEvent` with all types
- `SearchFieldFocusEvent` empty payload

### Edge Case Tests
- Unicode characters in results
- Special characters in search queries
- Empty results array
- Whitespace-only strings

---

## Swift Test Strategy

### Key Insight: Extract Pure Logic

SwiftUI views can't be unit tested directly (they need a view hierarchy). The solution is to extract pure logic into standalone structs:

**Model example — MarqueeAnimationCalculator:**
```swift
struct MarqueeAnimationCalculator {
    let spacing: CGFloat
    let pixelsPerSecond: CGFloat

    func shouldScroll(textWidth: CGFloat, containerWidth: CGFloat) -> Bool
    func scrollDistance(textWidth: CGFloat) -> CGFloat
    func animationDuration(for distance: CGFloat) -> Double
}
```

This struct has zero SwiftUI dependencies — it's pure math. Tests can verify all edge cases:
- Zero/negative inputs
- Division safety (min pixelsPerSecond prevents /0)
- Boundary conditions (textWidth == containerWidth)

**Other testable extractions:**
- `HexColorParser` — hex string → RGBA values (no SwiftUI `Color` dependency)
- `SearchResultItem` — Identifiable/Equatable conformance
- `SearchViewModel` — defaults and property behavior

### When to Extract

Extract into a standalone struct when:
1. The logic is non-trivial (more than a simple property check)
2. There are edge cases worth testing (boundary values, format parsing)
3. The logic doesn't depend on SwiftUI view state

---

## Coverage Notes

- TypeScript coverage is tracked via Jest (`npm run test:coverage`)
- Coverage report outputs to `coverage/` directory (gitignored)
- CI runs `npm run test:coverage` on both PR (`test-pr.yml`) and release (`release.yml`)
- Swift test coverage is tracked via Xcode (not part of CI)

---

## Related Documentation

- [`CLAUDE-patterns.md`](./CLAUDE-patterns.md) - Patterns being tested
- [`CLAUDE-development.md`](./CLAUDE-development.md) - CI pipelines that run tests
