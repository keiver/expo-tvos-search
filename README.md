# expo-tvos-search

[![npm version](https://img.shields.io/npm/v/expo-tvos-search.svg)](https://www.npmjs.com/package/expo-tvos-search)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Test Status](https://github.com/keiver/expo-tvos-search/workflows/Test%20PR/badge.svg)](https://github.com/keiver/expo-tvos-search/actions)

A native tvOS search component for Expo and React Native.

This library provides a native tvOS search view using SwiftUI's `.searchable` modifier. It handles focus, keyboard navigation, and accessibility out of the box, providing a seamless search experience on Apple TV with a native fullscreen search interface.

<p align="center">
  <img src="screenshots/results.png" width="700" alt="TomoTV Search Results"/>
</p>

<table>
  <tr>
    <td align="center">
      <img src="screenshots/default.png" width="280" alt="Search"/><br/>
      <sub>Native Search</sub>
    </td>
    <td align="center">
      <img src="screenshots/results.png" width="280" alt="Results"/><br/>
      <sub>Results</sub>
    </td>
    <td align="center">
      <img src="screenshots/no-results.png" width="280" alt="No Results"/><br/>
      <sub>Empty State</sub>
    </td>
  </tr>
</table>


## Installation

```bash
npm install expo-tvos-search
```

Or install from GitHub:

```bash
npm install github:keiver/expo-tvos-search
```

Then rebuild your native project:

```bash
EXPO_TV=1 npx expo prebuild --clean
npx expo run:ios
```

## Usage

```tsx
import { TvosSearchView, isNativeSearchAvailable } from 'expo-tvos-search';

function SearchScreen() {
  const [results, setResults] = useState([]);
  const [isLoading, setIsLoading] = useState(false);

  const handleSearch = (event) => {
    const query = event.nativeEvent.query;
    // Fetch your results...
  };

  const handleSelect = (event) => {
    const id = event.nativeEvent.id;
    // Navigate to detail...
  };

  if (!isNativeSearchAvailable()) {
    return <YourFallbackSearch />;
  }

  return (
    <TvosSearchView
      results={results}
      columns={5}
      placeholder="Search..."
      isLoading={isLoading}
      topInset={140}
      onSearch={handleSearch}
      onSelectItem={handleSelect}
      style={{ flex: 1 }}
    />
  );
}
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `results` | `SearchResult[]` | `[]` | Array of search results |
| `columns` | `number` | `5` | Number of columns in the grid |
| `placeholder` | `string` | `"Search..."` | Search field placeholder |
| `isLoading` | `boolean` | `false` | Shows loading indicator |
| `showTitle` | `boolean` | `false` | Show title below each result |
| `showSubtitle` | `boolean` | `false` | Show subtitle below title |
| `showFocusBorder` | `boolean` | `false` | Show border on focused item |
| `topInset` | `number` | `0` | Top padding (for tab bar clearance) |
| `showTitleOverlay` | `boolean` | `true` | Show title overlay with gradient at bottom of card |
| `enableMarquee` | `boolean` | `true` | Enable marquee scrolling for long titles |
| `marqueeDelay` | `number` | `1.5` | Delay in seconds before marquee starts |
| `onSearch` | `function` | required | Called when search text changes |
| `onSelectItem` | `function` | required | Called when result is selected |

## SearchResult Type

```typescript
interface SearchResult {
  id: string;
  title: string;
  subtitle?: string;
  imageUrl?: string;
}
```

## Requirements

- Expo SDK 51+
- tvOS 15.0+
- React Native TVOS

## Troubleshooting

### Native module not found

If you see `requireNativeViewManager("ExpoTvosSearch") returned null`, the native module hasn't been built:

```bash
# Clean and rebuild with tvOS support
EXPO_TV=1 npx expo prebuild --clean
npx expo run:ios
```

### Images not loading

1. Verify your image URLs are HTTPS (HTTP may be blocked by App Transport Security)
2. Check that the Jellyfin API key is included in the URL query parameters
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

### Best Practices

For optimal performance:
- **Debounce search input**: Wait 300-500ms after typing stops before calling your API
- **Batch result updates**: Update the entire `results` array at once rather than incrementally
- **Limit image sizes**: Use appropriately sized poster images (280x420 is the card size)
- **Cap result count**: Consider limiting to 50-100 results for smooth scrolling

## Accessibility

### Built-in Support

The native SwiftUI implementation provides accessibility features automatically:
- **Focus management**: tvOS focus system handles navigation
- **VoiceOver**: Cards announce title and subtitle
- **Button semantics**: Cards are properly identified as interactive elements
- **Focus indicators**: Visual feedback for focused state

### Remote Navigation

The native `.searchable` modifier provides standard tvOS navigation:
- **Swipe up/down**: Move between search field and results
- **Swipe left/right**: Navigate between grid items
- **Click (select)**: Open the focused result
- **Menu button**: Exit search or navigate back

Built for [TomoTV](https://github.com/keiver/tomotv), a Jellyfin client for Apple TV.

Swift documentation references:
- [.searchable modifier](https://developer.apple.com/documentation/SwiftUI/Creating-a-tvOS-media-catalog-app-in-SwiftUI)

## License

MIT