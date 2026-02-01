# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2026-02-01

### Added
- `colorScheme` prop — override the system color scheme for the search view (`'dark'`, `'light'`, or `'system'`)
  - Fixes illegible search bar text when app has a dark background and system is in light mode
  - Maps to `UIHostingController.overrideUserInterfaceStyle` on the native side
  - Default `"system"` preserves existing behavior (no breaking change)

### Changed
- Search bar interactive controls (cursor, highlights) now tint to match `accentColor`

## [1.3.2] - 2026-01-25

### Added
- **Apple TV hardware keyboard support**: New `onSearchFieldFocused` and `onSearchFieldBlurred` event callbacks
  - Enables proper Siri Remote keyboard input on physical Apple TV devices
  - Works with `TVEventControl.disableGestureHandlersCancelTouches()` for JS-side handling
  - Native Swift implementation automatically disables tap/press gesture recognizers when search field is focused
  - Keeps swipe/pan recognizers enabled for keyboard navigation
  - TypeScript type `SearchFieldFocusEvent` for the new focus events
  - **Data URI support for images**: `imageUrl` now accepts `data:` URIs (e.g., `data:image/png;base64,...`) in addition to HTTP/HTTPS URLs
    - Enables inline base64-encoded images without external requests
    - Useful for cached thumbnails or placeholder images

### Fixed
- Siri Remote click events not reaching native SwiftUI search field on real Apple TV hardware
- React Native gesture handlers intercepting keyboard input before it reached SwiftUI `.searchable` modifier

## [1.3.1] - 2026-01-21

### Fixed
- Minor stability improvements
- Documentation updates

## [1.3.0] - 2026-01-20

### Added
- `cardMargin` prop - Customize spacing between cards in the grid (default: 40)
- `cardPadding` prop - Customize padding inside cards for overlay content (default: 16)
- `overlayTitleSize` prop - Customize font size for title in blur overlay (default: 20)

### Changed
- Improved grid layout flexibility with customizable spacing

## [1.2.3] - 2026-01-20
- Patch release for npm publish workflow fix.

### Added
- GitHub Actions workflow step for npm publish, trigger on PR with labels: `release:patch`, `release:minor`, `release:major`

## [1.2.0] - 2026-01-17

### Added
- `onError` callback - Receive notifications for fatal errors (image loading failures, validation errors)
- `onValidationWarning` callback - Receive non-fatal warnings (truncated fields, clamped values, invalid URLs)
- `SearchViewErrorEvent` and `ValidationWarningEvent` TypeScript types
- JSDoc documentation for all TypeScript exports
- `SearchEvent` and `SelectItemEvent` type interfaces for improved type safety
- Coverage thresholds (80% global) in Jest configuration
- Explicit tvOS modules section in expo-module.config.json
- Performance and Accessibility documentation sections in README
- Debug logging for skipped invalid results (id or title missing/empty)

### Changed
- Input validation: `columns` prop now clamps between 1-10 (was: min 1 only)
- Input validation: `topInset` prop now clamps between 0-500 (was: min 0 only)
- Input validation: `marqueeDelay` prop now clamps between 0-60 seconds (was: min 0 only)
- Input validation: `placeholder` prop now limited to 500 characters
- Input validation: `results` array now limited to 500 items max
- MarqueeAnimationCalculator guards against division by zero
- MarqueeAnimationCalculator ensures non-negative values for spacing and distances

### Security
- URL scheme validation: `imageUrl` now only accepts HTTP/HTTPS schemes
- String length limits: `id`, `title`, `subtitle` clamped to 500 characters each
- Empty string rejection: Results with empty `id` or `title` are now skipped
- Added `@types/react-native` and build dependencies for TypeScript compilation

### Fixed
- TypeScript build now compiles successfully with `jsx: "react"` option
- Empty strings no longer pass validation for required fields

## [1.1.0] - 2026-01-15

### Added
- Marquee scrolling animation for long titles that overflow card width
- `enableMarquee` prop to toggle marquee behavior (default: true)
- `marqueeDelay` prop to control delay before scrolling starts (default: 1.5s)
- `showTitleOverlay` prop for gradient title overlay at bottom of cards
- MarqueeAnimationCalculator for testable animation logic

### Changed
- Title display now uses overlay by default instead of below-card text
- Improved focus state visual feedback

## [1.0.0] - 2026-01-10

### Added 
- Initial release
- Native SwiftUI search view with `.searchable` modifier
- Grid layout for search results with configurable columns
- `TvosSearchView` React Native component
- `isNativeSearchAvailable()` utility function
- Core props:
  - `results`, `columns`, `placeholder`, `isLoading`
  - `cardWidth`, `cardHeight` - Customizable card dimensions
  - `imageContentMode` - Image scaling (`fill`, `fit`, `contain`)
  - `textColor`, `accentColor` - Color customization
  - `showTitle`, `showSubtitle`, `showFocusBorder` - Display options
  - `topInset` - Tab bar clearance
  - `emptyStateText`, `searchingText`, `noResultsText`, `noResultsHintText` - Text customization
- `onSearch` and `onSelectItem` event callbacks
- Automatic fallback when native module is unavailable
- TypeScript type definitions (`SearchResult`, `TvosSearchViewProps`, etc.)
- Comprehensive test suite
