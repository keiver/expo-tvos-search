import React from "react";
import type { ViewStyle } from "react-native";
import { Platform } from "react-native";

/**
 * Event payload for search text changes.
 * Fired when the user types in the native search field.
 */
export interface SearchEvent {
  nativeEvent: {
    /** The current search query string entered by the user */
    query: string;
  };
}

/**
 * Event payload for item selection.
 * Fired when the user selects a search result.
 */
export interface SelectItemEvent {
  nativeEvent: {
    /** The unique identifier of the selected search result */
    id: string;
  };
}

/**
 * Event payload for a long press on a result.
 * Fired when the user holds the select button on the focused card.
 */
export interface LongSelectItemEvent {
  nativeEvent: {
    /** The unique identifier of the long pressed search result */
    id: string;
  };
}

/**
 * Categories of errors that can occur in the search view.
 */
export type SearchViewErrorCategory =
  | "module_unavailable"
  | "validation_failed"
  | "image_load_failed"
  | "unknown";

/**
 * Event payload for error callbacks.
 * Provides details about errors that occur during search view operations.
 */
export interface SearchViewErrorEvent {
  nativeEvent: {
    /** Category of the error for programmatic handling */
    category: SearchViewErrorCategory;
    /** Human-readable error message */
    message: string;
    /** Optional additional context (e.g., result ID, URL) */
    context?: string;
  };
}

/**
 * Event payload for validation warnings.
 * Non-fatal issues like truncated fields or clamped values.
 */
export interface ValidationWarningEvent {
  nativeEvent: {
    /** Type of validation warning */
    type: "field_truncated" | "value_clamped" | "value_truncated" | "results_truncated" | "url_invalid" | "url_insecure" | "validation_failed";
    /** Human-readable warning message */
    message: string;
    /** Optional additional context */
    context?: string;
  };
}

/**
 * Event payload for search field focus changes.
 * Fired when the native search field gains or loses focus.
 * Useful for managing RN gesture handlers via TVEventControl.
 */
export interface SearchFieldFocusEvent {
  nativeEvent: Record<string, never>;
}

/**
 * Event payload for the results region's size.
 * Fired when the area the children are drawn in changes size.
 */
export interface ContentLayoutEvent {
  nativeEvent: {
    /** Region width in points */
    width: number;
    /** Region height in points */
    height: number;
  };
}

/**
 * Represents a single search result displayed in the grid.
 */
export interface SearchResult {
  /** Unique identifier for the result (used in onSelectItem callback) */
  id: string;
  /** Primary display text for the result */
  title: string;
  /** Optional secondary text displayed below the title */
  subtitle?: string;
  /** Optional image URL for the result poster/thumbnail. Supports HTTPS, HTTP, file://, and data: URIs */
  imageUrl?: string;
}

/**
 * Props for the TvosSearchView component.
 *
 * @example
 * ```tsx
 * <TvosSearchView
 *   results={searchResults}
 *   columns={5}
 *   placeholder="Search..."
 *   isLoading={loading}
 *   topInset={140}
 *   onSearch={(e) => handleSearch(e.nativeEvent.query)}
 *   onSelectItem={(e) => navigateTo(e.nativeEvent.id)}
 *   style={{ flex: 1 }}
 * />
 * ```
 */
export interface TvosSearchViewProps {
  /**
   * Array of search results to display in the grid.
   * Each result should have a unique `id`.
   * Arrays larger than 500 items are truncated.
   * Results with empty `id` or `title` are skipped.
   * @maximum 500
   */
  results: SearchResult[];

  /**
   * Number of columns in the results grid.
   * Values outside 1-10 range are clamped.
   * @default 5
   * @minimum 1
   * @maximum 10
   */
  columns?: number;

  /**
   * Placeholder text shown in the search field when empty.
   * @default "Search..."
   */
  placeholder?: string;

  /**
   * Programmatically set the search field text.
   * Works like React Native TextInput's `value` + `onChangeText` pattern.
   * Useful for restoring search state, deep links, or "search for similar" flows.
   *
   * **Warning:** Avoid setting `searchText` inside your `onSearch` handler with
   * transforms (e.g., trimming, lowercasing). The native guard only prevents
   * same-value loops, so transformed values will trigger a new `onSearch` event,
   * creating an infinite update cycle.
   */
  searchText?: string;

  /**
   * Whether to show a loading indicator.
   * @default false
   */
  isLoading?: boolean;

  /**
   * Show title text below each result card.
   * @default false
   */
  showTitle?: boolean;

  /**
   * Show subtitle text below title.
   * Requires `showTitle` to be true to be visible.
   * @default false
   */
  showSubtitle?: boolean;

