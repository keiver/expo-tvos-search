import { ViewStyle, Platform } from "react-native";

export interface SearchResult {
  id: string;
  title: string;
  subtitle?: string;
  imageUrl?: string;
}

export interface TvosSearchViewProps {
  results: SearchResult[];
  columns?: number;
  placeholder?: string;
  isLoading?: boolean;
  /** Show title text below each result card (default: false) */
  showTitle?: boolean;
  /** Show subtitle text below title (default: false) */
  showSubtitle?: boolean;
  /** Show gold border on focused card (default: false) */
  showFocusBorder?: boolean;
  /** Extra top padding in points for tab bar clearance (default: 0) */
  topInset?: number;
  /** Show title overlay at bottom of card with gradient (default: true) */
  showTitleOverlay?: boolean;
  /** Enable marquee scrolling for long titles (default: true) */
  enableMarquee?: boolean;
  /** Delay in seconds before marquee starts scrolling (default: 1.5) */
  marqueeDelay?: number;
  onSearch: (event: { nativeEvent: { query: string } }) => void;
  onSelectItem: (event: { nativeEvent: { id: string } }) => void;
  style?: ViewStyle;
}

// Safely try to load the native view - it may not be available if:
// 1. Running on a non-tvOS platform
// 2. Native module hasn't been built yet (needs expo prebuild)
// 3. expo-modules-core isn't properly installed
let NativeView: React.ComponentType<TvosSearchViewProps> | null = null;

if (Platform.OS === "ios" && Platform.isTV) {
  try {
    const { requireNativeViewManager } = require("expo-modules-core");
    if (typeof requireNativeViewManager === "function") {
      NativeView = requireNativeViewManager("ExpoTvosSearch");
    }
  } catch {
    // Native module not available - will fall back to React Native implementation
  }
}

export function TvosSearchView(props: TvosSearchViewProps) {
  if (!NativeView) {
    return null;
  }
  return <NativeView {...props} />;
}

export function isNativeSearchAvailable(): boolean {
  return NativeView !== null;
}
