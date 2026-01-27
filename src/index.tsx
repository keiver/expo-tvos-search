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
 * Represents a single search result displayed in the grid.
 */
export interface SearchResult {
  /** Unique identifier for the result (used in onSelectItem callback) */
  id: string;
  /** Primary display text for the result */
  title: string;
  /** Optional secondary text displayed below the title */
  subtitle?: string;
  /** Optional image URL for the result poster/thumbnail. Supports HTTPS, HTTP, and data: URIs */
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
   * same-value loops — transformed values will trigger a new `onSearch` event,
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
   * Width of each result card in points.
   * Allows customization for portrait, landscape, or square layouts.
   * @default 280
   * @example 420 for landscape cards
   */
  cardWidth?: number;

  /**
   * Height of each result card in points.
   * Allows customization for portrait, landscape, or square layouts.
   * @default 420
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
   * @default 40
   * @example 60 for spacious layouts, 20 for compact grids
   */
  cardMargin?: number;

  /**
   * Padding inside the card for overlay content (title, subtitle).
   * @default 16
   * @example 20 for more breathing room, 12 for compact cards
   */
  cardPadding?: number;

  /**
   * Font size for title in the blur overlay (when showTitleOverlay is true).
   * Allows customization of overlay text size for different card layouts.
   * @default 20
   * @example 18 for smaller cards, 24 for larger cards
   */
  overlayTitleSize?: number;

  /**
   * Callback fired when the search text changes.
   * Debounce this handler to avoid excessive API calls.
   *
   * **Note:** If using the `searchText` prop, do not set it to a transformed
   * value inside this handler — see `searchText` docs for loop prevention.
   */
  onSearch: (event: SearchEvent) => void;

  /**
   * Callback fired when a search result is selected.
   * Use the `id` from the event to identify which result was selected.
   */
  onSelectItem: (event: SelectItemEvent) => void;

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
   * Optional style for the view container.
   */
  style?: ViewStyle;
}

/**
 * Native module for imperative calls.
 * Loaded once at module initialization on tvOS only.
 */
let NativeModule: {
  restoreTVFocus(): void;
  enableFocusDebugging(): void;
  disableFocusDebugging(): void;
  logFocusState(): void;
} | null = null;

if (Platform.OS === "ios" && Platform.isTV) {
  try {
    const { requireNativeModule } = require("expo-modules-core");
    NativeModule = requireNativeModule("ExpoTvosSearch");
  } catch {
    // Module unavailable — restoreTVFocus will no-op
  }
}

/**
 * Restores tvOS vertical focus traversal after fullScreenModal dismiss.
 *
 * After a react-native-screens fullScreenModal is dismissed, UIKit's focus
 * engine loses track of SwiftUI focus items (UIKitFocusableViewResponderItem)
 * inside UISearchContainerViewController. This causes UP/DOWN navigation to
 * fail with `nextFocusedItem: NIL` while LEFT/RIGHT between tab buttons
 * still works.
 *
 * Fix: Increments a SwiftUI `.id()` token on the NavigationView, forcing
 * SwiftUI to destroy the entire subtree (including the stale
 * UISearchContainerViewController and its focus proxy items) and recreate
 * it with fresh focus registrations. The UIHostingController stays in the
 * VC hierarchy — only SwiftUI's internal tree is rebuilt. State is preserved
 * via the shared SearchViewModel ObservableObject. After a 300ms delay
 * (for SwiftUI to process the identity change), UIKit focus update is
 * requested. Diagnostic NSLog with `[FocusRestore]` prefix — check Xcode
 * console.
 *
 * Call this ~200ms after returning to the tab layout (e.g., in a
 * useFocusEffect callback) to allow UIKit's transition to settle.
 *
 * No-op on non-tvOS platforms or when the native module is unavailable.
 */
export function restoreTVFocus(): void {
  NativeModule?.restoreTVFocus();
}

/**
 * Starts logging all tvOS focus updates and failed focus movements
 * to the Xcode console via NSLog with [FocusDebug] prefix.
 *
 * Registers observers for UIFocusSystem.didUpdateNotification and
 * UIFocusSystem.movementDidFailNotification (tvOS 12+). Each log
 * entry includes the source/target view class, tag, frame, and
 * movement direction (UP/DOWN/LEFT/RIGHT).
 *
 * For failed movements, also logs whether nextFocusedItem was nil
 * (focus engine found no target) or non-nil (blocked by
 * shouldUpdateFocusInContext returning NO), plus scroll view
 * ancestor state (contentOffset, contentSize, frame).
 *
 * Call disableFocusDebugging() to stop logging.
 *
 * No-op on non-tvOS platforms or when the native module is unavailable.
 */
export function enableFocusDebugging(): void {
  NativeModule?.enableFocusDebugging();
}

/**
 * Stops focus debug logging started by enableFocusDebugging().
 *
 * No-op on non-tvOS platforms or when the native module is unavailable.
 */
export function disableFocusDebugging(): void {
  NativeModule?.disableFocusDebugging();
}

/**
 * Dumps current focus state to the Xcode console via NSLog.
 *
 * Logs: currently focused item (class, tag, frame), its full
 * superview chain, scroll view ancestors with their contentOffset
 * and contentSize, and the root view controller hierarchy.
 *
 * Call this after modal dismiss to inspect the focus state.
 *
 * No-op on non-tvOS platforms or when the native module is unavailable.
 */
export function logFocusState(): void {
  NativeModule?.logFocusState();
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
