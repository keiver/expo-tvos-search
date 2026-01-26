# TODO / Known Issues

Tracked issues, improvement opportunities, and future work for `expo-tvos-search`.

> For bug reports and feature requests from users, see [GitHub Issues](https://github.com/keiver/expo-tvos-search/issues).
> This file tracks internal technical debt and architectural improvements identified during development.

---

## Known Issues

### 1. `@Published` inconsistency in SearchViewModel

**Severity:** Medium — works today, fragile for future use cases
**File:** `ios/ExpoTvosSearchView.swift` (SearchViewModel, lines 55-97)

Only `results`, `isLoading`, and `searchText` are marked `@Published`. All other properties (`columns`, `showTitle`, `cardWidth`, `cardMargin`, `showFocusBorder`, etc.) are plain `var`.

**Why it matters:** `@ObservedObject` only triggers SwiftUI re-renders on `@Published` property changes. If a consumer updates only a non-published property (e.g., changing `columns` for a layout rotation) without also updating `results`, the grid won't re-render.

**Why it works today:** React Native prop updates typically arrive in batches alongside `results` changes, which IS published and triggers a full re-render.

**Fix:** Mark all dynamically changeable ViewModel properties as `@Published`. Evaluate performance impact — excessive `@Published` properties can cause unnecessary re-renders if many props change in a single update cycle.

---

### 2. Redundant validation clamping in two layers

**Severity:** Low — no incorrect behavior, just maintenance overhead
**Files:** `ios/ExpoTvosSearchModule.swift` (lines 47-58) and `ios/ExpoTvosSearchView.swift` (didSet observers)

The module layer clamps values (e.g., `columns` to `[1, 10]`) and emits `onValidationWarning`. Then the view's `didSet` observers clamp again (e.g., `viewModel.columns = max(1, min(columns, 10))`).

**Why it matters:** Validation logic exists in two places with slightly different styles. Adding a new numeric prop requires updating clamping ranges in both locations, and they could drift out of sync.

**Fix:** Choose a single validation layer. The module layer is the better location (it has access to `onValidationWarning`). Remove redundant clamping from `didSet` observers, or make `didSet` a simple passthrough: `didSet { viewModel.columns = columns }`.

---

## Future Improvements

### 3. Programmatic search text control

**Priority:** Feature request (likely from media app developers)

Currently, search text flows one direction only: native → JS via `onSearch`. There is no way for JavaScript to set the search text programmatically.

**Use cases:**
- Restoring a previous search query when navigating back to the search screen
- Pre-filling search from a deep link or push notification
- "Search for similar" flows where selecting a result pre-fills a new query

**Implementation notes:** Would require adding an `initialSearchText` or `searchText` prop, flowing it through the module layer to `viewModel.searchText`. Care needed to avoid infinite loops (`searchText` prop change → `onChange` fires `onSearch` → JS updates state → prop change again).

---

### 4. Image caching for AsyncImage

**Priority:** Performance improvement

`AsyncImage` (used in `SearchResultCard`) has no persistent caching strategy. Each time `results` updates, images may re-fetch from the network, causing visible flicker during search-as-you-type flows where results change rapidly.

**Impact:** Most visible in media apps with poster images — users see loading spinners or blank cards for images they've already seen.

**Options:**
- Configure `URLCache` with a larger memory/disk budget for the shared session
- Replace `AsyncImage` with a caching image loader (e.g., Kingfisher, Nuke, or a custom `URLSession`-based loader with `NSCache`)
- Add an `imageCachePolicy` prop to let consumers control caching behavior

**Trade-off:** Adding a third-party image library increases bundle size and dependency surface. A custom `NSCache`-based loader would keep dependencies at zero.

---

### 5. Non-tvOS fallback class duplication

**Priority:** Low — maintenance convenience

**File:** `ios/ExpoTvosSearchView.swift` (lines 839-893)

The `#else` branch for non-tvOS platforms duplicates every property declaration as stubs. Every new prop must be added to both the tvOS implementation and the fallback class.

**Current state:** ~20 properties duplicated with no-op implementations.

**Options:**
- Extract shared property declarations into a protocol that both classes conform to
- Use `#if os(tvOS)` around only the implementation bodies, not the entire class
- Generate the fallback class from the tvOS class (build script)

**Trade-off:** The current approach is explicit and simple. The duplication is annoying but unlikely to cause bugs since the fallback is just a "not available" label. Only worth fixing if the prop count grows significantly.

---

## Completed

_Move items here when resolved. Include the date and PR/commit reference._

<!--
### Example: Fixed issue title
**Resolved:** 2026-01-XX — PR #YY or commit abc1234
**What was done:** Brief description of the fix
-->
