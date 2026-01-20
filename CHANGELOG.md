# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.2] - 2025-01-20

### Added
- GitHub Actions workflow step for npm publish, trigger on PR with labels: `release:patch`, `release:minor`, `release:major`

## [1.2.0] - 2025-01-17

### Added
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

## [1.1.0] - 2025-01-15

### Added
- Marquee scrolling animation for long titles that overflow card width
- `enableMarquee` prop to toggle marquee behavior (default: true)
- `marqueeDelay` prop to control delay before scrolling starts (default: 1.5s)
- `showTitleOverlay` prop for gradient title overlay at bottom of cards
- MarqueeAnimationCalculator for testable animation logic

### Changed
- Title display now uses overlay by default instead of below-card text
- Improved focus state visual feedback

## [1.0.0] - 2025-01-10

### Added
- Initial release
- Native SwiftUI search view with `.searchable` modifier
- Grid layout for search results with configurable columns
- `TvosSearchView` React Native component
- `isNativeSearchAvailable()` utility function
- Support for:
  - Search result images with async loading
  - Loading state indicator
  - Custom placeholder text
  - Title and subtitle display options
  - Focus border styling
  - Top inset for tab bar clearance
- Automatic fallback when native module is unavailable
- TypeScript type definitions
- Comprehensive test suite
