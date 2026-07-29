# expo-tvos-search

[![npm version](https://img.shields.io/npm/v/expo-tvos-search.svg)](https://www.npmjs.com/package/expo-tvos-search)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Test Status](https://github.com/keiver/expo-tvos-search/workflows/Test%20PR/badge.svg)](https://github.com/keiver/expo-tvos-search/actions)

A native Apple TV search component built with SwiftUI's `.searchable` modifier. Drop it into your Expo tvOS app and get the system search experience — keyboard, Siri Remote, focus handling — out of the box.

## Features

- **Native SwiftUI** — uses `.searchable` for the real tvOS search experience, not a web imitation
- **Siri Remote support** — full keyboard navigation, swipe, tap, and long-press handling on real hardware
- **Configurable grid** — portrait, landscape, square, or mini cards with adjustable columns, spacing, and padding
- **Marquee titles** — long titles auto-scroll on focus with configurable delay
- **Image caching** — async image loading with NSCache-backed caching
- **Title overlay** — gradient overlay with blur effect on card images, toggleable
- **External titles** — show title and subtitle below cards instead of (or alongside) the overlay
- **Customizable colors** — text color, accent/focus color, all via hex strings
- **Color scheme override** — force dark or light appearance regardless of system setting
- **Controlled search text** — set search field text programmatically for deep links, state restore, or "search for similar" flows
- **Error & validation callbacks** — structured error events and non-fatal validation warnings
- **Focus callbacks** — `onSearchFieldFocused` / `onSearchFieldBlurred` for gesture handler coordination
- **Platform-safe** — renders `null` on non-tvOS platforms; use `isNativeSearchAvailable()` to gate rendering

<p align="center">
  <img src="screenshots/demo-05.webp" alt="Native tvOS search with portrait card grid showing planet results with gold accent and marquee titles" width="100%"/>
</p>

## Installation

```bash
npx expo install expo-tvos-search
```

Or install from GitHub:

```bash
npx expo install github:keiver/expo-tvos-search
```

## Prerequisites for tvOS Builds

Your project must be configured for React Native tvOS.

**Platform requirements:** tvOS 15.0+, Expo SDK 51+, React Native tvOS 0.71+

### 1. Install react-native-tvos

```bash
npm install react-native-tvos@latest
```

### 2. Install the tvOS config plugin

```bash
npx expo install @react-native-tvos/config-tv
```

Then add the plugin in `app.json` / `app.config.js`:

```json
{
  "expo": {
    "plugins": ["@react-native-tvos/config-tv"]
  }
}
```

## Quick Start

```tsx
import { TvosSearchView, type SearchResult } from 'expo-tvos-search';

const results: SearchResult[] = [
  {
    id: 'earth',
    title: 'Earth',
    subtitle: 'The Blue Marble',
    imageUrl: 'https://example.com/earth.jpg',
  },
  {
    id: 'mars',
    title: 'Mars',
    subtitle: 'The Red Planet',
    imageUrl: 'https://example.com/mars.jpg',
  },
];

export default function SearchScreen() {
  return (
    <TvosSearchView
      results={results}
      columns={4}
      placeholder="Search planets..."
      isLoading={false}
      topInset={80}
      onSearch={(e) => console.log('Search:', e.nativeEvent.query)}
      onSelectItem={(e) => console.log('Selected:', e.nativeEvent.id)}
      textColor="#E5E5E5"
      accentColor="#E50914"
      cardWidth={280}
      cardHeight={420}
      overlayTitleSize={18}
      style={{ flex: 1 }}
    />
  );
}
```

### Apple TV Hardware Keyboard Support

On real Apple TV hardware, React Native's `RCTTVRemoteHandler` installs gesture recognizers that consume Siri Remote presses before they reach SwiftUI's `.searchable` text field, which prevents keyboard input. When the search field gains focus, this component temporarily disables touch cancellation using the official `react-native-tvos` notification API, and also disables tap/long-press recognizers from parent views (to cover cases like `react-native-gesture-handler`). Swipe and pan recognizers stay active for keyboard navigation. Everything is restored when focus leaves the field. This only applies to physical devices — the Simulator doesn't need it.

If this interferes with gesture handling in your app, please [open an issue](https://github.com/keiver/expo-tvos-search/issues) so we can sort it out.

For additional control, you can use the focus callbacks with `TVEventControl`:

```tsx
import { TVEventControl } from 'react-native';

<TvosSearchView
  onSearchFieldFocused={() => {
    TVEventControl.disableGestureHandlersCancelTouches();
  }}
  onSearchFieldBlurred={() => {
    TVEventControl.enableGestureHandlersCancelTouches();
  }}
  // ... other props
/>
```


### Color Scheme Override

Apps with a fixed dark background can get illegible search bar text when the system is in light mode. Use `colorScheme` to force a specific appearance:

```tsx
<TvosSearchView
  colorScheme="dark"
  // ... other props
/>
```

- `"dark"` — white text, dark UI elements (good for dark-background apps)
- `"light"` — black text, light UI elements
- `"system"` — follows the device setting (default, no override)

### Matching a Custom Card Design

By default the card renders with Apple's card focus effect, a blur title bar and white title text. Every part of that is overridable, so a native card can be made to match a card you already render in JS elsewhere in your app.

This example reproduces a common media-app card: rounded corners, a faint resting outline, a gold border and backlight on focus, and a title bar that flips from a dark blur to solid gold with dark text.

```tsx
<TvosSearchView
  results={results}
  onSearch={handleSearch}
  onSelectItem={handleSelect}

  columns={6}
  cardWidth={340}
  cardHeight={510}
  cardMargin={32}
  cardPadding={16}

  cardCornerRadius={32}
  cardBackgroundColor="#1C1C1E"
  borderWidth={2}
  borderColor="#26FFFFFF"          // rgba(255, 255, 255, 0.15)

  focusStyle="custom"              // drop Apple's lift/parallax
  showFocusBorder
  focusBorderWidth={4}
  accentColor="#FFC312"
  focusGlowColor="#FFC312"
  focusGlowOpacity={0.55}
  focusGlowRadius={7}

  showTitleOverlay
  overlayHeight={46}
  overlayTitleSize={22}
  overlayTitleWeight="bold"
  overlayTextColor="#FFFFFF"
  overlayBackgroundColorFocused="#FFC312"
  overlayTextColorFocused="#2B1F05"

  enableMarquee
  marqueeDelay={0.3}
  marqueeSpeed={60}
  marqueeMode="bounce"
/>
```

Two things worth knowing:

- Set `focusStyle="custom"` when matching an exact design. Left on `"system"`, tvOS adds its own lift, parallax and shadow on top of your border and glow.
- Setting `overlayBackgroundColor` (or its focused variant) replaces the native blur material with a solid fill. A translucent color composited over the blur muddies both, so the overlay picks one or the other.

## API Reference

### Props

#### Core

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `results` | `SearchResult[]` | `[]` | Array of search results to display. Capped at 500 items. |
| `columns` | `number` | `5` | Number of grid columns (clamped 1–10) |
| `placeholder` | `string` | `"Search..."` | Search field placeholder text |
| `searchText` | `string` | — | Programmatically set search field text (for deep links, state restore) |
| `isLoading` | `boolean` | `false` | Shows a loading indicator |

#### Card Dimensions & Spacing

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `cardWidth` | `number` | `280` | Width of each result card in points (clamped 50–1000) |
| `cardHeight` | `number` | `420` | Height of each result card in points (clamped 50–1000) |
| `cardMargin` | `number` | `40` | Spacing between cards (horizontal and vertical, clamped 0–200) |
| `cardPadding` | `number` | `16` | Padding inside the card for overlay content (clamped 0–100) |
| `cardCornerRadius` | `number` | `12` | Corner radius of the card in points (clamped 0–100) |
| `topInset` | `number` | `0` | Top padding for tab bar clearance (clamped 0–500) |

#### Display Options

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `showTitle` | `boolean` | `false` | Show title below each result card |
| `showSubtitle` | `boolean` | `false` | Show subtitle below title |
| `showTitleOverlay` | `boolean` | `true` | Show title overlay with gradient at bottom of card |
| `showFocusBorder` | `boolean` | `false` | Show border on focused item |
| `imageContentMode` | `'fill' \| 'fit' \| 'contain'` | `'fill'` | How images fill the card: `fill` crops, `fit`/`contain` letterbox |

#### Styling & Colors

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `textColor` | `string` | system default | Color for text and UI elements (hex, e.g. `"#FFFFFF"`) |
| `accentColor` | `string` | `"#FFC312"` | Accent color for focused elements (hex, e.g. `"#E50914"`) |
| `colorScheme` | `'light' \| 'dark' \| 'system'` | `"system"` | Override the system color scheme for the search view |
| `cardBackgroundColor` | `string` | dark gray | Background behind the image, and wherever the image doesn't cover the card |
| `borderWidth` | `number` | `0` | Border drawn on every card, focused or not (clamped 0–20) |
| `borderColor` | `string` | transparent | Color of the resting border. 8-digit `AARRGGBB` hex is supported, e.g. `"#26FFFFFF"` |

Borders are drawn inside the card bounds, like a CSS `border-box` border.

#### Focus Appearance

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `focusStyle` | `'system' \| 'custom'` | `'system'` | `system` uses Apple's card lift, parallax and shadow. `custom` applies only this library's border, glow and scale |
| `focusBorderWidth` | `number` | `4` | Border width for the focused card, used when `showFocusBorder` is true (clamped 0–20) |
| `focusScale` | `number` | `1` | Scale applied to the focused card. Only used when `focusStyle` is `custom` (clamped 1–1.5) |
| `focusGlowColor` | `string` | `accentColor` | Color of the glow around the focused card |
| `focusGlowOpacity` | `number` | `0.55` | Opacity of the focus glow (clamped 0–1) |
| `focusGlowRadius` | `number` | `0` | Blur radius of the focus glow. `0` disables it (clamped 0–60) |

`focusStyle` is ignored on tvOS 16 and earlier, which always takes the custom path — the system card style conflicts with React Native's remote gesture handler there.

#### Title Overlay

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `overlayTitleSize` | `number` | `20` | Font size for title text in the overlay (clamped 8–72) |
| `overlayTitleWeight` | `'regular' \| 'medium' \| 'semibold' \| 'bold' \| 'heavy'` | `'semibold'` | Font weight for the overlay title |
| `overlayHeight` | `number` | 25% of `cardHeight` | Height of the overlay in points (clamped 0–500) |
| `overlayBackgroundColor` | `string` | blur material | Overlay background. Setting it replaces the native blur with a solid fill |
| `overlayTextColor` | `string` | `"#FFFFFF"` | Overlay text color |
| `overlayBackgroundColorFocused` | `string` | `overlayBackgroundColor` | Overlay background while the card is focused |
| `overlayTextColorFocused` | `string` | `overlayTextColor` | Overlay text color while the card is focused |

#### Animation

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `enableMarquee` | `boolean` | `true` | Enable marquee scrolling for long titles |
| `marqueeDelay` | `number` | `1.5` | Delay in seconds before marquee starts (clamped 0–60) |
| `marqueeSpeed` | `number` | `30` | Marquee scroll speed in points per second (clamped 5–300) |
| `marqueeMode` | `'loop' \| 'bounce'` | `'loop'` | `loop` scrolls continuously and repeats. `bounce` scrolls to the end, pauses, then scrolls back |

#### Text Customization

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `emptyStateText` | `string` | `"Search your library"` | Text shown when search field is empty |
| `searchingText` | `string` | `"Searching..."` | Text shown during search |
| `noResultsText` | `string` | `"No results found"` | Text shown when no results match |
| `noResultsHintText` | `string` | `"Try a different search term"` | Hint text below no results message |

#### Event Handlers

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `onSearch` | `(event: SearchEvent) => void` | Yes | Called when search text changes |
| `onSelectItem` | `(event: SelectItemEvent) => void` | Yes | Called when a result is selected |
| `onError` | `(event: SearchViewErrorEvent) => void` | No | Called on errors (image loading, validation) |
| `onValidationWarning` | `(event: ValidationWarningEvent) => void` | No | Called for non-fatal warnings (truncated fields, clamped values) |
| `onSearchFieldFocused` | `(event: SearchFieldFocusEvent) => void` | No | Called when native search field gains focus |
| `onSearchFieldBlurred` | `(event: SearchFieldFocusEvent) => void` | No | Called when native search field loses focus |

#### Other

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `style` | `ViewStyle` | — | Style object for the view container |

### SearchResult

```ts
interface SearchResult {
  id: string;        // Unique identifier (used in onSelectItem)
  title: string;     // Primary display text
  subtitle?: string; // Optional secondary text
  imageUrl?: string; // Optional poster/thumbnail URL (HTTPS, HTTP, file://, or data: URI)
}
```

### isNativeSearchAvailable()

```ts
function isNativeSearchAvailable(): boolean
```

Returns `true` when running on tvOS with the native module properly built. Use this to conditionally render a fallback on non-tvOS platforms.

```tsx
import { TvosSearchView, isNativeSearchAvailable } from 'expo-tvos-search';

if (!isNativeSearchAvailable()) {
  return <FallbackSearch />;
}
return <TvosSearchView {...props} />;
```

## Result Validation

The native implementation applies the following constraints:

- **Maximum results** — the array is capped at 500 items; extras are silently ignored
- **Required fields** — results with empty `id` or `title` are filtered out
- **Image URL schemes** — HTTP, HTTPS, `file://`, and `data:` URIs are accepted; other schemes are rejected
- **HTTPS recommended** — HTTP URLs may be blocked by App Transport Security unless explicitly allowed in Info.plist

## Demo App

Explore all configurations in the [expo-tvos-search-demo](https://github.com/keiver/expo-tvos-search-demo) repository.

## Testing

```bash
npm test                # Run tests once
npm run test:watch      # Watch mode
npm run test:coverage   # Generate coverage report
```

Tests cover:

- Behavior across platforms
- Component rendering when native module is unavailable
- Event structure validation

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:

- Code of conduct
- Development setup
- Testing requirements
- Commit message conventions
- Pull request process

<table>
  <tr>
    <td><img src="screenshots/default.webp" alt="Default empty search state with tvOS keyboard and tab bar" width="100%"/></td>
    <td><img src="screenshots/demo-01.webp" alt="Square card grid layout with planet images and no title overlay" width="100%"/></td>
    <td><img src="screenshots/demo-02.webp" alt="Four-column grid with title overlays and hardware keyboard active indicator" width="100%"/></td>
  </tr>
  <tr>
    <td><img src="screenshots/demo-03.webp" alt="Five-column compact grid with short overlay titles" width="100%"/></td>
    <td><img src="screenshots/demo-04.webp" alt="Mini card grid with truncated overlay titles on planet cards" width="100%"/></td>
    <td><img src="screenshots/demo-06.webp" alt="Demo app home screen with feature badges and configuration menu" width="100%"/></td>
  </tr>
  <tr>
    <td><img src="screenshots/no-results.webp" alt="No results found state after searching for a term with no matches" width="100%"/></td>
    <td><img src="screenshots/results-jungle-book.webp" alt="Single search result for Jungle Book with poster card and title overlay" width="100%"/></td>
    <td><img src="screenshots/results.webp" alt="Focused search result card for Caminandes with accent color border" width="100%"/></td>
  </tr>
</table>


## License

MIT — see [LICENSE](LICENSE) for details.
