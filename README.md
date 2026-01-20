# expo-tvos-search

[![npm version](https://img.shields.io/npm/v/expo-tvos-search.svg)](https://www.npmjs.com/package/expo-tvos-search)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Test Status](https://github.com/keiver/expo-tvos-search/workflows/Test%20PR/badge.svg)](https://github.com/keiver/expo-tvos-search/actions)

A native tvOS search component for Expo and React Native using SwiftUI's `.searchable` modifier. Handles focus, keyboard navigation, and accessibility out of the box.

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
npx expo install expo-tvos-search
```

Or install from GitHub:

```bash
npx expo install github:keiver/expo-tvos-search
```

Then rebuild your native project:

```bash
EXPO_TV=1 npx expo prebuild --clean
npx expo run:ios
```

## Prerequisites for tvOS Builds (Expo)

This package only provides the search UI module. To actually build and run an Expo app on tvOS, your project must be configured for React Native tvOS.

**Quick Checklist:**

- ✅ `react-native-tvos` in use
- ✅ `@react-native-tvos/config-tv` installed + added to Expo plugins
- ✅ Run prebuild with `EXPO_TV=1`

### 1. Use the React Native tvOS fork

React Native tvOS support comes from the [react-native-tvos](https://github.com/react-native-tvos/react-native-tvos) fork (not upstream `react-native`). For tvOS builds, your app should use the tvOS fork version that matches your Expo / React Native version.

**Tip:** Pick the `react-native-tvos` version that corresponds to your React Native major/minor (e.g., RN 0.7x → compatible `react-native-tvos` for the same RN line). If versions don't match, you'll usually see native build or runtime errors.

### 2. Install the tvOS config plugin

Expo needs a config plugin to generate tvOS-compatible native projects during prebuild.

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

When generating iOS/tvOS native projects, set the tvOS flag:

```bash
EXPO_TV=1 npx expo prebuild --clean
```

Then run:

```bash
npx expo run:ios
```

### 4. Common gotchas

- **Prebuild must be re-run** if you add/remove tvOS dependencies or change the tvOS plugin configuration.
- **If you see App Transport Security errors** for images, ensure your `imageUrl` uses `https://` (recommended) or add the appropriate ATS exceptions.
- **If the tvOS keyboard/search UI doesn't appear**, confirm you're actually running a tvOS target/simulator, not an iOS target.

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
| `emptyStateText` | `string` | `"Search for movies and videos"` | Text shown when search field is empty |
| `searchingText` | `string` | `"Searching..."` | Text shown during search |
| `noResultsText` | `string` | `"No results found"` | Text shown when no results found |
| `noResultsHintText` | `string` | `"Try a different search term"` | Hint text below no results message |
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

## Requirements

- Node.js 18.0+
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

## License

MIT