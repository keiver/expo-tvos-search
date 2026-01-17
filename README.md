# expo-tvos-search

A native tvOS search component for Expo and React Native.

Built because React Native's TextInput + FlatList has focus navigation issues on tvOS. This module uses SwiftUI's `.searchable` modifier, which handles focus and keyboard navigation the way Apple intended.

## The Problem

If you've tried building a search screen on tvOS with React Native, you've likely hit these issues:

- Can't move focus from TextInput to FlatList results
- `nextFocusDown` doesn't work reliably with `numColumns > 1`
- Focus gets lost after selecting a result

## The Solution

This module provides a native SwiftUI view with proper tvOS focus handling out of the box.

## Installation

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

## License

MIT

## Author

[Keiver Hernandez](https://github.com/keiver)

---

Built for [TomoTV](https://github.com/keiver/tomotv), a Jellyfin client for Apple TV.

---

Swift documentation references
- [.searchable modifier](https://developer.apple.com/documentation/SwiftUI/Creating-a-tvOS-media-catalog-app-in-SwiftUI)