  /**
   * Show gold border on focused card.
   * @default false
   */
  showFocusBorder?: boolean;

  /**
   * Extra top padding in points for tab bar clearance.
   * Useful when the view is displayed under a navigation bar.
   * Values outside 0-500 range are clamped.
   * @default 0
   * @minimum 0
   * @maximum 500
   */
  topInset?: number;

  /**
   * Show title overlay with gradient at bottom of card.
   * This displays the title on top of the image.
   * @default true
   */
  showTitleOverlay?: boolean;

  /**
   * Enable marquee scrolling for long titles that overflow the card width.
   * @default true
   */
  enableMarquee?: boolean;

  /**
   * Delay in seconds before marquee starts scrolling when item is focused.
   * Values outside 0-60 range are clamped.
   * @default 1.5
   * @minimum 0
   * @maximum 60
   */
  marqueeDelay?: number;

  /**
   * Text displayed when the search field is empty and no results are shown.
   * @default "Search your library"
   */
  emptyStateText?: string;

  /**
   * Text displayed while searching (when loading with no results yet).
   * @default "Searching..."
   */
  searchingText?: string;

  /**
   * Text displayed when search returns no results.
   * @default "No results found"
   */
  noResultsText?: string;

  /**
   * Hint text displayed below the no results message.
   * @default "Try a different search term"
   */
  noResultsHintText?: string;

  /**
   * Color for text and UI elements in the search interface.
   * Hex color string (e.g., "#FFFFFF", "#E5E5E5").
   * @default Uses system default based on userInterfaceStyle
   * @example "#E5E5E5" for light gray text on dark background
   */
  textColor?: string;

  /**
   * Accent color for focused elements and highlights.
   * Hex color string (e.g., "#FFC312").
   * @default "#FFC312" (gold)
   * @example "#E50914" for Netflix red
   */
  accentColor?: string;

  /**
   * Override the system color scheme for the search view.
   * - `'dark'`: Force dark appearance (white text, dark UI elements)
   * - `'light'`: Force light appearance (black text, light UI elements)
   * - `'system'`: Follow the system appearance (default)
   *
   * Useful when your app has a fixed dark background and the system is in
   * light mode, which would make search bar text illegible.
   * @default "system"
   */
  colorScheme?: 'light' | 'dark' | 'system';

  /**
   * Width of each result card in points.
   * Allows customization for portrait, landscape, or square layouts.
   * Values outside 50-1000 range are clamped.
   * @default 280
   * @minimum 50
   * @maximum 1000
   * @example 420 for landscape cards
   */
  cardWidth?: number;

  /**
   * Height of each result card in points.
   * Allows customization for portrait, landscape, or square layouts.
   * Values outside 50-1000 range are clamped.
   * @default 420
   * @minimum 50
   * @maximum 1000
   * @example 240 for landscape cards (16:9 ratio with width=420)
   */
  cardHeight?: number;

  /**
   * How the image fills the card area.
   * - 'fill': Image fills entire card, may crop (default)
   * - 'fit': Image fits within card, may show letterboxing
   * - 'contain': Same as fit (alias for consistency)
   * @default "fill"
   */
  imageContentMode?: 'fill' | 'fit' | 'contain';

  /**
   * Spacing between cards in the grid layout (both horizontal and vertical).
   * Values outside 0-200 range are clamped.
   * @default 40
   * @minimum 0
   * @maximum 200
   * @example 60 for spacious layouts, 20 for compact grids
   */
  cardMargin?: number;

  /**
   * Padding inside the card for overlay content (title, subtitle).
   * Values outside 0-100 range are clamped.
   * @default 16
   * @minimum 0
   * @maximum 100
   * @example 20 for more breathing room, 12 for compact cards
   */
  cardPadding?: number;

  /**
   * Font size for title in the blur overlay (when showTitleOverlay is true).
   * Allows customization of overlay text size for different card layouts.
   * Values outside 8-72 range are clamped.
   * @default 20
   * @minimum 8
   * @maximum 72
   * @example 18 for smaller cards, 24 for larger cards
   */
  overlayTitleSize?: number;

  /**
   * Corner radius of the card in points.
   * When `showTitle` or `showSubtitle` is set, only the top corners are rounded
   * (the text block below the image continues the card).
   * Values outside 0-100 range are clamped.
   * @default 12
   * @minimum 0
   * @maximum 100
   * @example 32 for heavily rounded cards
   */
  cardCornerRadius?: number;

