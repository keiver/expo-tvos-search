# TODO / Known Issues

Internal technical debt and improvements. For bug reports, see [GitHub Issues](https://github.com/keiver/expo-tvos-search/issues).

---

## Open

### 5. Non-tvOS fallback class duplication
- **File:** `ios/ExpoTvosSearchView.swift` (lines ~837-890)
- **Impact:** Low — maintenance annoyance, no bugs
- The `#else` branch duplicates ~23 property declarations as stubs. Every new prop must be added to both classes.
- **Status:** Evaluated and deferred — merging into one class would require ~30 `#if os(tvOS)` blocks, making the code harder to read than the current two clean classes. Only revisit if prop count grows significantly.

---

## Completed

### 1. `@Published` inconsistency in SearchViewModel
- All 24 UI-state properties now have `@Published` for proper SwiftUI reactivity.
- Callbacks (`onSearch`, `onSelectItem`) correctly left without it.

### 2. Redundant validation clamping in didSet
- Removed duplicate clamping from 8 `didSet` observers (`columns`, `topInset`, `marqueeDelay`, `cardWidth`, `cardHeight`, `cardMargin`, `cardPadding`, `overlayTitleSize`).
- Module layer (`ExpoTvosSearchModule`) is now the single validation source.

### 3. Programmatic search text control
- Added `searchText` prop across all layers: TypeScript interface, Expo module `Prop("searchText")`, Swift view (`searchTextProp`), and fallback class.
- Guard prevents redundant updates when JS echoes back the same value.
- 2 new tests added.

### 4. Image caching with CachedAsyncImage
- Created `ios/CachedAsyncImage.swift` with NSCache-backed `ImageCache` singleton (100 items, 100MB limit).
- Cached images appear instantly (no loading flash). Failures show `EmptyView()` so the existing placeholder shows through.
- Replaced `AsyncImage` usage in `SearchResultCard`.
