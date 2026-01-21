# expo-tvos-search

[![npm version](https://img.shields.io/npm/v/expo-tvos-search.svg)](https://www.npmjs.com/package/expo-tvos-search)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Test Status](https://github.com/keiver/expo-tvos-search/workflows/Test%20PR/badge.svg)](https://github.com/keiver/expo-tvos-search/actions)
[![Bundle Size](https://img.shields.io/bundlephobia/minzip/expo-tvos-search)](https://bundlephobia.com/package/expo-tvos-search)

A native tvOS search component for Expo and React Native using SwiftUI's `.searchable` modifier. Provides the native tvOS search experience with automatic focus handling, remote control support, and flexible customization for media apps.

**Platform Support:**
- tvOS 15.0+
- Expo SDK 51+
- React Native tvOS 0.71+

<p align="center">
  <img src="screenshots/demo-mini.png" width="80%" alt="Demo Mini screen for expo-tvos-search" style="border-radius: 16px;max-width: 100%;"/>
</p>

## Installation

```bash
npx expo install expo-tvos-search
```

Or install from GitHub:

```bash
npx expo install github:keiver/expo-tvos-search
```

Then follow the **tvOS prerequisites** below and rebuild your native project.

## Quick Start

### Try the Demo App

**[expo-tvos-search-demo](https://github.com/keiver/expo-tvos-search-demo)** - Comprehensive showcase with 7 tabs demonstrating all library features:

- **Default** - 4-column grid with custom colors
- **Portrait** - Netflix-style tall cards (280×420)
- **Landscape** - Wide 16:9 cards (500×280)
- **Mini** - Compact 5-column layout (240×360)
- **External Title** - Titles displayed below cards
- **Minimal** - Bare minimum setup (5 props)
- **Help** - Feature overview and usage guide

Clone and run:
```bash
git clone https://github.com/keiver/expo-tvos-search-demo.git
cd expo-tvos-search-demo
npm install
npm run prebuild
npm run tvos
```

The demo uses a planet search theme with 8 planets (Mercury to Neptune) and demonstrates all library features with real working code.

## Prerequisites for tvOS Builds (Expo)

Your project must be configured for React Native tvOS to build and run this module.

**Quick Checklist:**

- ✅ `react-native-tvos` in use
- ✅ `@react-native-tvos/config-tv` installed + added to Expo plugins
- ✅ Run prebuild with `EXPO_TV=1`

### 1. Swap to react-native-tvos

Replace `react-native` with the [tvOS fork](https://github.com/react-native-tvos/react-native-tvos):

```bash
npm remove react-native && npm install react-native-tvos@latest
```

### 2. Install the tvOS config plugin

Install:

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

### 3. Generate native projects with tvOS enabled

```bash
EXPO_TV=1 npx expo prebuild --clean
```

Then run:

```bash
npx expo run:ios
```


## Usage

### Minimal Example

For the absolute minimum setup, see the [Minimal tab](https://github.com/keiver/expo-tvos-search-demo/blob/main/app/(tabs)/minimal.tsx) in the demo app.

<p align="center">
  <img src="screenshots/demo-default.png" width="80%" alt="Minimal demo screen for expo-tvos-search" style="border-radius: 16px;max-width: 100%;"/><br/>
</p>

### Complete Example

This example from the demo's [Portrait tab](https://github.com/keiver/expo-tvos-search-demo/blob/main/app/(tabs)/portrait.tsx) shows a complete implementation with best practices:

```tsx
import { useState } from 'react';
import { Alert } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import {
  TvosSearchView,
  isNativeSearchAvailable,
  type SearchResult,
} from 'expo-tvos-search';

const PLANETS: SearchResult[] = [
  {
    id: 'earth',
    title: 'Earth - The Blue Marble of Life',
    subtitle: 'Our home planet, the only known world to harbor life',
    imageUrl: require('./assets/planets/earth.webp'),
  },
  // ... more planets
];

export default function SearchScreen() {
  const [results, setResults] = useState<SearchResult[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const insets = useSafeAreaInsets();

  const handleSearch = (event: { nativeEvent: { query: string } }) => {
    const { query } = event.nativeEvent;

    if (!query.trim()) {
      setResults([]);
      return;
    }

    setIsLoading(true);

    // Debounce search (300ms)
    setTimeout(() => {
      const filtered = PLANETS.filter(
        planet =>
          planet.title.toLowerCase().includes(query.toLowerCase()) ||
          planet.subtitle?.toLowerCase().includes(query.toLowerCase())
      );
      setResults(filtered);
      setIsLoading(false);
    }, 300);
  };

  const handleSelect = (event: { nativeEvent: { id: string } }) => {
    const planet = PLANETS.find(p => p.id === event.nativeEvent.id);
    if (planet) {
      Alert.alert(planet.title, planet.subtitle);
    }
  };

  if (!isNativeSearchAvailable()) {
    return null; // Or show web fallback
  }

  return (
    <LinearGradient
      colors={['#0f172a', '#1e293b', '#0f172a']}
      style={{ flex: 1 }}
    >
      <TvosSearchView
        results={results}
        columns={4}
        placeholder="Search planets..."
        isLoading={isLoading}
        topInset={insets.top + 80}
        onSearch={handleSearch}
        onSelectItem={handleSelect}
        textColor="#E5E5E5"
        accentColor="#E50914"
        cardWidth={280}
        cardHeight={420}
        overlayTitleSize={18}  // v1.3.0 - control title font size
        style={{ flex: 1 }}
      />
    </LinearGradient>
  );
}
```

## Layout Styles

Explore all 7 configurations in the [demo app](https://github.com/keiver/expo-tvos-search-demo).

### Portrait Cards

```tsx
<TvosSearchView
  columns={4}
  cardWidth={280}
  cardHeight={420}
  overlayTitleSize={18}
  // ... other props
/>
```

### Landscape Cards

```tsx
<TvosSearchView
  columns={3}
  cardWidth={500}
  cardHeight={280}
  // ... other props
/>
```

### Mini Grid

```tsx
<TvosSearchView
  columns={5}
  cardWidth={240}
  cardHeight={360}
  cardMargin={60}  // v1.3.0 - extra spacing
  // ... other props
/>
```

### External Titles

```tsx
<TvosSearchView
  showTitle={true}
  showSubtitle={true}
  showTitleOverlay={false}
  // ... other props
/>
```

### Error Handling

```tsx
<TvosSearchView
  onError={(e) => {
    const { category, message, context } = e.nativeEvent;
    console.error(`[Search Error] ${category}: ${message}`, context);
  }}
  onValidationWarning={(e) => {
    const { type, message, context } = e.nativeEvent;
    console.warn(`[Validation] ${type}: ${message}`, context);
  }}
  // ... other props
/>
```

### Customizing Colors and Card Dimensions

```tsx
<TvosSearchView
  textColor="#E5E5E5"
  accentColor="#E50914"
  cardWidth={420}
  cardHeight={240}
  // ... other props
/>
```

### Title Overlay Customization (v1.3.0+)

```tsx
<TvosSearchView
  overlayTitleSize={22}
  enableMarquee={true}
  marqueeDelay={1.5}
  // ... other props
/>
```

### Layout Spacing (v1.3.0+)

```tsx
<TvosSearchView
  cardMargin={60}
  cardPadding={25}
  // ... other props
/>
```

### Image Display Mode

```tsx
<TvosSearchView
  imageContentMode="fit"  // 'fill' (crop), 'fit'/'contain' (letterbox)
  // ... other props
/>
```

## TypeScript Support

The library provides comprehensive type definitions for all events and props.

### Event Types

```typescript
import type {
  SearchEvent,
  SelectItemEvent,
  SearchViewErrorEvent,
  ValidationWarningEvent,
  SearchResult,
} from 'expo-tvos-search';

// Search event - fired on text change
interface SearchEvent {
  nativeEvent: {
    query: string;
  };
}

// Selection event - fired when result is selected
interface SelectItemEvent {
  nativeEvent: {
    id: string;
  };
}

// Error event - fatal errors (v1.2.0+)
interface SearchViewErrorEvent {
  nativeEvent: {
    category: 'module_unavailable' | 'validation_failed' | 'image_load_failed' | 'unknown';
    message: string;
    context?: string;
  };
}

// Validation warning - non-fatal issues (v1.2.0+)
interface ValidationWarningEvent {
  nativeEvent: {
    type: 'field_truncated' | 'value_clamped' | 'url_invalid' | 'validation_failed';
    message: string;
    context?: string;
  };
}

// Search result shape
interface SearchResult {
  id: string;           // Required, max 500 chars
  title: string;        // Required, max 500 chars
  subtitle?: string;    // Optional, max 500 chars
  imageUrl?: string;    // Optional, HTTPS recommended
}
```

### Typed Usage

```typescript
const handleSearch = (event: SearchEvent) => {
  const query = event.nativeEvent.query;
  // TypeScript knows query is a string
};

const handleSelect = (event: SelectItemEvent) => {
  const id = event.nativeEvent.id;
  // TypeScript knows id is a string
};

const handleError = (event: SearchViewErrorEvent) => {
  const { category, message, context } = event.nativeEvent;
  // Full autocomplete for category values
  if (category === 'image_load_failed') {
    logger.warn(`Image failed to load: ${message}`, { context });
  }
};
```

## Demo Apps & Examples

### Official Demo App

**[expo-tvos-search-demo](https://github.com/keiver/expo-tvos-search-demo)** - Complete working examples with 7 different layout styles. Browse the [source code](https://github.com/keiver/expo-tvos-search-demo/tree/main/app/(tabs)) for each configuration.

### Apps Using This Library

**[Tomo TV](https://github.com/keiver/tomotv)** - Full-featured tvOS Jellyfin client
- Real-world integration with media library API
- Advanced search with live server calls
- Complete authentication and navigation flow

## See it in action:

<p align="center">
  <img src="screenshots/expo-tvos-search.gif" width="700" alt="expo-tvos-search screen in action" loading="lazy" />
</p>

## Props

### Core Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `results` | `SearchResult[]` | `[]` | Array of search results |
| `columns` | `number` | `5` | Number of columns in the grid |
| `placeholder` | `string` | `"Search movies and videos..."` | Search field placeholder |
| `isLoading` | `boolean` | `false` | Shows loading indicator |

### Card Dimensions & Spacing

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `cardWidth` | `number` | `280` | Width of each result card in points |
| `cardHeight` | `number` | `420` | Height of each result card in points |
| `cardMargin` | `number` | `40` | **(v1.3.0+)** Spacing between cards in the grid (horizontal and vertical) |
| `cardPadding` | `number` | `16` | **(v1.3.0+)** Padding inside the card for overlay content (title/subtitle) |
| `topInset` | `number` | `0` | Top padding (for tab bar clearance) |

### Display Options

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `showTitle` | `boolean` | `false` | Show title below each result |
| `showSubtitle` | `boolean` | `false` | Show subtitle below title |
| `showTitleOverlay` | `boolean` | `true` | Show title overlay with gradient at bottom of card |
| `showFocusBorder` | `boolean` | `false` | Show border on focused item |
| `imageContentMode` | `'fill' \| 'fit' \| 'contain'` | `'fill'` | How images fill the card: `fill` (crop to fill), `fit`/`contain` (letterbox) |

### Styling & Colors

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `textColor` | `string` | system default | Color for text and UI elements (hex format, e.g., "#FFFFFF") |
| `accentColor` | `string` | `"#FFC312"` | Accent color for focused elements (hex format, e.g., "#FFC312") |
| `overlayTitleSize` | `number` | `20` | **(v1.3.0+)** Font size for title text in the blur overlay (when showTitleOverlay is true) |

### Animation

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `enableMarquee` | `boolean` | `true` | Enable marquee scrolling for long titles |
| `marqueeDelay` | `number` | `1.5` | Delay in seconds before marquee starts |

### Text Customization

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `emptyStateText` | `string` | `"Search for movies and videos"` | Text shown when search field is empty |
| `searchingText` | `string` | `"Searching..."` | Text shown during search |
| `noResultsText` | `string` | `"No results found"` | Text shown when no results found |
| `noResultsHintText` | `string` | `"Try a different search term"` | Hint text below no results message |

### Event Handlers

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `onSearch` | `function` | required | Called when search text changes |
| `onSelectItem` | `function` | required | Called when result is selected |
| `onError` | `function` | optional | **(v1.2.0+)** Called when errors occur (image loading failures, validation errors) |
| `onValidationWarning` | `function` | optional | **(v1.2.0+)** Called for non-fatal warnings (truncated fields, clamped values, invalid URLs) |

### Other

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `style` | `ViewStyle` | optional | Style object for the view container |

## SearchResult Type

```typescript
interface SearchResult {
  id: string;
  title: string;
  subtitle?: string;
  imageUrl?: string;
}
```

## Result Handling

The native implementation applies the following validation and constraints:

- **Maximum results**: The results array is capped at 500 items. Any results beyond this limit are silently ignored.
- **Required fields**: Results with empty `id` or `title` are automatically filtered out and not displayed.
- **Image URL schemes**: Only HTTP and HTTPS URLs are accepted for `imageUrl`. Other URL schemes (e.g., `file://`, `data:`) are rejected.
- **HTTPS recommended**: HTTP URLs may be blocked by App Transport Security on tvOS unless explicitly allowed in Info.plist.

## Focus Handling - Do's and Don'ts

The native `.searchable` modifier manages focus automatically. Here's what to do and what to avoid:

### ✅ Do: Render directly in your screen

```tsx
function SearchScreen() {
  return (
    <TvosSearchView
      results={results}
      onSearch={handleSearch}
      onSelectItem={handleSelect}
      style={{ flex: 1 }}
    />
  );
}
```

### ❌ Don't: Wrap in focusable containers

```tsx
// ❌ WRONG - breaks focus navigation
function SearchScreen() {
  return (
    <Pressable>  {/* Don't wrap in Pressable */}
      <TvosSearchView ... />
    </Pressable>
  );
}

// ❌ WRONG - interferes with native focus
function SearchScreen() {
  return (
    <TouchableOpacity>  {/* Don't wrap in TouchableOpacity */}
      <TvosSearchView ... />
    </TouchableOpacity>
  );
}
```

**Why this breaks**: Focusable wrappers steal focus from the native SwiftUI search container, which breaks directional navigation.

### ✅ Do: Use non-interactive containers

```tsx
// ✅ CORRECT - View is not focusable
function SearchScreen() {
  return (
    <View style={{ flex: 1, backgroundColor: '#000' }}>
      <TvosSearchView ... />
    </View>
  );
}

// ✅ CORRECT - SafeAreaView is not focusable
function SearchScreen() {
  return (
    <SafeAreaView style={{ flex: 1 }}>
      <TvosSearchView ... />
    </SafeAreaView>
  );
}
```

## Troubleshooting

### Native module not found

If you see `requireNativeViewManager("ExpoTvosSearch") returned null`, the native module hasn't been built:

```bash
# Clean and rebuild with tvOS support
EXPO_TV=1 npx expo prebuild --clean
npx expo run:ios
```

**Note:** Expo Go doesn't support this. Build a dev client or native build instead.

### Images not loading

1. Verify your image URLs are HTTPS (HTTP may be blocked by App Transport Security)
2. Ensure required authentication parameters are included in image URLs
3. For local development, ensure your server is accessible from the Apple TV

### Focus issues

If focus doesn't move correctly:

1. Ensure `columns` prop matches your layout (default: 5)
2. Check `topInset` if the first row is hidden under the tab bar
3. The native `.searchable` modifier handles focus automatically - avoid wrapping in focusable containers

### Marquee not scrolling

If long titles don't scroll when focused:

1. Verify `enableMarquee={true}` (default)
2. Check `marqueeDelay` - scrolling starts after this delay (default: 1.5s)
3. Text only scrolls if it overflows the card width

## Testing

Run TypeScript tests:

```bash
npm test                # Run tests once
npm run test:watch      # Watch mode
npm run test:coverage   # Generate coverage report
```

Tests cover:
- `isNativeSearchAvailable()` behavior on different platforms
- Component rendering when native module is unavailable
- Event structure validation

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Code of conduct
- Development setup
- Testing requirements
- Commit message conventions
- Pull request process

### Adding New Props

If you're adding new props to the library, follow the comprehensive checklist in [CLAUDE-adding-new-props.md](./CLAUDE-adding-new-props.md). This memory bank provides a 9-step guide ensuring props are properly wired from TypeScript through to Swift rendering.

## License

MIT