  /**
   * Background color shown behind the image while it loads, and wherever the
   * image does not cover the card (letterboxing with `imageContentMode="fit"`).
   * Hex color string.
   * @default Dark gray (20% white)
   * @example "#1C1C1E"
   */
  cardBackgroundColor?: string;

  /**
   * Border width in points drawn on every card, focused or not.
   * The border is drawn inside the card bounds, like a CSS `border-box` border.
   * Values outside 0-20 range are clamped.
   * @default 0 (no resting border)
   * @minimum 0
   * @maximum 20
   * @example 2 for a subtle outline on every card
   */
  borderWidth?: number;

  /**
   * Color of the resting border drawn by `borderWidth`.
   * Hex color string. Supports 8-digit `AARRGGBB` for translucency.
   * @default Transparent
   * @example "#26FFFFFF" for rgba(255, 255, 255, 0.15)
   */
  borderColor?: string;

  /**
   * Border width in points for the focused card, used when `showFocusBorder`
   * is true. Drawn inside the card bounds, replacing the resting border.
   * Values outside 0-20 range are clamped.
   * @default 4
   * @minimum 0
   * @maximum 20
   */
  focusBorderWidth?: number;

  /**
   * How the card reacts to focus.
   * - `'system'`: tvOS card button style, giving Apple's lift, parallax, and shadow
   * - `'custom'`: no system effect; only `focusScale`, the focus border, and
   *   the focus glow are applied. Use this to match a custom JS card exactly.
   *
   * Ignored on tvOS 16 and earlier, which always uses the custom path because
   * the system card style conflicts with React Native's remote gesture handler.
   * @default "system"
   */
  focusStyle?: 'system' | 'custom';

  /**
   * Scale applied to the focused card when `focusStyle` is `'custom'`.
   *
   * This is the only lift available on that path, and tvOS 16 and earlier always
   * take it because the system card style is unusable there. Without it a focused
   * card on tvOS 16 has no depth cue beyond its border.
   *
   * Values outside 1-1.5 range are clamped.
   * @default 1 (no scaling)
   * @minimum 1
   * @maximum 1.5
   * @example 1.05 for a subtle lift
   */
  focusScale?: number;

  /**
   * Color of the glow drawn around the focused card.
   * Hex color string. Has no effect unless `focusGlowRadius` is greater than 0.
   * @default Uses `accentColor`
   * @example "#FFC312"
   */
  focusGlowColor?: string;

  /**
   * Opacity of the focus glow.
   * Values outside 0-1 range are clamped.
   * @default 0.55
   * @minimum 0
   * @maximum 1
   */
  focusGlowOpacity?: number;

  /**
   * Blur radius of the focus glow in points. Set to 0 to disable the glow.
   * Values outside 0-60 range are clamped.
   * @default 0 (no glow)
   * @minimum 0
   * @maximum 60
   * @example 7 for a tight backlight
   */
  focusGlowRadius?: number;

  /**
   * Background color of the title overlay (when `showTitleOverlay` is true).
   * Hex color string. Supports 8-digit `AARRGGBB` for translucency.
   * @default A native blur material
   * @example "#B3000000" for a dark translucent bar
   */
  overlayBackgroundColor?: string;

  /**
   * Text color of the title overlay.
   * Hex color string.
   * @default "#FFFFFF"
   */
  overlayTextColor?: string;

  /**
   * Background color of the title overlay while the card is focused.
   * Hex color string.
   * @default Falls back to `overlayBackgroundColor`
   * @example "#FFC312" to flip the bar to the accent color on focus
   */
  overlayBackgroundColorFocused?: string;

  /**
   * Text color of the title overlay while the card is focused.
   * Hex color string.
   * @default Falls back to `overlayTextColor`
   * @example "#2B1F05" for dark text on a gold focused bar
   */
  overlayTextColorFocused?: string;

  /**
   * Font weight for the title in the overlay.
   * @default "semibold"
   */
  overlayTitleWeight?: 'regular' | 'medium' | 'semibold' | 'bold' | 'heavy';

  /**
   * Height of the title overlay in points.
   * Values outside 0-500 range are clamped.
   * @default 25% of `cardHeight`
   * @minimum 0
   * @maximum 500
   * @example 46 for a thin title sliver
   */
  overlayHeight?: number;

  /**
   * Marquee scroll speed in points per second.
   * Values outside 5-300 range are clamped.
   * @default 30
   * @minimum 5
   * @maximum 300
   */
  marqueeSpeed?: number;

  /**
   * How the marquee scrolls long titles.
   * - `'loop'`: the title scrolls left continuously, repeating seamlessly
   * - `'bounce'`: the title scrolls to the end, pauses, then scrolls back
   * @default "loop"
   */
  marqueeMode?: 'loop' | 'bounce';

  /**
   * Fire `onLongSelectItem` when the select button is held on the focused card.
   * The select that ends the hold is swallowed, so a long press never also selects.
   * @default false
   */
  enableLongPress?: boolean;

  /**
   * Callback fired when the search text changes.
   * Debounce this handler to avoid excessive API calls.
   *
   * **Note:** If using the `searchText` prop, do not set it to a transformed
   * value inside this handler. See the `searchText` docs for loop prevention.
   */
  onSearch: (event: SearchEvent) => void;

  /**
   * Callback fired when a search result is selected.
   * Use the `id` from the event to identify which result was selected.
   */
  onSelectItem: (event: SelectItemEvent) => void;

  /**
   * Optional callback fired when the select button is held on the focused card.
   * Requires `enableLongPress`. Use it for a context panel or item actions.
   * @example
   * ```tsx
   * enableLongPress
   * onLongSelectItem={(e) => router.push(`/info/${e.nativeEvent.id}`)}
   * ```
   */
  onLongSelectItem?: (event: LongSelectItemEvent) => void;

  /**
   * Optional callback fired when errors occur.
   * Use this to monitor and log issues in production.
   * @example
   * ```tsx
   * onError={(e) => {
   *   const { category, message, context } = e.nativeEvent;
   *   logger.error(`Search error [${category}]: ${message}`, { context });
   * }}
   * ```
   */
  onError?: (event: SearchViewErrorEvent) => void;

  /**
   * Optional callback fired for non-fatal validation warnings.
   * Examples: truncated fields, clamped values, invalid URLs.
   * @example
   * ```tsx
   * onValidationWarning={(e) => {
   *   const { type, message } = e.nativeEvent;
   *   console.warn(`Validation warning [${type}]: ${message}`);
   * }}
   * ```
   */
  onValidationWarning?: (event: ValidationWarningEvent) => void;

  /**
   * Optional callback fired when the native search field gains focus.
   * Use this to disable RN gesture handlers via TVEventControl if the
   * automatic gesture handling doesn't work on your device.
   *
   * @example
   * ```tsx
   * import { TVEventControl } from 'react-native';
   *
   * onSearchFieldFocused={() => {
   *   TVEventControl.disableGestureHandlersCancelTouches();
   * }}
   * ```
   */
  onSearchFieldFocused?: (event: SearchFieldFocusEvent) => void;

  /**
   * Optional callback fired when the native search field loses focus.
   * Use this to re-enable RN gesture handlers via TVEventControl if you
   * disabled them in onSearchFieldFocused.
   *
   * @example
   * ```tsx
   * import { TVEventControl } from 'react-native';
   *
   * onSearchFieldBlurred={() => {
   *   TVEventControl.enableGestureHandlersCancelTouches();
   * }}
   * ```
   */
  onSearchFieldBlurred?: (event: SearchFieldFocusEvent) => void;

  /**
   * Fired with the results region's size in points whenever it changes, and only while children
   * are rendered. React sizes your children against the whole native view, which is larger than
   * the region they are drawn in, so size your subtree from this to keep its layout honest.
   *
   * @example
   * ```tsx
   * onContentLayout={(e) => setRegion(e.nativeEvent)}
   * ```
   */
  onContentLayout?: (event: ContentLayoutEvent) => void;

  /**
   * Optional style for the view container.
   */
  style?: ViewStyle;

  /**
   * Render your own results region. When children are passed they fill the area the built-in
   * grid would occupy, and `results` along with the grid's card, column, and state-text props
   * stop having any effect. Focus, select, and scrolling inside the children behave as they do
   * anywhere else in your app.
   *
   * Pass a single view and lay out inside it; multiple children are stacked, each filling the
   * region.
   *
   * @example
   * ```tsx
   * <TvosSearchView onSearch={handleSearch} onSelectItem={() => {}}>
   *   <MyResultsGrid items={items} />
   * </TvosSearchView>
   * ```
   */
  children?: React.ReactNode;
}

/**
 * Native view component loaded at module initialization.
 * Returns null on non-tvOS platforms or when the native module is unavailable.
 */
let NativeView: React.ComponentType<TvosSearchViewProps> | null = null;

if (Platform.OS === "ios" && Platform.isTV) {
  try {
    const { requireNativeViewManager } = require("expo-modules-core");
    if (typeof requireNativeViewManager === "function") {
      NativeView = requireNativeViewManager("ExpoTvosSearch");
    } else {
      console.warn(
        "[expo-tvos-search] requireNativeViewManager is not a function. " +
          "This usually indicates an incompatible expo-modules-core version. " +
          "Try reinstalling expo-modules-core or updating to a compatible version."
      );
    }
  } catch (error) {
    // Categorize the error to help with debugging
    const errorMessage = error instanceof Error ? error.message : String(error);

    if (errorMessage.includes("expo-modules-core")) {
      console.warn(
        "[expo-tvos-search] Failed to load expo-modules-core. " +
          "Make sure expo-modules-core is installed: npm install expo-modules-core\n" +
          `Error: ${errorMessage}`
      );
    } else if (errorMessage.includes("ExpoTvosSearch")) {
      console.warn(
        "[expo-tvos-search] Native module ExpoTvosSearch not found. " +
          "This usually means:\n" +
          "1. You haven't run 'expo prebuild' yet, or\n" +
          "2. The native project needs to be rebuilt (try 'expo prebuild --clean')\n" +
          "3. You're not running on a tvOS simulator/device\n" +
          `Error: ${errorMessage}`
      );
    } else {
      // Unexpected error - log full details for debugging
      console.warn(
        "[expo-tvos-search] Unexpected error loading native module.\n" +
          `Error: ${errorMessage}\n` +
          "Please report this issue at: https://github.com/keiver/expo-tvos-search/issues"
      );

      // In development, log the full error for debugging
      if (typeof __DEV__ !== "undefined" && __DEV__) {
        console.error("[expo-tvos-search] Full error details:", error);
      }
    }
  }
}

/**
 * Native tvOS search view component using SwiftUI's `.searchable` modifier.
 *
 * This component provides a native search experience on tvOS with proper focus
 * handling and keyboard navigation. On non-tvOS platforms or when the native
 * module is unavailable, it renders `null` - use `isNativeSearchAvailable()`
 * to check availability and render a fallback.
 *
 * @example
 * ```tsx
 * import { TvosSearchView, isNativeSearchAvailable } from 'expo-tvos-search';
 *
 * function SearchScreen() {
 *   const [results, setResults] = useState<SearchResult[]>([]);
 *
 *   if (!isNativeSearchAvailable()) {
 *     return <FallbackSearchComponent />;
 *   }
 *
 *   return (
 *     <TvosSearchView
 *       results={results}
 *       onSearch={(e) => fetchResults(e.nativeEvent.query)}
 *       onSelectItem={(e) => router.push(`/detail/${e.nativeEvent.id}`)}
 *       style={{ flex: 1 }}
 *     />
 *   );
 * }
 * ```
 *
 * @param props - Component props
 * @returns The native search view on tvOS, or `null` if unavailable
 */
export function TvosSearchView(props: TvosSearchViewProps): JSX.Element | null {
  if (!NativeView) {
    // Warn in development when native module is unavailable
    if (typeof __DEV__ !== "undefined" && __DEV__) {
      const isRunningOnTvOS = Platform.OS === "ios" && Platform.isTV;

      if (isRunningOnTvOS) {
        // On tvOS but module failed to load - this is unexpected
        console.warn(
          "[expo-tvos-search] TvosSearchView is rendering null on tvOS. " +
            "This usually means:\n" +
            "1. The native module wasn't built properly (try 'expo prebuild --clean')\n" +
            "2. expo-modules-core is missing or incompatible\n" +
            "3. The app needs to be restarted after installing the module\n\n" +
            "Check the earlier console logs for specific error details."
        );
      } else {
        // Not on tvOS - expected behavior, but developer might want to know
        console.info(
          "[expo-tvos-search] TvosSearchView is not available on " +
            `${Platform.OS}${Platform.isTV ? " (TV)" : ""}. ` +
            "Use isNativeSearchAvailable() to check before rendering this component."
        );
      }
    }
    return null;
  }
  return <NativeView {...props} />;
}

/**
 * Checks if the native tvOS search component is available.
 *
 * Returns `true` only when:
 * - Running on tvOS (Platform.OS === "ios" && Platform.isTV)
 * - The native module has been built (via `expo prebuild`)
 * - expo-modules-core is properly installed
 *
 * Use this to conditionally render a fallback search implementation
 * on non-tvOS platforms or when the native module is unavailable.
 *
 * @returns `true` if TvosSearchView will render, `false` if it will return null
 *
 * @example
 * ```tsx
 * if (!isNativeSearchAvailable()) {
 *   return <ReactNativeSearchFallback />;
 * }
 * return <TvosSearchView {...props} />;
 * ```
 */
export function isNativeSearchAvailable(): boolean {
  return NativeView !== null;
}
